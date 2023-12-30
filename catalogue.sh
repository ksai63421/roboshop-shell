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
     echo -e "Installing $2....$R FAILURE $N"
     exit 1
     else 
      echo -e "Installing $2...$G SUCCESS $N"
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

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "downloading catalogue artifact"

cd /app &>> $LOGFILE

VALIDATE $? "moving into app dir"

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping catalogue"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

# give full path of catalogue.serice because we are inside /app directrory
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue.service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enabling catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting catalogue"

cp/home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Installing mongo repo"

yum install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongo client"

mongo --host mongodb.joindevops.online </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "loading catalogue data into mongodb"

