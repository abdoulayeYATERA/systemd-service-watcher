# Systemd Service Watcher

## What it is and what it does

System service watcher is a simple script that send notifications(emails)
periodically if there are failed services.

## How to use it

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

  help
    show the help
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

  ```
    vim /opt/systemd-service-watcher/systemd-service-watcher.conf
    #or
    nano /opt/systemd-service-watcher/systemd-service-watcher.conf
  ```

  Edit the config file

  ```
  mail=myemail@mydomain.com
  ```

  To receive mail notifications put your email or alias (see https://www.baeldung.com/linux/etc-aliases-file).<br/>
  System Postfix have to be working for email notifications to work.

  ```
  gotify_url=https://gotify.mywebsite.com
  gotify_app_token=xdnsidutsridx_isté
  ```

  To receive Gotify notifications put your Gotify url and app key.

  - 3.Done

    Delete the cloned project

    ```
    rm -r ./systemd-service-watcher
    ```

    You're done, you'll receive notifications every 10 minutes when you have failed services.
