#!/bin/sh
echo "Going to deploy Reddit app"
echo "Clonning app source code to $PWD/monolith"
git clone -b monolith https://github.com/express42/reddit.git
echo "App installation start ..."
cd reddit && bundle install
echo "Starting app service ..."
puma -d
echo -e "Success!\nReddit app is running on socket:"
ps aux | grep puma | awk 'NR==1{print $13}'
