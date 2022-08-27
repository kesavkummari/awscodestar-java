#!/bin/bash

# Setup Hostname 
sudo hostnamectl set-hostname "tomcat.kesavkummari.com"

# Update the hostname part of Host File
echo "`hostname -I | awk '{ print $1 }'` `hostname`" >> /etc/hosts 

# Update the Repository on Ubuntu 22.04
sudo apt-get update 

# Install required utility softwares 
sudo apt-get install git curl wget unzip tree -y 

# Download, Install Java 11
sudo apt-get install openjdk-11-jdk -y

# Backup the Environment File
sudo cp -pvr /etc/environment "/etc/environment_$(date +%F_%R)"

# Create Environment Variables 
echo "JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/" >> /etc/environment

# Compile the Configuration 
sudo source /etc/environment

# Go to /opt directory to download Apache Tomcat 
cd /opt/

# Download Apache Tomcat - Application
sudo wget https://downloads.apache.org/tomcat/tomcat-8/v8.5.82/bin/apache-tomcat-8.5.82.tar.gz

# Extract the Tomcat File
sudo tar xvzf apache-tomcat-8.5.82.tar.gz

# Rename the Tomcat Folder
sudo mv apache-tomcat-8.5.82 tomcat

# Go Inside the Tomcat Folder
# cd /opt/tomcat/

# Take Tomcat Configuration as backup 
sudo cp -pvr /opt/tomcat/conf/tomcat-users.xml "/opt/tomcat/conf/tomcat-users.xml_$(date +%F_%R)"

# To delete last line and which contains </tomcat-users>
sed -i '$d' /opt/tomcat/conf/tomcat-users.xml

#Add User & Attach Roles to Tomcat 
echo '<role rolename="manager-gui"/>'  >> /opt/tomcat/conf/tomcat-users.xml
echo '<role rolename="manager-script"/>' >> /opt/tomcat/conf/tomcat-users.xml
echo '<role rolename="manager-jmx"/>'    >> /opt/tomcat/conf/tomcat-users.xml
echo '<role rolename="manager-status"/>' >> /opt/tomcat/conf/tomcat-users.xml
echo '<role rolename="admin-gui"/>'     >> /opt/tomcat/conf/tomcat-users.xml
echo '<role rolename="admin-script"/>' >> /opt/tomcat/conf/tomcat-users.xml
echo '<user username="admin" password="redhat@123" roles="manager-gui,manager-script,manager-jmx,manager-status,admin-gui,admin-script"/>' >> /opt/tomcat/conf/tomcat-users.xml
echo "</tomcat-users>" >> /opt/tomcat/conf/tomcat-users.xml

# Start Tomcat Server
cd /opt/tomcat/bin/

./startup.sh


# To Restart SSM Agent on Ubuntu 
sudo systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent.service

touch /etc/systemd/system/tomcat.service

echo '[Unit]' >> /etc/systemd/system/tomcat.service
echo 'Description=Apache Tomcat Web Application Container' >> /etc/systemd/system/tomcat.service
echo 'After=network.target' >> /etc/systemd/system/tomcat.service

echo '[Service]' >> /etc/systemd/system/tomcat.service
echo 'Type=forking' >> /etc/systemd/system/tomcat.service

echo 'Environment=JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64' >> /etc/systemd/system/tomcat.service
echo 'Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid' >> /etc/systemd/system/tomcat.service
echo 'Environment=CATALINA_HOME=/opt/tomcat' >> /etc/systemd/system/tomcat.service
echo 'Environment=CATALINA_BASE=/opt/tomcat' >> /etc/systemd/system/tomcat.service
echo 'Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'' >> /etc/systemd/system/tomcat.service
echo 'Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'' >> /etc/systemd/system/tomcat.service

echo 'ExecStart=/opt/tomcat/bin/startup.sh' >> /etc/systemd/system/tomcat.service
echo 'ExecStop=/opt/tomcat/bin/shutdown.sh' >> /etc/systemd/system/tomcat.service

echo 'User=tomcat' >> /etc/systemd/system/tomcat.service
echo 'Group=tomcat' >> /etc/systemd/system/tomcat.service
echo 'UMask=0007' >> /etc/systemd/system/tomcat.service
echo 'RestartSec=10' >> /etc/systemd/system/tomcat.service
echo 'Restart=always' >> /etc/systemd/system/tomcat.service

echo '[Install]' >> /etc/systemd/system/tomcat.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/tomcat.service


# Verify the tomcat.service
# sudo systemctl status tomcat.service

# Enable Jenkins Daemon/Service at Boot
sudo systemctl enable tomcat.service

# Restart the Jenkins Daemon/Service 
sudo systemctl restart tomcat.service

aws s3 cp s3://kesavkummari-s3/staragileops.zip /opt/

unzip /opt/staragileops.zip 

cp -pvr /opt/staragileops/target/ROOT.war /opt/tomcat/webapps/

# Usig Process Status Command 
# ps -aux | grep tomcat 
