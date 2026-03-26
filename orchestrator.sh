#!/bin/bash

# Install sshpass on frontend to automate internal connections
sudo dnf install sshpass -y

PASSWORD="DevOps321"
DOMAIN="daws88.online"

# Function to run script on remote host
deploy_component(){
    local component=$1
    local host="$component.$DOMAIN"
    local files=$2

    echo "Deploying $component to $host..."
    
    # Copy files
    sshpass -p $PASSWORD scp -o StrictHostKeyChecking=no $files common.sh ec2-user@$host:/home/ec2-user/
    
    # Run setup script as root
    sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no ec2-user@$host "sudo bash /home/ec2-user/$component.sh"
}

# Deploy all components
deploy_component "mongodb" "mongo.repo mongodb.sh"
deploy_component "redis" "redis.sh"
deploy_component "rabbitmq" "rabbitmq.repo rabbitmq.sh"
deploy_component "mysql" "mysql.sh"
deploy_component "catalogue" "catalogue.service catalogue.sh mongo.repo"
deploy_component "user" "user.service user.sh"
deploy_component "cart" "cart.service cart.sh"
deploy_component "shipping" "shipping.service shipping.sh"
deploy_component "payment" "payment.service payment.sh"

# Frontend is local
echo "Deploying frontend locally..."
sudo bash ./frontend.sh
