FROM debian:jessie
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

RUN apt-get update && apt-get install -y --no-install-recommends curl unzip make ca-certificates
# This is the latest commit + upgrade of qdnaseq package, not yet merged as of building of this image
RUN curl -L https://github.com/transmart/transmart-data/archive/ceb21f907e955a27617cbb19f40bce693de3da68.zip -o transmart-data.zip && \
    unzip transmart-data.zip && \
    mv transmart-data-ceb21f907e955a27617cbb19f40bce693de3da68 transmart-data && \
    rm transmart-data.zip

WORKDIR /transmart-data

ENV TABLESPACES=dummy

RUN apt-get install -y libcairo-dev gfortran g++ libreadline-dev libxt-dev libpango1.0-dev libprotoc-dev \
    texlive-fonts-recommended tex-gyre liblz4-tool pv


# Remove the -march=native option so our container will run on more CPUs, add it in again
# after building so people can rebuild it if they want to
# Keep trying make command until we succeed, it seems downloading R packages fails regularly
RUN sed -i 's/R_FLAGS ?= -O2 -march=native/R_FLAGS ?= -O2/' R/Makefile && \
    until make -C R install_packages; do echo "Failed, retrying..."; done && \
    sed -i 's/R_FLAGS ?= -O2/R_FLAGS ?= -O2 -march=native/' R/Makefile

RUN apt-get purge -y --auto-remove curl unzip make g++ ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i s/deamon/daemon/ /transmart-data/R/Rserv_nodaemon.conf
RUN echo remote enable >> /transmart-data/R/Rserv_nodaemon.conf

EXPOSE 6311

CMD ["/transmart-data/R/root/lib/R/bin/R","CMD","Rserve.dbg","--no-save","--RS-conf","/transmart-data/R/Rserv_nodaemon.conf"]

