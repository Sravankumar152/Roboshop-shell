USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
#MYSQL_Host=mysql.daws88.online
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

dnf install python3 gcc python3-devel -y &>> $LOGS_FILE
VALIDATE $? "Installing python"

if [ $? -ne 0 ]; then

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
    VALIDATE $? "Creating user for roboshop"
else
    echo "User already exists....skipping "

fi

mkdir -p /app &>> $LOGS_FILE
VALIDATE $? "Creating directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading code"

rm -rf /app/*
VALIDATE $? "deleting files in repo"


cd /app &>> $LOGS_FILE
VALIDATE $? "Changing directory"

unzip /tmp/payment.zip &>> $LOGS_FILE
VALIDATE $? "Unziping code"

pip3 install -r requirements.txt &>> $LOGS_FILE
VALIDATE $? "Installing requirements"

cp /home/ec2-user/Roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGS_FILE
VALIDATE $? "Copying files"

systemctl daemon-reload &>> $LOGS_FILE
systemctl enable payment &>> $LOGS_FILE
systemctl start payment &>> $LOGS_FILE
VALIDATE $? "Starting service"










