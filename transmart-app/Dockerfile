FROM tomcat:7-jre8
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

# change the random number generator to /dev/urandom, since inside a container there is not a lot of
# entropy to feed /dev/random and it will block for a long time when starting the application
RUN sed -i 's#securerandom.source=file:/dev/random#securerandom.source=file:/dev/urandom#' /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

# Use .war compiled from source
ADD transmart.war /usr/local/tomcat/webapps/transmart.war

LABEL SOURCE_COMMIT="https://github.com/dennyverbeeck/transmartApp/tree/66e7023a6eb99258b485da96f4f1d79d770e68f7"
