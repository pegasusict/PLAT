#!/usr/bin/env bash
clear
apt-get update; apt-get install -qy apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update; apt-get install docker-ce docker-ce-cli containerd.io

usermod -aG docker $USER
newgrp docker

docker version
pause
########################################################################################################################
clear
curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url  | \
grep docker-compose-linux-x86_64 | cut -d '"' -f 4 | wget -qi -
chmod +x docker-compose-linux-x86_64
mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose

docker-compose version
########################################
pause
clear

curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose \
-o /etc/bash_completion.d/docker-compose
source /etc/bash_completion.d/docker-compose

########################################################################################################################
mkdir ~/portainer
cd ~/portainer

docker pull portainer/portainer
docker tag portainer/portainer portainer
export CONT_NAME="portainer"

docker run -d -p 9000:9000 --restart always -v /var/run/docker.sock:/var/run/docker.sock -v ~/portainer:/data \
--name ${CONT_NAME} portainer
