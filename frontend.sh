#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
DIR=$PWD

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

dnf module list nginx
dnf module disable nginx -y
dnf module enable nginx:1.24 -y
dnf install nginx -y
VALIDATE $? "Installing Nginx" &>> $LOGS_FILE

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloading Frontend" &>> $LOGS_FILE

rm -rf /usr/share/nginx/html/* 
VALIDATE "removing default nginx files" &>> $LOGS_FILE

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "Extracting application in nginx html directory"

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "removing default nginx conf"

cp $PWD/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "copying modified nginx.conf "

systemctl enable nginx 
systemctl start nginx 
systemctl restart nginx 
VALIDATE $? "starting nginx"
