#!/usr/bin/env php
<?php
include_once(dirname(__FILE__) . "/tools-common.php");

$pages = include_once(TOOLS_CFG_DIR . "/perftest.urls.php");

$dir = dirname(__FILE__);
$args = implode(" ", $argv);
foreach ($pages as $page) {
  echo "GET HTTP/1.1 $page\n";
  echo `php $dir/runpage.php --query-perf $args $page`;
  echo "\n";
}
