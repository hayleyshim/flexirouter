#!/bin/bash

set -e  # exit on the first command failure
#set -x  # echo executed commands while expanding variables

# keep track of the last executed command
trap 'last_status=$?; last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'if [ $last_status == 0 ]; then echo "DONE"; else echo "ABORTED !"; fi' EXIT

# Parse arguments
INSTALL_ROOT=
if [ "$1" != "" ]; then
    mkdir -p $1
    INSTALL_ROOT=$(realpath $1)
fi

function copy_vpp_binaries {
    SRC_DIR=$1/
    DST_DIR=$INSTALL_ROOT$2
    SRC_FILES=
    if [ "$3" != "" ]; then
        SRC_FILES="-name $3"
    fi

    if [ ! -d $DST_DIR ]; then
        sudo mkdir -p $DST_DIR
    fi
    find $SRC_DIR -maxdepth 1 -type f $SRC_FILES | sudo xargs -I {} cp {} $DST_DIR/
    find $SRC_DIR -maxdepth 1 -type l $SRC_FILES | sudo xargs -I {} cp {} $DST_DIR/
}

cd vpp

VPP_PATH=`pwd`
VPP_PATH_BINARIES=$VPP_PATH/build-root/build-vpp_debug-native/vpp

copy_vpp_binaries $VPP_PATH_BINARIES/bin             /usr/bin                  "*vpp*"
copy_vpp_binaries $VPP_PATH_BINARIES/lib             /usr/lib/x86_64-linux-gnu
copy_vpp_binaries $VPP_PATH_BINARIES/lib/vpp_plugins /usr/lib/vpp_plugins
if [ ! -f $INSTALL_ROOT/etc/vpp/startup.conf ]; then
    copy_vpp_binaries $VPP_PATH/src/vpp/conf /etc/vpp "startup.conf"
fi
if [ ! -f $INSTALL_ROOT/etc/sysctl.d/80-vpp.conf ]; then
    copy_vpp_binaries $VPP_PATH/src/vpp/conf /etc/sysctl.d "80-vpp.conf"
fi

cd $VPP_PATH
