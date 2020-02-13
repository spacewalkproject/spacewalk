#!/bin/bash
#
# Copyright (c) 2008--2018 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#
# Builds an rpm out of command line options
#

PATH=$PATH:/usr/bin

NAME=useless
EPOCH=
VERSION=1.0.0
RELEASE=1
ARCH=noarch
GROUP="RHN/Dummy"
SUMMARY="Dummy package"
DESCRIPTION="The package description"
PACKAGER="(none)"
VENDOR="(none)"

usage() {
    echo "Usage:"
    echo "$0 [OPTIONS] [FILES]"
    echo "Builds an rpm from the specified command line options, optionally"
    echo "including files"
    echo
    echo "  OPTIONS:"
    echo "    --help          display usage and exit"
    echo "    --name          use this name for the rpm [$NAME]"
    echo "    --epoch         use this epoch [default is null]"
    echo "    --version       use this version [$VERSION]"
    echo "    --release       use this release [$RELEASE]"
    echo "    --arch          build the package for this arch [$ARCH]"
    echo "    --group         group this package belongs [$GROUP]"
    echo "    --packager      packager [$PACKAGER]"
    echo "    --vendor        vendor [$VENDOR]"
    echo "    --summary       package summary"
    echo "    --description   package description"
    echo "    --requires      make the generated rpm require this"
    echo "    --provides      make the generated rpm provide this"
    echo "    --conflicts     make the generated rpm conflict with this"
    echo "    --obsoletes     make the generated rpm obsolete with this"
    echo "    --buildreq      make the generated source rpm require this to build"
    echo "    --post          path to a postinstall script"
    echo "    --pre           path to a preinstall script"
    echo "    --postun        path to a post-uninstall script"
    echo "    --preun         path to a pre-uninstall script"
    echo
    echo "  FILES: <file-spec>*"
    echo "    <file-spec> ::== <dest-path>[:mode]=<source-path>"
    echo "      adds <source-path> in the RPM package, at <dest-path>"
    echo "      NOTE: <dest-path> has to be a filename"
    echo
    echo "Example:"
    echo "  $0 --name useless --version 0.99 --release 1 /var/foo=/var/log/messages"
    exit $1
}

ensure_file_exists() {
    file=$1
    sectname=$2

    if [ "$file" -a ! -s "$file" ]; then
        echo "Cannot read $sectname section from $file"
        exit -1
    fi

}

# Generates the post/pre/postun/preun sections
generate_section() {
    file=$1
    sectname=$2
    if [ "$file" ]; then
        echo "%$sectname"
        cat $file
        echo
    fi
}

# Builds the requires/provides/conflicts/obsoletes
generate_depend_section() {
    sectname=$1
    shift
    while [ "$1" ]; do
        val=$1
        shift
        echo "$sectname: $val"
    done | sort | uniq
}

# Array we use for grabbing the files
declare -a PARAMS
declare -a REQUIRES
declare -a PROVIDES
declare -a CONFLICTS
declare -a OBSOLETES
declare -a BUILDREQS

POST=""
PRE=""
POSTUN=""
PREUN=""

