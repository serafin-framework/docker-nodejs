#!/usr/bin/env sh

if [ ! -z $TIMEZONE ]; then
    /opt/docker/startup-timezone.sh $TIMEZONE
fi

if [ ! -z $BUILD ]; then
    if [ $BUILD = "dev" ]; then BUILD='-d'; else BUILD=''; fi
    /opt/docker/build.sh $BUILD $GIT_BUCKET $GIT_BRANCH
fi

if [ $# -gt 0 ]; then
    echo "Executing: $*"
    $*
fi