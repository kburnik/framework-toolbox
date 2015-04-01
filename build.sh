#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/tools-common

exit_code=0
# Compile all CSS
for src in $SRC/public_html/css/*.less; do
  dest=$(echo $src | sed s'/.less/.min.css/');
  echo "Building $dest"
  lessc --compress $src > $dest
  [ $? != 0  ] && exit_code=1
done;

exit $exit_code
