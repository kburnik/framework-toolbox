#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/tools-common

CONF=$SRC/config

# CONFIG

conf_file="/C/xampp/apache/conf/extra/httpd-vhosts.conf"
hosts_file="c:/Windows/System32/drivers/etc/hosts"

project_root=$(cd $SRC && pwd)

project_name=$(get_project_setting PROJECT_NAME)
server_admin=$(get_project_setting PROJECT_AUTHOR_MAIL)
public_html_dir=$(get_project_setting PROJECT_PUBLIC_HTML_DIR public_html)
document_root=$(echo "${project_root}/${public_html_dir}" | to_xampp_path)

user=$(whoami)

project_development_domain=$(get_project_setting PROJECT_DEVELOPMENT_DOMAIN)
project_conf_file="$CONF/${project_development_domain}.conf"
hosts_line="127.0.0.1 ${project_development_domain}"

cat $CFG/virtualhost.conf.template | \
    sed "s!%project_name%!$project_name!g" | \
    sed "s!%server_name%!$project_development_domain!g" | \
    sed "s!%document_root%!$document_root!g" | \
    sed "s!%server_admin%!$server_admin!g" | \
    sed "s!%user%!$user!g" > $project_conf_file

vhost_line=$(echo "$project_conf_file" | to_xampp_path)

function install_virtual_host {
  [ ! -f "$conf_file" ] && \
      echo "Missing vhosts config file: $conf_file." 1>&2 && \
      return 1

  [ ! -f "$project_conf_file" ] && \
      echo "Missing project config file: $project_conf_file." 1>&2 && \
      return 1

  cat $conf_file | grep "$vhost_line" && echo "Already installed." && \
  return 0

  echo "Include $vhost_line" >> $conf_file

  cat $conf_file | grep "$vhost_line" > /dev/null && \
      echo "Installed to vhosts. Restart apache server to take affect." && \
      return 0

  return 1
}

function install_to_hosts {
  [ ! -f "$hosts_file" ] && \
      echo "Missing hosts file: $hosts_file" 1>&2 && \
      return 1

  cat $hosts_file | grep "$hosts_line" && echo "Already in hosts." && return 0

  echo $hosts_line >> $hosts_file

  (cat $hosts_file | grep "$hosts_line" > /dev/null) || \
      echo "Unable to write to hosts file: $hosts_file." 1>&2 &&
      echo "Check if running as administrator." 1>&2 && return 1

  echo "Installed to hosts."
}

install_virtual_host && install_to_hosts && exit 0
exit 1
