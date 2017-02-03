FROM debian:jessie
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

RUN apt-get update && apt-get install -y --no-install-recommends curl unzip make
RUN curl http://library.transmartfoundation.org/release/release16_2_0_artifacts/transmart-data-release-16.2.zip -o transmart-data-release-16.2.zip && \
    unzip transmart-data-release-16.2.zip && \
    mv transmart-data-release-16.2 transmart-data && \
    rm transmart-data-release-16.2.zip

WORKDIR /transmart-data

ENV TABLESPACES=dummy
ADD kettle.properties /root/.kettle/kettle.properties

RUN apt-get install -y --no-install-recommends postgresql-client openjdk-7-jdk php5-cli php5-json xz-utils zip

# install groovy
RUN curl -s "https://get.sdkman.io" | bash && \
    bash -c "source /root/.sdkman/bin/sdkman-init.sh && \
    sdk install groovy 2.4.5"
	
ENV PATH /root/.sdkman/candidates/groovy/2.4.5/bin:$PATH


ENV TABLESPACES=dummy \
    PATH=/root/.sdkman/candidates/groovy/2.4.5/bin:$PATH \
    KETTLE_JOBS_PSQL=/transmart-data/env/tranSMART-ETL/Postgres/GPL-1.0/Kettle/Kettle-ETL/ \
    KITCHEN=/transmart-data/env/data-integration/kitchen.sh \
    PGHOST=tmdb \
    PGPORT=5432 \
    PGDATABASE=transmart \
    PGUSER=docker \
    PGPASSWORD=docker \
    PGSQL_BIN=/usr/bin

RUN make -C env data-integration && \
    make update_datasets

RUN cd env && curl http://library.transmartfoundation.org/release/release16_2_0_artifacts/tranSMART-ETL-release-16.2.zip -o tranSMART-ETL-release-16.2.zip && \
    unzip tranSMART-ETL-release-16.2.zip && \
	mv tranSMART-ETL-release-16.2 tranSMART-ETL && \
	rm tranSMART-ETL-release-16.2.zip

CMD ["echo","Use the make commands provided by samples/postgres to load data. E.g. run\ndocker-compose run --rm tmload make -C samples/postgres load_clinical_ElevadaGSE14468\nFor more information go to https://wiki.transmartfoundation.org/display/transmartwiki/Curated+Data."]
