FROM ubuntu:24.04

ENV FACTORIO_GAME_PASSWORD=""

RUN apt update -y \
&& DEBIAN_FRONTEND=noninteractive apt upgrade -y

COPY factorio/ /factorio/
COPY entrypoint.sh /factorio/

RUN useradd factorio && chown -R factorio:factorio /factorio

EXPOSE 34197/udp

USER factorio

WORKDIR /factorio

RUN mkdir saves && mkdir write-data

ENTRYPOINT [ "./entrypoint.sh" ]
