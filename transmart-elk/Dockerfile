FROM sebp/elk

ADD http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz /etc/logstash/GeoLiteCity.dat.gz
RUN gunzip /etc/logstash/GeoLiteCity.dat.gz && chmod 666 /etc/logstash/GeoLiteCity.dat

# let's preload filebeat template to elasticsearch
ADD filebeat.template.json /etc/filebeat/filebeat.template.json
ADD load_filebeat.sh /usr/bin/load_filebeat.sh

# add configuration files
ADD ./tmdb.conf /etc/logstash/conf.d/tmdb.conf
ADD ./tmweb.conf /etc/logstash/conf.d/tmweb.conf

# add new start.sh
ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh /usr/bin/load_filebeat.sh
