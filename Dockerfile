
FROM linuxserver/baseimage
MAINTAINER Mark Burford <sparklyballs@gmail.com>

ENV HOME /root

# make some folders and add some files required before we build the packages
RUN mkdir -p /prebuild /defaults /app && \
chown abc:abc -R /app
ADD prebuild /prebuild/

# install build dependencies
RUN mv /prebuild/excludes /etc/dpkg/dpkg.cfg.d/excludes && \
apt-get update && \
apt-get install --no-install-recommends \
automake \
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
libconfuse-dev -qy && \

# build curl package
cd /tmp && \
wget http://curl.haxx.se/download/curl-7.43.0.tar.gz && \
tar xvf curl-* && \
cd curl-* && \
./configure \
--prefix=/usr \
--with-ssl \
--with-zlib && \
make && \
make install && \

# build taglib package
cd /tmp && \
wget http://taglib.github.io/releases/taglib-1.9.1.tar.gz && \
tar xvf taglib-* && \
cd taglib-* && \
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_RELEASE_TYPE=Release . && \
make && \
make install && \
ldconfig && \

# build libevent package
cd /tmp && \
wget --no-check-certificate https://qa.debian.org/watch/sf.php/levent/libevent-2.1.5-beta.tar.gz && \
tar xvf libevent-* && \
cd libevent-*  && \
./configure && \
make && \
make install && \

# build sqlite package
cd /tmp && \
wget http://www.sqlite.org/sqlite-amalgamation-3.7.2.tar.gz && \
tar xvf sqlite-* && \
cd sqlite-* && \
mv /prebuild/Makefile.*  . && \
./configure && \
make && \
make install && \

# build ffmpeg package
cd /tmp && \
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

# configure and build forked-daapd
cd /tmp && \
git clone https://github.com/ejurgensen/forked-daapd.git && \
cd forked-daapd && \
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
cp /etc/forked-daapd.conf /defaults/forked-daapd.conf && \
cd / && \

# clean build dependencies
apt-get purge --remove \
automake \
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
libconfuse-dev -y && \
apt-get -y autoremove && \

# install runtime dependencies
apt-get update -q && \
apt-get install \
libgcrypt20 \
libavahi-client3 \
libflac8 \
libogg0 \
libantlr3c-3.2-0 \
libasound2 \
libplist1 \
libmxml1 \
libunistring0 \
avahi-daemon \
libconfuse0 -qy && \
apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# set volumes
VOLUME /config /music

#Adding Custom files
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run /etc/my_init.d/*.sh && \

# tweak config for forked-daapd
sed -i -e 's/\(uid.*=\).*/\1 \"abc\"/g' /etc/forked-daapd.conf && \
sed -i s#"My Music on %h"#"LS.IO Music"#g /etc/forked-daapd.conf && \
sed -i s#/srv/music#/music#g /etc/forked-daapd.conf && \
sed -i s#/var/cache/forked-daapd/songs3.db#/config/dbase_and_logs/songs3.db#g /etc/forked-daapd.conf && \
sed -i s#/var/cache/forked-daapd/cache.db#/config/dbase_and_logs/cache.db#g /etc/forked-daapd.conf && \
sed -i s#/var/log/forked-daapd.log#/config/dbase_and_logs/forked-daapd.log#g /etc/forked-daapd.conf && \
sed -i "/db_path\ =/ s/# *//" /etc/forked-daapd.conf && \
sed -i "/cache_path\ =/ s/# *//" /etc/forked-daapd.conf
