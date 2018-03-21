# Start with docker-tangerine-support, which provides the core Tangerine apps.
FROM tangerine/docker-tangerine-base-image:v3-with-wrapper

# build-base installs gcc, which is necessary for building couchapp.
RUN apk add --update \
 ruby ruby-dev sqlite-dev build-base nginx vim yarn python git \
 && rm -rf /var/cache/apk/*

# https://github.com/frol/docker-alpine-python3
RUN apk add --no-cache python python-dev && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip2 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip2 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python /usr/bin/python; fi && \
    rm -r /root/.cache

RUN pip install couchapp

RUN mkdir -p /etc/nginx/sites-available/ && \
    mkdir -p /etc/nginx/sites-enabled/

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default /etc/nginx/sites-enabled/default

RUN mkdir /run/nginx

ADD client/config.xml /tangerine/client/config.xml
ADD client/hooks /tangerine/client/hooks
ADD client/res /tangerine/client/res
ADD client/platforms /tangerine/client/platforms
ADD client/www /tangerine/client/www

WORKDIR /tangerine/client

RUN cordova platform add android@7.0.0
RUN cordova plugin add cordova-plugin-whitelist --save
RUN cordova plugin add cordova-plugin-geolocation --save
RUN cordova plugin add cordova-plugin-camera --save
RUN cordova plugin add cordova-plugin-file --save
RUN cordova plugin add cordova-plugin-crosswalk-webview --save

RUN cordova build

# Install brockman.
ADD ./brockman/Gemfile /tangerine/brockman/Gemfile
ADD ./brockman/Gemfile.lock /tangerine/brockman/Gemfile.lock
RUN cd /tangerine/brockman \
    && gem install bundler --no-ri --no-rdoc \
    && bundle install --path vendor/bundle

WORKDIR /tangerine
# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]