#!/bin/bash

source ./common.sh

CHECK_ROOT
INITIALIZE_LOGGING

dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "Disabling default redis"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "Enabling redis:7"

dnf install redis -y &>>$LOGS_FILE
VALIDATE $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOGS_FILE
VALIDATE $? "Updating redis bind address"

sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>>$LOGS_FILE
VALIDATE $? "Disabling redis protected mode"

systemctl enable redis &>>$LOGS_FILE
systemctl start redis &>>$LOGS_FILE
VALIDATE $? "Starting Redis"
