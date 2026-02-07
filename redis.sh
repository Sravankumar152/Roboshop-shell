#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
Mongo_Host=mongodb.daws88.online

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

dnf module disable redis -y &>> $LOGS_FILE
VALIDATE $? "disabling redis module"

dnf module enable redis:7 -y &>> $LOGS_FILE
VALIDATE $? "Enable redis module"

dnf install redis -y &>> $LOGS_FILE
VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOGS_FILE
VALIDATE $? "Updating redis config"

sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
VALIDATE $? "Updating redis protected mode"

systemctl enable redis 
VALIDATE $? "Enabling redis"

systemctl start redis 
VALIDATE $? "Starting redis"



