# Start with docker-tangerine-support, which provides the core Tangerine apps.
FROM tangerine/docker-tangerine-base-image:v3-with-wrapper

# build-base installs gcc, which is necessary for building couchapp.
RUN apk add --update \
 ruby build-base

# https://github.com/frol/docker-alpine-python3
RUN apk add --no-cache python3 python3-dev && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

RUN pip install couchapp

RUN apk add --update \
 nginx

RUN mkdir -p /etc/nginx/sites-available/ && \
    mkdir -p /etc/nginx/sites-enabled/

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default /etc/nginx/sites-enabled/default

RUN apk add --update \
 ruby-dev sqlite-dev

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
