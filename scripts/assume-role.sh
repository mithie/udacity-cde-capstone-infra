#!/usr/bin/env bash

ACCOUNT_ID=$1
ROLE_NAME=$2

EKS_ADMIN_ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"

ASSUME_ROLE_OUTPUT=$(aws sts assume-role --role-arn $EKS_ADMIN_ROLE_ARN --role-session-name eks-setup-session)
ASSUME_ROLE_ENVIRONMENT=$(echo $ASSUME_ROLE_OUTPUT | jq -r '.Credentials | .["AWS_ACCESS_KEY_ID"] = .AccessKeyId | .["AWS_SECRET_ACCESS_KEY"] = .SecretAccessKey | .["AWS_SECURITY_TOKEN"] = .SessionToken | del(.AccessKeyId, .SecretAccessKey, .SessionToken, .Expiration) | to_entries[] | "export \(.key)=\(.value)"')

eval $ASSUME_ROLE_ENVIRONMENT