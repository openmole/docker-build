
FROM openjdk:8-jdk-alpine AS build-openmole-sources

MAINTAINER Romain Reuillon <romain.reuillon@iscpif.fr>, Sebastien Rey-Coyrehourcq <sebastien.rey-coyrehourcq@univ-rouen.fr> Jonathan Passerat-Palmbach <j.passerat-palmbach@imperial.ac.uk>

RUN echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk upgrade --update-cache --available
RUN apk add --update && apk add --no-cache -f gnupg ca-certificates git git-lfs curl sbt nodejs python python-pycurl bash tar gzip ca-certificates-java openssh

WORKDIR /home/root

RUN mkdir -p .ssh && \
    chmod 0700 .ssh
    #ssh-keyscan -t rsa gitlab.iscpif.fr >> .ssh/known_hosts &&\
    #cat .ssh/known_hosts

COPY scripts/config .ssh/config

#RUN ssh-keyscan gitlab.iscpif.fr >> ~/.ssh/known_hosts
RUN git clone https://github.com/openmole/openmole.git

WORKDIR /home/root/openmole
RUN git submodule update --init --remote openmole
RUN git lfs logs last

COPY scripts/compile.sh .
RUN ["sh", "compile.sh"]

FROM openjdk:8-jdk-alpine AS openmole

ARG UID=1000
ARG GID=1000

RUN echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk upgrade --update-cache --available
RUN apk add --update &&  apk add --no-cache -f ca-certificates ca-certificates-java su-exec shadow bash mlocate

COPY ./scripts/docker-entrypoint.sh /usr/local/bin

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN addgroup -S mole -g $GID && \
    adduser -h /home/mole -S -u $UID -G mole mole

WORKDIR /home/mole/

COPY --from=build-openmole-sources home/root/openmole/openmole/bin/openmole/target/assemble/ .
RUN chmod +x openmole

RUN ls

VOLUME /home/mole
EXPOSE 8443

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/home/mole/openmole", "--port", "8443", "--remote"]


