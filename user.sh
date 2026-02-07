#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
DIR=$PWD
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

dnf module list &>> $LOGS_FILE
VALIDATE $? "Enabling module list"

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling nodejs" 

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Installign nodejs"

if [ $? -ne 0 ]; then

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating user for roboshop"
else
    echo "User already exists....skipping "

fi

mkdir -p /app &>> $LOGS_FILE
VALIDATE $? "creating directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading zip file in temp"

rm -rf /app/* &>> $LOGS_FILE
VALIDATE $? "Deleting files in repo"

cd /app &>> $LOGS_FILE
VALIDATE $? "Changing directory"

unzip /tmp/user.zip &>> $LOGS_FILE
VALIDATE $? "Unzipping code"

npm install &>> $LOGS_FILE
VALIDATE $? "Installing dependencies"

cp $PWD/user.service /etc/systemd/system/user.service &>> $LOGS_FILE
VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOGS_FILE
VALIDATE $? "reloading systemd"

systemctl enable user 
systemctl start user &>> $LOGS_FILE
VALIDATE $? "Starting user service"

