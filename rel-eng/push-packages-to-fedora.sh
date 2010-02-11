#!/bin/bash

# top dir of you fedora cvs checkout 
# e.g. ~/fedora/cvs
TOP_DIR_FEDORA=$1

# top dir of spacewalk git checkout
TOP_DIR_GIT=$2

PACKAGE_LIST="nocpulse-common perl-Satcon perl-NOCpulse-CLAC perl-NOCpulse-Debug perl-NOCpulse-Gritch perl-NOCpulse-Object perl-NOCpulse-SetID perl-NOCpulse-Utils spacewalk-proxy-html spacewalk-proxy-docs"


if [ -z "$TOP_DIR_FEDORA" -o ! -d "$TOP_DIR_FEDORA" ]; then
    echo "Error: Fedora CVS directory $TOP_DIR_FEDORA do not exist"
    exit 1
fi
if [ -z "$TOP_DIR_GIT" -o ! -d "$TOP_DIR_GIT" ]; then
    echo "Error: Spacewalk git checkout $TOP_DIR_FEDORA do not exist"
    exit 2
fi

pushd `pwd`
for package in $PACKAGE_LIST; do
        echo "Importing $package to Fedora:"
		cd "$TOP_DIR_GIT"
		cd `cat rel-eng/packages/$package | cut -f2 -d" "`
		SRC_RPM=`tito build --srpm | tail -n1 | cut -f2 -d" "`
		BASENAME=`basename $SRC_RPM`
		NVR_GIT=`rpm -qp --queryformat '%{name}-%{version}' "$SRC_RPM"`
		cd "$TOP_DIR_FEDORA"
		if [ ! -d "$package" ]; then
			echo "Directory $TOP_DIR_FEDORA/$package do not exist!"
			exit 1
		fi
		cd "$package"

		echo "Updating $TOP_DIR_FEDORA/$package"
		cvs -fq update -d -P >/dev/null

		# find version of package in fedora CVS and strip release from it
		cd devel
		NVR_CVS=`make verrel | perl -an -F- -e 'pop @F; print join("-", @F)'`
		cd ..

		if [ "$NVR_CVS" != "$NVR_GIT" ]; then
			echo "Version in CVS is: $NVR_CVS"
			echo "Importing version: $NVR_GIT"
			./common/cvs-import.sh -m "Rebase to $BASENAME in rawhide." $SRC_RPM || exit $?
			cvs -fq update -d -P >/dev/null
			cd devel
			make build
		else
			echo "$NVR_CVS already imported - skipping."
		fi
done

popd
