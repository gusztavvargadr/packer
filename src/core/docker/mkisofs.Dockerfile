FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get -y install mkisofs

ADD ./mkisofs.entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
