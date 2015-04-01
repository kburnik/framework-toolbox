#!/usr/bin/env php
<?php

$filename = $argv[1];

if (count($argv) < 2) {
  file_put_contents("php://stderr", "Usage: {$argv[0]} file.json\n");
  exit(1);
}

if (!file_exists($filename) || !is_file($filename)) {
  file_put_contents("php://stderr", "File does not exist: $filename\n");
  exit(2);
}

$data = file_get_contents($filename);
$json = json_decode($data, true);

if (!is_array($json)) {
  file_put_contents("php://stderr", "Malformed json: $filename\n");
  exit(3);
}

array_shift($argv);
array_shift($argv);
foreach ($json as $entry) {
  echo implode(" ", $entry) . "\n";
}
