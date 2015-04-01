#!/usr/bin/env php
<?php

include_once(dirname(__FILE__) . "/tools-common.php");
include_once(TOOLS_SRC_DIR . "/project.php");

if ($argv[1]) {
  $const = $argv[1];
  if (!defined($const)) {
    file_put_contents("php://stderr", "Constant '$const' is not defined\n");
    exit(1);
  }
  echo constant($const) . "\n";
  exit(0);
} else {
  file_put_contents("php://stderr", "Usage: {$argv[0]} constant\n");
  exit(1);
}
