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
    netcat-traditional

# Install node and some node based services
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
  && apt-get -y install nodejs \
  && npm install -g pm2 \
  && npm install -g bower \
  && npm install -g npm

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
  && /bin/bash -l -c "rvm install ruby-2.4.3" \
  && /bin/bash -l -c "rvm install ruby-2.4.3-dev" \
  && /bin/bash -l -c "rvm --default use ruby-2.4.3" \
  && /bin/bash -c "source /usr/local/rvm/bin/rvm && gem install bundler --no-ri --no-rdoc "
ENV PATH /usr/local/rvm/rubies/ruby-2.4.3/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV GEM_PATH /usr/local/rvm/rubies/ruby-2.4.3
ENV GEM_HOME /usr/local/rvm/rubies/ruby-2.4.3

RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Set up environment variables
ENV SDK_HOME /opt/android-sdk
ENV ANDROID_HOME /opt/android-sdk
ENV SDK_URL https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
#ENV GRADLE_URL https://services.gradle.org/distributions/gradle-4.5.1-all.zip
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

# Support Gradle
ENV JAVA_OPTS "-Xms512m -Xmx1536m"
#ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"

# Install Cordova and other useful globals
RUN npm update && \
    npm install -g cordova@6 && \
    npm install -g phantomjs-prebuilt --unsafe-perm

# create test app
RUN cordova create hello com.example.hello HelloWorld

WORKDIR /opt/hello

RUN cordova platform add android@6.3.0
RUN cordova plugin add cordova-plugin-whitelist --save
RUN cordova plugin add cordova-plugin-geolocation --save
RUN cordova plugin add cordova-plugin-camera --save
RUN cordova plugin add cordova-plugin-crosswalk-webview --save

RUN cordova build

RUN echo `which gradle`

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]