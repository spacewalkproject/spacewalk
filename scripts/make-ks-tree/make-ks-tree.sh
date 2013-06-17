#!/bin/sh
#

usage() {
    echo "Usage:"
    echo "$0 [OPTIONS]"
    echo "Creates a kickstart tree for a channel"
    echo
    echo "  OPTIONS:"
    echo "    --help		display usage and exit"
    echo "    --channel		create a kickstart tree for this base channel (channel label, i.e. fedora-9-i386)"
    echo "    --update		use this to specify a base channel update (u2/u4/etc)"
    echo "    --source		location of exploded distribution directory including arch"
    echo "    --dsn		database connect string (i.e. spacewalk/spacewalk@xe)"
    echo "    --install-type	type of kickstart install tree [ rhel_2.1 | rhel_3 | rhel_4 | rhel_5 ]"
    echo "    --variant         the variant for the distribution.  Applies to rhel_5 install types only. [ server | client | ppc | s390x | centos ]"
    echo "    --override	override missing packages from the lint step -- use with caution --"
    echo "    --clear      	clear the trees as you add files (advanced use only)"
    echo "    --commit          commit addition of files to database (verify first)"
    echo "    --debug		set debug level"
    echo
    echo "Example:"
    echo "  $0 --channel fedora9   --source /mnt/f9iso/ --dsn spacewalk/spacewalk@xe --install-type fedora_9 [[ --commit ]"
    exit $1
}

while true; do
    case "$1" in
        --help)
            usage 0
            ;;
        --channel)
            case "$2" in
                "") echo "No parameter specified for --channel"; break;;
                *)  CHANNEL=$2; shift 2;;
            esac;;
        --update)
            case "$2" in
                "") echo "No parameter specified for --update"; break;;
                *)  UPDATE=$2; shift 2;;
            esac;;
        --source)
            case "$2" in
                "") echo "No parameter specified for --source"; break;;
                *)  SOURCE=$2; shift 2;;
            esac;;
        --dsn)
            case "$2" in
                "") echo "No parameter specified for --dsn"; break;;
                *)  DSN=$2; shift 2;;
            esac;;
        --install-type)
            case "$2" in
                "") echo "No parameter specified for --install-type"; break;;
                *)  INSTALL_TYPE=$2; shift 2;;
            esac;;
        --variant)
            case "$2" in
                "") echo "No parameter specified for --variant"; break;;
                *)  VARIANT=$2; shift 2;;
            esac;;
        --debug)
            case "$2" in
                "") echo "No parameter specified for --debug"; break;;
                *)  DEBUG=$2; shift 2;;
            esac;;
        --base)
            case "$2" in
                "") echo "No parameter specified for --base"; break;;
                *)  BASE=$2; shift 2;;
            esac;;
        --commit)
            COMMIT="1"; shift;;
        --clear)
            CLEAR="--clear"; shift;;
        --override)
            OVERRIDE="1"; shift;;
        "") break;;
        *) echo "Unknown keywords $*"; usage 1;;
    esac
done

DEBUG=${DEBUG:--1}
BASE=${BASE:-/var/satellite/rhn/kickstart}

[ -z "$CHANNEL" ] && echo "Missing --channel" && usage 1
[ -z "$SOURCE" ] && echo "Missing --source" && usage 1
[ -z "$DSN" ] && echo "Missing --dsn" && usage 1
[ -z "$INSTALL_TYPE" ] && echo "Missing --install-type" && usage 1

# A variant option is required for rhel_5 and above.  Make sure it's there if
# needed.

if [ -z "$VARIANT" ] ; then
    if [ $INSTALL_TYPE = "rhel_5" ] ; then
        echo "The --variant option is required when using the $INSTALL_TYPE install type."
        usage 1
    fi
else
    case $INSTALL_TYPE in
        rhel_5)
            case $VARIANT in
                server) ;;
                client) ;;
                ppc) ;;
                s390x) ;;
		centos) ;;
                *)  echo "Invalid variant specified: $VARIANT" ; usage 1 ;;
            esac
            ;;

        # Ignore the variant option for non-relevant install types.
        *) VARIANT="" ;;
    esac
fi

populate_component_list() {
    case $INSTALL_TYPE in
        rhel_2.1) COMPONENTS="RedHat/RPMS" ;;
        rhel_3)   COMPONENTS="RedHat/RPMS" ;;
        rhel_4)   COMPONENTS="RedHat/RPMS" ;;
	fedora_9)   COMPONENTS="Packages" ;;
        rhel_5)
            case $VARIANT in
                server)  COMPONENTS="Server         \
                                     Cluster        \
                                     ClusterStorage \
                                     VT" ;;
                client)  COMPONENTS="Client         \
                                     VT             \
                                     Workstation" ;;
                   ppc)  COMPONENTS="Server         \
                                     Cluster        \
                                     ClusterStorage" ;;
                 s390x)  COMPONENTS="Server" ;;
		centos)  COMPONENTS="CentOS";; 
                *) echo "Unknown variant: $VARIANT" ; exit 1 ;;
            esac ;;

        *) echo "Unknown install type: $INSTALL_TYPE" ; exit 1 ;;
    esac
}

