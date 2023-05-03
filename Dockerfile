FROM node:18-bullseye

# Same as "export TERM=dumb"; prevents error "Could not open terminal for stdout: $TERM not set"
ENV TERM linux

# Doing this in a separate stage due to cdn errors.
RUN apt-get update && apt-get -y install \
    software-properties-common

# Doing this in a separate stage due to cdn errors.
RUN apt-get update && apt-get -y install \
    bzip2 unzip zip \
    openssh-client \
    curl \
    wget \
    vim \
    nano

# Doing this in a separate stage due to cdn errors.
RUN apt-get update && apt-get -y install \
    git \
    git-core \
    apt-transport-https

WORKDIR /tangerine/client

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
