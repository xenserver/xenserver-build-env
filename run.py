#!/usr/bin/python

"""
Thin wrapper around "docker run" which simplifies the creation of a build
environment for XenServer packages.
"""

import argparse
import os
import os.path
import subprocess
import shutil
import sys
import uuid

CONTAINER = "xenserver/xenserver-build-env"
SRPMS_MOUNT_ROOT = "/tmp/docker-SRPMS"
# On OS X with boot2docker there are limits, see:
# http://blog.docker.com/2014/10/docker-1-3-signed-images-process-injection-security-options-mac-shared-directories/
# https://github.com/docker/docker/issues/4023
if sys.platform == 'darwin':
    home = os.getenv("HOME")
    if not home.startswith("/Users"):
        print >> sys.stderr, \
            "On OS X $HOME needs to be within /Users for mounting to work"
        exit(1)
    SRPMS_MOUNT_ROOT = home + SRPMS_MOUNT_ROOT


def make_mount_dir():
    """
    Make a randomly-named directory under SRPMS_MOUNT_ROOT.
    """
    srpm_mount_dir = os.path.join(SRPMS_MOUNT_ROOT, str(uuid.uuid4()))
    try:
        os.makedirs(srpm_mount_dir)
    except OSError:
        pass
    return srpm_mount_dir


def copy_srpms(srpm_mount_dir, srpms):
    """
    Copy each SRPM into the mount directory.
    """
    for srpm in srpms:
        srpm_name = os.path.basename(srpm)
        shutil.copyfile(srpm, os.path.join(srpm_mount_dir, srpm_name))


def main():
    """
    Main entry point.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('-b', '--branch',
                        help='XenServer branch name (default trunk)',
                        default='trunk')
    parser.add_argument('-s', '--srpm', action='append',
                        help='SRPMs for which dependencies will be installed')
    parser.add_argument('-d', '--dir', action='append',
                        help='Local dir to mount in the '
                        'image. Will be mounted at /external/<dirname>')
    parser.add_argument('--rm', action='store_true',
                        help='Destroy the container on exit')

    args = parser.parse_args(sys.argv[1:])
    docker_args = [
        "docker", "run", "-e", "XS_BRANCH=%s" % args.branch,
        "-i", "-t", "-u", "builder"
        ]
    if args.rm:
        docker_args += ["--rm=true"]
    # Copy all the RPMs to the mount directory
    if args.srpm:
        srpm_mount_dir = make_mount_dir()
        copy_srpms(srpm_mount_dir, args.srpm)
        docker_args += ["-v", "%s:/mnt/docker-SRPMS" % srpm_mount_dir]
    if args.dir:
        for localdir in args.dir:
            if not os.path.isdir(localdir):
                print "Local directory argument is not a directory!"
                sys.exit(1)
            ext_path = os.path.abspath(localdir)
            int_path = os.path.basename(ext_path)
            docker_args += ["-v", "%s:/external/%s" % (ext_path, int_path)]

    # exec "docker run"
    docker_args += [CONTAINER, "/usr/local/bin/init-container.sh"]
    print "Launching docker with args %s" % docker_args
    subprocess.call(docker_args)


if __name__ == "__main__":
    main()
