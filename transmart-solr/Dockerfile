FROM openjdk:8
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

RUN apt-get update && apt-get install -y --no-install-recommends curl unzip make
RUN curl http://library.transmartfoundation.org/release/release16_2_0_artifacts/transmart-data-release-16.2.zip -o transmart-data-release-16.2.zip && \
    unzip transmart-data-release-16.2.zip && \
    mv transmart-data-release-16.2 transmart-data && \
    rm transmart-data-release-16.2.zip

ENV TABLESPACES=dummy PGHOST=tmdb PGPORT=5432 PGDATABASE=transmart

WORKDIR /transmart-data

RUN make -C solr solr-4.5.0.tgz && \
    make -C solr solr_home && \
    apt-get purge -y --auto-remove make rsync patch php5-cli php5-json && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8983
WORKDIR /transmart-data/solr
ENTRYPOINT ["java", "-jar", "start.jar"]
    