#!/bin/bash
#exit on error
set -e
#exit on unset variable
set -u
#extend globbing
shopt -s extglob

my_name=${0##*/}
my_path=$(readlink -f "$0")
top_dir=${my_path%/*}
my_real_name=${my_path##*/}

script_name="Systemd Service Watcher"
script_version="1.0.0"
installed_path="/opt/systemd-service-watcher"
installed_script_path="${installed_path}/systemd-service-watcher.sh"
installed_conf_path="${installed_path}/systemd-service-watcher.conf"
installed_cron_path="/etc/cron.d/systemd-service-watcher"
default_config="
mail=root
gotify=
"
default_cron="
DATEVAR=date -u +%Y-%m-%dT%H:%M
#m h dom m dow user script
*/10 * * * *  root \"$installed_script_path\"
"

hostname=$(hostname -f)

is_installed() {
  if ! [ -f "$installed_script_path" ] || ! [ -f "$installed_conf_path" ] || ! [ -f "$installed_cron_path" ]; then
    return 1
  fi
}

print_help() {
  echo "Use with the following arguments

  install   
    install the script on the system

  remove    
    remove the script from the system

  check-services  
    check that there is no systemd serice failure,
    and send notification if it's the case.
    See $installed_conf_path for notifications config 

  test-notifications  
    send test notifications
    See $installed_conf_path for notifications config 
  "
}

echo "---  $script_name $script_version ---"

if [ $# -eq 0 ]; then
  print_help;
fi

if [ "$1" = "install" ]; then
  echo "install $script_name $script_version"
  echo "create folder : $installed_path"
  mkdir -p "$installed_path"
  echo "copy script : $installed_script_path"
  cp "$my_path" "$installed_script_path"
  echo "copy conf : $installed_conf_path"
  printf "%s" "$default_config" > "$installed_conf_path"
  echo "copy cron : $installed_cron_path"
  printf "%s" "$default_cron" > "$installed_cron_path"
  echo "set permissions"
  chmod -R u=rwx,go=rx "$installed_path"
  echo "$script_name $script_version installed !"
  echo "Don't forget to edit $installed_conf_path for notifications config !"
	exit 0
fi 

if [ "$1" = "remove" ]; then
  echo "remove $script_name"
  if [ -f "$installed_cron_path" ]; then
    echo "remove cron : $installed_cron_path"
    rm  "$installed_cron_path" || { echo "Error deleting $installed_cron_path"; exit 1; }
  fi
  
  if [ -f "$installed_path" ]; then
    echo "delete folder : $installed_path"
    rm -r "$installed_path" || { echo "Error deleting $installed_path"; exit 1; }
  fi 
  echo "$script_name removed !"
	exit 0
fi

if [ "$1" = "help" ]; then
  print_help
  exit 0
fi

if [ "$1" != "check-services" ] && [ "$1" != "test-notifications" ]; then
  print_help
  exit 1
fi

if ! is_installed; then
  echo "$script_name is not intalled !"
  exit 1
fi
#source config
source "$installed_conf_path"
systemctl_status_return=$(systemctl status) || { echo "Error getting services status !"; exit 1; }
systemctl_failed_services_return=$(systemctl list-units --failed) || { echo "Error getting services status !"; exit 1; }

if [ "$1" = "test-notifications" ]; then 
	if [ -n "$mail" ]; then 
	  #send mail
    echo "Send test notification mail to $mail"
    printf "%s" "$systemctl_failed_services_return" | mail -s "Test notification $script_name on $hostname" "$mail" 
  fi

  if [ -n "$gotify" ]; then
    echo "TODO send gotfiy notification"
  fi
fi

if [[ $systemctl_status_return =~ "Failed: 0 units" ]]; then
  #no failed service, exit the script
  echo "All services running corretly !"
  exit 0
fi
echo "Failed services detected !"
if [ -n "$mail" ]; then 
  #send mail
  echo "Send services failed email to $mail"
  printf "%s" "$systemctl_failed_services_return" | mail -s "Services Failed on $hostname" "$mail" 
fi

if [ -n "$gotify" ]; then
  #send gotify notification
  echo "TODO : gotify notification"
fi



