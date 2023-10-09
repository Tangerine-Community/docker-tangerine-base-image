FROM node:14.21.3-buster

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
#RUN apt-get update && apt-get -y install \
#    openjdk-8-jdk

# Install AdoptOpenJDK 8 - https://stackoverflow.com/a/59436618
RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add -
RUN add-apt-repository --yes https://packages.adoptium.net/artifactory/deb
RUN apt-get update && apt-get -y install temurin-8-jdk

# Install Android SDK
# Set up environment variables
ENV ANDROID_HOME /opt/android-sdk
# https://developer.android.com/studio#command-tools
ENV CMDLINE_TOOLS_URL https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip
ENV GRADLE_URL https://services.gradle.org/distributions/gradle-6.5-all.zip
ENV API_LEVEL=30 \
    ANDROID_BUILD_TOOLS_VERSION=30.0.2

RUN echo "ANDROID_HOME: $ANDROID_HOME"
RUN echo "ANDROID_BUILD_TOOLS_VERSION: $ANDROID_BUILD_TOOLS_VERSION"

WORKDIR /opt

ENV ANDROID_SDK_ROOT=$ANDROID_HOME \
    PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/tools:${ANDROID_HOME}/cmdline-tools/tools/bin:${ANDROID_HOME}/platform-tools
    
# Download Android SDK
RUN mkdir "$ANDROID_HOME" .android \
    && cd "$ANDROID_HOME" \
    && mkdir cmdline-tools \
    && curl -o cmdline-tools/commandlinetools.zip $CMDLINE_TOOLS_URL \
    && unzip cmdline-tools/commandlinetools.zip -d cmdline-tools \
    && rm cmdline-tools/commandlinetools.zip

# Accept all licenses
RUN yes | sdkmanager --licenses

RUN touch /root/.android/repositories.cfg

RUN echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_HOME/licenses/android-sdk-license
RUN echo d56f5187479451eabf01fb78af6dfcb131a6481e >> $ANDROID_HOME/licenses/android-sdk-license
RUN echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_HOME/licenses/android-sdk-preview-license

RUN echo y | sdkmanager "tools" "platform-tools"
RUN echo y | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION"
## Android 5
RUN echo y | sdkmanager "platforms;android-22" "platforms;android-21"
## Android 6 and 7
RUN echo y | sdkmanager "platforms;android-25" "platforms;android-24" "platforms;android-23"
## Android 8
RUN echo y | sdkmanager "platforms;android-27" "platforms;android-26"
## Android 10 and 9
RUN echo y | sdkmanager "platforms;android-29" "platforms;android-28"
## Android 11
RUN echo y | sdkmanager "platforms;android-${API_LEVEL}"

## Mavien libs for Gradle
RUN echo y | sdkmanager "extras;android;m2repository" "extras;google;m2repository"

# Install Cordova and other useful globals
RUN npm update && \
    npm install -g cordova@10.0.0

# Install Gradle
RUN wget -q $GRADLE_URL -O gradle.zip \
 && unzip -qq gradle.zip \
 && mv gradle-6.5 gradle \
# && rm gradle.zip \
 && mkdir /root/.gradle

# Support Gradle
ENV GRADLE_HOME /opt/gradle
ENV PATH="${PATH}:${GRADLE_HOME}/bin"
ENV JAVA_OPTS "-Xms512m -Xmx1536m"
RUN echo "PATH: $PATH"
RUN echo `which gradle`
ENV CORDOVA_ANDROID_GRADLE_DISTRIBUTION_URL=file:///opt/gradle.zip

RUN git clone -b 9.0.0 https://github.com/apache/cordova-android.git
ENV CORDOVA_ANDROID_DIRECTORY="/opt/cordova-android"


RUN mkdir -p /tangerine/client/builds/apk

ADD cordova /tangerine/client/builds/apk/
WORKDIR /tangerine/client/builds/apk

#RUN cordova platform add github:apache/cordova-android && sleep 30
RUN cordova platform add $CORDOVA_ANDROID_DIRECTORY --nosave && sleep 5

RUN cordova plugin add cordova-plugin-whitelist --save && sleep 5
# TODO: awaiting fix for -dev versions of cordova-android: https://github.com/apache/cordova-lib/issues/790
# So, remove the specific @ versions when this issue has been resolved.
RUN cordova plugin add cordova-plugin-geolocation@4.0.2 --save && sleep 5
RUN cordova plugin add cordova-plugin-camera@4.1.0 --save && sleep 5
RUN cordova plugin add cordova-plugin-file@6.0.2 --save && sleep 5
RUN cordova plugin add cordova-plugin-androidx --save && sleep 5
RUN cordova plugin add cordova-plugin-androidx-adapter --save && sleep 5
RUN cordova plugin add cordova-hot-code-push-plugin --save && sleep 5
RUN cordova plugin add cordova-plugin-nearby-connections@0.6.1 --save && sleep 5
RUN cordova plugin add cordova-sms-plugin --save && sleep 5
RUN cordova plugin add cordova-plugin-android-permissions --save && sleep 5
RUN cordova plugin add github:brodybits/cordova-plugin-sqlcipher-crypto-batch-connection-manager-core-pro-free#unstable-build-2020-07-15-01 --save && sleep 5
RUN cordova plugin add cordova-sqlite-storage-file --save && sleep 5
RUN cordova plugin add cordova-plugin-ml-text --save && sleep 5
RUN cordova plugin add cordova-plugin-x-socialsharing --save && sleep 5
RUN cordova build 

WORKDIR /tangerine/client

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
