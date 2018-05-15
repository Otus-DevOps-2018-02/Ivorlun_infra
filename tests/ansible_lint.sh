#! /bin/bash
set -e
cd ../ansible
ansible-lint --exclude=roles/jdauphant.nginx -x ANSIBLE0004 playbooks/*
