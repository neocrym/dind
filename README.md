# neocrym/dind -- An Ubuntu-based Docker-in-Docker image with systemd

This is a Docker installation based on Ubuntu. It installs systemd and Docker.

This image is used for running Docker containers via an isolated Docker daemon. This is useful for testing code that launches Docker containers without giving complete access to the Docker daemon on the host machine.

If you are fine with giving your code access to your host machine's Docker socket, you might instead consider binding your host's Docker socket into your container. Jérôme Petazzoni further in his [blog post](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/) comparing Docker-in-Docker to bind-mounting the Docker socket.

## Usage

To use this image, you will need to use the `--privileged` flag. Note that this effectively gives this container root access to your machine. At this time of writing, this container will not work on Docker Swarm because Swarm Mode does not support the `--privileged` flag for containers.

You should also mount `/run` and `/run/lock` as tmpfs mounts. The container's `/sys/fs/cgroup` should be a read-only mount to the same directory on the host. You should also create a Docker volume at `/var/lib/docker` to persist Docker state across container runs. Do not have multiple containers share this volume.

The Docker Compose for the above configuration looks like:

```yaml
version: "3.9"

services:
  dind:
    image: jamesmishra/dind
    privileged: true
    volumes:
      - type: tmpfs
        target: /run
      - type: tmpfs
        target: /run/lock
      - type: bind
        source: /sys/fs/cgroup
        target: /sys/fs/cgroup
        read_only: true
      - type: volume
        source: dind_volume
        target: /var/lib/docker

volumes:
  dind_volume:
```

### Overriding the entrypoint

If you are creating a new image based on this image, you might want to override the image's entrypoint to run commands upon container startup.

To make sure that systemd starts, make sure your container entrypoint ends by exec-ing `/lib/systemd/systemd`. As a bash script, this looks like:

```bash
#!/bin/bash
echo "Your code goes here."
exec /lib/systemd/systemd
```

## Credits

This image takes heavy inspiration from [cruizba/ubuntu-dind](https://github.com/cruizba/ubuntu-dind), [docker/dind](https://hub.docker.com/_/docker) and [jrei/systemd-ubuntu](https://hub.docker.com/r/jrei/systemd-ubuntu).
