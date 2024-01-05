#!/bin/bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

RETRIES=15

until PGPASSWORD=${DB_PASSWORD} psql -h ${DB_HOST} -U ${DB_USERNAME} -d ${DB_SCHEMA} -c "select 1" > /dev/stdout 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "Waiting for zou postgres with username ${DB_USERNAME} on host ${DB_HOST}, $((RETRIES--)) remaining attempts..."
  sleep 3
done

service redis-server start

. /opt/zou/env/bin/activate

zou upgrade-db
zou init-data
zou create-admin admin@example.com --password ${KITSU_DEFAULT_PASSWORD}

service redis-server stop
