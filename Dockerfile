FROM linuxserver/baseimage
MAINTAINER Mark Burford <sparklyballs@gmail.com>

ENV HOME /root

# add files required before we build the packages
RUN mkdir -p /prebuild
ADD prebuild /prebuild/

# set the app folder
RUN mkdir -p /app && \
chown abc:abc -R /app

# set variable containing build dependencies
ENV buildDeps="automake \
gperf \
gettext \
libtool \
yasm \
autoconf \
libgcrypt20-dev \
cmake \
build-essential \
libflac-dev \
antlr3 \
libasound2-dev \
libplist-dev \
libmxml-dev \
zlib1g-dev \
libunistring-dev \
libantlr3c-dev \
git-core \
wget \
libavahi-client-dev \
libconfuse-dev"

# set variable containing runtime dependencies
ENV runtimeDeps="libgcrypt20 \
libavahi-client3 \
libflac8 \
libogg0 \
libantlr3c-3.2-0 \
libasound2 \
libplist1 \
libmxml1 \
libunistring0 \
avahi-daemon \
libconfuse0"

# install build dependencies
RUN mv /prebuild/excludes /etc/dpkg/dpkg.cfg.d/excludes && \
apt-get update && \
apt-get install --no-install-recommends \
$buildDeps -qy && \
apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# build curl package
RUN cd /tmp && \
wget http://curl.haxx.se/download/curl-7.43.0.tar.gz && \
tar xvf curl-* && \
cd curl-* && \
./configure \
--prefix=/usr \
--with-ssl \
--with-zlib && \
make && \
make install && \
rm -rf /tmp/*

# build taglib package
RUN cd /tmp && \
wget http://taglib.github.io/releases/taglib-1.9.1.tar.gz && \
tar xvf taglib-* && \
cd taglib-* && \
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_RELEASE_TYPE=Release . && \
make && \
make install && \
ldconfig && \
rm -rf /tmp/*

# build libevent package
RUN cd /tmp && \
wget --no-check-certificate https://qa.debian.org/watch/sf.php/levent/libevent-2.1.5-beta.tar.gz && \
tar xvf libevent-* && \
cd libevent-*  && \
./configure && \
make && \
make install && \
rm -rf /tmp/*

# build sqlite package
RUN cd /tmp && \
wget http://www.sqlite.org/sqlite-amalgamation-3.7.2.tar.gz && \
tar xvf sqlite-* && \
cd sqlite-* && \
mv /prebuild/Makefile.*  . && \
./configure && \
make && \
make install && \
rm -rf /tmp/*

# build ffmpeg package
RUN cd /tmp && \
git clone https://github.com/FFmpeg/FFmpeg.git && \
cd FFmpeg && \
./configure \
--prefix=/usr \
--enable-nonfree \
--disable-static \
--enable-shared \
--disable-debug && \
make && \
make install && \
rm -rf /tmp/*

# configure and build forked-daapd
RUN cd /tmp && \
git clone https://github.com/ejurgensen/forked-daapd.git && \
cd forked-daapd && \
autoreconf -i && \
./configure \
--enable-itunes \
--enable-mpd \
--enable-lastfm \
--enable-flac \
--enable-musepack \
--prefix=/app \
--sysconfdir=/etc \
--localstatedir=/var && \
make && \
make install && \
cd / && \
rm -rf /tmp/*

# clean build dependencies
RUN apt-get purge --remove \
$buildDeps -y && \
apt-get -y autoremove && \
apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# install runtime dependencies
RUN apt-get update -q && \
apt-get install \
$runtimeDeps -qy && \
apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# tweak config for forked-daapd
RUN sed -i -e 's/\(uid.*=\).*/\1 \"abc\"/g' /etc/forked-daapd.conf && \
sed -i s#"My Music on %h"#"LS.IO Music"#g /etc/forked-daapd.conf && \
sed -i s#/srv/music#/music#g /etc/forked-daapd.conf && \
sed -i s#/var/cache/forked-daapd/songs3.db#/config/dbase_and_logs/songs3.db#g /etc/forked-daapd.conf && \
sed -i s#/var/cache/forked-daapd/cache.db#/config/dbase_and_logs/cache.db#g /etc/forked-daapd.conf && \
sed -i s#/var/log/forked-daapd.log#/config/dbase_and_logs/forked-daapd.log#g /etc/forked-daapd.conf && \
sed -i "/db_path\ =/ s/# *//" /etc/forked-daapd.conf && \
sed -i "/cache_path\ =/ s/# *//" /etc/forked-daapd.conf 

# set volumes
VOLUME /config /music

#Adding Custom files
RUN mkdir -p /defaults 
RUN cp /etc/forked-daapd.conf /defaults/forked-daapd.conf 
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run
RUN chmod -v +x /etc/my_init.d/*.sh

