#!/bin/bash
##Provisioning script provided by Professor Daniele Santoro (https://gitlab.fbk.eu/dsantoro/paas-lab-fcc/-/blob/master/provision.sh)##
DEBIAN_FRONTEND=noninteractive sudo apt-get -qqy update
DEBIAN_FRONTEND=noninteractive sudo apt-get dist-upgrade -y
sudo apt-get install emacs-nox jq htop -y
sudo apt-get install docker.io -y
DEBIAN_FRONTEND=noninteractive sudo apt install snapd
sudo snap install yq
sudo usermod -aG docker eval
## Download and setup kind
cd /home/eval
wget --progress=bar:force https://github.com/kubernetes-sigs/kind/releases/download/v0.10.0/kind-linux-amd64
sudo mv kind-linux-amd64 /usr/local/bin/kind
sudo chmod a+x /usr/local/bin/kind
## Download and setup kubectl
cd /home/eval
KC_REL=v1.20.0
curl -LO https://storage.googleapis.com/kubernetes-release/release/$KC_REL/bin/linux/amd64/kubectl
## To download the latest version:
## curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo -u ubuntu kubectl completion bash >> ~/.bashrc
sudo -u eval kubectl completion bash >> ~/.bashrc
sudo mkdir -p /storage/docker/mysql-data/
sudo docker run --detach --name=Users_DB --env="MYSQL_ROOT_PASSWORD=$1" --publish 3306:3306 --restart=on-failure --volume=/storage/docker/mysql-data:/var/lib/mysql mysql
sleep 120
sudo docker exec Users_DB mysql -u root -p$1 -e "CREATE DATABASE nodejs_login;"
sudo docker exec Users_DB mysql -u root -p$1 -e "USE nodejs_login; CREATE TABLE \`users\` (\`id\` int(10) unsigned NOT NULL AUTO_INCREMENT, \`name\` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL, \`email\` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL, \`password\` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,PRIMARY KEY (\`id\`),UNIQUE KEY \`email\` (\`email\`)) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"
sudo docker exec Users_DB mysql -u root -p$1 -e "ALTER USER \`root\`@\`%\` IDENTIFIED WITH mysql_native_password BY \"$1\"; FLUSH PRIVILEGES;"

