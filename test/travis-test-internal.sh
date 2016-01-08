#!/bin/sh

set -eux

ulimit -s 16384

PACKAGE=ocaml-xcp-idl

yum-builddep -y $PACKAGE

yumdownloader --source $PACKAGE
yum-builddep -y $PACKAGE*.src.rpm
rpmbuild --rebuild $PACKAGE*.src.rpm
