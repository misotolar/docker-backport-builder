#!/bin/bash

set -ex

BACKPORT_UPSTREAM=${BACKPORT_UPSTREAM:-$BACKPORT_VERSION}

apt source "$BACKPORT_PACKAGE"="$BACKPORT_UPSTREAM"/"$BACKPORT_ORIGIN"

cd "$BACKPORT_PACKAGE"-* || exit 1

mk-build-deps --install --remove --root-cmd=sudo --tool="apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y"

dch -b -v "$BACKPORT_VERSION"~"$BACKPORT_RELEASE" "Backport $BACKPORT_UPSTREAM release from $BACKPORT_ORIGIN"
dch -r "" -D "$BACKPORT_DISTRO"

if [ -z "$GPG_SIGN_KEY" ]; then
    dpkg-buildpackage -b -us -uc
else
    gpg -v --batch --import <(echo "$GPG_SIGN_KEY")
    dpkg-buildpackage -b --sign-key="$(gpg --list-signatures --with-colons | grep 'sig' | grep "$DEBEMAIL" | head -n 1 | cut -d':' -f13)"
fi

cd ..

if [ -z "$REPOSITORY_FQDN" ]; then
    /bin/cp -av /usr/local/bin/upgrade.sh "$@"
    /bin/cp -av /home/backport/*.deb "$@"
else
    envsubst < "/usr/local/etc/dput.cf" > "/home/backport/dput.cf"
    dput -c /home/backport/dput.cf -u "$BACKPORT_PACKAGE"_"$BACKPORT_VERSION"~"$BACKPORT_RELEASE"_"$(dpkg --print-architecture)".changes
    curl -X POST "$REPOSITORY_METHOD"://"$REPOSITORY_FQDN"/api/v1/repo/import
fi
