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
sudo apt install -y zulu17-jdk
java -version

sleep 10

# Install MariaDB server
sudo apt install mariadb-server mariadb-client -y
sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service

sudo mysql_secure_installation

maridb -u root -p 
CREATE database `fineract_tenants` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE database `fineract_default` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit

# Download Tomcat 10
sudo mkdir /usr/share/tomcat10
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.34/bin/apache-tomcat-10.1.34.zip 
unzip apache-tomcat-10.1.34.zip
cd apache-tomcat-10.1.34
sudo mv * /usr/share/tomcat10



# Enable SSL 
sudo keytool -genkey -keyalg RSA -keysize 2048 -alias tomcat -validity 3650 -keystore /usr/share/tomcat.keystore \
 -noprompt -dname "CN=${HOSTNAME}, OU=Mifos, O=Company, L=London, S=London, C=GB" -storepass xyz123 -keypass xyz123


sudo cat <<EOF > /usr/share/tomcat10/conf/server.xml

<?xml version='1.0' encoding='utf-8'?>
<Server port="8005" shutdown="SHUTDOWN">

<Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
<Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
<Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
<Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
<GlobalNamingResources>
<Resource name="UserDatabase" auth="Container"
type="org.apache.catalina.UserDatabase" description="User database that can be updated and saved"
factory="org.apache.catalina.users.MemoryUserDatabaseFactory" pathname="conf/tomcat-users.xml" />

<Resource
type="javax.sql.DataSource" name="jdbc/fineract_tenants" factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"
driverClassName="com.mysql.cj.jdbc.Driver" url="jdbc:mysql://localhost:3306/fineract_tenants"
username="root" password="mysql" initialSize="3" maxActive="15" maxIdle="6" minIdle="3" validationQuery="SELECT 1"
testOnBorrow="true" testOnReturn="true" testWhileIdle="true" timeBetweenEvictionRunsMillis="30000" 
minEvictableIdleTimeMillis="60000" logAbandoned="true" suspectTimeout="60" />
</GlobalNamingResources>
<Service name="Catalina">

<Connector
protocol="org.apache.coyote.http11.Http11NioProtocol"
port="443" maxThreads="200" scheme="https" secure="true" SSLEnabled="true"
keystoreFile="/usr/share/tomcat.keystore" keystorePass="xyz123"
clientAuth="false" sslProtocol="TLS" URIEncoding="UTF-8" compression="force"
acceptCount="100" minSpareThreads="25" maxSpareThreads="75" enableLookups="false"
disableUploadTimeout="true" maxHttpHeaderSize="8192"
compressableMimeType="text/html,text/xml,text/plain,text/javascript,text/css"/>

<Engine name="Catalina" defaultHost="localhost">

<Realm className="org.apache.catalina.realm.LockOutRealm">
<Realm className="org.apache.catalina.realm.UserDatabaseRealm" resourceName="UserDatabase"/>
</Realm>

<Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
prefix="localhost_access_log." suffix=".log"
pattern="%h %l %u %t &quot;%r&quot; %s %b" /></Host>
</Engine>
</Service>
</Server>

EOF

# Add required libraries, including the Drizzle and MySQL Connector JARs, to the Tomcat library.
sudo wget https://repo1.maven.org/maven2/org/drizzle/jdbc/drizzle-jdbc/1.4/drizzle-jdbc-1.4.jar -O /usr/share/tomcat9/lib/drizzle-jdbc-1.4.jar
cd /tmp
wget https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-java-8.0.21.tar.gz 
tar xzf mysql-connector-java-8.0.21.tar.gz;
sudo mv mysql-connector-java-8.0.21/mysql-connector-java-8.0.21.jar /usr/share/tomcat9/lib/ 
sudo rm -r mysql-connector-java-8.0.21.tar.gz mysql-connector-java-8.0.21

cat <<EOF > /etc/systemd/system/tomcat10.service
[Unit]
Description=Tomcat 10
After=network.target

[Service]
User=root
Group=root
ExecStart=/usr/share/tomcat10/bin/startup.sh
#ExecStop=/usr/share/tomcat10/bin/shutdown.sh
ExecStop=/usr/bin/pkill -9 -u root -x java
WorkingDirectory=/usr/share/tomcat10
Type=forking
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable tomcat10
sudo systemctl start tomcat10


cd /home
wget https://sourceforge.net/projects/mifos/files/Mifos%20X/mifosplatform-25.03.22.RELEASE.zip
unzip mifosplatform-25.03.22.RELEASE.zip
cd mifosplatform-25.03.22.RELEASE
cp -Rf ./webapp/* /usr/share/tomcat10/webapps/ROOT
cp fineract-provider.war /usr/share/tomcat10/webapps/
cp -Rf apps/community-app/ /usr/share/tomcat10/webapps/ 
cp -Rf api-docs/ /usr/share/tomcat10/webapps/

