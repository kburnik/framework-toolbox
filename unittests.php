#!/usr/bin/env php
<?php
session_start();
@ob_flush();
@ob_end_flush();
@flush();

include_once(dirname(__FILE__) . "/tools-common.php");
include_once(TOOLS_SRC_DIR . '/project.php');
chdir(TOOLS_SRC_DIR);

$test_groups = include_once(TOOLS_CFG_DIR . '/test.groups.php');

// Command line options:
// -s for summary
// --no-color to inhibit colors
// --teamcity for teamcity output

$filter = "";
$summary = false;
if (in_array("-s", $argv)) {
  $summary = true;
}

$coloredOutput = true;
if (in_array("--no-color", $argv)) {
  $coloredOutput = false;
}

$reporter = null;
if (in_array("--teamcity", $argv)) {
  $reporter = new TeamCityTestReporter();
}

if (in_array("--mysql", $argv)) {
  Project::GetQDP()->useDatabase(constant('PROJECT_MYSQL_TEST_DATABASE'));
  SurogateDataDriver::SetRealDataDriver(new MySQLDataDriver());
  ModelMocker::SetDataDriverClass('MySQLDataDriver');
}

$fails = 0;
$testStartTime = microtime(true);
foreach ($test_groups as $group_name => $tests) {
  file_put_contents("php://stdout", "$group_name:\n");
  foreach ($tests as $test) {
    chdir(TOOLS_SRC_DIR . "/" . dirname($test));
    $testname = str_replace('.php', '', basename($test));
    $testcase = new $testname();
    $testcase->setReporter($reporter);
    $testcase->setSummary($summary);
    $testcase->setFilter($filter);
    $testcase->setColoredOutput($coloredOutput);
    $fails += $testcase->start();
  }
}

$testRunTime = round((microtime(true) - $testStartTime) * 1000, 2);
file_put_contents("php://stdout", "Total runtime: $testRunTime ms\n");

if ($fails > 0)
  exit(1);

exit(0);
