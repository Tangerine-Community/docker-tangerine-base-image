# CHANGELOG

# v4.0.0
- added cordova-plugin-ml-text plugin
- added cordova-plugin-x-socialsharing plugin and READ_EXTERNAL_STORAGE permission
- The "AndroidInsecureFileModeEnabled" preference enables the continued use of the file:// scheme.
- Set ANDROID_BUILD_TOOLS_VERSION=32.0.0 and gradle-7.3.3

# v3.8.0
- Base image is now node 18, using Debian 11 (Bullseye).

# v3.7.4
- Added android.permission.RECORD_AUDIO to config.xml
- Added android.permission.MODIFY_AUDIO_SETTINGS to config.xml

# v3.7.3
- Tweaked the edit-config property so that the new `android:largeHeap="true"` attribute will work. Also added Adaptive icons for Android.
- Update to node:14.16.1-stretch

# v3.7.2
Added `android:largeHeap="true"` to config.xml to enable larger memory use.

# v3.7.1
Saving the cordova platform version by git cloning cordova-android to /opt/cordova-android.

# v3.7.0
Updated to node:14.12.0-stretch
Updated Android API_LEVEL=30 and Android build tools to 30.0.2
Updated Cordova to 10.0.0 and its corresponding android:targetSdkVersion="29"

# v3.6.0
Updated cordova-plugin-nearby-connections plugin for Android 10.

# v3.5.4
Same sqlite plugin code, just an updated tag for it.

# v3.5.3
Added androidX plugin

# v3.5.2
Brought back version numbers of some plugins - cordova 9 still uses -dev in version, which screws up version comparison.

TODO: awaiting fix for -dev versions of cordova-android: https://github.com/apache/cordova-lib/issues/790

# v3.5.1
Updated Sqlite plugin - no background processing. 
Removed version numbers of some plugins.

# v3.5.0-rc01
Added test version of cordova-sqlite-demo-plugin and related dependency.

# Repository change
We've made a change in how this repository works. The default branch used to be v3, and the master branch a copy of the v2 branch. We have now copied v3 to master and set the default to be master. 

# v3.4.0
- add cordova-sqlcipher-adapter

# v3.3.0
- add cordova-plugin-android-permissions plugin to support permissions dialog
- increment cordova-plugin-nearby-connections@0.5.0
