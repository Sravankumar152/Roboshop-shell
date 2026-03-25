#!/bin/bash

source ./common.sh

CHECK_ROOT
INITIALIZE_LOGGING

dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "Disabling default nginx"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATE $? "Enabling nginx:1.24"

dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Installing Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGS_FILE
VALIDATE $? "Removing default nginx files"

curl -L -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading Frontend code"

cd /usr/share/nginx/html &>>$LOGS_FILE
unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Extracting application code"

cp $(pwd)/nginx.conf /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "Copying modified nginx.conf"

systemctl enable nginx &>>$LOGS_FILE
systemctl start nginx &>>$LOGS_FILE
systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "Starting Nginx"
