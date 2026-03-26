#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(basename $0 | cut -d "." -f1)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

# Colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]; then
        echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
        exit 1
    fi
}

INITIALIZE_LOGGING(){
    mkdir -p $LOGS_FOLDER
    echo "Script started executing at: $TIMESTAMP" &>>$LOGS_FILE
}

CREATE_ROBOSHOP_USER(){
    id roboshop &>>$LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "Creating roboshop user"
    else
        echo -e "User roboshop already exists....$Y skipping $N"
    fi
}

SETUP_APP_DIR(){
    mkdir -p /app &>>$LOGS_FILE
    VALIDATE $? "Creating app directory"
}

CLEAN_APP_DIR(){
    rm -rf /app/* &>>$LOGS_FILE
    VALIDATE $? "Cleaning app directory"
}

DOWNLOAD_AND_EXTRACT(){
    local component=$1
    local url=$2
    curl -L -o /tmp/$component.zip $url &>>$LOGS_FILE
    VALIDATE $? "Downloading $component code"

    cd /app &>>$LOGS_FILE
    VALIDATE $? "Changing to app directory"

    unzip /tmp/$component.zip &>>$LOGS_FILE
    VALIDATE $? "Unzipping $component code"
}

INSTALL_NODEJS(){
    dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Disabling default nodejs"

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "Enabling nodejs:20"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Installing nodejs"
}

SYSTEMD_SETUP(){
    local component=$1
    cp $(dirname $0)/$component.service /etc/systemd/system/$component.service &>>$LOGS_FILE
    VALIDATE $? "Copying $component service file"

    systemctl daemon-reload &>>$LOGS_FILE
    VALIDATE $? "Reloading systemd"

    systemctl enable $component &>>$LOGS_FILE
    VALIDATE $? "Enabling $component service"

    systemctl start $component &>>$LOGS_FILE
    VALIDATE $? "Starting $component service"
}
