FROM debian:jessie
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

RUN apt-get update && apt-get install -y --no-install-recommends curl unzip make ca-certificates
# This is the latest commit at November 9th 2016, the week after the release of eTRIKS v3.0
RUN curl -L https://github.com/transmart/transmart-data/archive/d72385fca7b68011524aa12d9d0e7e1478e7e68a.zip -o transmart-data.zip && \
    unzip transmart-data.zip && \
    mv transmart-data-d72385fca7b68011524aa12d9d0e7e1478e7e68a transmart-data && \
    rm transmart-data.zip

WORKDIR /transmart-data

ENV TABLESPACES=dummy

RUN apt-get install -y libcairo-dev gfortran g++ libreadline-dev libxt-dev libpango1.0-dev libprotoc-dev \
    texlive-fonts-recommended tex-gyre liblz4-tool pv
    
RUN make -C R install_packages

RUN apt-get purge -y --auto-remove curl unzip make g++ ca-certificates && \
    rm -rf /var/lib/apt/lists/*
    
RUN sed -i s/deamon/daemon/ /transmart-data/R/Rserv_nodaemon.conf
RUN echo remote enable >> /transmart-data/R/Rserv_nodaemon.conf

VOLUME ["/transmart-data/R"]

EXPOSE 6311

CMD ["/transmart-data/R/root/lib/R/bin/R","CMD","Rserve.dbg","--no-save","--RS-conf","/transmart-data/R/Rserv_nodaemon.conf"]
    