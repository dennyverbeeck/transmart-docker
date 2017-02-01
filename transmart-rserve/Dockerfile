FROM debian:jessie
MAINTAINER Denny Verbeeck <dverbeec@its.jnj.com>

RUN apt-get update && apt-get install -y --no-install-recommends curl unzip make ca-certificates
# This is the latest commit at February 1st 2017
RUN curl -L https://github.com/transmart/transmart-data/archive/7c492340e43eaf4366c6bac003a273a4287f3cad.zip -o transmart-data.zip && \
    unzip transmart-data.zip && \
    mv transmart-data-7c492340e43eaf4366c6bac003a273a4287f3cad transmart-data && \
    rm transmart-data.zip

WORKDIR /transmart-data

ENV TABLESPACES=dummy

RUN apt-get install -y libcairo-dev gfortran g++ libreadline-dev libxt-dev libpango1.0-dev libprotoc-dev \
    texlive-fonts-recommended tex-gyre liblz4-tool pv
    
# Keep trying make command until we succeed, it seems downloading R packages fails regularly
RUN until make -C R install_packages; do echo "Failed, retrying..."; done

RUN apt-get purge -y --auto-remove curl unzip make g++ ca-certificates && \
    rm -rf /var/lib/apt/lists/*
    
RUN sed -i s/deamon/daemon/ /transmart-data/R/Rserv_nodaemon.conf
RUN echo remote enable >> /transmart-data/R/Rserv_nodaemon.conf

EXPOSE 6311

CMD ["/transmart-data/R/root/lib/R/bin/R","CMD","Rserve.dbg","--no-save","--RS-conf","/transmart-data/R/Rserv_nodaemon.conf"]
    
