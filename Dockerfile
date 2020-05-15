
FROM openjdk:13-jdk-alpine AS build-openmole-sources

MAINTAINER Romain Reuillon <romain.reuillon@iscpif.fr>, Sebastien Rey-Coyrehourcq <sebastien.rey-coyrehourcq@univ-rouen.fr> Jonathan Passerat-Palmbach <j.passerat-palmbach@imperial.ac.uk>

RUN echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk upgrade --update-cache --available
RUN apk add --update && apk add --no-cache -f gnupg ca-certificates git git-lfs curl sbt nodejs python python-pycurl bash tar gzip ca-certificates-java openssh npm nodejs-legacy tree

WORKDIR /home/root

RUN mkdir -p .ssh && \
    chmod 0700 .ssh

COPY scripts/config .ssh/config

RUN git clone https://gitlab.openmole.org/openmole/openmole.git

WORKDIR /home/root/openmole

COPY scripts/compile.sh .
RUN ["sh", "compile.sh"]

FROM openjdk:13-jdk-alpine AS openmole

RUN echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk upgrade --update-cache --available
RUN apk add --update &&  apk add --no-cache -f ca-certificates ca-certificates-java su-exec shadow bash mlocate

ARG GID
ARG UID

RUN addgroup -g $GID mole && adduser -h /home/mole -s /bin/sh -D -G mole -u $UID mole

COPY ./scripts/docker-entrypoint.sh /usr/local/bin

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /home/mole/

COPY --from=build-openmole-sources --chown=mole:mole home/root/gama-plugin/openmole/openmole/bin/openmole/target/assemble/ .
RUN chmod +x openmole

EXPOSE 8443
VOLUME /home/mole/workspace

ENV MEM=8G

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh", "-c", "./openmole --mem ${MEM} --port 8443 --remote --workspace /home/mole/workspace"]