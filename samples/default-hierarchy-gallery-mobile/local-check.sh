#
# Copyright 2024 IceRock MAG Inc. Use of this source code is governed by the Apache 2.0 license.
#

set -e

log() {
  echo "\033[0;32m> $1\033[0m"
}

./gradlew clean assembleDebug
log "default-hierarchy-gallery-mobile android success"

if ! command -v xcodebuild &> /dev/null
then
    echo "xcodebuild could not be found, skip ios checks"

    ./gradlew build
    log "default-hierarchy-gallery-mobile full build success"
else
    ./gradlew clean compileKotlinIosX64
    log "default-hierarchy-gallery-mobile ios success"

    ./gradlew clean podspec build generateDummyFramework --rerun-tasks
    log "default-hierarchy-gallery-mobile full build success"

    (
    cd ios-app &&
    pod install &&
    set -o pipefail &&
    xcodebuild -scheme TestProj -workspace TestProj.xcworkspace -configuration Debug -destination "generic/platform=iOS Simulator" build CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO | xcpretty
    )
    log "default-hierarchy-gallery-mobile ios xcode success"
fi