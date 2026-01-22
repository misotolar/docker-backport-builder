FROM debian:trixie-20260112-slim

LABEL org.opencontainers.image.url="https://github.com/misotolar/docker-backport-builder"
LABEL org.opencontainers.image.description="Debian backport build container"
LABEL org.opencontainers.image.authors="Michal Sotolar <michal@sotolar.com>"

ENV DEBFULLNAME="Michal Sotolar"
ENV DEBEMAIL="michal@sotolar.com"

ENV BACKPORT_ORIGIN=unstable
ENV BACKPORT_DISTRO=trixie-backports

ENV DEBIAN_FRONTEND=noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

COPY resources/debian/dput.cf /usr/local/etc/dput.cf
COPY resources/debian/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources
COPY resources/debian/sudoers.d/backport /etc/sudoers.d/backport
COPY resources/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY resources/upgrade.sh /usr/local/bin/upgrade.sh

WORKDIR /dest

RUN set -ex; \
    apt --update upgrade -y;\
    apt install -y \
        devscripts \
        build-essential \
        gettext-base \
        sudo \
    ; \
    useradd -ms /bin/bash backport; \
    chown backport:backport /dest; \
    rm -rf \
        /var/tmp/* \
        /tmp/*

USER backport
WORKDIR /home/backport

VOLUME /dest

ENTRYPOINT ["entrypoint.sh"]
CMD ["/dest"]
