#!/bin/sh

# clean yum cache to avoid download errors
sudo yum clean all

# enable additional repositories if needed
if [ -n "$ENABLEREPO" ]; then
    sudo yum-config-manager --enable "$ENABLEREPO"
fi

# update to either install newer updates or to take packages from added repos into account
sudo yum update -y --disablerepo=epel

cd $HOME

SRPM_MOUNT_DIR=/mnt/docker-SRPMS/
LOCAL_SRPM_DIR=$HOME/local-SRPMs

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

if [ ! -z $BUILD_LOCAL ]; then
    pushd ~/rpmbuild
    rm BUILD BUILDROOT RPMS SRPMS -rf
    sudo yum-builddep -y SPECS/*.spec
    if [ $? == 0 ]; then
        if [ ! -z "$RPMBUILD_DEFINE" ]; then
            rpmbuild -ba SPECS/*.spec --define "$RPMBUILD_DEFINE"
        else
            rpmbuild -ba SPECS/*.spec
        fi
        if [ $? == 0 -a -d ~/output/ ]; then
            cp -rf RPMS SRPMS ~/output/
        fi
    fi
    popd
elif [ ! -z $REBUILD_SRPM ]; then
    # build deps already installed above
    if [ ! -z "$RPMBUILD_DEFINE" ]; then
        rpmbuild --rebuild $LOCAL_SRPM_DIR/$REBUILD_SRPM --define "$RPMBUILD_DEFINE"
    else
        rpmbuild --rebuild $LOCAL_SRPM_DIR/$REBUILD_SRPM
    fi
    if [ $? == 0 ]; then
        cp -rf ~/rpmbuild/RPMS ~/output/
    fi
elif [ ! -z "$COMMAND" ]; then
    $COMMAND
else
    /bin/bash --login
    exit 0
fi

if [ ! -z $NO_EXIT ]; then
    /bin/bash --login
fi