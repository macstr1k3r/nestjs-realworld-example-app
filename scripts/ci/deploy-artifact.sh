#!/bin/bash -ex


[ -z $TARGET_ENV ] && echo 'Please provide a target environment' && exit 1;
[ -z $TARGET_VERSION ] && echo 'Please provide a target version' && exit 1;

cd terraform;
terraform init;

terraform plan -var-file=vars/${TARGET_ENV}.tfvars -var="app_version=${TARGET_VERSION}" -out=out.tfplan
terraform apply --auto-approve out.plan