#!/bin/sh

# a fairly simple script to merge a given tree into an existing,
# bootable ramdisk.  a new ramdisk is created since space may be an
# issue (especially if we start letting people put their own files in
# here to preserve across the install).

unset LANG

unset PATH
export PATH=/sbin:/bin:/usr/sbin:/usr/bin

SOURCE_INITRD=$1
DEST_INITRD=$2
USER_TREE=$3

# Make sure we get the full pathnames.

SOURCE_INITRD=`(cd \`dirname $SOURCE_INITRD\` ; pwd)`/`basename $SOURCE_INITRD`
DEST_INITRD=`(cd \`dirname $DEST_INITRD\` ; pwd)`/`basename $DEST_INITRD`
USER_TREE=`(cd $USER_TREE ; pwd)`

fatal() {
    err=$1; shift; echo "$*"; exit $err
}

usage() {
    fatal 1 "Usage: $0 SOURCERD DESTRD /path/to/merge/from"
}

tarcp() {
    source=$1
    dest=$2

    mkdir -p $dest
    tar cf - -C $source . | tar xf - -C $dest
}

# Constants for use with the below function.
INITRD_TYPE_CPIO=1
INITRD_TYPE_EXT2=2

# $1 - The file to check.
get_initrd_type() {
    local UNCOMPRESSED_INITRD=$1

    INITRD_TYPE=-1
    if file $UNCOMPRESSED_INITRD | grep cpio > /dev/null 2>&1 ; then
        INITRD_TYPE=$INITRD_TYPE_CPIO
    elif file $UNCOMPRESSED_INITRD | grep ext2 > /dev/null 2>&1 ; then
        INITRD_TYPE=$INITRD_TYPE_EXT2
    fi

    return $INITRD_TYPE
}

uncompress_rd() {
    local COMPRESSED_INITRD=$1
    local UNCOMPRESSED_INITRD=$2
    if ! zcat $COMPRESSED_INITRD > $UNCOMPRESSED_INITRD 2> /dev/null; then
        xzcat $COMPRESSED_INITRD > $UNCOMPRESSED_INITRD
    fi
}

# Expands the provided initrd file into the specified directory.  Returns the
# uncompressed directory in the EXPANDED_TREE argument.
expand_rd() {
    local UNCOMPRESSED_INITRD=$1
    local TARGET_TREE=$2

    get_initrd_type $UNCOMPRESSED_SOURCE_INITRD
    local INITRD_TYPE=$?

    mkdir -p $TARGET_TREE

    if [ $INITRD_TYPE -eq $INITRD_TYPE_EXT2 ] ; then

        mount -o loop $UNCOMPRESSED_INITRD $TARGET_TREE \
            || fatal 3 "mount loopback failed"

    elif [ $INITRD_TYPE -eq $INITRD_TYPE_CPIO ] ; then

        cd $TARGET_TREE
        ( cat $UNCOMPRESSED_INITRD | \
            cpio -i -d -H newc --no-absolute-filenames ) > /dev/null 2>&1
        cd - > /dev/null 2>&1

    else
        fatal 9 "Unknown initrd type"
    fi
}

create_rd() {
    local INITRD_TYPE=$1
    local TARGET_INITRD=$2
    local EXISTING_TREE=$3
    local ESTIMATED_INITRD_SIZE=$4

    if [ $INITRD_TYPE -eq $INITRD_TYPE_EXT2 ] ; then

        dd if=/dev/zero      \
           of=$TARGET_INITRD \
           bs=1024           \
           count=$(($ESTIMATED_INITRD_SIZE/1024)) &> /dev/null
        mke2fs -Fq -i 4096 $TARGET_INITRD &> /dev/null

        # Now that we've created the target image, copy the contents of the
        # tree into it.

        local TARGET_MOUNTED=$TEMP_DIR/target-mounted
        mkdir $TARGET_MOUNTED
        mount -o loop $TARGET_INITRD $TARGET_MOUNTED || \
            fatal 6 "mount of dest image"
        tarcp $EXISTING_TREE $TARGET_MOUNTED
        umount $TARGET_MOUNTED

    elif [ $INITRD_TYPE -eq $INITRD_TYPE_CPIO ] ; then

        cd $EXISTING_TREE
        ( find . | cpio -o -H newc > $TARGET_INITRD ) > /dev/null 2>&1
        cd - > /dev/null 2>&1

    else
        fatal 9 "Unknown initrd type"
    fi
}

