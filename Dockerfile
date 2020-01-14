FROM golang:1.13
RUN rm -rf /usr/local/go
RUN wget https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.13.4.linux-amd64.tar.gz
RUN rm go1.13.4.linux-amd64.tar.gz
RUN echo "deb https://deb.nodesource.com/node_12.x stretch main\ndeb-src https://deb.nodesource.com/node_12.x stretch main" | tee /etc/apt/sources.list.d/nodesource.list
RUN curl -sL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN apt-get update && apt-get install -y git libx11-dev tor net-tools sudo gdb strace x11vnc xvfb less apt-transport-https nodejs firefox-esr vim
RUN apt-get clean
RUN useradd -ms /bin/bash snowflake
RUN adduser snowflake sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER snowflake
RUN go get -u github.com/smartystreets/goconvey
WORKDIR /go/src/
COPY script.sh .
COPY test.sh .
