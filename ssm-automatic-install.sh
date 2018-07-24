#!/bin/bash

# default parameters values
aws_region="eu-central-1"

# parameters
while getopts a:s:r:k: option
do
case "${option}"
in
    h) sethost=${OPTARG};;
    k) ssh_pub=${OPTARG};;
esac
done

# do the work
# TODO set hostname if "sethost" variable is set

echo "Installing AWSCLI..."
pip install awscli

service awslogs restart
service awslogs status
tail -n 20 /var/log/awslogs.log


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

# reboot in one minute
shutdown -r +1