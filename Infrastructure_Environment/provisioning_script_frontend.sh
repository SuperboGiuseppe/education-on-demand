#!/bin/bash
sudo curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt install -y nodejs unzip
sudo mkdir -p /webserver/nodejs_login/
cd /webserver/nodejs_login/
sudo wget https://github.com/chandantudu/nodejs-login-registration/archive/refs/heads/master.zip
sudo unzip -j master.zip -d .
sudo mkdir views
sudo unzip -j master.zip 'nodejs-login-registration-master/views/*' -d ./views
sudo npm install --save express ejs express-validator cookie-session bcrypt mysql2
sudo sed -i "s/password : '',/password : '$1',/g" database.js
sudo sed -i "s/host : 'localhost',/host : '$2',/g" database.js
sudo node index.js &

