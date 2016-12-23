
FROM openjdk:8-jdk

MAINTAINER Romain Reuillon <romain.reuillon@iscpif.fr>, Jonathan Passerat-Palmbach <j.passerat-palmbach@imperial.ac.uk>

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils apt-transport-https gnupg2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt-get update && \
    apt-get install -y --no-install-recommends sbt curl npm nodejs-legacy git git-lfs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./scripts/clone /usr/local/bin
COPY ./scripts/compile /usr/local/bin
RUN mkdir /sources && \
    chmod 777 /sources && \
    chmod +x /usr/local/*
WORKDIR /sources

