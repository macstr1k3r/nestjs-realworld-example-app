#!/bin/bash -ex

ARTIFACTORY_REGION="us-east-1"
[ -z $GITHUB_SHA ] && echo 'This script is intended to be ran inside Github Actions, dont atempt to run it manually unless you know what youre doing.' && exit 1;

APP_VERSION=${GITHUB_SHA::8}
[ -z $AWS_ACCOUNT_ID ] && echo 'Please provide the target AWS account via the $AWS_ACCOUNT_ID env var.' && exit 1; 


REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${ARTIFACTORY_REGION}.amazonaws.com"
PUSH_TARGET="${REPO}/nrw-app:${APP_VERSION}"

aws --version
aws sts get-caller-identity 2>&1;
aws ecr get-login-password --region $ARTIFACTORY_REGION | docker login --username AWS --password-stdin $REPO

docker build --target=production . -t $PUSH_TARGET
docker push $PUSH_TARGET