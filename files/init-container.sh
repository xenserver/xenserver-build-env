#!/bin/sh

set -eux

cd $HOME

SRPM_MOUNT_DIR="/mnt/docker-SRPMS"

sed -e "s/@XS_BRANCH@/${XS_BRANCH}/" /tmp/Citrix.repo.in > $HOME/Citrix.repo
sudo mv $HOME/Citrix.repo /etc/yum.repos.d.xs/Citrix.repo

if [ -d $SRPM_MOUNT_DIR ]
then
    SRPMS=`find $SRPM_MOUNT_DIR -name *.src.rpm`

    for SRPM in $SRPMS
    do
        sudo yum-builddep -y $SRPM
    done
fi

/bin/sh --login
