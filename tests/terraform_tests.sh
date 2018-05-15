#! /bin/bash
set -e
cd ../terraform/stage && mv terraform.tfvars.example terraform.tfvars && \
terraform init -backend=false && terraform validate && tflint
cd ../prod && mv terraform.tfvars.example terraform.tfvars && \
terraform init -backend=false && terraform validate && tflint
