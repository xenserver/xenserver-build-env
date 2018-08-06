#!/bin/sh

set -eux

./build.sh dev

PACKAGE=xcp-networkd
REPO=xcp-networkd

git clone git://github.com/xapi-project/$REPO /tmp/$REPO

cp \
    run.py \
    utils/travis-build-repo.sh \
    utils/travis-build-repo-internal.sh \
    /tmp/$REPO

cd /tmp/$REPO

REPO_PACKAGE_NAME=$PACKAGE \
    REPO_CONFIGURE_CMD=true \
    REPO_BUILD_CMD=make \
    REPO_TEST_CMD='make test' \
    bash travis-build-repo.sh
