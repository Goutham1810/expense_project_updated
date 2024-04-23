#!/bin/bash

set -e

error_handle()
{
    echo "Error occured at line number $1, using command of $2"
}

trap 'error_handle() ${LINENO} "$BASH_COMMAND"' ERR

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER_VALIDATE()
{
        if [ $USERID -ne 0 ]
    then
        echo -e "Please Connect To $R SUDO USER $N"
        exit 1;
    else
        echo -e "Connected To $G SUDO USER $N"
        fi

}

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