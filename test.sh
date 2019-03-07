#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
NONE='\033[0m'

echo "=== Testing proxy communication with broker ==="

/go/src/script.sh

printf "Checking proxy poll... "
if grep -q "Invalid data" /go/bin/broker.err; then
    printf "${RED}[fail]${NONE}\n"
    printf "\tProxy provided invalid data\n"
else
    printf "${GREEN}[pass]${NONE}\n"
fi
printf "Checking proxy ID... "
if grep -q "Mismatched IDs!" /go/bin/broker.err; then
    printf "${RED}[fail]${NONE}\n"
    printf "\tProxy provided the wrong ID\n"
else
    printf "${GREEN}[pass]${NONE}\n"
fi

echo "=== Testing client connectivity ==="
printf "Checking for proxies... "
if grep -q "Client: No snowflake proxies available." /go/bin/broker.err; then
    printf "${RED}[fail]${NONE}\n"
    printf "\tThere are no proxies\n"
else
    printf "${GREEN}[pass]${NONE}\n"
fi

/go/src/script.sh --client

wait 30
printf "Checking connectivity... "
if grep -q "Failed to retrieve answer.." /go/bin/*client*.log; then
    printf "${RED}[fail]${NONE}\n"
    printf "\tCouldn't connect to proxy\n"
    exit
else
    printf "${GREEN}[pass]${NONE}\n"
fi


printf "Attempting to connect to proxy... "
if grep -q "Client: Timed out." /go/bin/broker.err; then
    printf "${RED}[fail]${NONE}\n"
    printf "\tProxy was too slow to respond\n"
else
    printf "${GREEN}[pass]${NONE}\n"
fi

