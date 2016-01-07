#!/bin/sh

set -eux

./build.sh

docker run --rm=true \
    -v $PWD/test/travis-test-internal.sh:/tmp/travis-test-internal.sh \
    xenserver/xenserver-build-env \
    /tmp/travis-test-internal.sh
