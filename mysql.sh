#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
#Mongo_Host=mongodb.daws88.online
#Redis_Host=redis.daws88.online


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

dnf install mysql-server -y &>> $LOGS_FILE
VALIDATE $? "Installing mysql"

systemctl enable mysqld &>> $LOGS_FILE
systemctl start mysqld &>> $LOGS_FILE
VALIDATE $? "Installing mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGS_FILE
VALIDATE $? "Setting pwd for root user"
