![https://linuxserver.io](https://www.linuxserver.io/wp-content/uploads/2015/06/linuxserver_medium.png)

The [LinuxServer.io](https://linuxserver.io) team brings you another container release featuring easy user mapping and community support. Find us for support at:
* [forum.linuxserver.io](https://forum.linuxserver.io)
* [IRC](https://www.linuxserver.io/index.php/irc/) on freenode at `#linuxserver.io`
* [Podcast](https://www.linuxserver.io/index.php/category/podcast/) covers everything to do with getting the most from your Linux Server plus a focus on all things Docker and containerisation!

# lsiodev/daapd
![](https://raw.githubusercontent.com/linuxserver/beta-templates/master/lsiodev/img/daapd-git.png)

DAAP (iTunes) media server with support for AirPlay devices, Apple Remote (and compatibles), Spotify, Chromecast, MPD and internet radio. [Forked-daapd](https://ejurgensen.github.io/forked-daapd/)


## Usage

```
docker create --name=daapd -v <path to data>:/config \
-v <path to music>:/music -e PGID=<gid> -e PUID=<uid>  \
--net=host lsiodev/daapd
```

**Parameters**

* `--net=host` - must be run in host mode
* `-v /config` - Where daapd server stores its config and dbase files.
* `-v /music` - map to your music folder
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation

It is based on phusion-baseimage with ssh removed, for shell access whilst the container is running do `docker exec -it daapd /bin/bash`.

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up the application 

Map your music folder, open up itunes on the same LAN to see your music there.
For further setup options of remotes etc, check out the daapd website, [Forked-daapd](https://ejurgensen.github.io/forked-daapd/).

## Logs and shell
* To monitor the logs of the container in realtime `docker logs -f daapd`.
* Shell access whilst the container is running: `docker exec -it daapd /bin/bash`


## Versions
+ **28.02.2016:** Add chromecast support, bump dependency versions.
+ **04.01.2016:** Disable ipv6 by default because in v23.4 it doesn't work in unraid with it set. 
+ **17.12.2015:** Add in spotify support.
+ **25.11.2015:** Initial Release. 

