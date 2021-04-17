#!/bin/bash
# from https://medium.com/@sandeeptengale/deploy-angular-app-on-aws-ec2-instance-20749f17b33e
echo 'update apt'
sudo apt update
echo 'install awscli'
sudo apt install -y awscli 
echo 'install nginx'
sudo apt install -y nginx
echo 'pull config'
sudo aws s3 cp s3://nus-iss-equeue-nginx/equeue.conf /etc/nginx/sites-available/equeue.conf
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf-bak
sudo aws s3 cp s3://nus-iss-equeue-nginx/nginx.conf /etc/nginx/nginx.conf
# sudo dos2unix /etc/nginx/sites-available/equeue.conf
# sudo dos2unix /etc/nginx/nginx.conf

echo 'link to sites-enabled'
sudo ln -s /etc/nginx/sites-available/equeue.conf /etc/nginx/sites-enabled/
sudo rm default

echo 'test site'
mkdir -p /var/www/equeue-frontend-angular/dist
cd /var/www/equeue-frontend-angular/dist
sudo aws s3 cp s3://nus-iss-equeue-nginx/equeue-frontend-angular.zip /var/www/equeue-frontend-angular/dist/equeue-frontend-angular.zip
sudo apt install -y unzip
sudo unzip /var/www/equeue-frontend-angular/dist/equeue-frontend-angular.zip
sudo rm /var/www/equeue-frontend-angular/dist/equeue-frontend-angular.zip

echo 'restart nginx'
service nginx restart