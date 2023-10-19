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

- 1.install

  use install argument to install the script on the system

- 2.configure

  edit /opt/systemd-service-watcher/systemd-service-watcher.conf

  update mail value to whatever suit you, default is root (see https://www.baeldung.com/linux/etc-aliases-file).<br/>
  Of course you can set non alias email (eg. myemail@mydomain.com)

```
mail=root
```

- 3.done
  You're done, delete the cloned project
