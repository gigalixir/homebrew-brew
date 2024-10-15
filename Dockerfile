FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
 && apt -y dist-upgrade \
 && apt install -y \
   rake \
   virtualenv \
   wget \
 && rm -rf /var/lib/apt/lists/*

VOLUME /brew
WORKDIR /brew

CMD ["rake"]
