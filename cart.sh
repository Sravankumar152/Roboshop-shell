#!/bin/bash

source ./common.sh

CHECK_ROOT
INITIALIZE_LOGGING

INSTALL_NODEJS
CREATE_ROBOSHOP_USER
SETUP_APP_DIR
CLEAN_APP_DIR
DOWNLOAD_AND_EXTRACT "cart" "https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip"

npm install &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

SYSTEMD_SETUP "cart"
