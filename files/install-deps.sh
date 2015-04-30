#!/bin/sh

SRPM=/mnt/docker-SRPMS/$SRPM_NAME

yum-builddep -y $SRPM
