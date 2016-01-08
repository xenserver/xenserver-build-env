#!/bin/sh

set -ex

cd $HOME

SRPM_MOUNT_DIR=/mnt/docker-SRPMS/
LOCAL_SRPM_DIR=$HOME/local-SRPMs

if [ ! -z $XS_BRANCH ]
then
    sudo mv /etc/yum.conf /etc/yum.conf.backup
    sudo mv /etc/yum.conf.xs /etc/yum.conf

    sed -e "s/@XS_BRANCH@/${XS_BRANCH}/" /tmp/Citrix.repo.in > $HOME/Citrix.repo
    sudo mv $HOME/Citrix.repo /etc/yum.repos.d.xs/Citrix.repo
fi

mkdir -p $LOCAL_SRPM_DIR

# Download the source for packages specified in the environment.
if [ -n "$PACKAGES" ]
then
    for PACKAGE in $PACKAGES
    do
        yumdownloader --destdir=$LOCAL_SRPM_DIR --source $PACKAGE
    done
fi

# Copy in any SRPMs from the directory mounted by the host.
if [ -d $SRPM_MOUNT_DIR ]
then
    cp $SRPM_MOUNT_DIR/*.src.rpm $LOCAL_SRPM_DIR

fi

# Install deps for all the SRPMs.
SRPMS=`find $LOCAL_SRPM_DIR -name *.src.rpm`

for SRPM in $SRPMS
do
    sudo yum-builddep -y $SRPM
done

# double the default stack size
ulimit -s 16384

/bin/sh --login
