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

# we manually copy files locally (avoiding go install so we don't have to recompile everytime)

if [ "$build" -ne "0" ]; then
    cd snowflake.git/broker

    go get -d -v
    go build -v

    cd ../proxy-go
    go get -d -v
    go build -v

    cd ../client
    go get -d -v
    go build -v
    
    cd /go/src
fi

cp snowflake.git/broker/broker /go/bin/
cp snowflake.git/proxy-go/proxy-go /go/bin/
cp snowflake.git/client/client /go/bin/
cp snowflake.git/client/torrc-localhost /go/bin

cd /go/bin

nohup broker -addr ":8080" -disable-tls &
nohup proxy-go -broker "http://localhost:8080" &

tor -f torrc-localhost
