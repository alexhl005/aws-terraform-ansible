#!/bin/bash
set -e

ENV=$1
SSH_KEY=$2

cd ansible
ansible-playbook -i inventories/${ENV}/hosts playbooks/deploy.yml \
  -e "@../tf_outputs/tf_outputs.json" \
  --key-file "${SSH_KEY}"

#test