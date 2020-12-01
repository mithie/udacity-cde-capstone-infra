#!/usr/bin/env bash

CFN_STACK_NAME=$1

EKS_ADMIN_ROLE_ARN=$(aws cloudformation describe-stacks --stack-name $CFN_STACK_NAME --region eu-central-1 --query "Stacks[0].Outputs[?OutputKey=='EKSAdminRoleARN'].OutputValue" --output text)

ASSUME_ROLE_OUTPUT=$(aws sts assume-role --role-arn $EKS_ADMIN_ROLE_ARN --role-session-name eks-setup-session)
ASSUME_ROLE_ENVIRONMENT=$(echo $ASSUME_ROLE_OUTPUT | jq -r '.Credentials | .["AWS_ACCESS_KEY_ID"] = .AccessKeyId | .["AWS_SECRET_ACCESS_KEY"] = .SecretAccessKey | .["AWS_SECURITY_TOKEN"] = .SessionToken | del(.AccessKeyId, .SecretAccessKey, .SessionToken, .Expiration) | to_entries[] | "export \(.key)=\(.value)"')

eval $ASSUME_ROLE_ENVIRONMENT