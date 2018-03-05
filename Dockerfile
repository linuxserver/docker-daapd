FROM lsiobase/alpine:3.7

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	alsa-lib-dev \
	autoconf \
	automake \
	avahi-dev \
	bash \
	bsd-compat-headers \
	confuse-dev \
	curl \
	curl-dev \
	ffmpeg-dev \
	file \
	flac-dev \
	g++ \
	gcc \
	gettext-dev \
	gnutls-dev \
	gperf \
	json-c-dev \
	libcurl \
	libevent-dev \
	libgcrypt-dev \
	libogg-dev \
	libplist-dev \
	libsodium-dev \
	libtool \
	libunistring-dev \
	make \
	openjdk8-jre-base \
	protobuf-c-dev \
	sqlite-dev \
	taglib-dev \
	tar && \
 apk add --no-cache --virtual=build-dependencies \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	libantlr3c-dev \
	mxml-dev && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	avahi \
	confuse \
	dbus \
	ffmpeg \
	json-c \
	libcurl \
	libevent \
	libgcrypt \
	libplist \
	libsodium \
	libunistring \
	protobuf-c \
	sqlite \
	sqlite-libs && \
 apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	libantlr3c \
	mxml && \
 echo "**** make antlr wrapper and compile forked-daapd ****" && \
 mkdir -p \
	/tmp/source/forked-daapd && \
 echo \
	"#!/bin/bash" > /tmp/source/antlr3 && \
 echo \
	"exec java -cp /tmp/source/antlr-3.4-complete.jar org.antlr.Tool \"\$@\"" >> /tmp/source/antlr3 && \
 chmod a+x /tmp/source/antlr3 && \
 curl -o \
 /tmp/source/antlr-3.4-complete.jar -L \
	http://www.antlr3.org/download/antlr-3.4-complete.jar && \
 DAAPD_VER=$(curl -sX GET "https://api.github.com/repos/ejurgensen/forked-daapd/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl -o \
 /tmp/source/forked.tar.gz -L \
	"https://github.com/ejurgensen/forked-daapd/archive/${DAAPD_VER}.tar.gz" && \
 tar xf /tmp/source/forked.tar.gz -C \
	/tmp/source/forked-daapd --strip-components=1 && \
 export PATH="/tmp/source:$PATH" && \
 cd /tmp/source/forked-daapd && \
 echo "**** fetch updated configure file if version equals 26.0 ****" && \
 if [ $DAAPD_VER==26.0 ]; then \
	curl -o /tmp/source/forked-daapd/configure.ac -L \
	https://raw.githubusercontent.com/ejurgensen/forked-daapd/master/configure.ac; fi && \
 autoreconf -i -v && \
 ./configure \
	--build=$CBUILD \
	--disable-avcodecsend \
	--enable-chromecast \
	--enable-itunes \
	--enable-lastfm \
	--enable-mpd \
	--host=$CHOST \
	--infodir=/usr/share/info \
	--localstatedir=/var \
	--mandir=/usr/share/man \
	--prefix=/app \
	--sysconfdir=/etc && \
 make && \
 make install && \
 cp /etc/forked-daapd.conf /etc/forked-daapd.conf.orig && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 3689
VOLUME /config /music
