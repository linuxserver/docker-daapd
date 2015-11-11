#!/bin/bash

[[ ! -f /config/forked-daapd.conf ]] && cp /defaults/forked-daapd.conf /config/forked-daapd.conf
[[ ! -L /etc/forked-daapd.conf && -f /etc/forked-daapd.conf ]] && rm /etc/forked-daapd.conf
[[ ! -L /etc/forked-daapd.conf ]] && ln -s /config/forked-daapd.conf /etc/forked-daapd.conf

mkdir -p /config/dbase_and_logs /daapd-pidfolder
chown -R abc:abc /config /daapd-pidfolder /app
