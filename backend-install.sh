#!/bin/bash

#We have to do two validations one is executing the node with root user

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Please Enter Password:"
read -s mysql_root_password

if [ $USERID -ne 0 ]
then
    echo -e "Please Connect To $R SUDO USER $N"
    exit 1;
else
    echo -e "Connected To $G SUDO USER $N"
fi

VALIDATE()
{
    if [ $1 -ne 0 ]
    then
        echo -e "The Action $2 $R Failed $N"
        exit 1;
    else
        echo -e "The Action $2 $G SUCCESS $N"
    fi 
}

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