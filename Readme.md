# transmart-docker

The purpose of this repository is to provide a Docker-based installation of TranSMART. Since TranSMART consists of multiple services, `docker-compose` is used to build images for the different services and manage the links between them. Apache is used to reverse proxy requests to the Tomcat server. This branch of the repository contains [eTRIKS](https://www.etriks.org/) version `3.0`, and the default settings are geared towards deployment on a server. If you want to try TranSMART on your local machine, please use the `-local` version of this branch instead.

### Usage
Clone this repository to an easily accessible location on your server. There are a few configuration files to be modified before building the images. The first is `transmart-app/Config.groovy`. Modify the line 
```
def transmartURL      = "http://localhost/transmart"
``` 
to the actual URL of your server. Additionally open the file `transmart-web/httpd-vhosts.cfg` and modify the `ServerAdmin` directive to the e-mail address of your server administrator. It should be sufficient now to execute `docker-compose up` in the root directory of the repository. This will automatically download all the necessary components, build images, create the network and run the containers. When you see a line like this

```
tmapp_1     | INFO: Server startup in 40888 ms
```

this means the services are up and running. Verify this by running `docker-compose ps`:

```
$ docker-compose ps
           Name                         Command               State                  Ports
---------------------------------------------------------------------------------------------------------
transmartdocker_tmapp_1      catalina.sh run                  Up       127.0.0.1:8009->8009/tcp, 8080/tcp
transmartdocker_tmdb_1       /usr/lib/postgresql/9.3/bi ...   Up       127.0.0.1:5432->5432/tcp
transmartdocker_tmload_1     echo Use the make commands ...   Exit 0
transmartdocker_tmrserve_1   /transmart-data/R/root/lib ...   Up       6311/tcp
transmartdocker_tmsolr_1     java -jar start.jar              Up       8983/tcp
transmartdocker_tmweb_1      httpd-foreground                 Up       
```

This overview gives us a lot of information. We can see all services except for `tmload` are up and running (more on `tmload` later). We also see that port 5432 of our own machine is forwarded to port 5432 of the `tmdb` container, and that port 8009 is forwarded to port 8009 of the `tmapp` container. Exposing the database port to the localhost allows us to connect to it using tools like `psql`. Port 8009 is used by the `tmweb` container to proxy requests to the web application over the `ajp` protocol. Point your browser to your server URL to see your installation running. By default you can log in with username and password admin. Change the password for the admin user as soon as possible.

After your first `docker-compose up` command, use `docker-compose stop` and `docker-compose start` to stop and start the TranSMART stack. Using `docker-compose down` **will delete all volumes as well**, resulting in loss of data loaded to TranSMART.

It is advisable to tune some Postgres settings based on your hardware. There is a script included in the image that sets sensible defaults based on your hardware configuration. You can run the script by executing 
```
docker exec transmartdocker_tmdb_1 /usr/bin/tunepgsql.sh
```
Restart the container to apply the settings: 
```docker restart transmartdocker_tmdb_1```

### Components
This `docker-compose` project consists of the following services:
  - `tmweb`: httpd frontend and reverse-proxy for tomcat, this container is connected to the `host` network. This allows to see the actual client IPs in the Apache logs rather than the IP of the docker bridge.
  - `tmapp`: the tomcat server and application,
  - `tmdb`: the Postgres database, the database in this image has a superadmin with username docker and password docker
  - `tmsolr`: the SOLR installation for faceted search,
  - `tmrserve`: Rserve instance for advanced analyses and,
  - `tmload`: a Kettle installation you can use for loading data.

### Loading public datasets

> Note: If you plan on copying an existing TranSMART database to your new docker-based one, please do this first, it is explained in the next section.

You can use the `tmload` image to load data to the database through Kettle. The `tmload` image is built by `docker-compose`, but does not run continuously. Instead, you should start a container based on this image every time you want to load data. The easiest way of loading public datasets is using the pre-curated library hosted by the TranSMART foundation. For more information, please read their [wiki page](https://wiki.transmartfoundation.org/display/transmartwiki/Curated+Data). All environment variables have already been set in the `tmload` image. The following command will fire up a new container based on the tmload image, load the clinical data of the GSE14468 study curated by Elevada, and remove the container after the command is completed:
```
$ docker-compose run --rm tmload make -C samples/postgres load_clinical_ElevadaGSE14468
```

### Copy data from an existing instance

If you have an existing instance of TranSMART running, you may want to copy the database to your new dockerized instance. It is best you do this to an empty, but initialized TranSMART database, since everything will be copied, including things like sequence values. The most portable way of copying is using `pg_dump` to dump all data from the old database in the form of attribute inserts, and use this file to load data into the new database. Using the `--attribute-inserts` option ensures that a single failed insertion (e.g. a row that exists in the new database, like the definition of the admin user) does not cause the whole table not to be loaded. It also guards against minor schema changes, such as a column with default value that was added to an existing table. On the host where the old database resides, log in as the `postgres` user (or any other means that allows you access to the database) and execute the following:

```sh
pg_dump -a --disable-triggers --attribute-inserts transmart | gzip > tmdump.sql.gz
```

Depending on the size of your database, this can take some time. When the command is finished, you will have a file called `tmdump.sql.gz`. This is the compressed file containing all SQL statements necessary to restore your database. Copy this file to the host running the `transmart-db` container. The default configuration exposes port 5432 of the container to localhost, so you should be able to connect to it. Use the following command to unzip the file and immediately send the SQL commands to the database:

```sh
zcat tmdump.sql.gz | psql -h 127.0.0.1 -U docker transmart
```

You will be asked for the password, which is docker. After the command finishes, you should have all your old data in your new TranSMART server!

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
Edit the parameters to match your specific case. Notice we specified the `DATA_LOCATION` to be `/my_study/`, so we will need to mount our study directory to that location in the container. We will also need to connect te container to the network where our database is connected, by default this network will be called `transmartdocker_default`. The default Jave heap size is 512MB, for large datasets it may be required to increase this. This can be done with the `JAVAMAXMEM` environment variable. The following command accomplishes all of these things, and runs the shell script we just created.
```
docker run -t --rm              \
  --network transmartdocker_default \
  -v $HOME/my_study:/my_study    \
  -e JAVAMAXMEM='4096'           \
  transmartdocker_tmload bash /my_study/load_clinical.sh
```
Docker will start a new container based on the `tmload` image, mount your data into it, run the load command and remove the container upon exit. In a different terminal, you can run the following command to keep an eye on the workload of your containers: `docker stats $(docker ps --format={{.Names}})`.
