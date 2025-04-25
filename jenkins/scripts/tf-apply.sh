#!/bin/bash
set -e

cd terraform/environments/dev
terraform init -input=false
terraform apply -input=false -auto-approve
terraform output -json > ../../../tf_outputs/tf_outputs.json