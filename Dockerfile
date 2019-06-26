FROM node:10.16.0-stretch

# Same as "export TERM=dumb"; prevents error "Could not open terminal for stdout: $TERM not set"
ENV TERM linux

RUN apt-get update && apt-get -y install \
    software-properties-common \
    bzip2 unzip zip \
    openssh-client \
    curl \
    wget \
    vim \
    nano \
    git \
    git-core \
    apt-transport-https

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
