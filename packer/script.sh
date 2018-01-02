apt-get update
apt-get upgrade -y
# https://tecadmin.net/install-tomcat-9-on-ubuntu/
# https://askubuntu.com/questions/777342/how-to-install-tomcat-9
apt-get -y install openjdk-8-jdk
cd /opt
wget http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.2/bin/apache-tomcat-9.0.2.tar.gz
tar xzf apache-tomcat-9.0.2.tar.gz
mv apache-tomcat-9.0.2 tomcat9
echo 'export CATALINA_HOME="/opt/tomcat9"' >> /etc/environment
echo 'export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"' >> /etc/environment
echo 'export JRE_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre"' >> /etc/environment
source ~/.bashrc

cd /tmp
git clone https://github.com/alexchx/MSAzureOSS
cd ./MSAzureOSS/helloworld/WebContent
jar -cvf helloworld.war *
mv helloworld.war /opt/tomcat9/webapps

cd /opt/tomcat9

# https://stackoverflow.com/questions/4756039/how-to-change-the-port-of-tomcat-from-8080-to-80
# https://dzone.com/articles/running-tomcat-port-80-user
# http://2ality.blogspot.com/2010/07/running-tomcat-on-port-80-in-user.html
sed -i 's/Connector port="8080"/Connector port="80"/g' ./conf/server.xml
apt-get install authbind
touch /etc/authbind/byport/80
chmod 500 /etc/authbind/byport/80
chown glassfish /etc/authbind/byport/80
echo 'CATALINA_OPTS="-Djava.net.preferIPv4Stack=true"' >> ./bin/setenv.sh
sed -i 's/exec "$PRGDIR"\/"$EXECUTABLE" start "$@"/exec authbind --deep "$PRGDIR"\/"$EXECUTABLE" start "$@"/g' ./bin/startup.sh

./bin/startup.sh
