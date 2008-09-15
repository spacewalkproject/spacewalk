# Macros
%define cvs_package    PerlModules/NP/Utils
%define npbin          /home/nocpulse/bin
%define buildroot      /tmp/%cvs_package

# Package specific stuff
Name:         perl-NOCpulse-Utils
Version:      1.14.2
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      NOCpulse utility packages
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        unsorted
Copyright:    (c) 2002-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers
Provides:     perl(NOCpulse::Module)

%description

%{name} provides miscellaneous utility packages


%prep
%entirely_abstract_build_step

%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%find_perl_installsitelib

install -d $installsitelib/NOCpulse/Utils/test
mkdir -p $RPM_BUILD_ROOT$installsitelib/NOCpulse/Utils

install -m 444 Module.pm          $RPM_BUILD_ROOT$installsitelib/NOCpulse/Module.pm 
#install -m 444 TestRunner.pm      $RPM_BUILD_ROOT$installsitelib/NOCpulse/Utils/TestRunner.pm
install -m 444 Error.pm           $RPM_BUILD_ROOT$installsitelib/NOCpulse/Utils/Error.pm
#install -m 755 -D runtest.pl      $RPM_BUILD_ROOT/%npbin/runtest.pl
install -m 444 Pickle.pm          $RPM_BUILD_ROOT$installsitelib/NOCpulse/Utils/Pickle.pm

%point_scripts_to_correct_perl
%make_file_list

%files -f %{name}-%{version}-%{release}-filelist


%clean

%abstract_clean_script
