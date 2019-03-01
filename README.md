[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)](https://linuxserver.io)

The [LinuxServer.io](https://linuxserver.io) team brings you another container release featuring :-

 * regular and timely application updates
 * easy user mappings (PGID, PUID)
 * custom base image with s6 overlay
 * weekly base OS updates with common layers across the entire LinuxServer.io ecosystem to minimise space usage, down time and bandwidth
 * regular security updates

Find us at:
* [Discord](https://discord.gg/YWrKVTn) - realtime support / chat with the community and the team.
* [IRC](https://irc.linuxserver.io) - on freenode at `#linuxserver.io`. Our primary support channel is Discord.
* [Blog](https://blog.linuxserver.io) - all the things you can do with our containers including How-To guides, opinions and much more!
* [Podcast](https://anchor.fm/linuxserverio) - on hiatus. Coming back soon (late 2018).

# [linuxserver/daapd](https://github.com/linuxserver/docker-daapd)
[![](https://img.shields.io/discord/354974912613449730.svg?logo=discord&label=LSIO%20Discord&style=flat-square)](https://discord.gg/YWrKVTn)
[![](https://images.microbadger.com/badges/version/linuxserver/daapd.svg)](https://microbadger.com/images/linuxserver/daapd "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/linuxserver/daapd.svg)](https://microbadger.com/images/linuxserver/daapd "Get your own version badge on microbadger.com")
![Docker Pulls](https://img.shields.io/docker/pulls/linuxserver/daapd.svg)
![Docker Stars](https://img.shields.io/docker/stars/linuxserver/daapd.svg)
[![Build Status](https://ci.linuxserver.io/buildStatus/icon?job=Docker-Pipeline-Builders/docker-daapd/master)](https://ci.linuxserver.io/job/Docker-Pipeline-Builders/job/docker-daapd/job/master/)
[![](https://lsio-ci.ams3.digitaloceanspaces.com/linuxserver/daapd/latest/badge.svg)](https://lsio-ci.ams3.digitaloceanspaces.com/linuxserver/daapd/latest/index.html)

[Daapd](https://ejurgensen.github.io/forked-daapd/) (iTunes) media server with support for AirPlay devices, Apple Remote (and compatibles), Chromecast, MPD and internet radio.

[![daapd](https://raw.githubusercontent.com/linuxserver/beta-templates/master/lsiodev/img/daapd-git.png)](https://ejurgensen.github.io/forked-daapd/)

## Supported Architectures

Our images support multiple architectures such as `x86-64`, `arm64` and `armhf`. We utilise the docker manifest for multi-platform awareness. More information is available from docker [here](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list) and our announcement [here](https://blog.linuxserver.io/2019/02/21/the-lsio-pipeline-project/). 

Simply pulling `linuxserver/daapd` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |
| arm64 | arm64v8-latest |
| armhf | arm32v6-latest |


## Usage

Here are some example snippets to help you get started creating a container.

### docker

```
docker create \
  --name=daapd \
  --net=host \
  -e PUID=1001 \
  -e PGID=1001 \
  -e TZ=Europe/London \
  -v <path to data>:/config \
  -v <path to music>:/music \
  --restart unless-stopped \
  linuxserver/daapd
```


### docker-compose

Compatible with docker-compose v2 schemas.

```
---
version: "2"
services:
  daapd:
    image: linuxserver/daapd
    container_name: daapd
    network_mode: host
    environment:
      - PUID=1001
      - PGID=1001
      - TZ=Europe/London
    volumes:
      - <path to data>:/config
      - <path to music>:/music
    mem_limit: 4096m
    restart: unless-stopped
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `--net=host` | Shares host networking with container. |
| `-e PUID=1001` | for UserID - see below for explanation |
| `-e PGID=1001` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London. |
| `-v /config` | Where daapd server stores its config and dbase files. |
| `-v /music` | Map to your music folder. |

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1001` and `PGID=1001`, to find yours use `id user` as below:

```
  $ id username
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```


&nbsp;
## Application Setup

Map your music folder, open up itunes on the same LAN to see your music there.

The web interface is available at `http://<your ip>:3689`

For further setup options of remotes etc, check out the daapd website, [Forked-daapd](https://ejurgensen.github.io/forked-daapd/).



## Support Info

* Shell access whilst the container is running: `docker exec -it daapd /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f daapd`
* container version number 
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' daapd`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' linuxserver/daapd`

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (ie. nextcloud, plex), we do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.  
  
Below are the instructions for updating containers:  
  
### Via Docker Run/Create
* Update the image: `docker pull linuxserver/daapd`
* Stop the running container: `docker stop daapd`
* Delete the container: `docker rm daapd`
* Recreate a new container with the same docker create parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* Start the new container: `docker start daapd`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Compose
* Update the image: `docker-compose pull linuxserver/daapd`
* Let compose update containers as necessary: `docker-compose up -d`
* You can also remove the old dangling images: `docker image prune`

## Versions

* **14.01.19:** - Add pipeline logic and multi arch.
* **20.08.18:** - Rebase to alpine linux 3.8.
* **09.06.18:** - Use buildstage and update dependencies.
* **05.03.18:** - Use updated configure ac and disable avcodecsend to hopefully mitigate crashes with V26.
* **25.02.18:** - Query version before pull and build latest release.
* **03.01.18:** - Deprecate cpu_core routine lack of scaling.
* **07.12.17:** - Rebase to alpine linux 3.7.
* **03.12.17:** - Bump to 25.0, cpu core counting routine for faster builds, linting fixes.
* **26.05.17:** - Rebase to alpine linux 3.6.
* **06.02.17:** - Rebase to alpine linux 3.5.
* **10.01.17:** - Bump to 24.2.
* **14.10.16:** - Add version layer information.
* **17.09.16:** - Rebase to alpine linux, remove redundant spotify support, move to main repository.
* **28.02.16:** - Add chromecast support, bump dependency versions.
* **04.01.16:** - Disable ipv6 by default because in v23.4 it doesn't work in unraid with it set.
* **17.12.15:** - Add in spotify support.
* **25.11.15:** - Initial Release.
