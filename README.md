# Systemctl Service Watcher

## What it is and what it does

System service watcher is a simple script that send notifications(emails)
periodically if a there are failed services.

## How to use it

Here is the helper

```
---  Systemd Service Watcher 1.0.0 ---
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
```

- 1.download
  clone the project on the system

  ```
  git clone
  ```

- 1.Install

  use install argument to install the script on the system

- 2.Configure

  edit /opt/systemd-service-watcher/systemd-service-watcher.conf

  ```
  mail=root
  ```

  To receive mail notifications put you email, default is root (see https://www.baeldung.com/linux/etc-aliases-file).<br/>
  Of course you can set non alias email (eg. myemail@mydomain.com)

  ```
  gotify=tdxnisotptpdxd
  ```

  To receive gotify notifications put your gotify app key.

- 3.Done

  Delete the cloned project, you're done, you'll receive notifications every 10 minutes when you have failed services.
