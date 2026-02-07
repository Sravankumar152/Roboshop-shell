#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
Record=mongodb.daws88.online

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

dnf module disable nodejs -y
VALIDATE $? "Disabling Nodejs" &>> $LOGS_FILE

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling Nodejs" &>> $LOGS_FILE

dnf install nodejs -y
VALIDATE $? "Installing Nodejs" &>> $LOGS_FILE

mkdir -p /app 
VALIDATE $? "Creating app directory" &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating app user" &>> $LOGS_FILE
else
    echo "User already exist....skipping"
fi

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downloading application code" &>> $LOGS_FILE

cd /app 
VALIDATE $? "Moving app to directory" &>> $LOGS_FILE

rm -f /app/*
VALIDATE $? "Removing all files" &>> $LOGS_FILE

unzip /tmp/catalogue.zip
VALIDATE $? "Unzipping code" &>> $LOGS_FILE

npm install 
VALIDATE $? "Installing npm" &>> $LOGS_FILE

cp /home/ec2-user/Roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue service" &>> $LOGS_FILE

systemctl daemon-reload
VALIDATE $? "reloading systemd as daemon" &>> $LOGS_FILE

systemctl enable catalogue 
VALIDATE $? "Enabling catalogue" &>> $LOGS_FILE

systemctl start catalogue
VALIDATE $? "Starting catalogue service" &>> $LOGS_FILE

# cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
# VALIDATE $? "updating repos"

# dnf install mongodb-mongosh -y &>>$LOGS_FILE
# VALIDATE $? "Installing Mobodb client"

# mongosh --host $Record </app/db/master-data.js &>>$LOGS_FILE
# VALIDATE $? "Loading master data to mongodb"









