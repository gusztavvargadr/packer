#!/bin/sh

terraform init
terraform workspace select $1 || terraform workspace new $1

terraform plan -out ./.terraform/terraform.tfplan

read -p "Press enter to apply"

terraform apply ./.terraform/terraform.tfplan
