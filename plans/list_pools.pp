plan dellemc_unity::list_pools(
  TargetSpec $targets
  ) {
  $pools = run_task('dellemc_unity::list_pools', $targets).first.value['pools']
  $rows = $pools.map | $r | {
    [
      $r['id'],
      $r['name'],
      $r['description'],
      format_bytes($r['sizeTotal']),
      format_bytes($r['sizeFree'])
      ]
    }
  $pools_table = format::table({
    title => 'Pool list',
    head => ['id', 'name', 'description', 'size', 'free'].map |$field| { format::colorize($field, yellow) },
    rows => $rows
    })
  out::message($pools_table)
}
