#!/bin/sh -eux

apt-get update
apt-get install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update
apt-get install -y docker-ce

curl -L https://github.com/docker/machine/releases/download/v0.15.0/docker-machine-$(uname -s)-$(uname -m) -o /tmp/docker-machine
install /tmp/docker-machine /usr/local/bin/docker-machine
for i in docker-machine-prompt.bash docker-machine-wrapper.bash docker-machine.bash
do
  wget "https://raw.githubusercontent.com/docker/machine/v0.15.0/contrib/completion/bash/${i}" -P /etc/bash_completion.d
done

curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -L https://raw.githubusercontent.com/docker/compose/1.22.0/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

usermod -aG docker vagrant
