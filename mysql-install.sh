#!/bin/bash

#We have to do two validations one is executing the node with root user

source ./common.sh

USER_VALIDATE

echo "Please enter the password"
read -s mysql_root_password

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installation of Mysql Server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling mysqld service"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mysqld service"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOGFILE
#VALIDATE $? "Setting up root password"

# In order to handle the Idempotent of shell script to avoid executing multiple times of mysql server password
# set connectivity 

mysql -h db.somustack.online -uroot -p${mysql_root_password} -e "SHOW DATABASES" &>>$LOGFILE

if [ $? -eq 0 ]
then
    echo -e "The ROOT Password $Y ALREADY CONFIGURED $G NO ACTION TO BE PERFORMED $N "
else
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>LOGFILE
    VALIDATE $? "Setting Up $Y ROOT PASSWORD $N"
fi
