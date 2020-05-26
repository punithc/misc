#!/bin/bash


current_time=$(date "+%Y%m%d%H%M%S")
WORKING_DIR=$PWD

# ISO IMAGE_URL
URL=$1
ISO_FILE="${URL##*/}"
ISO_FILE_NEW="$(echo $ISO_FILE | sed 's/\(.*\).iso/\1_v2.iso/g')"
CUSTOM_ISO_DIR=$WORKING_DIR/centos_$current_time
ISO_EXTRACT_DIR=/tmp/centos_$current_time


# Download the ISO image
if [ ! -f $ISO_FILE ]; then
        wget $URL
fi

if [ -f $ISO_FILE_NEW ]; then
        rm -rf $ISO_FILE_NEW
fi

mkdir $ISO_EXTRACT_DIR
mount -o loop $WORKING_DIR/$ISO_FILE $ISO_EXTRACT_DIR
mkdir $CUSTOM_ISO_DIR

cp -r $ISO_EXTRACT_DIR/* $CUSTOM_ISO_DIR/

umount $ISO_EXTRACT_DIR
rm -rf $ISO_EXTRACT_DIR

chmod -R u+w $CUSTOM_ISO_DIR
yes | cp -rf $WORKING_DIR/rpms/*.rpm $CUSTOM_ISO_DIR/Packages/

cd $CUSTOM_ISO_DIR/Packages/ && createrepo -dpo .. .

for file in $(ls $CUSTOM_ISO_DIR/repodata/*comps*.xml); do createrepo --update -g $file $CUSTOM_ISO_DIR/; done

cd $CUSTOM_ISO_DIR/ && mkisofs -o $WORKING_DIR/$ISO_FILE_NEW -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -V "CentOS 7 x86_64" -R -J -v -T isolinux/. $CUSTOM_ISO_DIR/
implantisomd5 $WORKING_DIR/$CUSTOM_ISO_FILE

rm -rf $CUSTOM_ISO_DIR


