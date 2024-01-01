#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# inside the above folder /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
  echo -e "$R ERROR:: Please run this script with root access $N"
  exit 1
fi
VALIDATE(){
  if [ $1 -ne 0 ];
  then 
     echo -e "$2....$R FAILURE $N"
     exit 1
     else 
      echo -e "$2...$G SUCCESS $N"
      fi
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE

VALIDATE $? "Setting up NPM Source"

yum install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing NodeJS"

#Once the user is created, if you run the csript for the 2nd time linux thorugh aba error, you will get an error
# this command will definately fail 
#improvement: first check the user already exit or not , if not exit will create it

useradd roboshop &>> $LOGFILE 

# write a condition to check dir already exit or not, if not run the below command
mkdir /app &>> $LOGFILE

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "downloading cart artifact"

cd /app &>> $LOGFILE

VALIDATE $? "moving into app dir"

unzip /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "unzipping cart"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

# give full path of cart.serice because we are inside /app directrory
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "copying cart.service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "enabling cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "starting cart"