create_remote_tree_dir() {
    [ "$DEBUG" -gt 0 ] && return
    if [ -z "$UPDATE" ]; then
	KSLABEL=ks-$CHANNEL
    else
	KSLABEL=ks-$CHANNEL-$UPDATE
    fi
    REMOTE_DIR=$BASE/$KSLABEL
 
if [ ! -d "$REMOTE_DIR" ]; then
    mkdir -p $REMOTE_DIR
    chown -R apache:apache $REMOTE_DIR
fi
}

create_tree() {
    [ "$DEBUG" -gt 1 ] && return
    if [ -d "$SOURCE" ]; then
	if [ -z "$UPDATE" ]; then
	    KSLABEL=ks-$CHANNEL
	else
	    KSLABEL=ks-$CHANNEL-$UPDATE
	fi
        
        # Exclude RPMS in all collections.
        EXCLUDE_COLL_PART=""
        for COMPONENT in $COMPONENTS ; do
            EXCLUDE_COLL_PART="$EXCLUDE_COLL_PART --exclude $COMPONENT/*.rpm"
        done

	rsync --delete --exclude 'RedHat/instimage' --exclude 'SRPMS' \
              $EXCLUDE_COLL_PART -varP -essh $SOURCE/ $BASE/$KSLABEL/

        if [ -n "$VARIANT" ] ; then
                if [ $VARIANT == "ppc" ]; then
                      rsync --delete --exclude 'RedHat/instimage' --exclude 'SRPMS' \
                            $EXCLUDE_COLL_PART -varP -essh $SOURCE/ppc/ppc64/ $BASE/$KSLABEL/images/pxeboot/
                      rsync --delete --exclude 'RedHat/instimage' --exclude 'SRPMS' \
                            $EXCLUDE_COLL_PART -varP -essh $SOURCE/ppc/ppc64/ramdisk.image.gz $BASE/$KSLABEL/images/pxeboot/initrd.img
                fi
        fi
    else
	echo "Source directory ($SOURCE) not found..."
	exit 1
    fi
}

lint_tree() {
    [ "$DEBUG" -gt 2 ] && return
    for COMPONENT in $COMPONENTS ; do
        find $SOURCE/$COMPONENT -type f -name '*.rpm' | \
            xargs perl kickstart-lint.pl --dsn $DSN --channel $CHANNEL --lookaside $BASE/$KSLABEL
    done
}
     
add_tree() {
    [ "$DEBUG" -gt 3 ] && set -x
    if [ -z "$COMMIT" ]; then
	echo "--commit not specified"
    else
	if [ -z "$UPDATE" ]; then
	    KSLABEL=ks-$CHANNEL
	else
	    KSLABEL=ks-$CHANNEL-$UPDATE
	fi
	find $BASE/$KSLABEL -type f | \
	    xargs perl add-kstree.pl $CLEAR --install_type $INSTALL_TYPE \
	    --dsn $DSN --label $KSLABEL --channel $CHANNEL --tree_type rhn-managed
    fi
}

# exit if something goes wrong
set -e

# determine which directories are RPM-providing components of the tree
populate_component_list

# first create the remote tree
echo "Creating remote kickstart tree directory "
create_remote_tree_dir
echo "... done"

# create the actual kickstart tree
echo "Populating kickstart tree "
create_tree
echo "... done"

# lint the tree against the channel
echo "Linting kickstart tree "
LINT_RESULTS=$( lint_tree )
echo "=== LINT_RESULTS BEGIN ==="
echo "$LINT_RESULTS"
echo "=== LINT_RESULTS END ==="
echo "... done"

if [ -z "$LINT_RESULTS" ]; then
    # everything should be cool add the tree to db
    echo "Package / Channel lint was clean..."
    echo "Adding kstree data to database $DSN"
    add_tree
    echo "... done"
else
    echo "packages not complete in channel $CHANNEL...  requires manual intervention..."
    LINT_RESULTS=${LINT_RESULTS//Not found:/}
    for lost in $LINT_RESULTS; do
	echo $lost
    done
    LINT_TMPFILE=$( mktemp /tmp/$CHANNEL-lint-results.XXXXXX )
    echo "Lint results written to $LINT_TMPFILE in case you need them."
    for x in $LINT_RESULTS; do echo $x ;done > $LINT_TMPFILE
    if [ ! -z "$OVERRIDE" ]; then
	echo "Adding kstree data to database $DSN"
	add_tree
	echo "... done"
    fi
fi

