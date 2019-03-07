#!/bin/sh
# POSIX

build=0
client=0

while :; do
    case $1 in
        -b|-\?|--build)
            build=1
            ;;
        -c|-\?|--client)
            client=1
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

if [ "$client" -ne "0" ]; then
    cd /go/bin

    # Find a SOCKSPort to bind to that is not in use
    count=0
    while :; do
        if ! netstat --inet -n -a -p 2> /dev/null | grep ":$(($count+9050))" ; then
            break
        fi
        count=$(($count+1))
    done

    cp torrc-localhost torrc-$count
    sed -i -e "s/datadir/datadir$count/g" torrc-$count
    echo "SOCKSPort $(($count+9050))" >> torrc-$count

    nohup tor -f torrc-$count > client-$count.log 2> client-$count.err &

    exit
fi

cp snowflake.git/broker/broker /go/bin/
cp snowflake.git/proxy-go/proxy-go /go/bin/
cp snowflake.git/client/client /go/bin/
cp snowflake.git/client/torrc-localhost /go/bin

cd /go/bin

nohup broker -addr ":8080" -disable-tls > broker.log 2> broker.err &
nohup proxy-go -broker "http://localhost:8080" > proxy.log 2> proxy.err &

nohup tor -f torrc-localhost > client-0.log 2> client-0.err &