while true; do
    case "$1" in
        --help)
            usage 0
            ;;
        --name)
            case "$2" in
                "") echo "No parameter specified for --name"; break;;
                *)  NAME=$2; shift 2;;
            esac;;
        --epoch)
            case "$2" in
                "") echo "No parameter specified for --epoch"; break;;
                *)  EPOCH=$2; shift 2;;
            esac;;
        --version)
            case "$2" in
                "") echo "No parameter specified for --version"; break;;
                *)  VERSION=$2; shift 2;;
            esac;;
        --release)
            case "$2" in
                "") echo "No parameter specified for --release"; break;;
                *)  RELEASE=$2; shift 2;;
            esac;;
        --arch)
            case "$2" in
                "") echo "No parameter specified for --arch"; break;;
                *)  ARCH=$2; shift 2;;
            esac;;
        --group)
            case "$2" in
                "") echo "No parameter specified for --group"; break;;
                *)  GROUP=$2; shift 2;;
            esac;;
        --summary)
            case "$2" in
                "") echo "No parameter specified for --summary"; break;;
                *)  SUMMARY=$2; shift 2;;
            esac;;
        --description)
            case "$2" in
                "") echo "No parameter specified for --description"; break;;
                *)  DESCRIPTION=$2; shift 2;;
            esac;;
        --packager)
            case "$2" in
                "") echo "No parameter specified for --packager"; break;;
                *)  PACKAGER=$2; shift 2;;
            esac;;
        --vendor)
            case "$2" in
                "") echo "No parameter specified for --vendor"; break;;
                *)  VENDOR=$2; shift 2;;
            esac;;
        --post)
            case "$2" in
                "") echo "No parameter specified for --post"; break;;
                *)  POST=$2; shift 2;;
            esac;;
        --pre)
            case "$2" in
                "") echo "No parameter specified for --pre"; break;;
                *)  PRE=$2; shift 2;;
            esac;;
        --postun)
            case "$2" in
                "") echo "No parameter specified for --postun"; break;;
                *)  POSTUN=$2; shift 2;;
            esac;;
        --preun)
            case "$2" in
                "") echo "No parameter specified for --preun"; break;;
                *)  PREUN=$2; shift 2;;
            esac;;
        --requires)
            case "$2" in
                "") echo "No parameter specified for --requires"; break;;
                *)  REQUIRES[${#REQUIRES[*]}]=$2; shift 2;;
            esac;;
        --provides)
            case "$2" in
                "") echo "No parameter specified for --provides"; break;;
                *)  PROVIDES[${#PROVIDES[*]}]=$2; shift 2;;
            esac;;
        --conflicts)
            case "$2" in
                "") echo "No parameter specified for --conflicts"; break;;
                *)  CONFLICTS[${#CONFLICTS[*]}]=$2; shift 2;;
            esac;;
        --obsoletes)
            case "$2" in
                "") echo "No parameter specified for --obsoletes"; break;;
                *)  OBSOLETES[${#OBSOLETES[*]}]=$2; shift 2;;
            esac;;
        --buildreq)
            case "$2" in
                "") echo "No parameter specified for --buildreq"; break;;
                *)  BUILDREQ[${#BUILDREQ[*]}]=$2; shift 2;;
            esac;;
        "") break;;
        *) 
            ftwo=`echo $1 | (read -n 2 foo; echo $foo)`
            if [ $ftwo == '--' ]; then
                echo "Unknown option $1"
                usage 1
            fi
            PARAMS[${#PARAMS[*]}]=$1
            shift
    esac
done

ensure_file_exists "$PRE" "pre"
ensure_file_exists "$POST" "post"
ensure_file_exists "$PREUN" "preun"
ensure_file_exists "$POSTUN" "postun"

# End of the command-line processing stage

RPM_BUILD_DIR=/tmp/$NAME-$VERSION-build
DIRNAME=$NAME-$VERSION
TARBALL=$NAME-$VERSION.tar.gz

echo "Building $NAME-$VERSION-$RELEASE.$ARCH.rpm"

rm -rf $RPM_BUILD_DIR
install --verbose -d $RPM_BUILD_DIR/$DIRNAME

# Prepare the tar file
i=0
while [ $i -lt ${#PARAMS[*]} ]; do
    echo ${PARAMS[$i]} | (
        IFS== read dstmod src
        echo ${dstmod} | (IFS=: read dst mod
            echo "${src} -> ${RPM_BUILD_DIR}/${DIRNAME}/${dst}"
            mkdir --parents --verbose ${RPM_BUILD_DIR}/${DIRNAME}/`dirname "${dst}"`; cp ${src} ${RPM_BUILD_DIR}/${DIRNAME}/${dst}
        )
    )
    i=$[$i+1]
done

# Build the install section
installsect=`i=0
while [ $i -lt ${#PARAMS[*]} ]; do
    echo ${PARAMS[$i]} | (
        IFS== read dstmod src
        echo ${dstmod} | (IFS=: read dst mod
            echo "install --verbose -d \\\$RPM_BUILD_ROOT\`dirname ${dst}\`"
            echo "install --verbose .${dst} \\\$RPM_BUILD_ROOT${dst}")
    )
    i=$[$i+1]
done | sort | uniq | while read line; do echo -n "$line\n"; done`

# Build the file section
filesect=`i=0
while [ $i -lt ${#PARAMS[*]} ]; do
    echo ${PARAMS[$i]} | (
        IFS== read dstmod src
        echo ${dstmod} | (IFS=: read dst mod
            # Now split mod into the actual mode, the user and the group
            # Default to 0644,-,-
            # NOTE there's already a %defattr(-,root,root), so if there's no u 
            # or g defined, set it to '-' by default
            echo $mod | (IFS=, read m u g
                echo "%attr(${m:-0644},${u:--},${g:--}) ${dst}"
            )
        )
    )
    i=$[$i+1]
done | sort | uniq | while read line; do echo -n "$line\n"; done`

cat > $RPM_BUILD_DIR/$DIRNAME/$NAME.spec << EOF
Name: $NAME
$(if [ -n "$EPOCH" ]; then echo "Epoch: $EPOCH"; fi)
Version: $VERSION
Release: $RELEASE
License: GPL
BuildArch: $ARCH
Source: %{name}-%{version}.tar.gz
Summary: $SUMMARY
Packager: $PACKAGER
Vendor: $VENDOR
`generate_depend_section Requires "${REQUIRES[@]}"`
`generate_depend_section Provides "${PROVIDES[@]}"`
`generate_depend_section Conflicts "${CONFLICTS[@]}"`
`generate_depend_section Obsoletes "${OBSOLETES[@]}"`
`generate_depend_section BuildRequires "${BUILDREQ[@]}"`

%description
`echo -e $DESCRIPTION`

%prep
%setup

%build

%install
rm -rf \$RPM_BUILD_ROOT
install -d \$RPM_BUILD_ROOT
`echo -e $installsect`

%clean
rm -rf \$RPM_BUILD_ROOT

`generate_section "$POST" post`
`generate_section "$PRE" pre`
`generate_section "$POSTUN" postun`
`generate_section "$PREUN" preun`

%files
`echo -e $filesect`
EOF

# Build the tarball
(cd $RPM_BUILD_DIR; tar cf - $DIRNAME | gzip -c > $RPM_BUILD_DIR/$TARBALL)
rm -rf $RPM_BUILD_DIR/$DIRNAME

# Build the rpm from that tarball
RPMOPTS="--define \"_topdir $RPM_BUILD_DIR\"\
 --define '_builddir    %{_topdir}'\
 --define '_sourcedir   %{_topdir}'\
 --define '_specdir     %{_topdir}'\
 --define '_rpmdir      %{_topdir}'\
 --define '_srcrpmdir   %{_topdir}'\
 --define '_source_filedigest_algorithm md5'\
 --define '_binary_filedigest_algorithm md5'\
 --define '_source_payload nil'\
 --define '_binary_payload nil'\
 "

eval "rpmbuild -ta $RPMOPTS --clean $RPM_BUILD_DIR/$TARBALL" || exit 1

mv $RPM_BUILD_DIR/$ARCH/$NAME-$VERSION-$RELEASE.$ARCH.rpm .
mv $RPM_BUILD_DIR/$NAME-$VERSION-$RELEASE.src.rpm .
rm -rf $RPM_BUILD_DIR
