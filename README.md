# Setup instructions #

## Image installation ##

 1. Download latest Raspbian image and write into microSD card
 1. Enable SSH by adding "ssh" empty file to /boot directory
 1. Setup WIFI by adding `/etc/wpa_supplicant/wpa_supplicant.conf` file into /boot diretory on SD
 1. Reboot

## Setup SSH and prerequisites ##

 1. SSH to RPi and login. Username: pi; password: raspberry
 1. Change default `pi` user password to something secure
    ``` bash
    sudo passwd pi
    ```
 1. SSH to server and install the following prerequisites:
    ``` bash
    apt-get install -y --upgrade ffmpeg screen pure-ftpd jq dnsutils
    ```

## Install FTP server for cameras ##

 1. Use [this tutorial](https://www.raspberrypi.org/documentation/remote-access/ftp.md)
 Note to set "upload" user with /var/captures/FTP home directory!

## How to setup RPI with SSM ##

 1. Upload all /var and /etc/scripts from local repo into corresponding folder on RPI
 1. Install SSM agent using [this AWS tutorial](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-manual-agent-install.html#agent-install-raspbianjessie)
 Note: use `SSMServiceRole` role from already created list when creating activation request.
 1. Execute `/etc/scripts/setup-rpi` to configure AWSCLI, AWSLOGS and rest of settings
