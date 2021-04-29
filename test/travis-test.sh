#!/bin/sh

set -eux

TARGET_XCP_NG_VERSION="8.2"

./build.sh "${TARGET_XCP_NG_VERSION}"

PACKAGE=emu-manager
REPO=xcp-emu-manager

git clone git://github.com/xcp-ng/$REPO /tmp/$REPO

cp \
    run.py \
    utils/travis-build-repo.sh \
    utils/travis-build-repo-internal.sh \
    /tmp/$REPO

cd /tmp/$REPO

REPO_PACKAGE_NAME=$PACKAGE \
    REPO_CONFIGURE_CMD=true \
    REPO_BUILD_CMD=make \
    REPO_TEST_CMD=true \
    TARGET_XCP_NG_VERSION="${TARGET_XCP_NG_VERSION}" \
    bash travis-build-repo.sh
