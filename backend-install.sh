#!/bin/bash

#We have to do two validations one is executing the node with root user
source ./common.sh

echo "Please Enter Password:"
read -s mysql_root_password

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling the NodeJs Service"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling NodeJs 20 Version "

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing NodeJS"

id expense &>>$LOGFILE

if [ $? -eq 0 ]
then
    echo -e "The UserID Already $G Created..$N"
else
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating UserID"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Moving To APP Directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Download Artifactory"

cd /app &>>$LOGFILE
rm -rf /app/* &>>$LOGFILE
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracting the Code"

cd /app
npm install &>>$LOGFILE
VALIDATE $? "NodeJS Installation"

#check your repo and path
cp /home/ec2-user/expense_project_shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copy backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Client"

mysql -h db.somustack.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting Backend"