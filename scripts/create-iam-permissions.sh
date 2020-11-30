#!/usr/bin/env bash

set -e

export AWS_PROFILE=mithie-udacity

USERNAME=testuser
EKS_ADMIN_ROLE_NAME=uda-eks-admin
EKS_ASSUME_ROLE_POLICY=assume-eks-admin-policy
EKS_ADMIN_ROLE_TRUST_TMPL_FILE=../config/iam/eks-role-trust-relationship-tmpl.json
EKS_ADMIN_ROLE_TRUST_GEN_FILE=../config/iam/eks-role-trust-relationship.json
EKS_ASSUME_ROLE_POLICY_TMPL_FILE=../config/iam/eks-assume-role-policy-tmpl.json
EKS_ASSUME_ROLE_POLICY_GEN_FILE=../config/iam/eks-assume-role-policy.json

###
# IAM EKS ROLE CREATION
###

# create new IAM user in AWS management console
echo "creating new user $USERNAME..."
USER_ARN=$(aws iam create-user --user-name $USERNAME | jq -r '.User | .Arn')

# create new IAM role in AWS with full administrative permissions and add previously created user to its trust relationship
echo "creating new role $EKS_ADMIN_ROLE_NAME..."
sed "s|<AWS_IAM_USER>|${USER_ARN}|g" $EKS_ADMIN_ROLE_TRUST_TMPL_FILE > $EKS_ADMIN_ROLE_TRUST_GEN_FILE
EKS_ADMIN_ROLE_ARN=$(aws iam create-role --role-name $EKS_ADMIN_ROLE_NAME --assume-role-policy-document file://$EKS_ADMIN_ROLE_TRUST_GEN_FILE | jq -r '.Role | .Arn')
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --role-name $EKS_ADMIN_ROLE_NAME

#create new IAM policy and attach it to the user
echo "creating new policy $EKS_ASSUME_ROLE_POLICY..."
sed "s|<EKS_ADMIN_ROLE>|${EKS_ADMIN_ROLE_ARN}|g" $EKS_ASSUME_ROLE_POLICY_TMPL_FILE > $EKS_ASSUME_ROLE_POLICY_GEN_FILE
EKS_ASSUME_ROLE_POLICY_ARN=$(aws iam create-policy --policy-name $EKS_ASSUME_ROLE_POLICY --policy-document file://$EKS_ASSUME_ROLE_POLICY_GEN_FILE | jq -r '.Policy | .Arn')
aws iam attach-user-policy --policy-arn $EKS_ASSUME_ROLE_POLICY_ARN  --user-name $USERNAME

# set ~/.aws/credentials and ~/.aws/config
CREATE_ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name $USERNAME)
ACCESS_KEY_ENVIRONMENT=$(echo $CREATE_ACCESS_KEY_OUTPUT | jq -r '.AccessKey | .["AWS_ACCESS_KEY_ID"] = .AccessKeyId | .["AWS_SECRET_ACCESS_KEY"] = .SecretAccessKey | del(.AccessKeyId, .SecretAccessKey, .UserName, .Status, .CreateDate) | to_entries[] | "export \(.key)=\(.value)"')

eval $ACCESS_KEY_ENVIRONMENT

# ~/.aws/credentials [default]
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

# ~/.aws/config [default]
aws configure set default.output json
aws configure set default.region eu-central-1

# ~/.aws/config [profile uda-eks-admin]
aws configure set profile.$EKS_ADMIN_ROLE_NAME.output json
aws configure set profile.$EKS_ADMIN_ROLE_NAME.region eu-central-1
aws configure set profile.$EKS_ADMIN_ROLE_NAME.role_arn $EKS_ADMIN_ROLE_ARN
aws configure set profile.$EKS_ADMIN_ROLE_NAME.source_profile default