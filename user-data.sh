#!/bin/bash

sudo yum update -y
sudo amazon-linux-extras install docker -y 
sudo yum install ruby wget xfsprogs -y
sudo yum install jq -y

echo "install codedeploy agent"
cd /home/ec2-user
wget https://aws-codedeploy-us-east-2.s3.us-east-2.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent restart

# checking if ebs already has a file system on it
FILESYSTEM=$(sudo file -s /dev/xvdb | awk '{print $2}')
if [[ "$FILESYSTEM" == "data" ]]; then
	echo "file system doesn't exist on drive"

	echo "creating file system on drive"
	sudo mkfs -t xfs /dev/xvdb
else 
	echo "file system  already exists on drive"
fi

echo "creating mount point"
sudo mkdir /mnt/data

echo "mounting drive"
sudo mount /dev/xvdb /mnt/data

# install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -a -G docker ec2-user

#rm ./install
