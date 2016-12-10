FROM edwinek/alpine-jdk8-maven:latest

ADD dns-update-server-src.tar /opt/src
WORKDIR /opt/src
RUN mvn package
