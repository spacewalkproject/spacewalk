# Macros
%define cvs_package PerlModules/NP/Probe
%define npbin        /home/nocpulse/bin

# Package specific stuff
Name:         perl-NOCpulse-Probe
Version:      1.183.0
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      Probe execution framework
Source:	      NOCpulse-Probe-%PACKAGE_VERSION.tar.gz
Requires:     perl(NOCpulse::OracleDB)
BuildArch:    noarch
Group:        unsorted
Copyright:    (c) 2002-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers
Prefix:       %{_our_prefix}

%description

Provides classes for executing probes.

%prep
%entirely_abstract_build_step

%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

install -m 755 -D runprobe.pl $RPM_BUILD_ROOT/%npbin/runprobe.pl

%find_perl_installsitelib

pkgdir="$RPM_BUILD_ROOT$installsitelib/NOCpulse/Probe"

dirs=". Config DataSource Shell SNMP Utils"
for dir in $dirs; do
  mkdir -p $pkgdir/$dir/test
  install -d 755 $pkgdir/$dir
  install -d 755 $pkgdir/$dir/test
  install -m 644 $dir/*.pm $pkgdir/$dir
  install -m 644 $dir/test/*.pm $pkgdir/$dir/test
done

%make_file_list
%point_scripts_to_correct_perl

%files -f %{name}-%{version}-%{release}-filelist


%clean

%abstract_clean_script

