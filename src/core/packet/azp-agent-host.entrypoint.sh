#!/bin/sh

terraform init
terraform workspace select $1 || terraform workspace new $1

terraform plan -out ./.terraform/terraform.tfplan
# terraform apply ./.terraform/terraform.tfplan
