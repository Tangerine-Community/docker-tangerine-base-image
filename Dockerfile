FROM ubuntu:16.04

# Same as "export TERM=dumb"; prevents error "Could not open terminal for stdout: $TERM not set"
ENV TERM linux

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install some core utilities
RUN apt-get update && apt-get -y install \
    software-properties-common \
    python-software-properties \
    bzip2 unzip \
    openssh-client \
    git \
    lib32stdc++6 \
    lib32z1 \
    curl \
    wget \
    vim \
    nano \
    links \
    rsync \
    bc \
    git \
    git-core \
    apt-transport-https \
    libxml2 \
    libxml2-dev \
    libcurl4-openssl-dev \
    openssl \
    sqlite3 \
    libsqlite3-dev \
    gawk \
    libreadline6-dev \
    libyaml-dev \
    autoconf \
    libgdbm-dev \
    libncurses5-dev \
    automake \
    libtool \
    bison \
    jq \
    libffi-dev \
    nginx \
    gradle \
    netcat-traditional

# Install node and some node based services
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
  && apt-get -y install nodejs \
  && npm install -g pm2 \
  && npm install -g bower \
  && npm install -g npm \
  && npm install -g nodemon

# Install Couchdb
RUN apt-get -y install software-properties-common \
  && apt-add-repository -y ppa:couchdb/stable \
  && apt-get update \
  && apt-get -y install couchdb \
  && chown -R couchdb:couchdb /usr/bin/couchdb /etc/couchdb /usr/share/couchdb \
  && chmod -R 0770 /usr/bin/couchdb /etc/couchdb /usr/share/couchdb \
  && mkdir /var/run/couchdb \
  && chown -R couchdb /var/run/couchdb \
  && sed -i -e "s#\[couch_httpd_auth\]#\[couch_httpd_auth\]\ntimeout=9999999#" /etc/couchdb/local.ini \
  && sed -i 's#;bind_address = 127.0.0.1#bind_address = 0.0.0.0#' /etc/couchdb/local.ini \
  && couchdb -k \
  && couchdb -b

# Install couchapp
RUN apt-get install build-essential python-dev -y \
  && curl -O https://bootstrap.pypa.io/get-pip.py \
  && python get-pip.py \
  && pip install couchapp

## Install Ruby
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
  && curl -L https://get.rvm.io | bash -s stable \
  && /bin/bash -l -c "rvm requirements" \
  && /bin/bash -l -c "rvm install ruby-2.2.0" \
  && /bin/bash -l -c "rvm install ruby-2.2.0-dev" \
  && /bin/bash -l -c "rvm --default use ruby-2.2.0" \
  && /bin/bash -c "source /usr/local/rvm/bin/rvm && gem install bundler --no-ri --no-rdoc "
ENV PATH /usr/local/rvm/rubies/ruby-2.2.0/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV GEM_PATH /usr/local/rvm/rubies/ruby-2.2.0
ENV GEM_HOME /usr/local/rvm/rubies/ruby-2.2.0

## Prepare to install Android Build Tools
#ENV GRADLE_OPTS -Dorg.gradle.jvmargs=-Xmx2048m
#ENV ANDROID_SDK_VERSION 26.0.2
#ENV ANDROID_API_LEVEL 26
##ENV ANDROID_BUILD_TOOLS_VERSION 26.0.2
##ENV ANDROID_SDK_FILENAME android-sdk_r24.4.1-linux.tgz
#ENV ANDROID_SDK_DIST tools_r${ANDROID_SDK_VERSION}-linux.zip
##ENV ANDROID_SDK_URL http://dl.google.com/android/${ANDROID_SDK_FILENAME}
#ENV ANDROID_SDK_URL http://dl.google.com/android/repository/${ANDROID_SDK_DIST}
##http://dl.google.com/android/repository/tools_r25.2.2-linux.zip
## Support from Ice Cream Sandwich, 4.0.3 - 4.0.4, to Marshmallow version 6.0
#ENV ANDROID_API_LEVELS android-15,android-16,android-17,android-18,android-19,android-20,android-21,android-22,android-23,android-24,android-25,android-26
## https://developer.android.com/studio/releases/build-tools.html
#ENV ANDROID_BUILD_TOOLS_VERSION 27.0.3
##ENV ANDROID_HOME /opt/android-sdk-linux
#ENV SDK_HOME /opt/android-sdk
##ENV PATH ${PATH}:${SDK_HOME}/tools:${SDK_HOME}/platform-tools

RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install Android SDK

#RUN cd /opt && \
#    wget -q $ANDROID_SDK_URL && \
#    unzip $ANDROID_SDK_DIST -d $SDK_HOME && \
#    rm $ANDROID_SDK_DIST && \
#    echo y | android update sdk --no-ui -a --filter tools,platform-tools,$ANDROID_API_LEVELS,build-tools-$ANDROID_BUILD_TOOLS_VERSION,extra-android-support,extra-android-m2repository

# Set up environment variables
ENV SDK_HOME /opt/android-sdk
ENV ANDROID_HOME /opt/android-sdk
ENV SDK_URL https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
ENV GRADLE_URL https://services.gradle.org/distributions/gradle-4.5.1-all.zip
ENV ANDROID_BUILD_TOOLS_VERSION 27.0.3

RUN echo "SDK_HOME: $SDK_HOME"
RUN echo "ANDROID_BUILD_TOOLS_VERSION: $ANDROID_BUILD_TOOLS_VERSION"

WORKDIR /opt
# Download Android SDK
RUN mkdir "$SDK_HOME" .android \
 && cd "$SDK_HOME" \
 && curl --silent -o sdk.zip $SDK_URL \
 && unzip sdk.zip \
 && rm sdk.zip \
 && yes | $SDK_HOME/tools/bin/sdkmanager --licenses

ENV PATH="${SDK_HOME}/tools:${SDK_HOME}/tools/bin:${SDK_HOME}/platform-tools:${PATH}"

RUN touch /root/.android/repositories.cfg

RUN echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_HOME/licenses/android-sdk-license
RUN echo d56f5187479451eabf01fb78af6dfcb131a6481e >> $ANDROID_HOME/licenses/android-sdk-license
RUN echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_HOME/licenses/android-sdk-preview-license

RUN sdkmanager "tools" "platform-tools"
RUN sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION"
RUN sdkmanager "platforms;android-25" "platforms;android-24" "platforms;android-23"
RUN sdkmanager "platforms;android-22" "platforms;android-21" "platforms;android-20" "platforms;android-19"
RUN sdkmanager "platforms;android-18" "platforms;android-17" "platforms;android-16" "platforms;android-15"
RUN sdkmanager "extras;android;m2repository" "extras;google;m2repository"

RUN echo y | $SDK_HOME/tools/bin/sdkmanager "platforms;android-26"

# Install Gradle
#RUN wget -q $GRADLE_URL -O gradle.zip \
# && unzip gradle.zip \
# && mv gradle-4.5.1 gradle \
## && rm gradle.zip \
# && mkdir /root/.gradle

# Support Gradle
#ENV GRADLE_HOME /opt/gradle
#ENV PATH="${PATH}:${GRADLE_HOME}/bin"
ENV JAVA_OPTS "-Xms512m -Xmx1536m"
RUN echo "PATH: $PATH"
#RUN echo `which gradle`
#ENV CORDOVA_ANDROID_GRADLE_DISTRIBUTION_URL=file:///opt/gradle.zip

#ENV PATH="/opt/gradle/bin:${PATH}"

# Install Cordova and other useful globals
RUN npm update && \
    npm install -g cordova@8.0.0 && \
    npm install -g phantomjs-prebuilt --unsafe-perm

ADD client/wrappers/apk /tangerine-client/client/wrappers/apk

WORKDIR /tangerine-client/client/wrappers/apk

RUN cordova platform add android@7.0.0
RUN cordova plugin add cordova-plugin-whitelist --save
RUN cordova plugin add cordova-plugin-geolocation --save
RUN cordova plugin add cordova-plugin-camera --save
RUN cordova plugin add cordova-plugin-file --save
RUN cordova plugin add cordova-plugin-crosswalk-webview --save
RUN cordova plugin add cordova-android-support-gradle-release --save

RUN cordova build

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]