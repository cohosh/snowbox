#!/bin/sh
# POSIX

build=0

while :; do
    case $1 in
        -b|-\?|--build)
            build=1
            ;;
        -?*)
            printf 'Warning: Unknown option: %s\n' "$1" >&2
            ;;
        *) #default case: no more options
            break
    esac

    shift
done


cd snowflake.git
cd broker

if [ "$build" -ne "0" ]; then
    go get -d -v
    go build -v
fi
nohup ./broker -addr ":8080" -disable-tls &

cd ../proxy-go
if [ "$build" -ne "0" ]; then
    go get -d -v
    go build -v
fi
nohup ./proxy-go -broker "http://localhost:8080" &

cd ../client
if [ "$build" -ne "0" ]; then
    go get -d -v
    go build -v
fi

tor -f torrc-localhost
