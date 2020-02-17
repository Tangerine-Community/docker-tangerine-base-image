FROM node:10.16.0-stretch

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

# Doing this in a separate stage due to cdn errors.
RUN apt-get update && apt-get -y install \
    openjdk-8-jdk

# Install Android SDK
# Set up environment variables
ENV SDK_HOME /opt/android-sdk
ENV ANDROID_HOME /opt/android-sdk
ENV SDK_URL https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
ENV GRADLE_URL https://services.gradle.org/distributions/gradle-4.10.1-all.zip
ENV ANDROID_BUILD_TOOLS_VERSION 29.0.0

RUN echo "SDK_HOME: $SDK_HOME"
RUN echo "ANDROID_BUILD_TOOLS_VERSION: $ANDROID_BUILD_TOOLS_VERSION"

WORKDIR /opt
# Download Android SDK
RUN mkdir "$SDK_HOME" .android \
 && cd "$SDK_HOME" \
 && curl --silent -o sdk.zip $SDK_URL \
 && unzip -qq sdk.zip \
 && rm sdk.zip \
 && yes | $SDK_HOME/tools/bin/sdkmanager --licenses

ENV PATH="${SDK_HOME}/tools:${SDK_HOME}/tools/bin:${SDK_HOME}/platform-tools:${PATH}"

RUN touch /root/.android/repositories.cfg

RUN echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_HOME/licenses/android-sdk-license
RUN echo d56f5187479451eabf01fb78af6dfcb131a6481e >> $ANDROID_HOME/licenses/android-sdk-license
RUN echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_HOME/licenses/android-sdk-preview-license

RUN echo y | $SDK_HOME/tools/bin/sdkmanager "tools" "platform-tools"
RUN echo y | $SDK_HOME/tools/bin/sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION"
## Android 5
RUN echo y | $SDK_HOME/tools/bin/sdkmanager "platforms;android-22" "platforms;android-21"
## Android 6 and 7
RUN echo y | $SDK_HOME/tools/bin/sdkmanager "platforms;android-25" "platforms;android-24" "platforms;android-23"
## Android 8
RUN echo y | $SDK_HOME/tools/bin/sdkmanager "platforms;android-27" "platforms;android-26"
## Android 9
RUN echo y | $SDK_HOME/tools/bin/sdkmanager "platforms;android-28"

## Mavien libs for Gradle
RUN echo y | $SDK_HOME/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;m2repository"

# Install Cordova and other useful globals
RUN npm update && \
    npm install -g cordova@8.0.0

# Install phantomjs - its download mirror can be tempermental so we use a specific mirror
RUN npm update && \
    npm install -g phantomjs-prebuilt --unsafe-perm --phantomjs_cdnurl=https://bitbucket.org/ariya/phantomjs/downloads

# Install Gradle
RUN wget -q $GRADLE_URL -O gradle.zip \
 && unzip -qq gradle.zip \
 && mv gradle-4.10.1 gradle \
# && rm gradle.zip \
 && mkdir /root/.gradle

# Support Gradle
ENV GRADLE_HOME /opt/gradle
ENV PATH="${PATH}:${GRADLE_HOME}/bin"
ENV JAVA_OPTS "-Xms512m -Xmx1536m"
RUN echo "PATH: $PATH"
RUN echo `which gradle`
ENV CORDOVA_ANDROID_GRADLE_DISTRIBUTION_URL=file:///opt/gradle.zip

RUN mkdir -p /tangerine/client/builds/apk

ADD cordova /tangerine/client/builds/apk/
WORKDIR /tangerine/client/builds/apk

RUN cordova platform add android@8 && sleep 120
RUN cordova plugin add cordova-plugin-whitelist --save && sleep 120
RUN cordova plugin add cordova-plugin-geolocation --save && sleep 120
RUN cordova plugin add cordova-plugin-camera --save && sleep 120
RUN cordova plugin add cordova-plugin-file --save && sleep 120
RUN cordova plugin add cordova-plugin-androidx-adapter --save && sleep 120
RUN cordova plugin add cordova-hot-code-push-plugin --save && sleep 120
RUN cordova plugin add cordova-plugin-nearby-connections@0.5.0 --save && sleep 120
RUN cordova plugin add cordova-sms-plugin --save && sleep 120
RUN cordova plugin add cordova-plugin-android-permissions --save && sleep 120
RUN cordova plugin add cordova-sqlcipher-adapter --save && sleep 120
RUN cordova build

WORKDIR /tangerine/client

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
