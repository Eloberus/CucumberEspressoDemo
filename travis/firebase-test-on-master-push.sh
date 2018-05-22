#!/bin/bash
if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    gc_sdk_url=$(curl -s "https://cloud.google.com/sdk/downloads?hl=de" | grep -o "https.*google-cloud-sdk.*linux.*x86_64.*\\.tar\\.gz" | sed s/\\?.*//g)
    ${gc_sdk_url} | tar xvz

    echo ${GOOGLE_AUTH} | base64 --decode > ${HOME}/gcp-key.json
    ./travis/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file ${HOME}/gcp-key.json
    ./travis/google-cloud-sdk/bin/gcloud --quiet config set project ${PROJECT_ID}
    ./gradlew assembleAndroidTest assemble
    APK_PATH=$(find . -path "*.apk" ! -path "*unaligned.apk" ! -path "*Test*.apk" -print -quit)
    TEST_APK_PATH=$(find "." "-path" "*Test*.apk" -print -quit)
    ./travis/google-cloud-sdk/bin/gcloud firebase test android run --type instrumentation --app ${APK_PATH} --test ${TEST_APK_PATH} --device model=sailfish,version=27,locale=en,orientation=portrait --timeout 30m
fi