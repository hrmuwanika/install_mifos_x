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

sudo mysql_secure_installation

mariadb --user="root" --password="" -h localhost -e "CREATE database fineract_tenants CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mariadb --user="root" --password="" -h localhost -e "CREATE database fineract_default CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

export FINERACT_DEFAULT_TENANTDB_PWD=se5rt67yhfgjjt
export FINERACT_HIKARI_PASSWORD=se5rt67yhfgjjt
export FINERACT_SERVER_SSL_ENABLED=false
export FINERACT_SERVER_PORT=8080

cd /usr/share/tomcat10/bin
sudo chmod +x catalina.sh
./catalina.sh run
 
# Create System Unit File
# ======================
# Create and open a new file in the /etc/system/system under the name tomcat.service:
sudo cat <<EOF >  /etc/systemd/system/tomcat.service

[Unit]
Description=Apache Tomcat 10 Web Application Server
After=network.target
 
[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-1.18.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/usr/share/tomcat10"
Environment="CATALINA_HOME=/usr/share/tomcat10"
Environment="CATALINA_PID=/usr/share/tomcat10/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=//usr/share/tomcat10/bin/startup.sh
ExecStop=//usr/share/tomcat10/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF

# For the changes to take place, reload the system daemon with the command:
sudo systemctl daemon-reload

# Now, you can finally start the Tomcat service:
sudo systemctl start tomcat.service
sudo systemctl enable tomcat.service 

# Verify the Apache Tomcat service is running with the command:
sudo systemctl status tomcat

# Adjust Firewall
# ===============
#  Open Port 8080 to allow traffic through it with the command:
sudo ufw allow 8080/tcp

# If the port is open, you should be able to see the Apache Tomcat splash page. Type the following in the browser window:
echo "Access from http://server_ip:8080 or http://localhost:8080"
echo "username: mifos"
echo "password: se5rt67yhfgjjt"



