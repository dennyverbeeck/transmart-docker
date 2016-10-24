FROM openjdk:8
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

RUN apt-get update && apt-get install -y --no-install-recommends curl unzip make
RUN curl http://library.transmartfoundation.org/release/release16_1_0_artifacts/transmart-data-release-16.1.zip -o transmart-data-release-16.1.zip && \
    unzip transmart-data-release-16.1.zip && \
    mv transmart-data-release-16.1 transmart-data && \
    rm transmart-data-release-16.1.zip

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
ENTRYPOINT ["java", "-jar", "start.jar"]
    