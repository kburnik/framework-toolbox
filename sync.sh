#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/tools-common

function sync_fail {
  echo "Sync failed."
}

function sync_pass {
  echo "Sync success."
}

function git_sync {
  dir=$1
  repo=$2
  remote=$3
  branch="master"
  [ "$4" != "" ] && branch="$4"

  success=0
  [ ! -d "$dir" ] && mkdir $dir
  cd $dir
  if [ -d "$repo" ]; then
    cd $repo
    git pull origin $branch && success=1
  else
    git clone -b $branch $remote $repo && success=1
  fi

  [ "$success" != "1" ] && sync_fail && return 1

  return 0
}

config_file="$PROJECT_CFG/sync-deps.json"

$DIR/parse-json.php $config_file | \
while read name url branch root_dir; do
  git_sync $SRC/$root_dir $name $url $branch || exit 1
done;

# Sync complete.
sync_pass && exit 0
