FROM golang:1.21-bullseye

ARG USER_ID
ARG GROUP_ID

# Install dependencies
RUN echo "deb https://deb.nodesource.com/node_12.x bullseye main\ndeb-src https://deb.nodesource.com/node_12.x bullseye main" | tee /etc/apt/sources.list.d/nodesource.list
RUN echo "deb [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main\ndeb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org bullseye main" | tee /etc/apt/sources.list.d/tor.list
RUN curl -sL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
RUN apt-get update && apt-get install -y git libx11-dev net-tools sudo gdb strace x11vnc xvfb less apt-transport-https nodejs vim tor
RUN apt-get clean

# Add a Snowflake user
RUN addgroup --gid $GROUP_ID snowflake
RUN adduser --uid $USER_ID --gid $GROUP_ID snowflake
RUN adduser snowflake sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
COPY script.sh /go/bin/
COPY test.sh /go/bin/
COPY torrc-server /home/snowflake/
COPY torrc-client /home/snowflake/
COPY bridge-list.json /home/snowflake/
RUN chown snowflake.snowflake /go/bin/* /home/snowflake/*
USER snowflake
#RUN go get -u github.com/smartystreets/goconvey
COPY aliases.txt .
RUN cat aliases.txt >> /home/snowflake/.bashrc
WORKDIR /home/snowflake/
