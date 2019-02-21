FROM golang:1.11
RUN apt-get update && apt-get install -y git libx11-dev tor
RUN apt-get clean
RUN useradd -ms /bin/bash snowflake
USER snowflake
WORKDIR /go/src/
COPY script.sh .
