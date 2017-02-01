FROM openjdk:8
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

RUN apt-get update && apt-get install -y --no-install-recommends make rsync patch php5-cli php5-json 
# This is the latest commit at February 1st 2017
RUN curl -L https://github.com/transmart/transmart-data/archive/7c492340e43eaf4366c6bac003a273a4287f3cad.zip -o transmart-data.zip && \
    unzip transmart-data.zip && \
    mv transmart-data-7c492340e43eaf4366c6bac003a273a4287f3cad transmart-data && \
    rm transmart-data.zip

ENV TABLESPACES=dummy PGHOST=tmdb PGPORT=5432 PGDATABASE=transmart

WORKDIR /transmart-data

RUN make -C solr solr-4.5.0.tgz && \
    make -C solr solr_home && \
    apt-get purge -y --auto-remove make rsync patch php5-cli php5-json && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8983
WORKDIR /transmart-data/solr
ENTRYPOINT ["java", "-jar", "start.jar"]
