apt-get update
apt-get -y install openjdk-8-jdk

groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

wget http://mirrors.shuosc.org/apache/tomcat/tomcat-8/v8.5.24/bin/apache-tomcat-8.5.24.tar.gz
tar -xzvf apache-tomcat-8.5.24.tar.gz
mv apache-tomcat-8.5.24 /opt/tomcat

chgrp -R tomcat /opt/tomcat
chown -R tomcat /opt/tomcat
chmod -R 755 /opt/tomcat

# clone code
cd /tmp
git clone https://github.com/alexchx/MSAzureOSS

# option 1: package and deploy .war
# cd ./MSAzureOSS/HelloWorld/WebContent
# jar -cvf HelloWorld.war *
# mv HelloWorld.war /opt/tomcat9/webapps

# option 2: deploy code to ROOT directly
rm -rf /opt/tomcat/webapps/ROOT/*
cp -r /tmp/MSAzureOSS/HelloWorld/WebContent/* /opt/tomcat/webapps/ROOT

sed -i 's/Connector port="8080"/Connector port="80"/g' /opt/tomcat/conf/server.xml

#echo 'export CATALINA_HOME="/opt/tomcat9"' >> /etc/environment
#echo 'export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"' >> /etc/environment
#echo 'export JRE_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre"' >> /etc/environment

echo "[Unit]
Description=Apache Tomcat Web Server
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=15
Restart=always

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/tomcat.service

systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

# ufw allow 8080

# /usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
