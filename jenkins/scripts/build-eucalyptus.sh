#!/bin/bash

# Variables defined by Jenkins with defaults
platform=${platform:-centos-6-x86_64}
MODE=${MODE:-prerelease}
GIT_BRANCH=${GIT_BRANCH:-testing}
BUILD_TAG=${BUILD_TAG:-0}
BUILD_NUMBER=${BUILD_NUMBER:-0}
JENKINS_URL=${JENKINS_URL:-http://jenkins.release.eucalyptus-systems.com}

# Git Repositories
EUCA_REPO=git://github.com/eucalyptus/eucalyptus.git
CLOUDLIB_REPO=git://github.com/eucalyptus/eucalyptus-cloud-libs.git
RPMFAB_REPO=git://github.com/gholms/rpmfab.git
SPEC_REPO=git://github.com/eucalyptus/eucalyptus-rpmspec.git
EUCAGIT="git --git-dir=eucalyptus/.git"

if [ ! -d eucalyptus ]; then
    git clone $EUCA_REPO
fi

if [ -n "$commit_override" ]; then
    $EUCAGIT clean -f
    $EUCAGIT checkout -f $commit_override
else
    $EUCAGIT checkout $GIT_BRANCH
    $EUCAGIT pull origin $GIT_BRANCH
fi

if [ ! -d eucalyptus-cloud-libs ]; then
    git clone $CLOUDLIB_REPO
fi

git --git-dir=eucalyptus-cloud-libs/.git archive \
    --format=tar HEAD | gzip > cloud-lib.tar.gz

# Tarball
cat > git-info.properties << EOF
MODE=$MODE
GIT_URL=$($EUCAGIT remote show -n origin | sed -n '/Fetch URL:/s/^[^:]*: //p')
GIT_BRANCH=$GIT_BRANCH
GIT_COMMIT=$($EUCAGIT rev-parse HEAD)
GIT_ABBREV_COMMIT=$($GIT_COMMIT | cut -c-8)
GIT_COMMIT_LENGTH=$($EUCAGIT log --oneline --first-parent | wc -l)
TARBALL_VERSION=$(cat eucalyptus/VERSION)
TARBALL_SUFFIX=$(eval echo $tar_suffix)
EOF

eval `cat git-info.properties`

$EUCAGIT archive --format=tar \
    --prefix=eucalyptus-${TARBALL_VERSION}${TARBALL_SUFFIX}/ \
    HEAD | gzip > eucalyptus-${TARBALL_VERSION}${TARBALL_SUFFIX}.tar.gz

# Eucalyptus SRPM
if [ ! -d rpmfab ]; then
    git clone -b master $RPMFAB_REPO rpmfab
fi

git --git-dir=rpmfab/.git pull origin master

BUILD_ID=
TARBALL_OPT=

if [ "$TARBALL_SUFFIX" != "" ]; then
    COMMON_OPTS="$COMMON_OPTS -m \"tar_suffix=${TARBALL_SUFFIX}\""
fi

if [ "$MODE" = "prerelease" ]; then
    BUILD_ID="0.${BUILD_NUMBER}.@DATE@git${GIT_ABBREV_COMMIT}"
elif [ "$MODE" = "postrelease" ]; then
    BUILD_ID="${BUILD_NUMBER}.@DATE@git${GIT_ABBREV_COMMIT}"
elif [ "$MODE" = "release" ]; then
    if [ -n "$TARBALL_SUFFIX" ]; then
        BUILD_ID="${BUILD_NUMBER}.$(echo $TARBALL_SUFFIX | sed 's/^-*//')"
    else
        BUILD_ID="${BUILD_NUMBER}"
    fi
fi

platform_url=$JENKINS_URL/userContent/mock/$platform.cfg

rpmfab/build-srpm-from-scm.py -c "$platform_url" -w . -o results \
    --mock-options "--uniqueext $BUILD_TAG" -m "build_id=$BUILD_ID" \
    -m "abi_version=${GIT_COMMIT}" \
    $TARBALL_OPT \
    -f eucalyptus-*.tar.gz -f cloud-lib.tar.gz \
    "${SPEC_REPO}#${GIT_BRANCH}"

# Eucalyptus RPM
rpmfab/build-arch.py -c "$platform_url" -o results \
    --mock-options "--uniqueext $BUILD_TAG" results/*.src.rpm

