#!/bin/bash

TOTALMEM=$(grep MemTotal /proc/meminfo | awk '{print $2;}')
if [ -z $TOTALMEM ]; then
  echo "tunepgsql.sh: Could not auto-detect total memory, setting to default of 8GB"
  TOTALMEM=$((8*1024))
else
  echo "tunepgsql.sh: Total memory auto-detected: $TOTALMEM kB"
fi

cat >> /etc/postgresql/9.3/main/postgresql.conf <<EOD
max_connections = 10
shared_buffers = $((TOTALMEM/4))kB
effective_cache_size = $((TOTALMEM*3/4))kB
work_mem = $((TOTALMEM/4/60))kB  # (Totalmem - shared_buffers) / (max_connections * 3) / 2
maintenance_work_mem = $((TOTALMEM/8))kB
checkpoint_segments = 128
checkpoint_completion_target = 0.9
wal_buffers = 16MB
EOD
