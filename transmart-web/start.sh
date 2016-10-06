#!/bin/bash

# if you get error messages regarding unable to resolve the name 'localhost', uncomment
# this to switch the go resolver, as the order might be dns server first, file second
# export GODEBUG=netdns=cgo
/usr/bin/filebeat -e -v -c /etc/filebeat/filebeat.yml &
httpd-foreground
