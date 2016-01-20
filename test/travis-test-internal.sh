#!/bin/sh

set -eux

PACKAGE=$1

cd $HOME

yumdownloader --source $PACKAGE
rpmbuild --rebuild $PACKAGE*.src.rpm
