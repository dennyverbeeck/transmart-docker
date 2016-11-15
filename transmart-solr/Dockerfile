FROM openjdk:8
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

RUN apt-get update && apt-get install -y --no-install-recommends make rsync patch php5-cli php5-json 
# This is the latest commit at November 9th 2016, the week after the release of eTRIKS v3.0
RUN curl -L https://github.com/transmart/transmart-data/archive/d72385fca7b68011524aa12d9d0e7e1478e7e68a.zip -o transmart-data.zip && \
    unzip transmart-data.zip && \
    mv transmart-data-d72385fca7b68011524aa12d9d0e7e1478e7e68a transmart-data && \
    rm transmart-data.zip

ENV TABLESPACES=dummy PGHOST=tmdb PGPORT=5432 PGDATABASE=transmart

WORKDIR /transmart-data

RUN make -C solr solr-4.5.0.tgz && \
    make -C solr solr_home && \
    apt-get purge -y --auto-remove make rsync patch php5-cli php5-json && \
    rm -rf /var/lib/apt/lists/*

VOLUME ["/transmart-data/solr"]
EXPOSE 8983
WORKDIR /transmart-data/solr
ENTRYPOINT ["java", "-jar", "start.jar"]
