#!/bin/bash

if [ -z "$GPG_SIGN_KEY" ]; then
    dpkg-buildpackage -b -us -uc
else
    gpg -v --batch --import <(echo "$GPG_SIGN_KEY")
    dpkg-buildpackage -b
fi

/bin/cp -av /usr/local/bin/upgrade.sh "$@"
/bin/cp -av /build/*.buildinfo "$@"
/bin/cp -av /build/*.changes "$@"
/bin/cp -av /build/*.deb "$@"
