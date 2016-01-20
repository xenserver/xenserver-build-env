#!/bin/sh

set -eux

./build.sh

PACKAGE=ocaml-xcp-idl

./run.py --rm \
    -v $PWD/test/travis-test-internal.sh:/tmp/travis-test-internal.sh \
    -p $PACKAGE \
    /tmp/travis-test-internal.sh $PACKAGE
