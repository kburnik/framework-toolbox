#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/tools-common

php="/usr/bin/env php"

function get_setting {
  $php -r "include_once('$SRC/project-settings.php'); echo constant('$1');"
}

server_name=$(hostname)
[ "$1" != "" ] && server_name=$1

document_root=$(cd $SRC && pwd)/public_html
server_admin=$(get_setting PROJECT_AUTHOR_MAIL)
project_name=$(get_setting PROJECT_NAME)
user=$(whoami)


apache_includes_dir="/usr/local/apache/conf/includes/"
conf_dest="$apache_includes_dir/$project_name.conf"

echo "# $conf_dest"

cat $CFG/virtualhost.conf.template | \
    sed "s/%server_name%/$server_name/" | \
    sed "s!%document_root%!$document_root!" | \
    sed "s/%server_admin%/$server_admin/" | \
    sed "s/%user%/$user/"




echo "# /etc/hosts/"
echo 127.0.0.1 $server_name
