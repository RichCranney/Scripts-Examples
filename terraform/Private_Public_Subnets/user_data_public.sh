#!/bin/bash

cd /tmp/
# Download Unzip from yum repo
yum install --downloadonly --downloaddir=/tmp/ unzip
# Rename unzip*.zip
mv unzip*.rpm unzip.rpm
# Install Unzip
yum localinstall -y /tmp/unzip.rpm
# Bring down latest version 
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
# Unzip into same directoy
unzip awscli-bundle.zip
# Install AWS CLI
./awscli-bundle/install -i /usr/local/aws -b /usr/bin/aws

# Upload above files to S3 Bucket
aws s3 cp /tmp/unzip.rpm s3://\$${bucket}/setup/
aws s3 cp /tmp/awscli-bundle.zip s3://\$${bucket}/setup/

# Remove files
#rm -f /tmp/unzip*.rpm
#rm -f /tmp/awscli-bundle.zip
#rm -f -r /tmp/awscli-bundle

# Place the Private Key into the id_rsa file
echo "${public_key}" >> /home/ec2-user/.ssh/id_rsa
# Check owner of file in case it doesn't exist
chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
# chmod 600 the file
chmod 600 /home/ec2-user/.ssh/id_rsa

# Create a script which will run when the user logs onto the Public Server.
# This will set up the Private server which we can't do at boot as there is no internet access to download AWS CLI
# The only way to do this at boot would be a pre-requisit of putting the CLI onto an S3 bucket which is static
cat <<EOF > /home/ec2-user/first_run.sh
RED='\033[0;31m'
MAG='\033[0;35m'
BLUE='\033[0;94m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\$${MAG}Running setup on \033[1mPrivate\$${MAG} Server (${private_ip})\$${NC}"
ssh -o "StrictHostKeyChecking no" ec2-user@${private_ip} "echo connected$"

echo -e "\$${MAG} Copying \033[1mUnzip\$${MAG} and \033[1mAWSCLI\$${MAG} to Private Server\$${NC}"
scp /tmp/unzip.rpm ec2-user@${private_ip}:/tmp/.
scp /tmp/awscli-bundle.zip ec2-user@${private_ip}:/tmp/.

echo -e "\$${MAG} Running install for unzip and unzipping AWSCLI on Private Server\$${NC}"
ssh ec2-user@${private_ip} "sudo yum localinstall -y /tmp/unzip.rpm && cd /tmp/ && sudo unzip -o /tmp/awscli-bundle.zip"
echo -e "\$${MAG} Installing AWSCLI on Private Server\$${NC}"
ssh ec2-user@${private_ip} "cd /tmp/ && sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/bin/aws"

echo -e "\$${MAG} Cleaning up script\$${NC}"
sed -i.bak '/. ~\/first_run.sh/d' ~/.bash_profile 

rm -f ~/first_run.sh

echo -e "\$${BLUE}\033[1mFinished\$${NC}"
EOF

chmod +x /home/ec2-user/first_run.sh

echo ". ~/first_run.sh" >> /home/ec2-user/.bash_profile