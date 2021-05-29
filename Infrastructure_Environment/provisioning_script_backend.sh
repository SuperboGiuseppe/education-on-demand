#!/bin/bash
##Provisioning script provided by Professor Daniele Santoro (https://gitlab.fbk.eu/dsantoro/paas-lab-fcc/-/blob/master/provision.sh)##
DEBIAN_FRONTEND=noninteractive sudo apt-get -qqy update
DEBIAN_FRONTEND=noninteractive sudo apt-get dist-upgrade -y
sudo apt-get install emacs-nox jq htop -y
sudo apt-get install docker.io -y
DEBIAN_FRONTEND=noninteractive sudo apt install snapd
sudo snap install yq
sudo usermod -aG docker vagrant
## Download and setup kind
cd /home/vagrant
wget --progress=bar:force https://github.com/kubernetes-sigs/kind/releases/download/v0.10.0/kind-linux-amd64
sudo mv kind-linux-amd64 /usr/local/bin/kind
sudo chmod a+x /usr/local/bin/kind
## Download and setup kubectl
cd /home/vagrant
KC_REL=v1.20.0
curl -LO https://storage.googleapis.com/kubernetes-release/release/$KC_REL/bin/linux/amd64/kubectl
## To download the latest version:
## curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo -u ubuntu kubectl completion bash >> ~/.bashrc
sudo -u eval kubectl completion bash >> ~/.bashrc
