FROM lsiobase/alpine
MAINTAINER sparklyballs

# package version
ARG FORKED_DAAPD_NAME="forked-daapd"
ARG FORKED_DAAPD_VER="24.1"

# environment settings
ARG ANTLR_WWW="http://www.antlr3.org/download/antlr-3.4-complete.jar"
ARG FORKED_DAAPD_ROOT="/tmp/source"
ARG FORKED_DAAPD_SRC="${FORKED_DAAPD_ROOT}/forked-daapd"
ARG FORKED_DAAPD_WWW="https://github.com/ejurgensen/forked-daapd/archive/${FORKED_DAAPD_VER}.tar.gz"

# install build packages
RUN \
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
	libtool \
	libunistring-dev \
	make \
	openjdk8-jre-base \
	protobuf-c-dev \
	sqlite-dev \
	taglib-dev \
	tar && \
 apk add --no-cache --virtual=build-dependencies2 \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	libantlr3c-dev \
	libavl-dev \
	mxml-dev && \

# make folders and antlr wrapper
 mkdir -p \
	"${FORKED_DAAPD_SRC}" && \
 echo \
	"#!/bin/bash" > "${FORKED_DAAPD_ROOT}/antlr3" && \
 echo \
	"exec java -cp $FORKED_DAAPD_ROOT/antlr-3.4-complete.jar org.antlr.Tool \"\$@\"" >> "${FORKED_DAAPD_ROOT}/antlr3" && \
 chmod a+x "${FORKED_DAAPD_ROOT}/antlr3" && \

# fetch source
 curl -o \
 "${FORKED_DAAPD_ROOT}/antlr-3.4-complete.jar" -L \
	"${ANTLR_WWW}" && \
 curl -o \
 "${FORKED_DAAPD_ROOT}/forked.tar.gz" -L \
	"${FORKED_DAAPD_WWW}" && \
 tar xf "${FORKED_DAAPD_ROOT}/forked.tar.gz" -C \
	"${FORKED_DAAPD_SRC}" --strip-components=1 && \

# configure and compile source
 export PATH="$FORKED_DAAPD_ROOT:$PATH" && \
 cd "${FORKED_DAAPD_SRC}" && \
 autoreconf -i -v && \
 ./configure \
	--build=$CBUILD \
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

# cleanup
 apk del --purge \
	build-dependencies \
	build-dependencies2 && \
 rm -rf \
	/tmp/*

# install runtime packages
RUN \
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
	libunistring \
	protobuf-c \
	sqlite \
	sqlite-libs && \
 apk add --no-cache \
 --repository http://nl.alpinelinux.org/alpine/edge/testing \
	libantlr3c \
	mxml

# copy local files
COPY root/ /

# ports and volumes
VOLUME /config /music
