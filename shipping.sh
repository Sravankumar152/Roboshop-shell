#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
MYSQL_Host=mysql.daws88.online
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

dnf install maven -y &>> $LOGS_FILE
VALIDATE $? "Installing maven"

if [ $? -ne 0 ]; then

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
    VALIDATE $? "Creating user for roboshop"
else
    echo "User already exists....skipping "

fi

mkdir -p /app &>> $LOGS_FILE
VALIDATE $? "creating directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading code"

cd /app &>> $LOGS_FILE
VALIDATE $? "Changing directory"

unzip /tmp/shipping.zip &>> $LOGS_FILE
VALIDATE $? "unzipping code to tmp directory"

mvn clean package &>> $LOGS_FILE
VALIDATE $? "Building code"

mv target/shipping-1.0.jar shipping.jar &>> $LOGS_FILE
VALIDATE $? "renaming shipping file name"

cp /home/ec2-user/Roboshop-shell/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "copying shipping.service"

systemctl daemon-reload &>> $LOGS_FILE
systemctl enable shipping &>> $LOGS_FILE 
systemctl start shipping &>> $LOGS_FILE
VALIDATE $? "Starting shipping service"

dnf install mysql -y 
VALIDATE $? "Installing mysql"

mysql -h $MYSQL_Host -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOGS_FILE
VALIDATE $? "Loading db schema"

mysql -h $MYSQL_Host -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOGS_FILE
VALIDATE $? "Loading appuser schema"

mysql -h $MYSQL_Host -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOGS_FILE
VALIDATE $? "Loading appuser masterdata"

systemctl restart shipping
VALIDATE $? "restarting the servcice"












