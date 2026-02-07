#!/bin/bash

SECURITY_GROUP_ID="sg-0439749f7885872a1"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z08836952WMRI129YL5JF"
DOMAIN_NAME="daws88.online"

for instance in $@
do

    Instance_Id=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SECURITY_GROUP_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text )

    if [ $instance == "frontend" ]; then
        IP=$(
            aws ec2 describe-instances --instance-ids $Instance_Id \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
        )
        RECORD_NAME=$DOMAIN_NAME
    else
        IP=$(
            aws ec2 describe-instances --instance-ids $Instance_Id \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text

        )
        RECORD_NAME=$instance.$DOMAIN_NAME

    fi

    echo "IPADDRESS: $IP"

    aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating Record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }

    
    '

    echo "record update for $instance"



done