compress_rd() {
    local UNCOMPRESSED_INITRD=$1
    local COMPRESSED_INITRD=$2

    (gzip -9c $UNCOMPRESSED_INITRD > $COMPRESSED_INITRD) \
        || fatal 7 "compressing into dest"
}

estimate_merged_rd_size() {
    local SOURCE_TREE=$1
    local MERGED_TREE=$2
    local RESULT_ASSN=$3

    # time for some arithmetic; add 20% to the dest size, even though we
    # should have a pretty good estimate of space.  nothing lost since
    # gzip will turn the empty expanses of zeros into almost nothing

    local ORIG_SIZE=$(du -s -b $SOURCE_TREE | cut -f 1)
    local MERGED_SIZE=$(du -s -b $MERGED_TREE | cut -f 1)
    local DELTA="$(($MERGED_SIZE - $ORIG_SIZE))"
    zcat $SOURCE_INITRD >& /dev/null && local ORIG_RD_SIZE=$(zcat $SOURCE_INITRD | wc -c)
    xzcat $SOURCE_INITRD >& /dev/null && local ORIG_RD_SIZE=$(xzcat $SOURCE_INITRD | wc -c)
    local MERGED_RD_SIZE="$(( 12 * ($ORIG_RD_SIZE + $DELTA) / 10 ))"

    eval "$RESULT_ASSN=\"$MERGED_RD_SIZE\""
}

remove_tree() {
    local TREE_TO_REMOVE=$1

    # The tree may or may not be mounted, depending on the type of initrd
    # that was used to create it.

    umount $TREE_TO_REMOVE > /dev/null 2>&1
    rm -rf $TREE_TO_REMOVE
}

################################ Main #########################################

[ -e "$SOURCE_INITRD" ] || usage

[ -d "$USER_TREE" ] || usage

TEMP_DIR=$(mktemp -d /tmp/mergerd.XXXXXX)
[ -d $TEMP_DIR ] || fatal 2 "mktemp failed"

COMPRESSED_SOURCE_INITRD=$SOURCE_INITRD
UNCOMPRESSED_SOURCE_INITRD=$TEMP_DIR/source-rd
SOURCE_TREE=$TEMP_DIR/source-tree

COMPRESSED_MERGED_INITRD=$DEST_INITRD
UNCOMPRESSED_MERGED_INITRD=$TEMP_DIR/merged-rd
MERGED_TREE=$TEMP_DIR/merged-tree

# Uncompress and expand the source initrd image.

uncompress_rd $COMPRESSED_SOURCE_INITRD $UNCOMPRESSED_SOURCE_INITRD
expand_rd $UNCOMPRESSED_SOURCE_INITRD $SOURCE_TREE

# Merge the source's and the user's trees together into a new tree.

tarcp $SOURCE_TREE $MERGED_TREE || fatal 4 "copy from source to dest"
tarcp $USER_TREE $MERGED_TREE || fatal 5 "copy of merge tree into rd"

# Determine the type of the initrd and create a new one.

estimate_merged_rd_size $SOURCE_TREE $MERGED_TREE ESTIMATED_SIZE
get_initrd_type $UNCOMPRESSED_SOURCE_INITRD
SOURCE_INITRD_TYPE=$?
create_rd $SOURCE_INITRD_TYPE         \
          $UNCOMPRESSED_MERGED_INITRD \
          $MERGED_TREE                \
          $ESTIMATED_SIZE

# Compress the new initrd image.

compress_rd $UNCOMPRESSED_MERGED_INITRD $COMPRESSED_MERGED_INITRD

# Clean up.

remove_tree $SOURCE_TREE
remove_tree $MERGED_TREE
rm -Rf $TEMP_DIR

