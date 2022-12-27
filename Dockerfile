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

# Doing this in a separate stage due to cdn errors.
RUN apt-get update && apt-get -y install \
    openjdk-11-jdk

# Install Android SDK
# Set up environment variables
ENV ANDROID_HOME /opt/android-sdk
# https://developer.android.com/studio#command-tools
ENV CMDLINE_TOOLS_URL https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip
ENV GRADLE_URL https://services.gradle.org/distributions/gradle-7.3.3-all.zip
ENV API_LEVEL=32 \
    ANDROID_BUILD_TOOLS_VERSION=32.0.0

RUN echo "ANDROID_HOME: $ANDROID_HOME"
RUN echo "ANDROID_BUILD_TOOLS_VERSION: $ANDROID_BUILD_TOOLS_VERSION"

WORKDIR /opt

ENV ANDROID_SDK_ROOT=$ANDROID_HOME \
    PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools
    
# Download Android SDK
RUN mkdir "$ANDROID_HOME" .android \
    && cd "$ANDROID_HOME" \
#    && mkdir cmdline-tools \
    && curl -o commandlinetools.zip $CMDLINE_TOOLS_URL \
    && unzip commandlinetools.zip \
    && rm commandlinetools.zip \
    && cp -R cmdline-tools latest \
    && mv latest cmdline-tools/latest

# Accept all licenses
RUN yes | sdkmanager --licenses

RUN touch /root/.android/repositories.cfg

#RUN echo y | sdkmanager --channel=3 emulator

RUN echo "uname: $(uname -m)"

# Emulator and Platform tools
RUN yes | sdkmanager "emulator" "platform-tools"

RUN echo y | sdkmanager "tools"
RUN echo y | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION"
## Android 5
RUN echo y | sdkmanager "platforms;android-21" "platforms;android-22"
## Android 6 and 7
RUN echo y | sdkmanager "platforms;android-23" "platforms;android-24" "platforms;android-25"
## Android 8
RUN echo y | sdkmanager "platforms;android-26" "platforms;android-27" "platforms;android-28"
## Android 10 and 9
RUN echo y | sdkmanager "platforms;android-29" "platforms;android-30"  "platforms;android-31"

RUN echo y | sdkmanager "platforms;android-${API_LEVEL}"

## Mavien libs for Gradle
RUN echo y | sdkmanager "extras;android;m2repository" "extras;google;m2repository"

# Workaround for a dependency that demands build-tools 32.
RUN echo y | sdkmanager "build-tools;32.0.0"

# Install Cordova and other useful globals
RUN npm update && \
    npm install -g cordova@11.0.0

# Install Gradle
RUN wget -q $GRADLE_URL -O gradle.zip \
 && unzip -qq gradle.zip \
 && mv gradle-7.3.3 gradle \
 && mkdir /root/.gradle

# Support Gradle
ENV GRADLE_HOME /opt/gradle
ENV PATH="${PATH}:${GRADLE_HOME}/bin"
ENV JAVA_OPTS "-Xms512m -Xmx1536m"
ENV CORDOVA_ANDROID_GRADLE_DISTRIBUTION_URL=file:///opt/gradle.zip

RUN mkdir -p /tangerine/client/builds/apk

ADD cordova /tangerine/client/builds/apk/
WORKDIR /tangerine/client/builds/apk

RUN cordova platform add android@11 && sleep 5

RUN cordova plugin add cordova-plugin-geolocation@4.1.0 --save && sleep 5
RUN cordova plugin add cordova-plugin-camera@6.0.0 --save && sleep 5
RUN cordova plugin add cordova-plugin-file@7.0.0 --save && sleep 5
RUN cordova plugin add cordova-plugin-androidx --save && sleep 5
RUN cordova plugin add cordova-plugin-androidx-adapter --save && sleep 5
RUN cordova plugin add github:Tangerine-Community/cordova-hot-code-push --save && sleep 5
RUN cordova plugin add cordova-plugin-nearby-connections@0.6.1 --save && sleep 5
RUN cordova plugin add cordova-sms-plugin --save && sleep 5
RUN cordova plugin add cordova-plugin-android-permissions --save && sleep 5
RUN cordova plugin add github:brodybits/cordova-plugin-sqlcipher-crypto-batch-connection-manager-core-pro-free#unstable-build-2020-07-15-01 --save && sleep 5
RUN cordova plugin add cordova-sqlite-storage-file --save && sleep 5

RUN echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f $(type -P java))))" > /etc/profile.d/javahome.sh

RUN cordova build

WORKDIR /tangerine/client

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
