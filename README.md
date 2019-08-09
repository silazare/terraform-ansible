## Terraform with Ansible examples

- [Inline inventory](https://github.com/silazare/terraform-ansible#inline-inventory)
- [Dynamic inventory](https://github.com/silazare/terraform-ansible#dynamic-inventory)
- [Terraform-inventory](https://github.com/silazare/terraform-ansible#terraform-inventory)
- [Ansible provisioner](https://github.com/silazare/terraform-ansible#ansible-provisioner)

#### Project Structure

```sh
.
├── README.md
├── ansible
├── ansible-provisioner-remote
├── terraform-dynamic
└── terraform-inline
```

#### Digital Ocean prerequisites

- Create SSH key and add public part to Digital Ocean SSH keys
```sh
ssh-keygen -t rsa -f ~/.ssh/someuser -C someuser -P ""
```

- Create API token and Space API secrets for backend

#### GCP prerequisites

- Create SSH key and add public part to GCP VM metadata
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

#### Terraform prerequisites
- terraform >= 0.12
- Terraform Cloud account with access token (https://app.terraform.io)

#### Terraform providers starting guide

https://www.terraform.io/docs/providers/google/getting_started.html
https://www.terraform.io/docs/providers/do/index.html

#### Ansible prerequisites

- Ansible >= 2.7.10
- [geerlingguy.nginx](https://github.com/geerlingguy/ansible-role-nginx) role is used with a little template customization
- simple webserver role is used for testing static http site:

  1) static html could be downloaded from GoogleDrive tables format or your direct link ([google_drive](./ansible/roles/webserver/defaults/main.yml) variable set true or false)
  2) docs_direct_url variable is getting from [vault](./ansible/roles/webserver/vars/secret_example.yml) and .vault_pass file should be located at the ansible folder


#### Inline inventory

- GCP provider
- Terraform Cloud remote backend is used
- 1 webserver instance is being provisioned
- Ansible executed as Terraform local-provisioner after **terraform apply**

Initialize providers:
```sh
cd terraform-inline
terraform init
```

Working in direct mode:
```sh
terraform plan
terraform apply -auto-approve

<HTTP at displayed webserver_nat_ip>

terraform destroy -force
```

Working with plan files:
```sh
terraform plan -out=apply.tfplan
terraform apply apply.tfplan

<HTTP at displayed webserver_nat_ip>

terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan

rm -f *.tfplan
```

#### Dynamic inventory

*Ansible inventory is not working with Terraform v0.12*
*Need refactoring of terraform.py script*

- GCP provider
- Terraform Cloud remote backend is used
- 3 webservers with 1 LoadBalancer
- Ansible executed separately with custom dynamic [inventory](https://github.com/express42/terraform-ansible-example/blob/master/ansible/dynamic_inventory.sh) pulling from Terraform tfstate:


```sh
cd terraform-dynamic

terraform init

terraform plan

terraform apply -auto-approve

cd ../ansible

ansible-playbook provision_dynamic.yml --vault-password-file .vault_pass

<HTTP at displayed loadbalancer_nat_ip>

terraform destroy -force
```

#### Terraform-inventory

- GCP provider
- GCP remote backend
- 3 webservers with 1 LoadBalancer
- Ansible executed separately with [Terraform-inventory](https://github.com/adammck/terraform-inventory)

```sh
cd terraform-dynamic

terraform init

terraform plan

terraform apply -auto-approve

ansible-playbook --inventory-file=$(which terraform-inventory) ../ansible/provision_tf_inventory.yml --vault-password-file ../ansible/.vault_pass

<HTTP at LoadBalancer IP>

terraform destroy -force
```

#### Ansible-provisioner

- Digital Ocean provider
- Digital Ocean remote backend
- 1 webserver instance is being provisioned
- Ansible executed as 3rd party [provisioner](https://github.com/radekg/terraform-provisioner-ansible)

##### Provisioner installation steps:

```sh
curl -sL \
  https://raw.githubusercontent.com/radekg/terraform-provisioner-ansible/master/bin/deploy-release.sh \
  --output deploy-release.sh

chmod +x deploy-release.sh
./deploy-release.sh -v 2.2.0
rm deploy-release.sh
```

##### Remote execution:

```sh
cd ansible-provisioner-remote

terraform init

terraform plan

terraform apply -auto-approve

<HTTP at Droplet Public IP>

terraform destroy -force
```

##### Local execution:

```sh
cd ansible-provisioner-local

terraform init

terraform plan

terraform apply -auto-approve

<HTTP at Droplet Public IP>

terraform destroy -force
```