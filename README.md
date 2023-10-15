# snowbox
A local test environment for testing Snowflake

### Building the docker container
```
docker build -t snowbox --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) .
```

### Running the test environment
The first step is to clone the snowflake repostory locally onto your machine. You must then set up the configuration file by running `./mktestenvconfig`

This will create the file `testenv_config` that you may edit with the path to your local snowflake repository.

If you haven't run the container yet, you will need to create the network with
the command
```
docker network create vnc
```

The command `./snowbox_run` will run the snowbox Docker container and mount the snowflake repository to the container with the following command:

```
docker rm snow_test; docker run --name snow_test -p 8080:8080 -it  -v ${SNOWFLAKE_REPO}:/go/src/snowflake.git snowbox /bin/bash
```

### Building snowflake inside the Docker container
Inside the snowbox container, execute ```build``` to build and run each component of snowflake.
```
$ build [ -b | --build ] [ -c | --client ] [--chromium | --gecko ]
```

### Attaching additional terminals to the test environment
Open a new terminal and execute ```./snowbox_run --attach```. Excluding the --attach argument will prompt the script to attempt an attachment if the container is already running.

### Running a browser-based proxy
To run and debug a browser-based proxy, execute ```build``` as described above to prepare the embeded and webextension proxies for use with the local broker. The best way to test browser-based proxies is to then load the badge or the webextension from outside the container.

##### Testing the embedded badge
After getting the broker running in snowbox, open ```snowflake.git/proxy/build/embed.html``` in a broswer. It should be pointing to the broker at `http://localhost:8080` after running the build script.

##### Testing the webextension
After getting the broker running in snowbox, navigate to ```about:debugging``` and select the "load temporary extension" option. Select ```snowflake.git/proxy/webext/manifest.json```

### Running a client
To test a snowflake client, run ```run-client```. The log output should appear
in two files in your current directory:
```snowflake_client-N.log``` contains logs from snowflake itself
```client-N.log``` contains log messages from the client tor process
