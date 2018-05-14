#! /bin/bash
cd ansible && ansible-lint --exclude=roles/jdauphant.nginx -x ANSIBLE0004 playbooks/*
