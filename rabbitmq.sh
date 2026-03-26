#!/bin/bash

source ./common.sh

CHECK_ROOT
INITIALIZE_LOGGING

cp $(dirname $0)/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOGS_FILE
VALIDATE $? "Adding rabbitmq.repo"

dnf install rabbitmq-server -y &>>$LOGS_FILE
VALIDATE $? "Installing RabbitMQ"

systemctl enable rabbitmq-server &>>$LOGS_FILE
systemctl start rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "Starting RabbitMQ"

rabbitmqctl add_user roboshop roboshop123 &>>$LOGS_FILE
VALIDATE $? "Creating RabbitMQ user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGS_FILE
VALIDATE $? "Setting RabbitMQ user permissions"
