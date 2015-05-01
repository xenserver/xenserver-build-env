#!/bin/sh

sed -e "s/@XS_BRANCH@/${XS_BRANCH}/" /root/Citrix.repo.in > /etc/yum.repos.d.xs/Citrix.repo

SRPM=/mnt/docker-SRPMS/$SRPM_NAME

yum-builddep -y $SRPM
