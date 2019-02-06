#!/bin/bash

# before executing make sure you read README.md

# parameters
while getopts h:k:z:d:r: option
do
case "${option}"
in
    h) sethost=${OPTARG};;
    k) ssh_pub=${OPTARG};;
    z) route53zoneId=${OPTARG};;
    d) route53domain=${OPTARG};;
    r) aws_region=${OPTARG};;
esac
done

# do the work
# TODO set hostname if "sethost" variable is set

# various prerequisites
apt-get install -y --upgrade ffmpeg screen pure-ftpd jq dnsutils

echo "Installing AWSCLI..."
pip2 install awscli --upgrade

echo "Installing AWSLOGS..."
pip2 install awslogs --upgrade
service awslogs restart
service awslogs status


if [ -z "$ssh_pub" ]; then
    echo "[WARN] Parameter 'k' is not set. Skipping SSH public key setting for for root"
else
    echo "Setting up /root/.ssh credentials"
    mkdir -p /root/.ssh
    echo $ssh_pub > /root/.ssh/authorized_keys

    echo "Setting up SSHD configuration"
    sed -i "s/\#\?PermitRootLogin.*/PermitRootLogin without-password/g" /etc/ssh/sshd_config
    sed -i "s/\#Port 22/Port 22/ig" /etc/ssh/sshd_config
    if [ $(cat /etc/ssh/sshd_config | grep -iP '^port 10022' | wc -l) -eq 0 ]; then
        echo "Port 10022" >> /etc/ssh/sshd_config
    fi
    service ssh restart
    service ssh status
    cat /etc/ssh/sshd_config | grep -i "root"
fi

# install some scheduled jobs
if [ -z "$route53zoneId" ] || [ -z "$route53domain" ]; then
    echo "[WARN] Parameters 'z' and/or 'd' are not set. Skipping crontab configuration"
else
    crontab -r
    (
        echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"; \
        echo "HOME=/root"; \
        echo "@daily /etc/scripts/sunset-sunrise-today &> /dev/null"; \
        echo "@hourly /etc/scripts/get-ip $route53zoneId $route53domain &> /dev/null"; \
        echo "55 */1 * * * /etc/scripts/reload-aws-credentials &> /dev/null"; \
        echo "*/2 * * * * /etc/scripts/capture-image cam1 &> /dev/null"
    ) | crontab -
    crontab -l

    # run some scripts
    /etc/scripts/get-ip $route53zoneId $route53domain
    /etc/scripts/sunset-sunrise-today
fi

# reboot in one minute
shutdown -r +1