# Systemd Service Watcher

## What it is and what it does

System service watcher is a simple script that send notifications(emails, Gotify)
periodically if there are failed services.

## How to use it

```
---  Systemd Service Watcher 3.0.3 ---
Use with the following arguments

  install
    install the script on the system

  remove
    remove the script from the system

  check-services
    check that there is no systemd serice failure,
    and send notification if it's the case.
    See /opt/systemd-service-watcher/systemd-service-watcher.conf for notifications config

  test-notifications
    send test notifications
    See /opt/systemd-service-watcher/systemd-service-watcher.conf for notifications config

  help
    show the help
  ------------
  For more details : https://github.com/abdoulayeYATERA/systemd-service-watcher
```

- 1.download

  Clone the project on the system

  ```
  git clone https://github.com/abdoulayeYATERA/systemd-service-watcher
  ```

- 1.Install

  Use install argument to install the script on the system

  ```
  ./systemd-service-watcher/systemd-service-watcher.sh install
  ```

- 2.Configure

  Edit the config file

  ```
    vim /opt/systemd-service-watcher/systemd-service-watcher.conf
    #or
    nano /opt/systemd-service-watcher/systemd-service-watcher.conf
  ```

  To receive mail notifications put your email or alias (see https://www.baeldung.com/linux/etc-aliases-file).<br/>
  System Postfix have to be working for email notifications to work.

  ```
  mail=myemail@mydomain.com
  ```

  To receive Gotify notifications put your Gotify url and app key.

  ```
  gotify_url=https://gotify.mywebsite.com
  gotify_app_token=xdnsidutsridx_isté
  ```

  To watch only some services, fill up the watchlist array.

  ```
  watchlist=( "apache2" "mariadb" "fail2ban" )
  ```

  To watch all services except some, fill the unwatchlist array.<br/>
  Note that watchlist has priority over unwatchlist.

  ```
  unwatchlist=( "logroatate" "man-db" )
  ```

- 3.Done

  Delete the cloned project

  ```
  rm -r ./systemd-service-watcher
  ```

  You're done, you'll receive notifications every 10 minutes when you have failed services.
