# @summary
#   This plan is inspired by and a loose re-implementation of the NAS creation wizard that one would interact with using the Unisphere web interface for the Unity Virtual Storage Appliance, or similar storage system from Dell as a demonstration of how one can automate and provide interfaces to repeatable tasks to address organizational needs with Puppet Bolt.
#
# @see https://github.com/timidri/puppet-dellemc-unity
#
# @example Create new NAS server with attached 100GB NFS export on newly provisioned Unity storage appliance
#   bolt plan run dellemc_unity::wizard -t my_vsa name=vmware ipaddress=192.168.19.219 interface=eth0 size=100GB
#
# @param targets
#   The target storage device(s) to execute this plan against, parameter seldom set on the CLI but implicitly sourced through Bolt's --targets or -t option
#
# @param name
#   This is the friendly name attached to all the resources created by this plan which support them, NAS, file system, and NFS export
#
# @param interface
#   Ethernet port that the filer's IP address will by attached to
#
# @param service_processor
#   Which of SP A or B that the NAS resource and IP interfaces will be initially assigned to
#
# @param ipaddress
#   IP address that the NFS server will be accessible over
#
# @param netmask
#   Netmask of the NFS server IP address if you intend on using something from a net block other than a /24
#
# @param size
#   The size of the file system that will be exported over NFS, if none is provided then the plan defaults to the size of the storage pool  
#
# @param pool
#   If the storage system has more than a single storage pool then pass in the name of the pool you wish to leverage when creates these NAS and NFS resources
#
plan dellemc_unity::wizard(
  TargetSpec                                          $targets,
  String[1]                                           $name,
  String[1]                                           $interface,
  Stdlib::Host                                        $ipaddress,
  Stdlib::Host                                        $netmask           = '255.255.255.0',
  Optional[Pattern[/[0-9]+[MGT]i?[Bb]?$/, /[0-9]+$/]] $size              = undef,
  Optional[String[1]]                                 $pool              = undef,
  Enum['spa', 'spb']                                  $service_processor = 'spa',
) {

  # This is not fully optimized, it makes more calls to API then absolutely
  # required. Purposefully mixes the use of raw calls directly to the API using
  # the command task and purpose built tasks to illustrate the various ways one
  # could accomplish automation of a storage device. The primary difference
  # between making raw API calls vs. purpose built tasks is in how clean the
  # interface is to the task and the data it returns after doing work.

  # Plan wil introspect the current device's state to determine if this is a
  # fresh VSA with no NAS resources defined, if none are found then it continues
  # doing the full provisioning of a new NAS through to an exported NFSv3 file
  # system but if one is found it will print out a nicely formatted table of the
  # currently defined NAS resources then walk through a couple interview questions
  # to determine what to do next.
  $nasi = run_task('dellemc_unity::command', $targets, {
    command    => 'get',
    endpoint   => 'types/nasServer/instances',
    parameters => { 'fields' => 'name,nfsServer' }
  }).first.value['response']

  if $nasi.empty {
    out::message('No existing NAS resources found...')
    $use_existing = 'N'
  } else {
    # Constructing the data structure needed for table construction
    $rows = $nasi.map |$r| {
      [
        $r['content']['id'],
        $r['content']['name'],
        $r['content']['nfsServer'].empty ? {
          true    => 'disabled',
          default => 'enabled'
        }
      ]
    }

    # Printing the NAS resource table
    $nas_table = format::table({
      title => 'Existing NAS resources',
      head => ['id', 'name', 'nfsServer'].map |$field| { format::colorize($field, yellow) },
      rows => $rows
    })
    out::message($nas_table)

    # First interactive user prompt that determines if the existing NAS will be
    # ignored or leveraged
    $use_existing = Enum['Y', 'N', 'YES', 'NO'](prompt('Found a pre-defined NAS resource(s), use existing? [(Y)es\(N)o]').upcase)
  }

  case $use_existing {
    'Y', 'YES': {
      # If user chose to use an existing NAS but there is only a single existing
      # NAS then we fetch it and check if it has NFS already enabled, if yes
      # then we interactively ask the user one more time if they want to create
      # a new one, if they still persist on re-use then plan aborts
      if $nasi.count == 1 {
        if $nasi[0]['content']['nfsServer'].empty {
          $nas_id     = $nasi[0]['content']['id']
          $nas_name   = $nasi[0]['content']['name']
          $create_nas = false
          out::message("Using existing NAS resource: ${nas_name}")
        } else {
          # Setting the acceptable return values of the prompt() function this
          # is interesting because it removes the need to do manual checking but
          # it doesn't produce the best error message
          $has_nfs = Enum['Y', 'N', 'YES', 'NO'](prompt('NFS protocol is already enabled on the existing NAS server, create new? [(Y)es\(N)o]').upcase)
          case $has_nfs {
            'Y', 'YES': { $create_nas = true }
            'N', 'NO':  { fail_plan('Plan aborted, you must either use a NAS resource that has not yet had NFS enabled or create a new one') }
          }
        }
      } else {
        # When there is more than one existing NAS resource then we prompt the
        # user to select one by name from a list that has had those with NFS
        # already configured filtered out
        $valid_nas  = $nasi.filter |$r| { $r['content']['nfsServer'].empty }

        # You could easily chain this map onto the end of the previous
        # expression...
        $valid_list = $valid_nas.map |$v| { $v['content']['name'] }

        # The array produced after filter out NAS resources with configured NFS
        # servers is handed to our Enum[] type definition to set the valid
        # responses to our prompt() function dynamically
        $chosen_nas = Enum[$valid_list](prompt("Select existing NAS resource to use from the list (${valid_list.join(',')})"))

        # Filtering valid down one more time to just that one chosen by the user
        # as a way to convert name to id for use by the plan if subsequent tasks
        $nas_id = $valid_nas.filter |$v| { $v['content']['name'] == $chosen_nas }[0]['content']['id']
        $create_nas = false
      }
    }
    'N', 'NO': {
      out::message('Will create new NAS resource...')
      $create_nas = true
    }
  }

  # First part will translates pool name to pool_id if it was given on the CLI
  # but if none was given we use the list_pools task to obtain all pools and if
  # only one is returned then we assume this one for further operations. Making
  # this section more intelligent would look similar to what we've done in the
  # NAS introspection and interview section above.
  if $pool {
    $_pool_id = run_task('dellemc_unity::command', $targets, {
      command  => 'get',
      endpoint => "instances/pool/name:${pool}",
    }).first.value['response']['content']['id']
  } else {
      $pools = run_task('dellemc_unity::list_pools', $targets).first.value['pools']

      if $pools.size == 1 {
        $_pool_id = $pools[0]['id']
        out::message("Found a single pool: ${pools[0]['name']}; using pool for subsequent operations...")
    }
  }

  # If an explicit size was provided on the CLI then covert it to bytes,
  # required by the Unity API. When no size if given then we query it from the
  # previously discovered pool, matching the new file system to the pool size
  if $size {
    $_size = $size.to_bytes
  } else {
    $_size = run_task('dellemc_unity::command', $targets, {
      command  => 'get',
      endpoint => "instances/pool/${_pool_id}",
      parameters => { 'fields' => 'sizeTotal' }
    }).first.value['response']['content']['sizeTotal']
  }

  # The result of the initial decision making block at the top of plan
  if $create_nas {
    $_nas_id = run_task('dellemc_unity::command', $targets, {
      command    => 'post',
      endpoint   => 'types/nasServer/instances',
      body       => {
        'name'                        => $name,
        'homeSP'                      => { 'id' => $service_processor },
        'pool'                        => { 'id' => $_pool_id },
        'currentUnixDirectoryService' => 0,
      }
    }).first.value['response']['content']['id']
  } else {
    $_nas_id = $nas_id
  }

  # Straight forward definition of an IP interface to be used by out eventually
  # newly created NFS server. Throughout the plan we've ran our task and stored
  # the returned id of the newly created resource into a variable, no exception
  # here
  $interface_id = run_task('dellemc_unity::command', $targets, {
    command    => 'post',
    endpoint   => 'types/fileInterface/instances',
    body       => {
      'nasServer' => { 'id' => $_nas_id },
      'ipPort'    => { 'id' => "${service_processor}_${interface}" },
      'ipAddress' => $ipaddress,
      'netmask'   => $netmask,
      'role'      => 0
    }
  }).first.value['response']['id']

  # From a web ui point of view this is equivalent to checking the box that'll
  # enable NFSv3 when going through the NAS creation wizard
  $nfs_id = run_task('dellemc_unity::command', $targets, {
    command    => 'post',
    endpoint   => 'types/nfsServer/instances',
    body       => {
      'nasServer'       => { 'id' => $_nas_id },
      'nfsv3Enabled'    => true,
      'isSecureEnabled' => false
    }
  }).first.value['response']['id']

  # Our last action is to bind a new file system and NFS export of that file
  # system to the NAS server we either created for selected from the list of
  # those previously created using another purpose built task
  run_task('dellemc_unity::create_nfs', $targets, {
    name     => $name,
    pool_id  => $_pool_id,
    nas_id   => $_nas_id,
    size     => $_size,
  })

  # Simple log message that summarizes the end result of actions taken
  out::message("Created NFSv3 enabled NAS of size ${format_bytes($_size)} mountable at ${ipaddress}:/${name}")
}
