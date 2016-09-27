#!/bin/bash

/usr/bin/filebeat -e -c /etc/filebeat/filebeat.yml &
httpd-foreground
