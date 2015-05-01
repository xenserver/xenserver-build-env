#!/bin/sh

if [ $# -ne 1 ]
then
    echo "Usage:"
    echo "./run.sh <SRPM URL>"
    exit 1
fi

SRPMS_MOUNT_DIR=/tmp/docker-SRPMS/`uuidgen`

SRPM=$1
SRPM_NAME=`basename $SRPM`

mkdir -p $SRPMS_MOUNT_DIR
cp $SRPM $SRPMS_MOUNT_DIR

docker run \
    -e SRPM_NAME=$SRPM_NAME \
    -i --rm=true -t \
    -v $SRPMS_MOUNT_DIR:/mnt/docker-SRPMS xenserver/xenserver-build-env
