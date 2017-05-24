#!/bin/bash

PLATFORMS="i686-unknown-linux-gnu x86_64-unknown-linux-gnu i686-apple-darwin x86_64-apple-darwin"
BASEURL="https://static.rust-lang.org/dist"
DATE=$1
VERSION=$2

if [[ -z  $DATE ]]
then
    echo "No date supplied"
    exit -1
fi

if [[ -z  $VERSION ]]
then
    echo "No version supplied"
    exit -1
fi

for PLATFORM in $PLATFORMS
do
    URL="$BASEURL/$DATE/rust-$VERSION-$PLATFORM.tar.gz.sha256"
    curl $URL
done
