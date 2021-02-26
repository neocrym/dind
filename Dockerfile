ARG UBUNTU_VERSION=focal-20210119
FROM ubuntu:${UBUNTU_VERSION}

ARG DEBIAN_FRONTEND=noninteractive

# Uncomment all Apt repositories.
RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    # Install tools needed for adding Ubuntu Apt PPAs.
    curl \
    gnupg2 \
    ca-certificates \
    software-properties-common \
    # Install systemd.
    systemd \
    systemd-sysv \
    # Remove Apt cache to shrink the image size.
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure systemd.
RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1 \
    && rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

# Install the Docker Apt PPA.
RUN curl --fail --show-error --silent --location https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository --no-update \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

# Install Docker.
RUN apt-get update \
    && apt-get install --yes --no-install-recommends  \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    # Remove Apt cache to shrink the image size.
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install docker-compose.
ARG DOCKER_COMPOSE_VERSION=1.28.4
RUN curl --fail --show-error --silent --location "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Add the container entrypoint.
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
