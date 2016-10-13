FROM tomcat:7-jre8
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

ADD Config.groovy /root/.grails/transmartConfig/Config.groovy
ADD DataSource.groovy /root/.grails/transmartConfig/DataSource.groovy
ADD setenv.sh /usr/local/tomcat/bin/setenv.sh

# comment following line and uncomment the line after that if you provide your own war file
ADD http://library.transmartfoundation.org/release/release16_1_0_artifacts/transmart.war /usr/local/tomcat/webapps/transmart.war
# ADD transmart.war /usr/local/tomcat/webapps/transmart.war

# change the random number generator to /dev/urandom, since inside a container there is not a lot of
# entropy to feed /dev/random and it will block for a long time when starting the application
RUN sed -i 's#securerandom.source=file:/dev/random#securerandom.source=file:/dev/urandom#' /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

# make these directories volumes so the rserve container can use them
VOLUME ["/tmp"]
VOLUME ["/usr/local/tomcat/webapps"]
