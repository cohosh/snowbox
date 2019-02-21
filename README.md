# snowbox
A local test environment for testing Snowflake

### Building the docker container
docker build -t snowbox .

### Running the text environment:
The first step is to clone the snowflake repostory locally onto your machine. You must then set up the configuration file by running ./mktestenvconfig

This will create the file testenv_config that you may edit with the path to your local snowflake repository.

The command ./snowbox_run will run the snowbox Docker container and mount the snowflake repository to the container with the following command:

```
docker rm snow_test; docker run --name snow_test -p 8080:8080 -it  -v ${SNOWFLAKE_REPO}:/go/src/snowflake.git snowbox /bin/bash
```

### Building snowflake inside the Docker container
Inside the snowbox container, execute ./script.sh to build and run each component of snowflake.
