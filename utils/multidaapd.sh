#!/bin/bash

SERVER_DEFINITIONS="$1"
VAR="$2"
BASEPORT=22000
PGID=daapd
PUID=daapd
HEADERLINE=$(printf "%s" 'DAAPD name;Media directories')

function usage() {
	echo "Usage: $0 <server file> <var base directory>"
	exit 1
}

if [ ! -f "$SERVER_DEFINITIONS" ] ; then
	echo "<server file> not accessible at [$SERVER_DEFINITIONS]"
	usage
fi

if [ ! -d "$VAR" ] ; then
	echo "<var base directory> not accessible at [$VAR]"
	usage
fi

port=$BASEPORT
i=0
cat "$SERVER_DEFINITIONS" | while read line ; do
	if [ $i = 0 ] ; then
		if [ "$line" = "$HEADERLINE" ] ; then
			i=$((i+1))
			continue
		fi
		printf "<server file> must contain a header line:\n%s\nFound:\n[%s]\n" "$HEADERLINE" "$line"
		usage
	fi 
	IFS=';' read -a columns <<< "$line"
	name=${columns[0]}
	mediadirs=${columns[1]}
	vardir="${VAR}/$i"
	mkdir "$vardir" 2>/dev/null
	if [ ! -d "$vardir" ] ; then
		echo "Cannot create: $vardir"
		exit 1
	fi
	if [ ! -d "$mediadirs" ] ; then
		echo "Cannot access: $mediadirs"
		exit 1
	fi
	echo "Starting $name"
#	        --lxc-conf='lxc.cgroup.devices.allow = c 116:* rwm' \
#		--privileged \
#    		-v /dev/snd:/dev/snd \
	docker create \
		--name=daapd"$i" \
		--group-add audio \
		--device=/dev/snd:/dev/snd \
		-v /etc/localtime:/etc/localtime:ro \
		-v "$vardir":/config \
		-v "$mediadirs":/srv/music \
		-e PGID=$PGID \
		-e PUID=$PUID \
		-e DAAPD_NAME="$name" \
		-e DAAPD_PORT=$((port+2*i-2)) \
		-e MPD_PORT=$((port+2*i-1)) \
		--net=host \
		polarspace/docker-daapd
	i=$((i+1))
done
