# transmart-docker

The purpose of this repository is to provide a Docker-based installation of TranSMART. Since TranSMART consists of multiple services, `docker-compose` is used to build images for the different services and manage the links between them. Apache is used to reverse proxy requests to the Tomcat server, and is the only service bound to a host port by default.

### Usage
It should be sufficient to clone the repository and execute `docker-compose up` in the root directory. This will automatically download all the necessary components, build images, create the network and run the containers. The current version that will be installed is `16.1`. When you see a line like this

```
tmapp_1     | INFO: Server startup in 40888 ms
```

this means the services are up and running. Verify this by running `docker-compose ps`:

```
$ docker-compose.exe ps
           Name                         Command               State             Ports
----------------------------------------------------------------------------------------------
transmartdocker_tmapp_1      catalina.sh run                  Up       8080/tcp
transmartdocker_tmdb_1       /usr/lib/postgresql/9.3/bi ...   Up       5432/tcp
transmartdocker_tmload_1     echo Use the make commands ...   Exit 0
transmartdocker_tmrserve_1   /transmart-data/R/root/lib ...   Up       6311/tcp
transmartdocker_tmsolr_1     java -jar start.jar              Up       8983/tcp
transmartdocker_tmweb_1      httpd-foreground                 Up       0.0.0.0:8888->80/tcp
```

This overview gives us a lot of information. We can see all services except for `tmload` are up and running (more on `tmload` later). We also see that port 8888 of our own machine is forwarded to port 80 of the `tmapp` container. Point your browser to http://localhost:8888/ to see your installation running. If you want you can provide your own `transmart.war` file. Simply place it in the `transmart-app` folder and modify the `Dockerfile` in the `transmart-app` directory.

After your first `docker-compose up` command, use `docker-compose stop` and `docker-compose start` to stop and start the TranSMART stack. Using `docker-compose down` **will delete all volumes as well**, resulting in loss of data loaded to TranSMART.

### Components
This `docker-compose` project consists of the following services:
  - `tmweb`: httpd frontend and reverse-proxy for tomcat
  - `tmapp`: the tomcat server and application
  - `tmdb`: the Postgres database,
  - `tmsolr`: the SOLR installation for faceted search,
  - `tmrserve`: Rserve instance for advanced analyses and
  - `tmload`: a Kettle installation you can use for loading data.

### Loading public datasets

> Note: If you plan on copying an existing TranSMART database to your new docker-based one, please do this first, it is explained in the next section.

You can use the `tmload` image to load data to the database through Kettle. The `tmload` image is built by `docker-compose`, but does not run continuously. Instead, you should start a container based on this image every time you want to load data. The easiest way of loading public datasets is using the pre-curated library hosted by the TranSMART foundation. For more information, please read their [wiki page](https://wiki.transmartfoundation.org/display/transmartwiki/Curated+Data). All environment variables have already been set in the `tmload` image. The following command will fire up a new container based on the tmload image, load the clinical data of the GSE14468 study curated by Elevada, and remove the container after the command is completed:
```
$ docker-compose run --rm tmload make -C samples/postgres load_clinical_ElevadaGSE14468
```

### Copy data from an existing instance

If you have an existing instance of TranSMART running, you may want to copy the database to your new dockerized instance. It is best you do this to an empty, but initialized TranSMART database, since everything will be copied, including things like sequence values.

To start, we will need to expose Postgres to your host machine. Add a `ports` section to the `tmdb` service in the `docker-compose.yml` file, and bind a local port of your choice to port 5432. The `tmdb` service should now look like this (the local port is 9001 in this example):
```YAML
  tmdb:
    build: ./transmart-db
	networks:
      - back
    ports:
      - "9001:5432"
```
Execute `docker-compose up` to recreate the database service for the changes to take effect.

Now we have access to our database via port 9001. Make note of the IP-address where your Docker services are running, it will be referred to as `<docker-ip>`. The port you exposed will be referred to as `<docker-db-port>` (set to 9001 in the above example). Log in to the host where your old database resides. The following set of commands will copy the complete database to your docker database. First you need to become the `postgres` user, then you can copy the existing database to the new one:
```sh
sudo su postgres
pg_dump -a --disable-triggers transmart | psql -h <docker-ip> -p <docker-db-port> -U docker transmart
```
This command will try to log in as user `docker` on docker-based databse, its password is `docker`. In general it is not a good idea to expose our database, so after the copy is complete remove the `ports` section from the `tmdb` service and execute another `docker-compose up` to apply the change.

### Loading your own studies

If you have a study prepared in a suitable format you can use the `tmload` container to load this as well. There is a manual describing the file formats available on the [eTRIKS Portal](https://portal.etriks.org/Portal/), under the 'Downloadable documents' section. The following tutorial will show you how to load clinical data.

Place all relevant files together in a directory, for instance at `$HOME/my_study`. Create a file `load_clinical.sh` and edit it so it contains the following:
```
set -x
$KITCHEN -norep=Y -file=/transmart-data/env/tranSMART-ETL/Kettle/postgres/Kettle-ETL/create_clinical_data.kjb  \
-param:COLUMN_MAP_FILE=columns.txt \
-param:DATA_LOCATION=/my_study/ \
-param:HIGHLIGHT_STUDY=N \
-param:SQLLDR_PATH=/usr/bin/psql \
-param:LOAD_TYPE=I \
-param:RECORD_EXCLUSION_FILE=x \
-param:SECURITY_REQUIRED=Y \
-param:SORT_DIR=$HOME \
-param:STUDY_ID=MY_STUDY \
-param:WORD_MAP_FILE=x \
-param:TOP_NODE='\Public Studies\My Study\'
```
Edit the parameters to match your specific case. Notice we specified the `DATA_LOCATION` to be `/my_study/`, so we will need to mount our study directory to that location in the container. We will also need to connect te container to the network where our database is connected, by default this network will be called `transmartdocker_back`. The default Jave heap size is 512MB, for large datasets it may be required to increase this. This can be done with the `JAVAMAXMEM` environment variable. The following command accomplishes all of these things, and runs the shell script we just created.
```
docker run -t --rm              \
  --network transmartdocker_back \
  -v $HOME/my_study:/my_study    \
  -e JAVAMAXMEM='4096'           \
  transmartdocker_tmload bash /my_study/load_clinical.sh
```
Docker will start a new container based on the `tmload` image, mount your data into it, run the load command and remove the container upon exit. In a different terminal, you can run the following command to keep an eye on the workload of your containers: `docker stats $(docker ps --format={{.Names}})`.
