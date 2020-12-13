#!/bin/sh

#  Created by Samin Pour on 18/6/18.
#  Copyright © 2018 ThreatMetrix. All rights reserved.
#
# ThreatMetrix iOS SDK contains multiple architectures, armv7, armv7s, arm64, x86_64. The arm
# architectures are for devices, x86_64 is for simulators. When preparing application for publishing
# Xcode removes simulator architectures from your application, but due to a bug / design flaw it
# doesn't strip these slices from dynamic frameworks.
#
# If these architectures are not removed Apple will reject the binary.
# http://www.openradar.me/radar?id=6409498411401216#ag9zfm9wZW5yYWRhci1ocmRyFAsSB0NvbW1lbnQYgICAuO-k9QgM
# Possible error  messages in Xcode are
# 1. “iTunes Store Operation Failed: Unsupported Architectures. The executable YourApp contains unsupported architectures '[(x86_64, i386)]'”
# 2. “LC_ENCRYPTION_INFO”
# 3. “Invalid Segment Alignment”
# 4. “The binary is invalid.”
# Removing simulator slices will resolve these issues.
#
# This script automatically strips unused architectures from ThreatMetrix framework, to use it please
# add a new "Run Script Phase" to the build phase and add the content of this file there.
#
# IMPORTANT NOTE: Please make sure to add this script after "Embed Frameworks" / "Copy File(s)"  phase


APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

find "$APP_PATH" -name 'TMX*.framework' -type d | while read -r FRAMEWORK; do
    FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
    FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"

    EXTRACTED_ARCHS=()

    for ARCH in $ARCHS; do
        lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
        EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
    done

    lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
    rm "${EXTRACTED_ARCHS[@]}"

    rm "$FRAMEWORK_EXECUTABLE_PATH"
    mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"

done
