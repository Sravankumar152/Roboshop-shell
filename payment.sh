#!/bin/bash

source ./common.sh

CHECK_ROOT
INITIALIZE_LOGGING

dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATE $? "Installing Python"

CREATE_ROBOSHOP_USER
SETUP_APP_DIR
CLEAN_APP_DIR
DOWNLOAD_AND_EXTRACT "payment" "https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip"

pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

SYSTEMD_SETUP "payment"
