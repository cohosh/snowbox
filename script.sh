cd snowflake.git
cd broker
go get -d -v
go build -v
nohup ./broker -addr ":8080" -disable-tls &

cd ../proxy-go
go get -d -v
go build -v
nohup ./proxy-go -broker "http://localhost:8080" &

cd ../client
go get -d -v
go build -v
tor -f torrc-localhost
