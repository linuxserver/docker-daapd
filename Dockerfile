FROM linuxserver/baseimage
MAINTAINER sparklyballs <sparklyballs@linuxserver.io>

ENV APTLIST="avahi-daemon libavahi-client3 libantlr3c-3.2-0 libasound2 \
libconfuse0 libflac8 libgcrypt20 libmxml1 libogg0 libplist1 libunistring0"

ENV BUILD_APTLIST="antlr3 autoconf automake build-essential cmake gettext \
git-core gperf libantlr3c-dev libasound2-dev libavahi-client-dev libconfuse-dev \ 
libflac-dev libgcrypt20-dev libplist-dev libtool libunistring-dev libmxml-dev \
wget yasm zlib1g-dev"

# add some files required before we build the packages
ADD prebuild /prebuild/

# install build dependencies
RUN mv /prebuild/excludes /etc/dpkg/dpkg.cfg.d/excludes && \
apt-get update && \
apt-get install --no-install-recommends \
$BUILD_APTLIST -qy && \

# fetch source code
mkdir -p /tmp/curl /tmp/taglib /tmp/libevent /tmp/sqlite && \
curl -o /tmp/curl.tar.gz -L http://curl.haxx.se/download/curl-7.43.0.tar.gz && \
curl -o  /tmp/taglib.tar.gz -L  http://taglib.github.io/releases/taglib-1.9.1.tar.gz && \
curl -o /tmp/libevent.tar.gz  -L https://qa.debian.org/watch/sf.php/levent/libevent-2.1.5-beta.tar.gz && \
curl -o /tmp/sqlite.tar.gz -L http://www.sqlite.org/sqlite-amalgamation-3.7.2.tar.gz && \
tar xvf /tmp/curl.tar.gz -C /tmp/curl --strip-components=1 && \
tar xvf /tmp/taglib.tar.gz -C /tmp/taglib --strip-components=1 && \
tar xvf /tmp/libevent.tar.gz -C /tmp/libevent --strip-components=1 && \
tar xvf /tmp/sqlite.tar.gz -C /tmp/sqlite --strip-components=1 && \
git clone https://github.com/FFmpeg/FFmpeg.git /tmp/FFmpeg && \
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
mv /prebuild/Makefile.*  . && \
./configure && \
make && \
make install && \

# build ffmpeg package
cd /tmp/FFmpeg && \
./configure \
--prefix=/usr \
--enable-nonfree \
--disable-static \
--enable-shared \
--disable-debug && \
make && \
make install && \

# configure and build forked-daapd
cd /tmp/forked-daapd && \
autoreconf -i && \
./configure \
--enable-itunes \
--enable-mpd \
--enable-lastfm \
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
sed -i s#/srv/music#/music#g /defaults/forked-daapd.conf && \
sed -i s#/var/cache/forked-daapd/songs3.db#/config/dbase_and_logs/songs3.db#g /defaults/forked-daapd.conf && \
sed -i s#/var/cache/forked-daapd/cache.db#/config/dbase_and_logs/cache.db#g /defaults/forked-daapd.conf && \
sed -i s#/var/log/forked-daapd.log#/config/dbase_and_logs/forked-daapd.log#g /defaults/forked-daapd.conf && \
sed -i "/db_path\ =/ s/# *//" /defaults/forked-daapd.conf && \
sed -i "/cache_path\ =/ s/# *//" /defaults/forked-daapd.conf

# set volumes
VOLUME /config /music

