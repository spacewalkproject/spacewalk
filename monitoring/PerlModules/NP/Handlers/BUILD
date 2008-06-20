# Macros

%define cvs_package      PerlModules/NP/Handlers
%define nocpulse_home    /opt/home/nocpulse

Name:         perl-NOCpulse-Handlers
Version:      1.8.1
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      apache handler development tools
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        unsorted
Copyright:    (c) 2002-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers

%description

mod_perl handler development tools

%prep
%entirely_abstract_build_step

%build
echo "Nothing to build"

%install

cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%find_perl_installsitelib

mkdir -p $RPM_BUILD_ROOT/$installsitelib/NOCpulse
mkdir -p $RPM_BUILD_ROOT/$installsitelib/LWP/Protocol
mkdir -p $RPM_BUILD_ROOT/%nocpulse_home/bin

install MockApacheLog.pm     $RPM_BUILD_ROOT/$installsitelib/NOCpulse
install MockApacheRequest.pm $RPM_BUILD_ROOT/$installsitelib/NOCpulse
install handler.pm           $RPM_BUILD_ROOT/$installsitelib/LWP/Protocol
install handle.pl            $RPM_BUILD_ROOT%nocpulse_home/bin

%point_scripts_to_correct_perl

%make_file_list

%files -f %{name}-%{version}-%{release}-filelist
%defattr(-,root,root,-)
%attr(555,root,root)  %nocpulse_home/bin/handle.pl


%clean
%abstract_clean_script

%changelog
* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)
