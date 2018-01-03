apt-get update
apt-get install openjdk-8-jdk

groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

wget http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v8.5.5/bin/apache-tomcat-8.5.5.tar.gz
tar -xzvf apache-tomcat-8.5.5.tar.gz
mv apache-tomcat-8.5.5 /opt/tomcat

chgrp -R tomcat /opt/tomcat
chown -R tomcat /opt/tomcat
chmod -R 755 /opt/tomcat

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
systemctl enable tomcat

ufw allow 8080

# /usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
