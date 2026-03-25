#!/bin/bash

source ./common.sh

MYSQL_Host=mysql.daws88.online

CHECK_ROOT
INITIALIZE_LOGGING

dnf install maven -y &>>$LOGS_FILE
VALIDATE $? "Installing Maven"

CREATE_ROBOSHOP_USER
SETUP_APP_DIR
CLEAN_APP_DIR
DOWNLOAD_AND_EXTRACT "shipping" "https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip"

mvn clean package &>>$LOGS_FILE
VALIDATE $? "Packaging application"

mv target/shipping-1.0.jar shipping.jar &>>$LOGS_FILE
VALIDATE $? "Moving artifact"

SYSTEMD_SETUP "shipping"

dnf install mysql -y &>>$LOGS_FILE
VALIDATE $? "Installing MySQL client"

mysql -h $MYSQL_Host -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOGS_FILE
VALIDATE $? "Loading schema"

mysql -h $MYSQL_Host -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOGS_FILE
VALIDATE $? "Loading app-user schema"

mysql -h $MYSQL_Host -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGS_FILE
VALIDATE $? "Loading master data"

systemctl restart shipping &>>$LOGS_FILE
VALIDATE $? "Restarting shipping service"
