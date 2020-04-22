plan dellemc_unity::list_pools(
  TargetSpec $target = 'unity'
  ) {
  $result = run_task('dellemc_unity::list_pools', $target).first
  $rows = $result.value['pools'].map | $r | {
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
