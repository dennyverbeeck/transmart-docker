FROM httpd:alpine
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

ADD httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf
ADD httpd.conf /usr/local/apache2/conf/httpd.conf

ADD start.sh /usr/bin/start.sh
ADD filebeat.yml /etc/filebeat/filebeat.yml
ADD logstash-beats.crt /etc/filebeat/logstash-beats.crt
ADD filebeat /usr/bin/filebeat
RUN chmod +x /usr/bin/start.sh
RUN chmod +x /usr/bin/filebeat

# to get filebeat to run
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

CMD ["/usr/bin/start.sh"]
