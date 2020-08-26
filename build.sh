#!/bin/bash

for i in *.xcodeproj; do
    a=$(expr ${#i} - 10)
    PROJECT="${i:0:$a}"
done

TARGET="${PROJECT}"
INST_DIR="${HOME}/Library/Frameworks"
CONF="Release"

xcodebuild -project "${PROJECT}.xcodeproj" -scheme "${TARGET}" -configuration "${CONF}" clean
xcodebuild -project "${PROJECT}.xcodeproj" -scheme "${TARGET}" -configuration "${CONF}" DSTROOT=${INST_DIR} INSTALL_PATH=/ SKIP_INSTALL=No install

exit $?
