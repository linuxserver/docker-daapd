FROM lsiobase/xenial
MAINTAINER sparklyballs

# set source versions
ARG CURL_VER="7.49.1"
ARG FORKED_VER="24.1"
ARG LIBEVENT_VER="2.1.5-beta"
ARG SQLITE_VER="autoconf-3130000"
ARG TAGLIB_VER="1.9.1"

# package variables and environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ARG BUILD_PACKAGES="\
	antlr3 \
	autoconf \
	automake \
	autotools-dev \
	binutils \
	cmake \
	g++ \
	gcc \
	gawk \
	gettext \
	git-core \
	gperf \
	libantlr3c-dev \
	libasound2-dev \
	libavahi-client-dev  \
	libavcodec-dev \
	libavfilter-dev \
	libavformat-dev \
	libavutil-dev \
	libconfuse-dev \
	libgcrypt20-dev \
	libgnutls-dev \
	libjson-c-dev \
	libmxml-dev \
	libplist-dev \
	libprotobuf-c-dev \
	libreadline-dev \
	libssh-dev \
	libswscale-dev \
	libtool \
	libunistring-dev \
	make \
	wget \
	zlib1g-dev"
ARG RUNTIME_PACKAGES="\
	avahi-daemon \
	libantlr3c-3.2-0 \
	libavahi-client3 \
	libav-tools \
	libconfuse0 \
	libgcrypt20 \
	libgnutlsxx28 \
	libjson-c2 \
	libmp3lame0 \
	libmxml1 \
	libplist3 \
	libprotobuf-c1 \
	libunistring0 \
	openssl"

# install build and runtime dependencies
RUN \
 apt-get update && \
 apt-get install -y \
	${BUILD_PACKAGES} \
	${RUNTIME_PACKAGES} && \

# make folders for source codes
 mkdir -p \
	/tmp/curl-source \
	/tmp/forked-source \
	/tmp/libevent-source \
	/tmp/spotify-source \
	/tmp/sqlite-source \
	/tmp/taglib-source && \

# fetch source codes
 curl -o \
 /tmp/curl.tar.gz -L \
	http://curl.haxx.se/download/curl-"${CURL_VER}".tar.gz && \
 curl -o \
 /tmp/forked.tar.gz -L \
	https://github.com/ejurgensen/forked-daapd/archive/"${FORKED_VER}".tar.gz && \
 curl -o \
 /tmp/libevent.tar.gz  -L \
	https://qa.debian.org/watch/sf.php/levent/libevent-"${LIBEVENT_VER}".tar.gz && \
 curl -o \
 /tmp/spotify_tar.gz -L \
	https://developer.spotify.com/download/libspotify/libspotify-12.1.51-Linux-x86_64-release.tar.gz && \
 curl -o \
 /tmp/sqlite.tar.gz -L \
	https://www.sqlite.org/2016/sqlite-"${SQLITE_VER}".tar.gz && \
 curl -o  \
 /tmp/taglib.tar.gz -L  \
	http://taglib.github.io/releases/taglib-$TAGLIB_VER.tar.gz && \

# unpack source codes
 tar xvf \
 /tmp/curl.tar.gz -C \
	/tmp/curl-source --strip-components=1 && \
 tar xvf \
 /tmp/forked.tar.gz -C \
	/tmp/forked-source --strip-components=1 && \
 tar xvf \
 /tmp/libevent.tar.gz -C \
	/tmp/libevent-source --strip-components=1 && \
 tar xvf \
 /tmp/spotify_tar.gz -C \
	/tmp/spotify-source --strip-components=1 && \
 tar xvf \
 /tmp/sqlite.tar.gz -C \
	/tmp/sqlite-source --strip-components=1 && \
 tar xvf \
 /tmp/taglib.tar.gz -C \
	/tmp/taglib-source  --strip-components=1 && \

# build curl package
 cd /tmp/curl-source && \
 ./configure \
	--prefix=/usr \
	--with-ssl \
	--with-zlib && \
 make && \
 make install && \

# build taglib package
 cd /tmp/taglib-source && \
 cmake \
	-DCMAKE_INSTALL_PREFIX=/usr/local \
	-DCMAKE_RELEASE_TYPE=Release . && \
 make && \
 make install && \
 ldconfig && \

# build libevent package
 cd /tmp/libevent-source && \
 ./configure && \
 make && \
 make install && \

# build sqlite package
 cd /tmp/sqlite-source && \
 sed -i \
	'/^AM_CFLAGS =/ s/$/ -DSQLITE_ENABLE_UNLOCK_NOTIFY/' /tmp/sqlite-source/Makefile.in && \
 sed -i \
	'/^AM_CFLAGS =/ s/$/ -DSQLITE_ENABLE_UNLOCK_NOTIFY/' /tmp/sqlite-source/Makefile.am && \
 ./configure && \
 make && \
 make install && \

# build spotify
 cd /tmp/spotify-source && \
 make install \
	prefix=/usr && \

# configure and build forked-daapd
 cd /tmp/forked-source && \
 autoreconf -i && \
 ./configure \
	--enable-chromecast \
	--enable-itunes \
	--enable-lastfm \
	--enable-mpd \
	--enable-spotify \
	--localstatedir=/var \
	--prefix=/app \
	--sysconfdir=/etc && \
 make && \
 make install && \

# clean build dependencies
 apt-get purge --remove -y \
	${BUILD_PACKAGES} && \
 apt-get autoremove -y && \
 apt-get autoclean -y && \

# reinstall runtime dependencies, above purge may have deleted needed packages.
 apt-get update && \
 apt-get install -y \
	${RUNTIME_PACKAGES} && \

# cleanup
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# ports and volumes
VOLUME /config /music
