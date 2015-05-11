#!/usr/bin/python

import argparse
import os
import os.path
import shutil
import sys
import uuid

CONTAINER = "xenserver/xenserver-build-env"
DOCKER_PATH = "/usr/bin/docker"
SRPMS_MOUNT_ROOT = "/tmp/docker-SRPMS"

def make_mount_dir():
    srpm_mount_dir = os.path.join(SRPMS_MOUNT_ROOT, str(uuid.uuid4()))
    try:
        os.makedirs(srpm_mount_dir)
    except OSError:
        pass
    return srpm_mount_dir

def copy_srpms(srpm_mount_dir, srpms):
    for srpm in srpms:
        srpm_name = os.path.basename(srpm)
        shutil.copyfile(srpm, os.path.join(srpm_mount_dir, srpm_name))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-b', '--branch', help='XenServer branch name (default trunk)',
                        default='trunk')
    parser.add_argument('-s', '--srpm', action='append',
                        help='SRPMs for which dependencies will be installed')
    parser.add_argument('-d', '--dir', action='append', help='Local dir to mount in the '
                        'image. Will be mounted at /external/<dirname>')
    parser.add_argument('--rm', action='store_true', help='Destroy the container on exit')

    args = parser.parse_args(sys.argv[1:])
    docker_args = [
        "docker", "run", "-e", "XS_BRANCH=%s" % args.branch,
        "-i", "-t", "-u", "builder"
        ]
    if args.rm:
        docker_args += ["--rm=true"]
    # Copy all the RPMs to the mount directory
    if args.srpm != []:
        srpm_mount_dir = make_mount_dir()
        copy_srpms(srpm_mount_dir, args.srpm)
        docker_args += ["-v", "%s:/mnt/docker-SRPMS" % srpm_mount_dir]
    for localdir in args.dir:
        dirname = os.path.basename(localdir)
        if not os.path.isdir(localdir):
            print "Local directory argument is not a directory!"
            sys.exit(1)
        docker_args += ["-v", "%s:/external/%s" % (localdir, dirname)]

    # exec "docker run"
    docker_args += [CONTAINER, "/usr/local/bin/init-container.sh"]
    print "Launching docker with args %s" % docker_args
    os.execv(DOCKER_PATH, docker_args)

if __name__ == "__main__":
    main()
