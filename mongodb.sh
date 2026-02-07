#!/bin/bash
echo "Calling roboshop script..."
bash ./roboshop.sh

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"

if [ $USERID -ne 0 ]; then
    echo "Please run this script with root user access" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo "$2 ... FAILURE" | tee -a $LOGS_FILE
        exit 1
    else
        echo "$2 ... SUCCESS" | tee -a $LOGS_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "updating repos"

dnf install mongodb-org -y 
VALIDATE $? "Installing Mongodb"

systemctl enable mongod 
VALIDATE $? "Enabling Mongodb"

systemctl start mongod 
VALIDATE $? "Starting Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Updating mongodb config"

systemctl restart mongod
VALIDATE $? "Mongodb Started"