#!/bin/bash
#exit on error
set -e
#exit on unset variable
set -u
#-o pipefail fail if pipe command failed (https://www.howtogeek.com/782514/how-to-use-set-and-pipefail-in-bash-scripts-on-linux/)
set -o pipefail
#extend globbing
shopt -s extglob

my_name=${0##*/}
my_path=$(readlink -f "$0")
top_dir=${my_path%/*}
my_real_name=${my_path##*/}

script_name="Systemd Service Watcher"
script_version="3.0.2"
installed_path="/opt/systemd-service-watcher"
installed_script_path="${installed_path}/systemd-service-watcher.sh"
installed_conf_path="${installed_path}/systemd-service-watcher.conf"
installed_cron_path="/etc/cron.d/systemd-service-watcher"
default_config="
mail=
gotify_url=
gotify_app_token=
watchlist=()
unwatchlist=()
"
default_cron="
DATEVAR=date -u +%Y-%m-%dT%H:%M
#m h dom m dow user script
*/10 * * * *  root \"$installed_script_path\" check-services > /dev/null
"

hostname=$(hostname -f)

is_installed() {
  if ! [ -f "$installed_script_path" ] || ! [ -f "$installed_conf_path" ] || ! [ -f "$installed_cron_path" ]; then
    return 1
  fi
}

gotify_send_message() {
  curl -X 'POST' \
  "$gotify_url/message" \
  -H 'accept: application/json' \
  -H "X-Gotify-Key: $gotify_app_token" \
  -H 'Content-Type: application/json' \
  -d "{
        \"message\": \"$2\",
        \"title\": \"$1\"
      }"
}

gotify_is_setup() {
  test -n "$gotify_url" && test -n "$gotify_app_token"
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
  
  help 
    show the help
  "
}

echo "---  $script_name $script_version ---"

if [ $# -eq 0 ]; then
  print_help
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
systemctl_status_return=$(systemctl status 2>&1) || { echo "Error getting services status !"; exit 1; }
systemctl_failed_services_return=$(systemctl list-units --failed 2>&1) || { echo "Error getting services status !"; exit 1; }

if [ "$1" = "test-notifications" ]; then 
  test_notification_title="Test notification $hostname $script_name $script_version"
	if [ -n "$mail" ]; then 
	  #send mail
    echo "Send test notification mail to $mail"
    printf "%s" "$systemctl_failed_services_return"  | \
      mail -s "$test_notification_title" "$mail" 
  fi

  if gotify_is_setup; then
    echo "Send test notification to Gotify 
    url : $gotify_url
    app_token : $gotify_app_token"
    gotify_notification_message="${systemctl_failed_services_return//$'\n'/\\n}"
    gotify_response=$(gotify_send_message "$test_notification_title" "$gotify_notification_message" 2>&1)
    echo "$gotify_response"
  fi
  exit 0
fi

if [[ $systemctl_status_return =~ "Failed: 0 units" ]]; then
  #no failed service, exit the script
  echo "All services running corretly !"
  exit 0
fi
echo "Failed services detected !"
echo "$systemctl_failed_services_return"
#check watchlist
watchlist_check_pass=1
#1 = pass as watchlist empty
#2 = pass with watchlist non empty
#0 = pass failed 
if [ ${#watchlist[@]} -gt 0 ]; then
  echo "Checking against watchlist : ${watchlist[*]}"
  watchlist_check_pass=2
  for watchlist_entry in "${watchlist[@]}"
  do
    if [[ "$systemctl_failed_services_return" = *"${watchlist_entry}.service"* ]]; then
      echo "following watched service(s) failed : $watchlist_entry"
      watchlist_check_pass=0
    fi
  done
fi

#check unwatchlist
unwatchlist_check_pass=1
#1 = pass as unwatchlist empty
#2 = pass with unwatchlist non empty
#0 = pass failed 
if [ ${#unwatchlist[@]} -gt 0 ]; then
  echo "Checking against unwatchlist : ${unwatchlist[*]}"
  IFS=$'\n' read -d '' -r -a failed_service_array < <( printf "%s" "$systemctl_failed_services_return" | grep -o -E "[^ ]*\.service" | sed "s/\.service//")
  for failed_service in "${failed_service_array[@]}"
  do
    for unwatchlist_entry in "${unwatchlist[@]}"
    do
      unwatchlist_check_pass=0
      if [[ "$unwatchlist_entry" = "$failed_service" ]]; then
        echo "following unwatched service(s) failed : $unwatchlist_entry"
        unwatchlist_check_pass=2
        break
      fi
    done

    if [ $unwatchlist_check_pass -eq 0 ]; then
        echo "following non unwatched service(s) failed : $failed_service"
        break
    fi
  done
fi

#watch list exit check comes before unwatch one
#because watch list has priority over unwatch list
if [ $watchlist_check_pass = 2 ]; then
 echo "All Failed services matching watchlist config. 
 We don't send failed services notification." 
 exit 0
fi

if [ $unwatchlist_check_pass = 2 ]; then
 echo "All failed services matching unwatchlist config. 
 We don't send failed services notification." 
 exit 0
fi

services_failed_notification_title="Services Failed on $hostname"
if [ -n "$mail" ]; then 
  #send mail
  echo "Send services failed email to $mail"
  printf "%s" "$systemctl_failed_services_return" | mail -s "$services_failed_notification_title" "$mail" 
fi

if gotify_is_setup; then
  #send gotify notification
  echo "Send services failed gotify notification
  url : $gotify_url
  app_token : $gotify_app_token"
  gotify_notification_message="${systemctl_failed_services_return//$'\n'/\\n}"
  gotify_response=$(gotify_send_message "$services_failed_notification_title" "$gotify_notification_message" 2>&1)
  echo "$gotify_response"
fi
