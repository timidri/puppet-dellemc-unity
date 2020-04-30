plan dellemc_unity::wizard(
  TargetSpec                                          $targets,
  String[1]                                           $name,
  String[1]                                           $interface,
  Stdlib::Host                                        $ipaddress,
  Stdlib::Host                                        $netmask           = '255.255.255.0',
  Optional[Pattern[/[0-9]+[MGT]i?[Bb]?$/, /[0-9]+$/]] $size              = undef,
  Optional[String]                                    $pool              = undef,
  Enum['spa', 'spb']                                  $service_processor = 'spa',
) {

  # Not fully optimized, making more calls to API then absolutely required.
  # Purposefully mixes the use of raw calls directly to the API using the
  # command task and purpose built tasks to illustrate the various ways one
  # could accomplish automation

  $nasi = run_task('dellemc_unity::command', $targets, {
    command    => 'get',
    endpoint   => 'types/nasServer/instances',
    parameters => { 'fields' => 'name,nfsServer' }
  }).first.value['response']

  if $nasi.empty {
    out::message('No existing NAS resources found...')
    $use_existing = 'N'
  } else {
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

    $nas_table = format::table({
      title => 'Existing NAS resources',
      head => ['id', 'name', 'nfsServer'].map |$field| { format::colorize($field, yellow) },
      rows => $rows
    })
    out::message($nas_table)

    $use_existing = Enum['Y', 'N', 'YES', 'NO'](prompt('Found a pre-defined NAS resource(s), use existing? [(Y)es\(N)o]').upcase)
  }

  case $use_existing {
    'Y', 'YES': {
      if $nasi.count == 1 {
        if $nasi[0]['content']['nfsServer'].empty {
          $nas_id     = $nasi[0]['content']['id']
          $nas_name   = $nasi[0]['content']['name']
          $create_nas = false
          out::message("Using existing NAS resource: ${nas_name}")
        } else {
          $has_nfs = Enum['Y', 'N', 'YES', 'NO'](prompt('NFS protocol is already enabled on the existing NAS server, create new? [(Y)es\(N)o]').upcase)
          case $has_nfs {
            'Y', 'YES': { $create_nas = true }
            default:    { fail_plan('Plan aborted, you must either use a NAS resource that has not yet had NFS enabled or create a new one') }
          }
        }
      } else {
        $valid_nas  = $nasi.filter |$r| { $r['content']['nfsServer'].empty }
        $valid_list = $valid_nas.map |$v| { $v['content']['name'] }
        $chosen_nas = Enum[$valid_list](prompt("Select existing NAS resource to use from the list (${valid_list.join(',')})"))
        $nas_id = $valid_nas.filter |$v| { $v['content']['name'] == $chosen_nas }[0]['content']['id']
        $create_nas = false
      }
    }
    default: {
      out::message('Will create new NAS resource...')
      $create_nas = true
    }
  }

  # Translate pool name to pool_id if name given, infer pool if none
  # is provided and number of pools is equal to 1
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

  if $size {
    $_size = $size.to_bytes
  } else {
    $_size = run_task('dellemc_unity::command', $targets, {
      command  => 'get',
      endpoint => "instances/pool/${_pool_id}",
      parameters => { 'fields' => 'sizeTotal' }
    }).first.value['response']['content']['sizeTotal']
  }

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

  $nfs_id = run_task('dellemc_unity::command', $targets, {
    command    => 'post',
    endpoint   => 'types/nfsServer/instances',
    body       => {
      'nasServer'       => { 'id' => $_nas_id },
      'nfsv3Enabled'    => true,
      'isSecureEnabled' => false
    }
  }).first.value['response']['id']

  run_task('dellemc_unity::create_nfs', $targets, {
    name     => $name,
    pool_id  => $_pool_id,
    nas_id   => $_nas_id,
    size     => $_size,
  })

  out::message("Created NFSv3 enabled NAS of size ${format_bytes($_size)} mountable at ${ipaddress}:/${name}")
}
