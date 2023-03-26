# Ubuntu Development Container for Qt 6.4.3
This repository provides a development image/container that allows multiple
users to have a common development environment to do QT development.

When the container launches it uses your GID/UID for the `devusr`.  This way if
you modify the contents of anything while using the container to build, it will
retain proper permissions between you and your host.

## Building
Building takes a while because of the size of Qt6.  Everything is being built
with the exception of the webengine
```
docker built . -t ubuntu_qt6:stages
```

## Running
```
./run.sh /path/to/projects /path/to/data
```
This will drop you to a shell that you can then use to build your projects.
Your user by default has sudo without a password so you can add packages as
needed.

Cloning and owning might be the best option for you, so that your base container
is nice and clean.
