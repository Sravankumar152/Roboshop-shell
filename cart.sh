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

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling module list"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling module list"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Installing Nodejs"

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
    VALIDATE $? "Creating user"
else
    echo "User already exists....skipping "

fi

mkdir -p /app &>> $LOGS_FILE
VALIDATE $? "Making directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading code"

rm -rf /app/* &>> $LOGS_FILE
VALIDATE $? "Deleting all files"

cd /app &>> $LOGS_FILE
VALIDATE $? "Changing directory"

unzip /tmp/cart.zip &>> $LOGS_FILE
VALIDATE $? "Unziping code"

npm install &>> $LOGS_FILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/Roboshop-shell//cart.service /etc/systemd/system/cart.service &>> $LOGS_FILE
VALIDATE $? "Copying files in cart servcie"

systemctl daemon-reload &>> $LOGS_FILE
VALIDATE $? "reloading systemd"

systemctl enable cart &>> $LOGS_FILE 
systemctl start cart &>> $LOGS_FILE
VALIDATE $? "Enabling and starting cart service"












