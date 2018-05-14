#! /bin/bash
packer validate -var-file packer/variables.json.example packer/app.json
packer validate -var-file packer/variables.json.example packer/db.json
packer validate -var-file packer/variables.json.example packer/immutable.json
packer validate -var-file packer/variables.json.example packer/ubuntu16.json
