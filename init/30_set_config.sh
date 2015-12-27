#!/bin/bash

[[ ! -f /config/forked-daapd.conf ]] && cp /defaults/forked-daapd.conf /config/forked-daapd.conf
[[ ! -L /etc/forked-daapd.conf && -f /etc/forked-daapd.conf ]] && rm /etc/forked-daapd.conf
[[ ! -L /etc/forked-daapd.conf ]] && ln -s /config/forked-daapd.conf /etc/forked-daapd.conf

sed -i -e "s:^[# \t]*port[ \t=]*3689:\tport = ${DAAPD_PORT:-3689}:" /etc/forked-daapd.conf
sed -i -e "s:^[# \t]*port[ \t=]*= 6600:\tport = ${MPD_PORT:-6600}:" /etc/forked-daapd.conf
sed -i -e "s#^[# \t]*name[ \t=].*#\tname=\"${DAAPD_NAME:-My Music on %h}\"#" /etc/forked-daapd.conf

usermod -a -G audio abc

mkdir -p /config/dbase_and_logs /daapd-pidfolder
chown -R abc:abc /config /daapd-pidfolder /app
