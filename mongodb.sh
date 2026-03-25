#!/bin/bash

source ./common.sh

CHECK_ROOT
INITIALIZE_LOGGING

cp $(pwd)/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "Updating mongo repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing Mongodb"

systemctl enable mongod &>>$LOGS_FILE
systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "Starting Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOGS_FILE
VALIDATE $? "Updating mongodb config"

systemctl restart mongod &>>$LOGS_FILE
VALIDATE $? "Restarting Mongodb"
