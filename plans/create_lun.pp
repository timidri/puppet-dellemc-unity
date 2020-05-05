plan dellemc_unity::create_lun(
  TargetSpec        $targets,
  String[1]         $name,
  Optional[String]  $pool_id = undef,
  Optional[String]  $description = undef,
  Pattern[/[0-9]+[MGT]i?[Bb]?$/, /[0-9]+$/] $size,
  Optional[Boolean] $is_thin_enabled = true,
  ) {
    if $pool_id {
      $_pool_id = $_pool_id
    } else {
      $pools = run_task('dellemc_unity::list_pools', $targets).first.value['pools']
      # out::message("pools size: ${pools.size}")
      if $pools.size == 1 {
        $_pool_id = $pools[0]['id']
        out::message("Found one pool ${_pool_id}; creating LUN on this pool...")
      }
    }

  $result = run_task('dellemc_unity::create_lun', $targets, {
    name            => $name,
    description     => $description,
    pool_id         => $_pool_id,
    size            => $size.to_bytes,
    is_thin_enabled => $is_thin_enabled,
  })

  if ! $result.ok {
    Error(
      message    => 'Sorry, this plan does not work yet.',
      kind       => 'mymodule/error',
      issue_code => 'NOT_IMPLEMENTED'
    )
    fail_plan('Sorry, this plan does not work yet.', 'mymodule/error')
  }

  out::message(String($result.first.value, '%h'))
  run_plan('dellemc_unity::list_luns', $targets)
}
