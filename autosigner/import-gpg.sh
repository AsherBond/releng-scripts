#!/bin/bash

if [ $# -ne 2 ]; then
    echo "usage `basename $0` <private-siging-key> <gpg-dir>" 1>&2
    exit 1
fi

key_file=$1
export GNUPGHOME=$2

echo "Creating GPG directory with key"
[ -d $GNUPGHOME ] && rm -rf $GNUPGHOME

mkdir -p $GNUPGHOME

keyid=$(gpg --with-fingerprint $key_file | head -n 1 | awk '{print $2}' | cut -d'/' -f2)

if [ $? -ne 0 ] || [ "$keyid" = "" ]; then
    echo "Failed to get key id!" 1>&2
    exit 1
fi

# Inject key id into package signing script
sed -e "s/^\(.*\)@KEYID@/\1$keyid/" sign-pkg.sh.in > sign-pkg.sh
chmod 755 sign-pkg.sh

if ! gpg --import $key_file &>/dev/null; then
    echo "Failed to create GPG directory!" 1>&2
    exit 1
fi

exit 0

