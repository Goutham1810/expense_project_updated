#!/bin/bash

dnf install nginx -y  &>>$LOGFILE

systemctl enable nginx &>>$LOGFILE

systemctl start nginx &>>$LOGFILE

rm -rf /usr/share/nginx/html/*
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGFILE

cp /home/ec2-user/expense_project_updated/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE

systemctl restart nginxd &>>$LOGFILE
echo "Restarting NGINX"
