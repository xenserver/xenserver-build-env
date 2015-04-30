For the yum repos to resolve properly, you'll need to add some DNS servers to
your docker config.

If you require packages which depend on systemd, you'll also have to work around
the fact that systemd won't install on older versions of AUFS. One option is to
switch to the devicemapper storage driver.

Add the following to your docker config:

```
DOCKER_OPTS="--dns 10.80.16.125 --dns 10.80.16.126 -s devicemapper"
```

Beware, switching to the devicemapper driver will mean you lose access to the
images you had available previously. Also, it's quite a lot slower than the
default AUFS driver.

For more info, see:

* https://bugs.centos.org/view.php?id=7480
* https://github.com/docker/docker/issues/6980

Start a container with a specified SRPM like so:

```
./run.sh <SRPM-PATH>
```

The container will run yum-builddep against the SRPM, and drop you into an
interactive shell.
