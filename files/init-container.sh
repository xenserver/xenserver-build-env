#!/bin/sh

set -e

cd $HOME

SRPM_MOUNT_DIR=/mnt/docker-SRPMS/
LOCAL_SRPM_DIR=$HOME/local-SRPMs

case $GIT_BRANCH in
	dundee-bugfix)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS9kOGJjOGVkZi1lOGMyLTRiNmQtYjgyZi0yNGQ2NzQyZWE4YmMvZG9tYWluMA==
		;;
	ely-bugfix)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS80NDllNTJhNC0yNzFhLTQ4M2EtYmFhNy0yNGJmMzYyODY2ZjcvZG9tYWluMA==
		;;
	falcon)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS9mYTdjMGVhOS05ZDMxLTUwYmItYThkNi04YWUzNjdlZjJmMTQvZG9tYWluMA==
		;;
	jura)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS83ZWEzNzIxMi05Mzc3LTIyYWMtZWJkZi01NGZlYTU0YjM0MjIvZG9tYWluMA==
		;;
	qemu-upstream)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS83ZWEzNzIxMi05MDc5LWUzMjEtNTdhYi0xZTQ5ZWFmYzBkY2YvZG9tYWluMA==
		;;
	vgpu-migration)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS9hNjIxMTk2MS04ZGFkLTQzYjctOGFlMy1iOTQ0YzIxNzkxNGEvZG9tYWluMA==
		;;
	usb-passthrough)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS8wMDViYmE1Mi03ZmIzLTlhMmMtZDY5MS1hOGI1Yjg5N2NmZjMvZG9tYWluMA==
		;;
	feature/REQ477/master)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS9mZWE3NjJlNy0yZTk0LTc3NzMtYTU3NC0yNDMyNmVhODc2ZmQvZG9tYWluMA==
		;;
	sr-iov)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS9kYmQ5OTRiOS0yZTQ1LTQyMDMtODU4OS03MzQ2N2MxM2M2ZTEvZG9tYWluMA==
		;;
	REQ-503)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS9mZWE3NjJlNy0yZTk1LTAzNzMtYTU3ZS0yMzRlYWY5YmRjZmYvZG9tYWluMA==
		;;
	uefi)
		XS_REPO_KEY=aHR0cDovL3hhcGktcmVwb3MuczMtd2Vic2l0ZS11cy1lYXN0LTEuYW1hem9uYXdzLmNvbS8yYjE2NWJmOS02OWM3LTQ2MTgtOTFmYS1hMmNlYTA1MzVhNTAvZG9tYWluMA==
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
