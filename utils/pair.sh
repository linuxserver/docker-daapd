#!/bin/bash

log="~/forked-daapd-docker/var/$1/dbase_and_logs/forked-daapd.log"
shift
pat="Discovered remote '"
n=$(wc -l $log)
curline=$(tail -n +$n $log | tail -1)
echo "$curline"

line=$(while true ; do
  line=$(tail -n +$n $log| grep "$pat" | tail -1)
  if [ "$line" != "$curline" ] ; then
  	if [ "$line" != "" ] ; then
  		echo $line
  		break
  	fi
  fi
  sleep 1
done)

name=$(echo "$line" | sed -e "s/.*$pat//;s/. [(]id .*//")
fname=$(echo "$name"|tr -d " \"':;,!")
echo -n ID:
read id

printf "%s\n$id\n" "$name" >/mnt/music/"$fname".remote

cat /mnt/music/"$fname".remote
