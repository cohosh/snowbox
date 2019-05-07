FROM golang:1.11
RUN apt-get update && apt-get install -y git libx11-dev tor net-tools sudo gdb strace x11vnc xvfb less apt-transport-https
## Setting up coffeescript for snowflake proxy
RUN echo "deb https://deb.nodesource.com/node_12.x stretch main\ndeb-src https://deb.nodesource.com/node_12.x stretch main" | tee /etc/apt/sources.list.d/nodesource.list
RUN curl -sL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN apt-get update && apt-get install -y nodejs firefox-esr
RUN npm install -g coffeescript
##
RUN apt-get clean
RUN useradd -ms /bin/bash snowflake
RUN adduser snowflake sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER snowflake
WORKDIR /go/src/
COPY script.sh .
COPY test.sh .
