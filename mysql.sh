#!/bin/bash

source ./common.sh

CHECK_ROOT
INITIALIZE_LOGGING

dnf install mysql-server -y &>>$LOGS_FILE
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld &>>$LOGS_FILE
systemctl start mysqld &>>$LOGS_FILE
VALIDATE $? "Starting mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGS_FILE
VALIDATE $? "Setting root password"
