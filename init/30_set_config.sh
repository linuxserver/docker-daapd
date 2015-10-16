#!/bin/bash
mkdir -p /config/dbase_and_logs /daapd-pidfolder

[[ ! -f "/config/forked-daapd.conf" ]] && cp /defaults/forked-daapd.conf /config/forked-daapd.conf

cp /config/forked-daapd.conf /etc/forked-daapd.conf
chown -R abc:abc /config /daapd-pidfolder /app
