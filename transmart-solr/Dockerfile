FROM openjdk:8
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

RUN apt-get update && apt-get install -y --no-install-recommends curl unzip make ca-certificates
RUN curl https://codeload.github.com/dennyverbeeck/transmart-data/zip/master -o transmart-data.zip && \
    unzip transmart-data.zip && \
    mv transmart-data-master transmart-data && \
    rm transmart-data.zip

WORKDIR /transmart-data

ENV TABLESPACES=dummy

RUN apt-get install -y --no-install-recommends rsync patch php5-cli php5-json 
    
RUN make -C solr solr-4.5.0.tgz
    
ENV PGHOST=tmdb
ENV PGPORT=5432
ENV PGDATABASE=transmart
    
RUN make -C solr solr_home
RUN apt-get purge -y --auto-remove curl unzip make rsync patch php5-cli php5-json && \
    rm -rf /var/lib/apt/lists/*

VOLUME ["/transmart-data/solr"]
EXPOSE 8983
WORKDIR /transmart-data/solr
CMD ["java", "-jar", "start.jar"]
    