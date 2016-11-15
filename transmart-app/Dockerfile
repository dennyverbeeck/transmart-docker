FROM tomcat:7-jre8
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

RUN curl -L https://owncloud.etriks.org/index.php/s/hQFAokD9WoA1Mhp/download -o /usr/local/tomcat/webapps/transmart.war

# change the random number generator to /dev/urandom, since inside a container there is not a lot of
# entropy to feed /dev/random and it will block for a long time when starting the application
RUN sed -i 's#securerandom.source=file:/dev/random#securerandom.source=file:/dev/urandom#' /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

# make these directories volumes so the rserve container can use them
VOLUME ["/tmp"]
VOLUME ["/usr/local/tomcat/webapps"]
