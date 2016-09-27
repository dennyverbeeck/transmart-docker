#!/bin/bash

# remove the pid file, this can be left here by an ungraceful container stop
rm -f /var/lib/postgresql/9.3/main/postmaster.pid

cd /var/lib/postgresql/9.3/main/pg_log && /usr/bin/filebeat -e -c /etc/filebeat/filebeat.yml &
/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf
