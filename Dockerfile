FROM debian:trixie-20251103-slim

LABEL org.opencontainers.image.url="https://github.com/misotolar/docker-backport-builder"
LABEL org.opencontainers.image.description="Debian backport build container"
LABEL org.opencontainers.image.authors="Michal Sotolar <michal@sotolar.com>"

ENV DEBFULLNAME="Michal Sotolar"
ENV DEBEMAIL="michal@sotolar.com"
ENV DEBIAN_FRONTEND=noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /build

RUN set -ex; \
    sed -i 's/^Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        build-essential \
        devscripts \
    ; \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

COPY resources/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY resources/upgrade.sh /usr/local/bin/upgrade.sh

VOLUME /dest

ENTRYPOINT ["entrypoint.sh"]
CMD ["/dest"]
