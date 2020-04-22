plan dellemc_unity::list_pools(
  TargetSpec $targets
  ) {
  $pools = run_task('dellemc_unity::list_pools', $targets).first.value['pools']
  $rows = $pools.map | $r | {
    [
      $r['content']['id'],
      $r['content']['name'],
      $r['content']['description'],
      $r['content']['sizeTotal'],
      $r['content']['sizeFree']
      ]
    }
  $pt = format::table({title => 'Pool list', head => ['id', 'name', 'description', 'size', 'free'], rows => $rows})
  out::message($pt)
}
