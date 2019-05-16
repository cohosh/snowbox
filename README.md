# snowbox
A local test environment for testing Snowflake

### Building the docker container
docker build -t snowbox .

### Running the test environment
The first step is to clone the snowflake repostory locally onto your machine. You must then set up the configuration file by running ./mktestenvconfig

This will create the file testenv_config that you may edit with the path to your local snowflake repository.

The command ./snowbox_run will run the snowbox Docker container and mount the snowflake repository to the container with the following command:

```
docker rm snow_test; docker run --name snow_test -p 8080:8080 -it  -v ${SNOWFLAKE_REPO}:/go/src/snowflake.git snowbox /bin/bash
```

### Building snowflake inside the Docker container
Inside the snowbox container, execute ```./script.sh --build``` to build and run each component of snowflake. You will not need to rebuild snowflake everytime the container is started. To run the broker, proxy-go and client components without building first, simply execute ./script.sh

### Attaching additional terminals to the test environment
Open a new terminal and execute ```./snowbox_run --attach```. Excluding the --attach argument will prompt the script to attempt an attachment if the container is already running.

### Running a browser-based proxy
To run and debug a browser-based proxy, you can connect to the docker container using VNC. On your host machine, run the following command:
```vncviewer localhost```
Then, inside snowbox start firefox with the command:
```DISPLAY=:1 nohup firefox &```
A window showing a running firefox session should appear. You can then navigate to
```file:/go/src/snowflake.git/proxy/build/embed.html```
to run the proxy.
