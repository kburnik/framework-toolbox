#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/tools-common

source $DIR/env.sh

function fail {
  echo "Step failed: $1" 1>&2
  shift
  echo $@ 1>&2
  exit 1
}

function get_connection_string {
  php -r "include(realpath('$SRC/project-settings.php')); echo '-u' . PROJECT_MYSQL_USERNAME . ' -p' . PROJECT_MYSQL_PASSWORD . ' ' . PROJECT_MYSQL_DATABASE;"
}

cd $SRC/migration
for step in $(ls | sort); do
  cd $SRC/migration/$step

  if [ -f ".migrated" ]; then
    echo "Skipping migrated step: $step" 1>&2
    continue
  fi

  echo "Performing step: $step"

  if [ -f "shell" ]; then
    cd $SRC
    bash $SRC/migration/$step/shell || fail $step "Failed executing shell script"
  else
    echo "No shell scripts to execute in $step" 1>&2
  fi

  cd $SRC/migration/$step
  if [ -f "rebuild" ]; then
    cd $SRC/model
    while read model; do
      [ "$model" == "" ] && continue;
      echo "Rebuilding: $model"
      buildentity.php $model || fail $step "Cannot rebuild model $model."
    done < rebuild
  else
    echo "No models to rebuild in $step" 1>&2
  fi


  cd $SRC/migration/$step
  if [ -f "sql" ]; then
    conn_string=$(get_connection_string)
    [ "$conn_string" == "" ] && fail $step "Cannot obtain connection string"
    echo "Executing SQL"
    cat sql
    mysql $conn_string < sql || fail $step "Error executing SQL"
  else
    echo "No SQL to execute in $step" 1>&2
  fi

  touch $SRC/migration/$step/.migrated
  echo "Step complete: $step"
  echo

done

exit 0
