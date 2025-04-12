#!/bin/sh

# Mifos X system installation

# Software:
# Linux Ubuntu 24.04 LTS 64 bits Operating System
# Apache Tomcat 10.1
# Java JDK Zulu version 17 LTS
# MariaDB 11.4
# Apache Fineract 1.11

# Hardware:
# 8Gb RAM 
# 2 vCPUs (Intel x86 64bits or AMD x86 64bits)
# 32Gb Storage 

# Install System Updates
sudo apt update && sudo apt upgrade -y
sudo apt autoremove

# Installation of the necessary tools
sudo apt install -y gnupg ca-certificates curl unzip git nano

# Install the Zulu JDK 17
curl -s https://repos.azul.com/azul-repo.key | sudo gpg --dearmor -o /usr/share/keyrings/azul.gpg
echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | sudo tee /etc/apt/sources.list.d/zulu.list
sudo apt update
sudo apt install -y zulu17-jdk
java -version

sleep 10

# Download Tomcat 10 core
sudo mkdir /usr/share/tomcat10
cd /usr/src
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.40/bin/apache-tomcat-10.1.40.zip
unzip apache-tomcat-10.1.40.zip
cd apache-tomcat-10.1.40
sudo rm -Rf ./webapps/ROOT/*
sudo mv * /usr/share/tomcat10

cd /usr/src
sudo rm apache-tomcat-10.1.40.zip
sudo rm -Rf apache-tomcat-10.1.40

cd /home
wget https://sourceforge.net/projects/mifos/files/Mifos%20X/mifosplatform-25.03.22.RELEASE.zip
unzip mifosplatform-25.03.22.RELEASE.zip
cd mifosplatform-25.03.22.RELEASE
cp -Rf ./webapp/* /usr/share/tomcat10/webapps/ROOT
cp fineract-provider.war /usr/share/tomcat10/webapps/

# Install MariaDB server
sudo apt install mariadb-server mariadb-client -y
sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service

#sudo mysql_secure_installation

mariadb --user="root" --password="" -h localhost -e "CREATE database fineract_tenants CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mariadb --user="root" --password="" -h localhost -e "CREATE database fineract_default CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

export FINERACT_DEFAULT_TENANTDB_PWD=skdcnwauicn2ucnaecasdsajdnizucawencascdca
export FINERACT_HIKARI_PASSWORD=skdcnwauicn2ucnaecasdsajdnizucawencascdca
export FINERACT_SERVER_SSL_ENABLED=false
export FINERACT_SERVER_PORT=8080

sudo chmod +x /usr/share/tomcat10/bin/catalina.sh
/usr/share/tomcat10/bin/catalina.sh run
 
# Adjust Firewall
# ===============
#  Open Port 8080 to allow traffic through it with the command:
sudo apt install -y ufw 
sudo ufw allow 8080/tcp
sudo ufw reload

# If the port is open, you should be able to see the Apache Tomcat splash page. Type the following in the browser window:
echo "Access from http://localhost:8080"
echo "username: mifos"
echo "password: password"



