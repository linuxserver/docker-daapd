FROM linuxserver/baseimage
MAINTAINER sparklyballs <sparklyballs@linuxserver.io>

ENV APTLIST="avahi-daemon libavahi-client3 libav-tools libantlr3c-3.2-0 \
libconfuse0 libgcrypt20 libmp3lame0 libmxml1 libplist1 libunistring0"

ENV BUILD_APTLIST="antlr3 autoconf autotools-dev build-essential cmake gawk gettext git-core gperf libasound2-dev libantlr3c-dev \
libavahi-client-dev  libavcodec-dev libavfilter-dev libavformat-dev libavutil-dev libconfuse-dev \
libgcrypt11-dev libplist-dev libtool libunistring-dev libswscale-dev libmxml-dev zlib1g-dev"

# set source versions
ENV CURL_VER="7.45.0" LIBEVENT_VER="2.1.5-beta" TAGLIB_VER="1.9.1" SQLITE_VER="autoconf-3090200"

# add excludes file
ADD defaults/excludes /etc/dpkg/dpkg.cfg.d/excludes

# install build dependencies
RUN apt-get update && \
apt-get install $APTLIST \
$BUILD_APTLIST -qy && \

# fetch source code
mkdir -p /tmp/curl /tmp/taglib /tmp/libevent /tmp/sqlite /tmp/spotify && \
curl -o /tmp/curl.tar.gz -L http://curl.haxx.se/download/curl-$CURL_VER.tar.gz && \
curl -o  /tmp/taglib.tar.gz -L  http://taglib.github.io/releases/taglib-$TAGLIB_VER.tar.gz && \
curl -o /tmp/libevent.tar.gz  -L https://qa.debian.org/watch/sf.php/levent/libevent-$LIBEVENT_VER.tar.gz && \
curl -o /tmp/sqlite.tar.gz -L https://www.sqlite.org/2015/sqlite-$SQLITE_VER.tar.gz && \
curl -o /tmp/spotify_tar.gz -L https://developer.spotify.com/download/libspotify/libspotify-12.1.51-Linux-x86_64-release.tar.gz && \
tar xvf /tmp/curl.tar.gz -C /tmp/curl --strip-components=1 && \
tar xvf /tmp/taglib.tar.gz -C /tmp/taglib --strip-components=1 && \
tar xvf /tmp/libevent.tar.gz -C /tmp/libevent --strip-components=1 && \
tar xvf /tmp/sqlite.tar.gz -C /tmp/sqlite --strip-components=1 && \
tar xvf /tmp/spotify_tar.gz -C /tmp/spotify --strip-components=1 && \
git clone https://github.com/ejurgensen/forked-daapd.git /tmp/forked-daapd && \

# build curl package
cd /tmp/curl && \
./configure \
--prefix=/usr \
--with-ssl \
--with-zlib && \
make && \
make install && \

# build taglib package
cd /tmp/taglib && \
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_RELEASE_TYPE=Release . && \
make && \
make install && \
ldconfig && \

# build libevent package
cd /tmp/libevent && \
./configure && \
make && \
make install && \

# build sqlite package
cd /tmp/sqlite && \
sed -i '/^AM_CFLAGS =/ s/$/ -DSQLITE_ENABLE_UNLOCK_NOTIFY/' /tmp/sqlite/Makefile.in && \
sed -i '/^AM_CFLAGS =/ s/$/ -DSQLITE_ENABLE_UNLOCK_NOTIFY/' /tmp/sqlite/Makefile.am && \
./configure && \
make && \
make install && \

# build spotify
cd /tmp/spotify && \
make install prefix=/usr && \

# configure and build forked-daapd
cd /tmp/forked-daapd && \
autoreconf -i && \
./configure \
--enable-itunes \
--enable-mpd \
--enable-lastfm \
--enable-spotify \
--prefix=/app \
--sysconfdir=/etc \
--localstatedir=/var && \
make && \
make install && \
cd / && \

# clean build dependencies
apt-get purge --remove \
$BUILD_APTLIST -y && \
apt-get -y autoremove && \

# install runtime dependencies
apt-get update -q && \
apt-get install \
$APTLIST -qy && \

# cleanup
apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Adding Custom files
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run /etc/my_init.d/*.sh && \

# tweak config for forked-daapd
mv /etc/forked-daapd.conf /defaults/forked-daapd.conf && \
sed -i -e 's/\(uid.*=\).*/\1 \"abc\"/g' /defaults/forked-daapd.conf && \
sed -i s#"My Music on %h"#"LS.IO Music"#g /defaults/forked-daapd.conf && \
sed -i s#"ipv6 = yes"#"ipv6 = no"#g /defaults/forked-daapd.conf && \
sed -i s#/srv/music#/music#g /defaults/forked-daapd.conf && \
sed -i s#/var/cache/forked-daapd/songs3.db#/config/dbase_and_logs/songs3.db#g /defaults/forked-daapd.conf && \
sed -i s#/var/cache/forked-daapd/cache.db#/config/dbase_and_logs/cache.db#g /defaults/forked-daapd.conf && \
sed -i s#/var/log/forked-daapd.log#/config/dbase_and_logs/forked-daapd.log#g /defaults/forked-daapd.conf && \
sed -i "/db_path\ =/ s/# *//" /defaults/forked-daapd.conf && \
sed -i "/cache_path\ =/ s/# *//" /defaults/forked-daapd.conf

# set volumes
VOLUME /config /music

