#!/bin/sh

set -e

cd $HOME

SRPM_MOUNT_DIR=/mnt/docker-SRPMS/
LOCAL_SRPM_DIR=$HOME/local-SRPMs

case $GIT_BRANCH in
	trunk-pvs-direct)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS84ZWZiM2VlLTNjN2QtMTFlNi1iOTVlLTMzZGU5MzkyZGRmMi9kb21haW4w
		;;
	dundee-bugfix)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS9kOGJjOGVkZi1lOGMyLTRiNmQtYjgyZi0yNGQ2NzQyZWE4YmMvZG9tYWluMA==
		;;
	trunk-car-2245)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS82MGFlMWY3Ny1kMzBlLTQ3MmYtYmQ3ZC1iYzZjM2RjZjI1ODUvZG9tYWluMA==
		;;
	ely-bugfix)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS80NDllNTJhNC0yNzFhLTQ4M2EtYmFhNy0yNGJmMzYyODY2ZjcvZG9tYWluMA==
		;;
	falcon)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS9mYTdjMGVhOS05ZDMxLTUwYmItYThkNi04YWUzNjdlZjJmMTQvZG9tYWluMA==
		;;
	*)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS8xMzM3YWI2Yy03N2FiLTljOGMtYTkxZi0zOGZiYThiZWU4ZGQvZG9tYWluMA==
		;;
esac

if [ ! -z $XS_BRANCH ]
then
    sudo mv /etc/yum.conf /etc/yum.conf.backup
    sudo mv /etc/yum.conf.xs /etc/yum.conf

    sed -e "s/@XS_BRANCH@/${XS_BRANCH}/" /tmp/Citrix.repo.in > $HOME/Citrix.repo
    sudo mv $HOME/Citrix.repo /etc/yum.repos.d.xs/Citrix.repo
else
    XS_REPO=`python -c "import base64; import re; \
        print re.escape(base64.b64decode('${XS_REPO_KEY}'))"`
    sed -e "s/@XS_REPO@/${XS_REPO}/" /tmp/xs.repo.in > $HOME/xs.repo
    sudo mv $HOME/xs.repo /etc/yum.repos.d/xs.repo
    sudo yum --enablerepo=xs clean metadata
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

touch $HOME/.setup-complete

if [ ! -z "$COMMAND" ]
then
    $COMMAND
else
    /bin/sh --login
fi
