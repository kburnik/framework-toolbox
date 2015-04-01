#!/usr/bin/env php
<?php

include_once(dirname(__FILE__) . "/tools-common.php");
include_once(TOOLS_SRC_DIR . "/project.php");

if ($index = array_search("--query-perf", $argv)) {
  unset($argv[$index]);
  $argv = array_values($argv);

  $reporter = null;
  if ($index = array_search("--teamcity", $argv)) {
    unset($argv[$index]);
    $argv = array_values($argv);
    $reporter = new TeamCityTestReporter();
  }

  $queryPerformanceTracker = new QueryPerformanceReporter(
      "QueryPerformace." . end($argv), $reporter);
  $mysql = Project::GetQDP();
  $mysql->addPartialEventHandler($queryPerformanceTracker);
}

// Execute the page.
$_SERVER['REQUEST_URI'] = end($argv);
$url = $_SERVER['REQUEST_URI'];
$query = parse_url($url, PHP_URL_QUERY);
parse_str($query, $get);
$_GET = array_merge($_GET, $get);
$_REQUEST = array_merge($_REQUEST, $get);
include_once(TOOLS_SRC_DIR . '/public_html/index.php');
