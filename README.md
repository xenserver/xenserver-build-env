# Xenserver-build-env
This docker config and collection of supporting scripts allows for creating
a docker container to work on and build a XenServer package from an SRPM. It
will build a Docker container with the right build environment (including some
useful tools) and then install all of the build-dependencies of the given
pacakge. You will then be in a chroot from which you can clone and build the
source.

## Configuration
You'll need to install docker. For most distros this is packaged as
`docker.io`.

If you'd like to run docker with a non-root account you can add your user to
the docker group:

```sh
usermod -G docker <username>
newgrp docker   # if you don't want to have to re-login
```
For the yum repos to resolve properly, you'll need to add some DNS servers to
your docker config.

If you require packages which depend on systemd, you'll also have to work around
the fact that systemd won't install on older versions of AUFS. One option is to
switch to the devicemapper storage driver.

Add the following to your docker config:

```sh
DOCKER_OPTS="--dns 10.80.16.125 --dns 10.80.16.126 -s devicemapper"
```

**Beware:** switching to the devicemapper driver will mean you lose access to the
images you had available previously. Also, it's quite a lot slower than the
default AUFS driver.

For more info, see:

* https://bugs.centos.org/view.php?id=7480
* https://github.com/docker/docker/issues/6980

## Usage
Start a container with a XenServer branch name and at least one SRPM like so:

```sh
./run.py -b trunk-ring3 -s xenopsd-0.10.1-1+s0+0.10.1+10+gf2c98e0.el7.centos.src.rpm
```

The container will run yum-builddep against the SRPM, using the yum repository
for the specified branch, and drop you into an interactive shell. You should
then have all the dependencies to be able to build the component whose SRPM was
specified above, e.g.

```sh
git clone git://github.com/xapi-project/xenopsd
cd xenopsd
./configure
make
```

## Mounting repos from outside the container
If you'd like to develop using the tools on your host and preseve the changes
to source and revision control but still use the container for building, you
can do using by using a docker volume.

Once you have built your image you can run it with an extra argument to mount
a directory from your host to a suitable point inside the container. For
example, if I clone some repos into a directory on my host, say `/work/code/`,
then I can mount it inside the container as follows:

```sh
docker run -i -t -v /work/code:/mnt/repos -u $(id -u) <IMAGE> /bin/bash
```

The `-u` flag uses the right UID inside so that changes made in the container
are with the same UID as outside the container. Docker >=1.6 supports group IDs
as well and both the group and user can be referenced by name. To get the
latest version see the installation instructions on http://docker.io.

On Ubuntu >=14.04, the following command will get the latest version of docker:

```sh
wget -qO- https://get.docker.com/ | sh
```

Then the following format is available to set the UID/GID:

```
-u, --user=                Username or UID (format: <name|uid>[:<group|gid>])
```
