#! /bin/bash
cd terraform/stage && terraform init && terraform validate && tflint
cd ../prod && terraform init && terraform validate && tflint
