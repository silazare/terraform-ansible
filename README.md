## Terraform with Ansible examples

- Inline inventory with 1 instance
- Dynamic inventory with 3 instances
- [Terraform-inventory](https://github.com/adammck/terraform-inventory) project

#### Project Structure

```sh
.
├── README.md
├── ansible
├── terraform-dynamic
└── terraform-inline
```

#### Prerequisites with gcloud

- Create SSH key and upload it to GCP VM metadata
```sh
ssh-keygen -t rsa -f ~/.ssh/tfuser -C tfuser -P ""
```

- Configure gcloud settings at ~/.config/gcloud/configurations/config_default

- Test manual VM creation
```sh
gcloud compute instances create \
--boot-disk-size=10GB \
--image-family=centos-7 \
--image-project=centos-cloud \
--machine-type=g1-small \
--tags webserver \
--restart-on-failure \
--zone=europe-west1-b webserver

gcloud compute instances list

ssh tfuser@$(gcloud compute instances list | awk '{print $5}' | tail -1) -i ~/.ssh/tfuser

gcloud compute instances delete --zone=europe-west1-b webserver
```

#### Terraform GCP provider starting guide

https://www.terraform.io/docs/providers/google/getting_started.html

#### Ansible part

- [geerlingguy.nginx](https://github.com/geerlingguy/ansible-role-nginx) role is used with a little template customization
- simple webserver role is used for testing static http site:

  1) static html could be downloaded from GoogleDrive tables format or your direct link ([google_drive](./ansible/webserver/defaults/main.yml) variable set true or false)
  2) docs_direct_url variable is getting from [vault](./ansible/webserver/vars/secret_example.yml) and vault_pass file should be located at the ansible folder


#### Inline inventory

- GCP provider
- Ansible executed as Terraform local-provisioner after **terraform apply**
- 1 webserver instance is being provisioned

```sh
cd terraform-inline

terraform init

terraform plan

terraform apply -auto-approve

<HTTP at Webserver IP>

terraform destroy -force
```

#### Dynamic inventory

- GCP provider
- 3 webservers with 1 LoadBalancer
- Ansible executed separately with custom dynamic [inventory](https://github.com/express42/terraform-ansible-example/blob/master/ansible/dynamic_inventory.sh) pulling from Terraform tfstate:


```sh
cd terraform-dynamic

terraform init

terraform plan

terraform apply -auto-approve

cd ../ansible

ansible-playbook provision_dynamic.yml --vault-password-file .vault_pass

<HTTP at LoadBalancer IP>

terraform destroy -force
```

#### Terraform-inventory

- GCP provider
- 3 webservers with 1 LoadBalancer
- Ansible executed separately with dynamic inventory

```sh
cd terraform-dynamic

terraform init

terraform plan

terraform apply -auto-approve

ansible-playbook --inventory-file=$(which terraform-inventory) ../ansible/provision_tf_inventory.yml --vault-password-file ../ansible/.vault_pass

<HTTP at LoadBalancer IP>

terraform destroy -force
```

