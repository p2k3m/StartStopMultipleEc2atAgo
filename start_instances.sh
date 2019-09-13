#!/bin/bash -eux
PATH="$PATH:/usr/local/bin"

aws_id="****"
#Set the account ID for the role-arn
if [ "$aws_id" = "*****" ] 
then
aws_account=*****
aws_name="test"
fi

# set default region
export AWS_DEFAULT_REGION="us-east-1"

# acquire temporary credentials
TMP_CREDS=`aws sts assume-role --role-arn arn:aws:iam::"$aws_account":role/"$role_arn" --role-session-name "$(uuidgen)"`
export AWS_SECRET_ACCESS_KEY=$(echo $TMP_CREDS |jq .Credentials.SecretAccessKey | sed -e 's/^"//'  -e 's/"$//')
export AWS_ACCESS_KEY_ID=$(echo $TMP_CREDS |jq .Credentials.AccessKeyId | sed -e 's/^"//'  -e 's/"$//')
export AWS_SESSION_TOKEN=$(echo $TMP_CREDS |jq .Credentials.SessionToken | sed -e 's/^"//'  -e 's/"$//')

ssodb=$(aws ec2 describe-instances --filters "Name=tag:InstanceName,Values=us-org-orgTest-ssodb-DB" "Name=instance-state-code,Values=80" --query 'Reservations[].Instances[].{id:InstanceId}' --output text)
if [ -z "${ssodb}" ]
then
echo "instance already started"
else
aws ec2 start-instances --instance-ids ${ssodb} 
fi


jasper=$(aws ec2 describe-instances --filters "Name=tag:InstanceName,Values=us-org-orgTest-jasper-web" "Name=instance-state-code,Values=80" --query 'Reservations[].Instances[].{id:InstanceId}' --output text)
if [ -z "${jasper}" ]
then
echo "instance already started"
else
aws ec2 start-instances --instance-ids ${jasper} 
fi

app=$(aws ec2 describe-instances --filters "Name=tag:InstanceName,Values=us-org-orgTest-app" "Name=instance-state-code,Values=80" --query 'Reservations[].Instances[].{id:InstanceId}'  --output text)

if [ -z "${app}" ]
then
echo "instance already started"
else
aws ec2 start-instances --instance-ids ${app} 
fi

proxy=$(aws ec2 describe-instances --filters "Name=tag:InstanceName,Values=us-org-orgTest-ssl-proxy" "Name=instance-state-code,Values=80" --query 'Reservations[].Instances[].{id:InstanceId}'  --output text)

if [ -z "${proxy}" ]
then
echo "instance already started"
else
aws ec2 start-instances --instance-ids ${proxy} 
fi
