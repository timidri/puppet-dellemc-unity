plan dellemc_unity::nas_wizard(
  TargetSpec                                          $targets,
  String[1]                                           $name,
  String[1]                                           $port,
  String[1]                                           $ipaddress,
  String[1]                                           $netmask           = '255.255.255.0',
  Optional[Pattern[/[0-9]+[MGT]i?[Bb]?$/, /[0-9]+$/]] $size              = undef,
  Optional[String]                                    $pool_id           = undef,
  Enum['spa', 'spb']                                  $service_processor = 'spa',
) {

  if $pool_id {
    $_pool_id = $pool_id
  } else {
    $pools = run_task('dellemc_unity::command', $targets, {
      command    => 'get',
      endpoint   => 'types/pool/instances',
    }).first.value['response']

    if $pools.size == 1 {
      $_pool_id = $pools[0]['content']['id']
        out::message("Found one pool ${_pool_id}; creating NAS on this pool...")
    }
  }

  if $size {
    $_size = $size
  } else {
    $_size = run_task('dellemc_unity::command', $targets, {
      command  => 'get',
      endpoint => "instances/pool/${_pool_id}",
      parameters => { 'fields' => 'sizeTotal' }
    }).first.value['response']['content']['sizeTotal']
  }

  $nas_id = run_task('dellemc_unity::command', $targets, {
    command    => 'post',
    endpoint   => 'types/nasServer/instances',
    body       => {
      'name'                        => $name,
      'homeSP'                      => { 'id' => $service_processor },
      'pool'                        => { 'id' => $_pool_id },
      'currentUnixDirectoryService' => 0,
    }
  }).first.value['response']['id']

  $interface_id = run_task('dellemc_unity::command', $targets, {
    command    => 'post',
    endpoint   => 'types/fileInterface/instances',
    body       => {
      'nasServer' => { 'id' => $nas_id },
      'ipPort'    => { 'id' => "${service_processor}_${port}" },
      'ipAddress' => $ipaddress,
      'netmask'   => $netmask,
      'role'      => 0
    }
  }).first.value['response']['id']

  $nfs_id = run_task('dellemc_unity::command', $targets, {
    command    => 'post',
    endpoint   => 'types/nfsServer/instances',
    body       => {
      'nasServer'       => { 'id' => $nas_id },
      'nfsv3Enabled'    => true,
      'isSecureEnabled' => false
    }
  }).first.value['response']['id']

  run_task('dellemc_unity::create_nfs', $targets, {
    name     => $name,
    pool_id => $_pool_id,
    nas_id   => $nas_id,
    size     => $_size,
  })

  out::message("Created NFSv3 enabled NAS of size ${format_bytes($_size)} mountable at ${ipaddress}:/${name}")
}
