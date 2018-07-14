# default parameters values
aws_region="eu-central-1"

# parameters
while getopts a:s:r:k: option
do
case "${option}"
in
    a) aws_access_key_id=${OPTARG};;
    s) aws_secret_access_key=${OPTARG};;
    r) aws_region=${OPTARG};;
    k) ssh_pub=${OPTARG};;
esac
done

# do the work

echo "Installing AWSCLI..."
pip install awscli

echo "Setting up ~/.aws/ credentials"
mkdir -p ~/.aws
(
    echo "[default]"
    echo "aws_access_key_id = $aws_access_key_id"
    echo "aws_secret_access_key = $aws_secret_access_key"
) > ~/.aws/credentials
(
    echo "[default]"
    echo "region = $aws_region"
    echo "output = json"
) > ~/.aws/config

#TODO: install awslogs automatically
echo "Setting up 'awslogs' credentials"
(
    echo "[plugins]"
    echo "cwlogs = cwlogs"
    echo "[default]"
    echo "region = $aws_region"
    echo "aws_access_key_id = $aws_access_key_id"
    echo "aws_secret_access_key = $aws_secret_access_key"
) > /var/awslogs/etc/aws.conf
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