![http://linuxserver.io](http://www.linuxserver.io/wp-content/uploads/2015/06/linuxserver_medium.png)

The [LinuxServer.io](https://www.linuxserver.io/) team brings you another quality container, easy user mapping and community support. Be sure to checkout our [forums](https://forum.linuxserver.io/index.php) or for real-time support our [IRC](https://www.linuxserver.io/index.php/irc/) on freenode at `#linuxserver.io`.

# lsiodev/daapd
DAAP (iTunes) media server with support for AirPlay devices, Apple Remote (and compatibles), MPD and internet radio. [Forked-daapd](http://ejurgensen.github.io/forked-daapd/)


## Usage

```
docker create --name=daapd -v /etc/localtime:/etc/localtime:ro -v <path to data>:/config -v <path to music>:/music -e PGID=<gid> -e PUID=<uid>  --net=host lsiodev/daapd
```

**Parameters**

* `--net=host` - must be run in host mode
* `-v /etc/localtime` for timesync - *optional*
* `-v /config` - Where daapd server stores its config and dbase files.
* `-v /music` - map to your music folder
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e DAAPD_NAME` - the library name of the daapd server - *optional*
* `-e DAAPD_PORT` - the port number of the daapd server - *optional* 
* `-e MPD_PORT` - the port number of the mpd server - *optional*

It is based on phusion-baseimage with ssh removed, for shell access whilst the container is running do `docker exec -it daapd /bin/bash`.

### User / Group Identifiers

**TL;DR** - The `PGID` and `PUID` values set the user / group you'd like your container to 'run as' to the host OS. This can be a user you've created or even root (not recommended).

Part of what makes our containers work so well is by allowing you to specify your own `PUID` and `PGID`. This avoids nasty permissions errors with relation to data volumes (`-v` flags). When an application is installed on the host OS it is normally added to the common group called users, Docker apps due to the nature of the technology can't be added to this group. So we added this feature to let you easily choose when running your containers.

## Setting up the application 

Map your music folder, open up itunes on the same LAN to see your music there.
For further setup options of remotes etc, check out the daapd website, link above.


## Logs

* To monitor the logs of the container in realtime `docker logs -f daapd`.



## Versions
+ **17.12.2015:** Add in spotify support.
+ **25.11.2015:** Initial Release. 

