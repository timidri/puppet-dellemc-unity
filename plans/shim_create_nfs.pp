plan dellemc_unity::shim_create_nfs(
  TargetSpec                                $targets,
  String[1]                                 $name,
  Pattern[/[0-9]+[MGT]i?[Bb]?$/, /[0-9]+$/] $size,
  Optional[String]                          $pool_id = undef,
  Optional[String]                          $nas_id  = undef,
) {

  if $pool_id {
    $_pool_id = $_pool_id
  } else {
    $pools = run_task('dellemc_unity::command', $targets, {
      command    => 'get',
      endpoint   => 'types/pool/instances',
    }).first.value['response']

    if $pools.size == 1 {
      $_pool_id = $pools[0]['content']['id']
        out::message("Found one pool ${_pool_id}; creating NFS filesystem on this pool...")
    }
  }

  if $nas_id {
    $_nas_id = $nas_id
  } else {
    $nass = run_task('dellemc_unity::command', $targets, {
      command    => 'get',
      endpoint   => 'types/nasServer/instances',
    }).first.value['response']

    if $nass.size == 1 {
      $_nas_id = $nass[0]['content']['id']
        out::message("Found one NAS ${_nas_id}; creating NFS filesystem on this NAS...")
    }
  }

  $result = run_task('dellemc_unity::command', $targets, {
    command    => 'post',
    endpoint   => 'types/storageResource/action/createFilesystem',
    body       => {
        "name" => $name,
        "fsParameters" => {
          "supportedProtocols" => 0,
          "pool" => {
            "id" => $_pool_id
          },
          "nasServer" => {
            "id" => $_nas_id
          },
          "isThinEnabled" => true,
          "size" => $size
        },
        "nfsShareCreate" => [
          {
            "name" => $name,
            "path" => "/"
          }
        ]
      }
  }).first.value['response']['storageResource']['id']

  out::message("Created one NFS filesystem: ${$result} on nas: ${_nas_id} and pool: ${_pool_id}")
}
