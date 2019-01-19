#!/bin/bash
set -xe

if ! which docker; then
    echo "docker engine not installed"
    exit 1
fi
# Check if we have docker running and accessible
# as the current user
# If not bail out with the default error message
docker ps

if [ "$1" != "" ]; then
  DOCKERFILE="Dockerfile-$1"
else
  DOCKERFILE='Dockerfile'
fi
FPM_IMAGE='prometheus-blackbox-exporter'
BUILD_ARTIFACTS_DIR='deb-package'

BINARY_NAME='prometheus-blackbox-exporter'
VERSION_STRING="$(cat VERSION)-1"


# check all the required environment variables are supplied
[ -z "$DEB_PACKAGE_NAME" ] && DEB_PACKAGE_NAME='prometheus-blackbox-exporter'
[ -z "$DEB_PACKAGE_DESCRIPTION" ] && DEB_PACKAGE_DESCRIPTION='Prometheus blackbox exporter for machine metrics'
[ -z "$PKG_VENDOR" ] && PKG_VENDOR='Oleh Halytskyi'
[ -z "$PKG_MAINTAINER" ] && PKG_MAINTAINER='Oleh Halytskyi'
[ -z "$PKG_URL" ] && PKG_URL='https://github.com/Halytskyi/prometheus-blackbox_exporter-deb'

docker build --build-arg \
    version=`cat VERSION` \
    --build-arg \
    version_string=$VERSION_STRING \
    --build-arg \
    binary_name=$BINARY_NAME \
    --build-arg \
    deb_package_name=$DEB_PACKAGE_NAME  \
    --build-arg \
    deb_package_description="$DEB_PACKAGE_DESCRIPTION" \
    --build-arg \
    pkg_vendor="$PKG_VENDOR" \
    --build-arg \
    pkg_maintainer="$PKG_MAINTAINER" \
    --build-arg \
    pkg_url="$PKG_URL" \
    -t $FPM_IMAGE -f $DOCKERFILE .
containerID=$(docker run -dt $FPM_IMAGE)
# docker cp does not support wildcard:
# https://github.com/moby/moby/issues/7710
mkdir -p $BUILD_ARTIFACTS_DIR
docker cp $containerID:/deb-package/${DEB_PACKAGE_NAME}-${VERSION_STRING}.deb $BUILD_ARTIFACTS_DIR/.
sleep 1
docker rm -f $containerID
