#!/bin/bash
[[ $_ == $0 ]] && echo "Usage: source $0" 1>&2 && exit 127;
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

curr=$(pwd)
cd $DIR/../..
ROOT_DIR=$(pwd)
cd $curr
unset curr

function env_save {
  export OLD_PATH="$PATH"
  export OLD_PS1="$PS1"
}

function env_restore {
  export PATH="$OLD_PATH"
  export PS1="$OLD_PS1"
  unset SRC
  unset ROOT_DIR
  unset DIR
  unset -f env_save
  unset -f env_restore
  unset -f activate
  unset -f deactivate
}

function activate {
  env_save
  testrun_location=$(which testrun.php 2>/dev/null)
  if [ "$testrun_location" != "" ]; then
    old=$(dirname $testrun_location)
    PATH=$(echo $PATH | sed -e "s#$old:##g")
  fi;

  export SRC="$ROOT_DIR"
  export PATH="$PATH:$DIR:$ROOT_DIR/third_party/framework/tools"
  export PS1="(env) $PS1"

  unset old
  echo "Started environment"
}

function deactivate {
  env_restore
}

activate
