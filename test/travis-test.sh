#!/bin/sh

set -eux

./build.sh

PACKAGE=ocaml-xcp-idl

CONTAINER=`./run.py --detach \
    -v $PWD/test/travis-test-internal.sh:/tmp/travis-test-internal.sh \
    -p $PACKAGE`

docker exec -t $CONTAINER /tmp/travis-test-internal.sh $PACKAGE

docker stop $CONTAINER
docker rm $CONTAINER
