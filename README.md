# Friendly disclaimer #

This solution is not complete. Its not world tested, in many areas not working as expected and is generally not stable. By using scripts from this repo you are risking to screw up your RPI configuration and/or loosing ALL data. Make sure you done proper backups and verified them before using any of the scripts or instructions provided. You have been warned :)

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
    apt-get install -y --upgrade ffmpeg screen vsftpd ftp jq dnsutils imagemagick nginx sqlite3
    ```

## Anonymous FTP ##

vsftpd is installed with (above mentioned) prerequisites for cameras to push captured motion videos. vsftpd is configured on anonymous-only mode. Note FTP works on private network only. Its configured with single [/etc/vsftpd.conf](/etc/vsftpd.conf) file.

## How to setup RPI with SSM ##

 1. Upload all of `/var` and `/etc` from local repo into corresponding folders on RPI
 1. Install SSM agent using [this AWS tutorial](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-manual-agent-install.html#agent-install-raspbianjessie)
 Note: use `SSMServiceRole` role from already created list when creating activation request.
 1. Execute `/etc/scripts/setup-rpi` to configure AWSCLI, AWSLOGS and rest of settings
