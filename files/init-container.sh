#!/bin/sh

set -eux

sed -e "s/@XS_BRANCH@/${XS_BRANCH}/" /root/Citrix.repo.in > /etc/yum.repos.d.xs/Citrix.repo

SRPMS=`ls /mnt/docker-SRPMS/*.src.rpm`

for SRPM in $SRPMS
do
    yum-builddep -y $SRPM
done
