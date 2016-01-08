#!/bin/sh

set -eux

PACKAGE=$1

while [ ! -f $HOME/.setup-complete ]
do
    sleep 10
done

cd $HOME

yumdownloader --source $PACKAGE
rpmbuild --rebuild $PACKAGE*.src.rpm
