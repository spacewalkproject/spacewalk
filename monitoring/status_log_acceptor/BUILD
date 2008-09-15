# Macros

%define cvs_package status_log_acceptor

%define registry	/etc/rc.d/np.d/apachereg

# Package specific stuff
Name:         status_log_acceptor
Version:      0.12.3
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      Current state log acceptor
Source:	      status_log_acceptor-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Provides:     logpusher
Requires:     perl, np-config
Group:        unsorted
Copyright:    Red Hat, Inc.  (c) 2000-2003.  All rights reserved.
Vendor:       Red Hat, Inc.
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers

%description

provides the cgi that accepts a status log, parses it, and stores the information

%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"


%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
 
%find_perl_installsitelib
perl_lib=$installsitelib/NOCpulse
 
mkdir -p $RPM_BUILD_ROOT$perl_lib
mkdir -p $RPM_BUILD_ROOT$perl_lib/AcceptStatusLog/test
mkdir -p $RPM_BUILD_ROOT%registry

 
install -o root -g root -m 444 AcceptStatusLog.pm $RPM_BUILD_ROOT$perl_lib
install -o root -g root -m 444 Apache.status_log_acceptor $RPM_BUILD_ROOT%registry
install -o root -g root -m 444 test/TestAcceptStatusLog.pm $RPM_BUILD_ROOT$perl_lib/AcceptStatusLog/test

%point_scripts_to_correct_perl
%make_file_list  
 

%files -f %{name}-%{version}-%{release}-filelist


%clean
%abstract_clean_script
