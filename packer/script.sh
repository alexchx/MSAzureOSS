apt-get update
apt-get upgrade -y

# install jdk
apt-get -y install openjdk-8-jdk

# https://tecadmin.net/install-tomcat-9-on-ubuntu/
# https://askubuntu.com/questions/777342/how-to-install-tomcat-9
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/classic/setup-tomcat

# install tomcat
cd /opt
wget http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.2/bin/apache-tomcat-9.0.2.tar.gz
tar xzf apache-tomcat-9.0.2.tar.gz
mv apache-tomcat-9.0.2 tomcat9

# add user for tomcat, it will be used in the step "chown tomcat /etc/authbind/byport/80" later
useradd -r -s /sbin/nologin tomcat
chown -R tomcat: /opt/tomcat9

# configure environment variables
echo 'export CATALINA_HOME="/opt/tomcat9"' >> /etc/environment
echo 'export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"' >> /etc/environment
echo 'export JRE_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre"' >> /etc/environment
source ~/.bashrc

# clone code
cd /tmp
git clone https://github.com/alexchx/MSAzureOSS

# option 1: package and deploy .war
# cd ./MSAzureOSS/HelloWorld/WebContent
# jar -cvf HelloWorld.war *
# mv HelloWorld.war /opt/tomcat9/webapps

# option 2: deploy code to ROOT directly
rm -rf /opt/tomcat9/webapps/ROOT/*
cp -r /tmp/MSAzureOSS/HelloWorld/WebContent/* /opt/tomcat9/webapps/ROOT

cd /opt/tomcat9

# https://stackoverflow.com/questions/4756039/how-to-change-the-port-of-tomcat-from-8080-to-80
# https://dzone.com/articles/running-tomcat-port-80-user
# http://2ality.blogspot.com/2010/07/running-tomcat-on-port-80-in-user.html

# change default port to 80 from 8080
sed -i 's/Connector port="8080"/Connector port="80"/g' ./conf/server.xml
# Steps below are used to change the default port too, but that appears they are not required, uncomment them only when the above line doesn't work
# apt-get install authbind
# touch /etc/authbind/byport/80
# chmod 500 /etc/authbind/byport/80
# chown tomcat /etc/authbind/byport/80
# echo 'CATALINA_OPTS="-Djava.net.preferIPv4Stack=true"' >> ./bin/setenv.sh
# sed -i 's/exec "$PRGDIR"\/"$EXECUTABLE" start "$@"/exec authbind --deep "$PRGDIR"\/"$EXECUTABLE" start "$@"/g' ./bin/startup.sh

# ./bin/shutdown.sh
# ./bin/startup.sh

# TODO: AUTO START TOMCAT ON LINUX
# https://askubuntu.com/questions/223944/how-to-automatically-restart-tomcat7-on-system-reboots
# http://www.mysamplecode.com/2012/05/automatically-start-tomcat-linux-centos.html

echo '# chkconfig: 2345 80 20
# Description: Tomcat Server basic start/shutdown script
# /etc/init.d/tomcat9 -- startup script for the Tomcat 9 servlet engine

TOMCAT_HOME=/opt/tomcat9/bin
START_TOMCAT=/opt/tomcat9/bin/startup.sh
STOP_TOMCAT=/opt/tomcat9/bin/shutdown.sh

start() {
 echo -n "Starting tomcat9: "
 cd $TOMCAT_HOME
 ${START_TOMCAT}
 echo "done."
}

stop() {
 echo -n "Shutting down tomcat9: "
 cd $TOMCAT_HOME
 ${STOP_TOMCAT}
 echo "done."
}

case "$1" in
 
start)
 start
 ;;

stop)
 stop
 ;;

restart)
 stop
 sleep 10
 start
 ;;

*)
 echo "Usage: $0 {start|stop|restart}"

esac
exit 0' >> /etc/init.d/tomcat9
chmod 755 /etc/init.d/tomcat9
# update-rc.d tomcat9 defaults

apt-get install chkconfig
chkconfig --add tomcat9





/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
