#!/bin/bash

TOTALMEM=$(grep MemTotal /proc/meminfo | awk '{print $2;}')
if ! [[ "$TOTALMEM" =~ ^[0-9]+$ ]]; then
  echo "tunepgsql.sh: Could not auto-detect total memory: $TOTALMEM, setting to default of 8GB"
  TOTALMEM=$((8*1024*1024))
else
  echo "tunepgsql.sh: Total memory auto-detected: $TOTALMEM kB"
fi

cat >> /etc/postgresql/9.3/main/postgresql.conf <<EOD
max_connections = 50
shared_buffers = $((TOTALMEM/4))kB
effective_cache_size = $((TOTALMEM*3/4))kB
work_mem = $((TOTALMEM/4/300))kB  # (Totalmem - shared_buffers) / (max_connections * 3) / 2
maintenance_work_mem = $((TOTALMEM/8))kB
checkpoint_segments = 128
checkpoint_completion_target = 0.9
wal_buffers = 16MB
log_destination = 'stderr,csvlog'
logging_collector = on
log_directory = pg_log
log_file_mode = 0666
log_min_duration_statement = 1000
log_statement = 'none'
EOD
