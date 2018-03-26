FROM alpine:latest
MAINTAINER Thomas Spicer <thomas@openbridge.com>

ENV RCLONE_VERSION="current"
ENV RCLONE_TYPE="amd64"
ENV BUILD_DEPS \
      wget@community \
      linux-headers@community \
      unzip@community \
      fuse@community

RUN set -x \
    && echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache --virtual .persistent-deps \
        bash@community \
        curl@community \
        monit@community \
        ca-certificates@community \
    && apk add --no-cache --virtual .build-deps \
        $BUILD_DEPS \
    && cd /tmp  \
    && wget -q http://downloads.rclone.org/rclone-${RCLONE_VERSION}-linux-${RCLONE_TYPE}.zip \
    && unzip /tmp/rclone-${RCLONE_VERSION}-linux-${RCLONE_TYPE}.zip \
    && mv /tmp/rclone-*-linux-${RCLONE_TYPE}/rclone /usr/bin \
    && addgroup -g 1000 rclone \
    && adduser -SDH -u 1000 -s /bin/false rclone -G rclone \
    && sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf \
	  && mkdir -p /config /defaults /data \
    && rm -Rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    && apk del .build-deps

COPY monit.d/ /etc/monit.d/
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY rclone.sh /rclone.sh
COPY env_secrets.sh /env_secrets.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [""]
