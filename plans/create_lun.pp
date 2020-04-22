plan dellemc_unity::create_lun(
  TargetSpec $targets,
  String[1] $name,
  Optional[String] $pool_id = undef,
  Integer $size,
  Optional[Boolean] $is_thin_enabled = true,
  ) {
    if $pool_id {
      $_pool_id = $_pool_id
    } else {
      $pools = run_task('dellemc_unity::list_pools', $targets).first.value['pools']
      # notice($pools)
      notice("pools size: ${pools.size}")
      if $pools.size == 1 {
        $_pool_id = $pools[0]['content']['id']
        out::message("Found one pool ${_pool_id}; creating LUN on this pool...")
      }
    }

  $result = run_task('dellemc_unity::create_lun', $targets, {
    name            => $name,
    pool_id         => $_pool_id,
    size            => $size,
    is_thin_enabled => $is_thin_enabled,
  })

  notice($result)
}
