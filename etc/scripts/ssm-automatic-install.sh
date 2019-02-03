#!/bin/bash

# before executing make sure you read README.md

# default parameters values
aws_region="eu-central-1"

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

echo "Installing AWSCLI..."
pip install awscli --upgrade

echo "Installing AWSLOGS..."
pip install awslogs --upgrade
service awslogs restart
service awslogs status

echo "Setting up ~/.ssh/ credentials"
mkdir -p ~/.ssh
echo $ssh_pub > ~/.ssh/authorized_keys

echo "Setting up SSHD configuration"
sed -i "s/\#\?PermitRootLogin.*/PermitRootLogin without-password/g" /etc/ssh/sshd_config
sed -i "s/\#Port 22/Port 22/ig" /etc/ssh/sshd_config
if [ $(cat /etc/ssh/sshd_config | grep -iP '^port 10022' | wc -l) -eq 0 ]; then
    echo "Port 10022" >> /etc/ssh/sshd_config
fi
service ssh restart
service ssh status
cat /etc/ssh/sshd_config | grep -i "root"

# install some scheduled jobs
crontab -r
(
    echo "@hourly /etc/scripts/get-ip $route53zoneId $route53domain &> /dev/null"; \
    echo "0 */4 * * * service amazon-ssm-agent restart"
) | crontab -
crontab -l

# run some scripts
/etc/scripts/get-ip $route53zoneId $route53domain

# reboot in one minute
shutdown -r +1