#!/bin/sh
# used to pull the current state from S3 and
# use this information for provisioning
# Direct usage to fetch inventory without Ansible: 
#(cd ../terraform && terraform state pull) > terraform.tfstate && ./terraform.py --root . --hostfile && rm -f terraform.tfstate
playbook=${1}
state_file_name="terraform.tfstate"

# fetch current state form s3
(cd ../terraform-dynamic && terraform state pull) > ${state_file_name}
./terraform.py ${1}

rm ${state_file_name}