#!/bin/sh
# POSIX

build=0
client=0
browser="chromium"

while :; do
    case $1 in
        -b|-\?|--build)
            build=1
            ;;
        -c|-\?|--client)
            client=1
            ;;
        --gecko)
            browser="gecko"
            ;;
        --chromium)
            browser="chromium"
            ;;
        -?*)
            printf 'Warning: Unknown option: %s\n' "$1" >&2
            ;;
        *) #default case: no more options
            break
    esac

    shift
done

# we manually copy files locally (avoiding go install so we don't have to recompile every time)

if [ "$build" -ne "0" ]; then
    #kill broker, proxy, client processes
    pkill -f broker
    pkill -f client
    pkill -f tor
    pkill -f server
    pkill -f probetest

    cd /go/src/snowflake/broker

    go get -d -v
    go build -v

    cd /go/src/snowflake/proxy
    go get -d -v
    go build -v

    cd /go/src/snowflake/client
    go get -d -v
    go build -v

    cd /go/src/snowflake/server
    go get -d -v
    go build -v

    cd /go/src/snowflake/probetest
    go get -d -v
    go build -v

    cd /go/src/snowflake-webext
    npm install
    npm run build
    npm run webext $browser
    #need to point to our localhost broker instead
    sed -i 's/snowflake-broker.freehaven.net/localhost:8080/' build/embed.js
    sed -i 's/snowflake-broker.freehaven.net/localhost:8080/' build-webext/snowflake.js
    sed -i 's/wss:\/\/snowflake.freehaven.net/ws:\/\/127.0.0.1:8000/' build/embed.js
    sed -i 's/wss:\/\/snowflake.freehaven.net/ws:\/\/127.0.0.1:8000/' build-webext/snowflake.js
    sed -i 's/snowflake.torproject.net/127.0.0.1/' build/embed.js
    sed -i 's/snowflake.torproject.net/127.0.0.1/' build-webext/snowflake.js
    sed -i 's/wss:\/\/\*.freehaven.net/ws:\/\/127.0.0.1:8000 http:\/\/localhost:8080/' build-webext/manifest.json
    
    cd /go/src
fi

if [ "$client" -eq "0" ]; then
    cp /go/src/snowflake/broker/broker /go/bin/
    cp /go/src/snowflake/proxy/proxy /go/bin/
    cp /go/src/snowflake/client/client /go/bin/
    cp /go/src/snowflake/server/server /go/bin/
    cp /go/src/snowflake/probetest/probetest /go/bin/

    cd

    broker -addr ":8080" -disable-tls -unsafe-logging  -default-relay-pattern ^127.0.0.1$ -allowed-relay-pattern ^127.0.0.1$ -bridge-list-path bridge-list.json > broker.log 2> broker.err &
    proxy -keep-local-addresses -broker "http://localhost:8080" -relay ws://127.0.0.1:8000/ -stun stun:stun.voip.blackberry.com:3478 -allowed-relay-hostname-pattern ^127.0.0.1$ -allow-non-tls-relay -unsafe-logging -verbose > proxy.log 2> proxy.err &
    tor -f torrc-server > server.out &
    probetest --disable-tls 2> probetest.err &
else
    cd

    # Find a SOCKSPort to bind to that is not in use
    count=0
    while :; do
        if ! netstat --inet -n -a -p 2> /dev/null | grep ":$(($count+9050))" ; then
            break
        fi
        count=$(($count+1))
    done

    cp torrc-client torrc-$count
    sed -i -e "s/datadir/datadir$count/g" torrc-$count
    sed -i -e "/^-url http:\/\/localhost:8080\//a -log snowflake_client-$count.log" torrc-$count
    echo "SOCKSPort $(($count+9050))" >> torrc-$count

    tor -f torrc-$count > client-$count.log 2> client-$count.err &
fi

