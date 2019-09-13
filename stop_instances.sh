#!/bin/bash -eux
PATH="$PATH:/usr/local/bin"


#Set the account ID for the role-arn
if [ "$aws_id" = "****" ] 
then
aws_account=**********
aws_name="test"
fi

# set default region
export AWS_DEFAULT_REGION="us-east-1"

# acquire temporary credentials
TMP_CREDS=`aws sts assume-role --role-arn arn:aws:iam::"$aws_account":role/"$role_arn" --role-session-name "$(uuidgen)"`
export AWS_SECRET_ACCESS_KEY=$(echo $TMP_CREDS |jq .Credentials.SecretAccessKey | sed -e 's/^"//'  -e 's/"$//')
export AWS_ACCESS_KEY_ID=$(echo $TMP_CREDS |jq .Credentials.AccessKeyId | sed -e 's/^"//'  -e 's/"$//')
export AWS_SESSION_TOKEN=$(echo $TMP_CREDS |jq .Credentials.SessionToken | sed -e 's/^"//'  -e 's/"$//')


orgTest=$(aws ec2 describe-instances --filters "Name=tag:Service,Values=elevate-db" "Name=tag:InstanceName,Values=us-elevate-orgTest*" "Name=instance-state-code,Values=16" --query 'Reservations[].Instances[].{id:InstanceId}'  --output text)

if [ -z "${orgTest}" ]
then
echo "instance already stopped"
else
aws ec2 stop-instances --instance-ids ${orgTest} 
fi

jasper=$(aws ec2 describe-instances --filters "Name=tag:InstanceName,Values=us-org-orgTest-jasper-web" "Name=instance-state-code,Values=16" --query 'Reservations[].Instances[].{id:InstanceId}' --output text)

if [ -z "${jasper}" ]
then
echo "instance already stopped"
else
aws ec2 stop-instances --instance-ids ${jasper} 
fi

app=$(aws ec2 describe-instances --filters "Name=tag:InstanceName,Values=us-org-orgTest-app" "Name=instance-state-code,Values=16" --query 'Reservations[].Instances[].{id:InstanceId}' --output text)

if [ -z "${app}" ]
then
echo "instance already stopped"
else
aws ec2 stop-instances --instance-ids ${app} 
fi

proxy=$(aws ec2 describe-instances --filters "Name=tag:InstanceName,Values=us-org-orgTest-ssl-proxy" "Name=instance-state-code,Values=16" --query 'Reservations[].Instances[].{id:InstanceId}' --output text)

if [ -z "${proxy}" ]
then
echo "instance already stopped"
else
aws ec2 stop-instances --instance-ids ${proxy} 
fi
