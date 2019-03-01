FROM golang:1.11
RUN apt-get update && apt-get install -y git libx11-dev tor net-tools sudo
RUN apt-get clean
RUN useradd -ms /bin/bash snowflake
RUN adduser snowflake sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER snowflake
WORKDIR /go/src/
COPY script.sh .
