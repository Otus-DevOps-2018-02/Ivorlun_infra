#!/bin/sh
echo "Ruby installation start ..."
echo "Checking for packages update ..."
apt update
echo "Installing ruby and developer tools ..."
apt install -y ruby-full ruby-bundler build-essential
echo "Ruby version Verification ..."
ruby -v && bundle -v
echo "Ruby installation complete!"
