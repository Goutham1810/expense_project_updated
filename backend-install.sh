#!/bin/bash

#We have to do two validations one is executing the node with root user
source ./common.sh

echo "Please Enter Password:"
read -s mysql_root_password

dnf module disable nodejs -y &>>$LOGFILE

dnf module enable nodejs:20 -y &>>$LOGFILE

dnf install nodejs -y &>>$LOGFILE

id expense &>>$LOGFILE

if [ $? -eq 0 ]
then
    echo -e "The UserID Already $G Created..$N"
else
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating UserID"
fi

mkdir -p /app &>>$LOGFILE

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE

cd /app &>>$LOGFILE
rm -rf /app/* &>>$LOGFILE
unzip /tmp/backend.zip &>>$LOGFILE

cd /app
npm install &>>$LOGFILE

#check your repo and path
cp /home/ec2-user/expense_project_updated/backend.service /etc/systemd/system/backend.service &>>$LOGFILE

systemctl daemon-reload &>>$LOGFILE

systemctl start backend &>>$LOGFILE

systemctl enable backend &>>$LOGFILE

dnf install mysql -y &>>$LOGFILE

mysql -h db.somustack.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE

systemctl restart backend &>>$LOGFILE
echo "Restart Backend Is Done.."