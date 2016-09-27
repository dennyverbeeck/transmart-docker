#!/bin/bash

# wait for Elasticsearch to start up before either starting Kibana (if enabled)
# or attempting to stream its log file
# - https://github.com/elasticsearch/kibana/issues/3077
counter=0
while [ ! "$(curl localhost:9200 2> /dev/null)" -a $counter -lt 30  ]; do
  sleep 1
  ((counter++))
  echo "waiting for Elasticsearch to be up ($counter/30)"
done

curl -XPUT 'http://localhost:9200/_template/filebeat?pretty' -d@/etc/filebeat/filebeat.template.json
echo "Filebeat template loaded"
