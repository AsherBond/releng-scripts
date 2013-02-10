#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "must run as root"
    exit 1
fi

BUILDER_NAME=jenkins-server-x86_64

if [ ! -d ./ami-creator ]; then
	git clone git://github.com/katzj/ami-creator.git
fi

./ami-creator/ami_creator/ami_creator.py \
	-c $BUILDER_NAME.cfg \
	-n $BUILDER_NAME -v -e || exit 1

rm -rf $BUILDER_NAME

mkdir -p $BUILDER_NAME/kvm-kernel

mv $BUILDER_NAME.img $BUILDER_NAME/
mv vmlinuz* $BUILDER_NAME/kvm-kernel/
mv init* $BUILDER_NAME/kvm-kernel/

tar -czvf $BUILDER_NAME.tgz $BUILDER_NAME

echo "Install EMI: eustore-install-image -b <bucket> -a x86_64 -s $BUILDER_NAME -t $BUILDER_NAME.tgz -k kvm"

