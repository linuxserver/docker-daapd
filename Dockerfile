FROM ghcr.io/linuxserver/baseimage-alpine:3.19 as buildstage
############## build stage ##############

ARG DAAPD_RELEASE

RUN \
  echo "**** install build packages ****" && \
  apk add -U --update --no-cache \
    alsa-lib-dev \
    autoconf \
    automake \
    avahi-dev \
    bison \
    bsd-compat-headers \
    confuse-dev \
    curl-dev \
    ffmpeg-dev \
    file \
    flac-dev \
    flex \
    g++ \
    gcc \
    gettext-dev \
    gnutls-dev \
    gperf \
    json-c-dev \
    libevent-dev \
    libgcrypt-dev \
    libogg-dev \
    libplist-dev \
    openssl-dev \
    libsodium-dev \
    libtool \
    libunistring-dev \
    libwebsockets-dev \
    make \
    mxml-dev \
    openjdk8-jre-base \
    protobuf-c-dev \
    sqlite-dev \
    taglib-dev && \
  mkdir -p \
    /tmp/source/owntone && \
  echo "**** compile owntone-server ****" && \
  if [ -z ${DAAPD_RELEASE+x} ]; then \
    DAAPD_RELEASE=$(curl -sX GET "https://api.github.com/repos/owntone/owntone-server/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
  /tmp/source/owntone.tar.gz -L \
    "https://github.com/owntone/owntone-server/archive/${DAAPD_RELEASE}.tar.gz" && \
  tar xf /tmp/source/owntone.tar.gz -C \
    /tmp/source/owntone --strip-components=1 && \
  export PATH="/tmp/source:$PATH" && \
  cd /tmp/source/owntone && \
  autoreconf -i -v && \
  ./configure \
    --build=$CBUILD \
    --enable-chromecast \
    --enable-lastfm \
    --enable-mpd \
    --host=$CHOST \
    --infodir=/usr/share/info \
    --localstatedir=/var \
    --mandir=/usr/share/man \
    --prefix=/usr \
    --sysconfdir=/etc && \
  make && \
  make DESTDIR=/tmp/daapd-build install && \
  mv /tmp/daapd-build/etc/owntone.conf /tmp/daapd-build/etc/owntone.conf.orig && \
  rm -rf /tmp/daapd-build/var
############## runtime stage ##############
FROM ghcr.io/linuxserver/baseimage-alpine:3.19

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="BernsteinA"

RUN \
  echo "**** install runtime packages ****" && \
  apk add -U --update --no-cache \
    avahi \
    confuse \
    dbus \
    ffmpeg \
    gnutls \
    json-c \
    libevent \
    libgcrypt \
    libplist \
    libsodium \
    libunistring \
    libuuid \
    libwebsockets \
    mxml \
    protobuf-c \
    sqlite \
    sqlite-libs && \
  apk add -U --update --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/testing \
    librespot && \
  mkdir -p /music

# copy buildstage and local files
COPY --from=buildstage /tmp/daapd-build/ /
COPY root/ /

# ports and volumes
EXPOSE 3689

VOLUME /config /music
