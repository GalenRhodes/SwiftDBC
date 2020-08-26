#!/bin/sh

#  docfixer.sh
#  Rubicon
#
#  Created by Galen Rhodes on 4/10/20.
#  Copyright © 2020 ProjectGalen. All rights reserved.

for i in *.xcodeproj; do
    a=$(expr ${#i} - 10)
    PROJECT="${i:0:$a}"
done

TARGET="DocFixer"
CONF="Release"
INST_DIR=./bin

#HOST="galenrhodes.com"
USER="grhodes"
HOST="goober"

if [ ! -f "bin/DocFixer" ]; then
    xcodebuild -project "${PROJECT}.xcodeproj" -scheme "${TARGET}" -configuration "${CONF}" clean || exit $?
    xcodebuild -project "${PROJECT}.xcodeproj" -scheme "${TARGET}" -configuration "${CONF}" DSTROOT="${INST_DIR}" INSTALL_PATH=/ install || exit $?
fi

bin/DocFixer "./${PROJECT}" || exit $?
rsync -avz --delete-after docs/ "${USER}@${HOST}:/var/www/html/${PROJECT}/"
exit $?
