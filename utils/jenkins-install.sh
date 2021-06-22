#!/bin/bash

# Install jenkins
sudo apt update
sudo apt install -y openjdk-11-jre-headless
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# sudo usermod --shell /bin/bash jenkins
# sudo usermod -a -G docker jenkins

# cat >> /etc/sudoers <<EOT
#jenkins ALL=(ALL)       NOPASSWD: ALL
#EOT

# Get admin password from file /var/lib/jenkins/secrets/initialAdminPassword
