#!/bin/bash

watch_name=mars
to_file=docker_logs_$watch_name.log
count=0
#1day=86400s
period_sec=86400

while true
do
  count=$((count+1))
  echo loop $count >> $to_file
  date >> $to_file
  docker logs $watch_name >> $to_file


  docker cp mars:/root/onos/apache-karaf-3.0.8/data/log/karaf.log karaf-$count.log
  docker cp mars:/root/onos/apache-karaf-3.0.8/data/log/karaf_error.log karaf_error-$count.log

  sleep $period_sec

done
