#!/bin/bash

source ./common.sh

Mongo_Host=mongodb.daws88.online

CHECK_ROOT
INITIALIZE_LOGGING

INSTALL_NODEJS
CREATE_ROBOSHOP_USER
SETUP_APP_DIR
CLEAN_APP_DIR
DOWNLOAD_AND_EXTRACT "catalogue" "https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip"

npm install &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

SYSTEMD_SETUP "catalogue"

cp $(pwd)/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "Updating mongo repo"

dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "Installing Mongodb client"

mongosh --host $Mongo_Host </app/db/master-data.js &>>$LOGS_FILE
VALIDATE $? "Loading master data to mongodb"
