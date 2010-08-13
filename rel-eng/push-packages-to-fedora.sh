#!/bin/bash

# top dir of you fedora cvs checkout 
# e.g. ~/fedora/cvs
TOP_DIR_FEDORA=$1

# top dir of spacewalk git checkout
TOP_DIR_GIT=$2

PACKAGE_LIST="rhnlib rhn-client-tools rhnsd yum-rhn-plugin rhncfg spacewalk-koan spacewalk-certs-tools rhnpush nocpulse-common perl-Satcon perl-NOCpulse-CLAC perl-NOCpulse-Debug perl-NOCpulse-Gritch perl-NOCpulse-Object perl-NOCpulse-SetID perl-NOCpulse-Utils spacewalk-proxy-html spacewalk-proxy-docs spacecmd"


if [ -z "$TOP_DIR_FEDORA" -o ! -d "$TOP_DIR_FEDORA" ]; then
    echo "Error: Fedora git directory $TOP_DIR_FEDORA do not exist"
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
		BASENAME=`basename $SRC_RPM .src.rpm`
		NVR_GIT=`rpm -qp --queryformat '%{name}-%{version}' "$SRC_RPM"`
		cd "$TOP_DIR_FEDORA"
		if [ ! -d "$package" ]; then
			echo "Directory $TOP_DIR_FEDORA/$package do not exist!"
			exit 1
		fi
		cd "$package"

		echo "Updating $TOP_DIR_FEDORA/$package"
		fedpkg switch-branch master || ( echo 'Error: could not switch to master' && exit 1 )
        git pull || ( echo 'Error: could not update git' && exit 1 )

		# find version of package in fedora git and strip release from it
		NVR_DISTGIT=`fedpkg verrel | perl -an -F- -e 'pop @F; print join("-", @F)'`

		if [ "$NVR_DISTGIT" != "$NVR_GIT" ]; then
			echo "Version in dist-git is: $NVR_DISTGIT"
			echo "Importing version: $NVR_GIT"
			fedpkg import $SRC_RPM || exit $?
            fedpkg commit -m "Rebase to $BASENAME in rawhide."
			git tag $BASENAME
			echo "Review your changes and hit ENTER to continue or Ctrl+C to stop"
            read
			git push || ( echo 'Error: could not push changes' && exit 1 )
            git push --tags
			fedpkg build --nowait
		else
			echo "$NVR_DISTGIT already imported - skipping."
		fi
done

popd
