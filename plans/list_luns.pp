plan dellemc_unity::list_luns(
  TargetSpec $targets
  ) {
  $luns = run_task('dellemc_unity::list_luns', $targets).first.value['luns']
  $rows = $luns.map | $r | {
    [
      $r['id'],
      $r['name'],
      $r['description'],
      format_bytes($r['sizeTotal']),
      $r['isThinEnabled']
      ]
    }
  $luns_table = format::table({
    title => 'Lun list',
    head => ['id', 'name', 'description', 'size', 'thin'].map |$field| { format::colorize($field, yellow) },
    rows => $rows
    })
  out::message($luns_table)
}
