#!/bin/sh
echo "Starting mongodb installation ..."
echo "Applying key for mongodb repo ..."
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "Trying to add mongodb repo to sources list..."
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list
echo "Checking for package index update ..."
apt update
echo "Going to install mongodb"
apt install -y mongodb-org
echo -e "Installed!\nSystemd service startup turning on ..."
systemctl enable mongod
echo "Starting database service ..."
systemctl start mongod
echo "Checking status ..."
systemctl status mongod
echo "Success!"
