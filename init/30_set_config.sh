#!/bin/bash

if [ ! -d "/config/dbase_and_logs" ]; then
mkdir -p /config/dbase_and_logs
fi

if [ ! -f "/config/forked-daapd.conf" ]; then
cp /defaults/forked-daapd.conf /config/forked-daapd.conf
fi

if [ ! -d "/daapd-pidfolder" ]; then
mkdir -p /daapd-pidfolder
fi

cp /config/forked-daapd.conf /etc/forked-daapd.conf
chown -R abc:abc /config /daapd-pidfolder /app
