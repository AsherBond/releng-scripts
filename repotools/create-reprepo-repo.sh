#!/bin/sh

set -e

if [ $UID != "0" ]; then
  echo "This program must be run with root privs"
  exit 1
fi

if [ "$#" -lt 3 ] ; then
  echo "Usage: $0 <repo> <distro> <release> <version>" >&2
  exit 1
fi

REPO=$1
DISTRO=$2
RELEASE=$3
VERSION=$4

REPOSITORY="/srv/software/releases/$REPO/$VERSION/$DISTRO"

mkdir -p "${REPOSITORY}"/conf
mkdir -p "${REPOSITORY}"/tmp
mkdir -p "${REPOSITORY}"/log
mkdir -p "${REPOSITORY}"/morgue
mkdir -p "${REPOSITORY}"/incoming/$RELEASE

touch ${REPOSITORY}/conf/incoming
touch ${REPOSITORY}/conf/distributions

if grep -q "^Codename: ${RELEASE}$" "${REPOSITORY}"/conf/distributions ; then
  echo "Codename/repository $RELEASE exists already, ignoring request to add again."
  exit 0
fi

cat >> "${REPOSITORY}"/conf/distributions << EOF

Codename: $RELEASE
AlsoAcceptFor: unstable $RELEASE
Architectures: amd64 i386 source
Components: main
DebIndices: Packages Release . .gz
DscIndices: Sources Release .gz
Tracking: minimal
EOF

if ! grep -q "^Name: $RELEASE$" "${REPOSITORY}/conf/incoming" 2>/dev/null ; then

cat >> "${REPOSITORY}/conf/incoming" << EOF

Name: $RELEASE
IncomingDir: incoming/$RELEASE
TempDir: tmp
LogDir: log
MorgueDir: ${REPOSITORY}/morgue
Allow: unstable>$RELEASE
Cleanup: unused_files on_deny on_error
EOF

fi
