#!/bin/sh

set -eux

SRPM_MOUNT_DIR="/mnt/docker-SRPMS"

sed -e "s/@XS_BRANCH@/${XS_BRANCH}/" /root/Citrix.repo.in > /etc/yum.repos.d.xs/Citrix.repo

if [ -d $SRPM_MOUNT_DIR ]
then
    SRPMS=`ls ${SRPM_MOUNT_DIR}/*.src.rpm`

    for SRPM in $SRPMS
    do
        yum-builddep -y $SRPM
    done
fi

su - builder
