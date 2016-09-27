FROM tomcat:7-jre8
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

ADD Config.groovy /root/.grails/transmartConfig/Config.groovy
ADD DataSource.groovy /root/.grails/transmartConfig/DataSource.groovy
ADD setenv.sh /usr/local/tomcat/bin/setenv.sh

# comment following line and uncomment the line after that if you provide your own war file
# ADD http://library.transmartfoundation.org/release/release16_1_0_artifacts/transmart.war /usr/local/tomcat/webapps/transmart.war
ADD transmart.war /usr/local/tomcat/webapps/transmart.war

# make these directories volumes so the rserve container can use them
VOLUME ["/tmp"]
VOLUME ["/usr/local/tomcat/webapps"]
