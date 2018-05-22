#!/bin/bash
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    echo no | android create avd --force -n test -t android-22 --abi armeabi-v7a
    emulator -avd test -no-audio -no-window &
    android-wait-for-emulator
    adb shell input keyevent 82 &
    ./gradlew build connectedCheck
fi