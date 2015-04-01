#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/tools-common

function find_sources {
  find . -name "*.php" | grep \
      -ve "gen/template" \
      -ve ".storage.php" \
      -ve "third_party/framework"
}

cd $SRC;
for x in $(find_sources); do
  echo $x;

  # remove closing php tag ?>
  sed -i 's/?>//' $x

  temp=$(mktemp)
  cp $x $temp

  # Remove extra new lines
  sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' -i $temp

  # replace macos line endings
  cat $temp | tr '\r' '\n' > $x
done
