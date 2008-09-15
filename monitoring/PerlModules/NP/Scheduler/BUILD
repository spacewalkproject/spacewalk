# Macros
%define cvs_package PerlModules/NP/Scheduler
%define home /home/nocpulse
%define bin  %home/bin 

# Package specific stuff
Name:         perl-NOCpulse-Scheduler
Version:      1.58.4
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      NOCpulse Event Scheduler
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
Requires:     NPusers
BuildArch:    noarch
Group:        unsorted
Copyright:    (c) 2002-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers
Prefix:       %{_our_prefix}
Provides:     perl(NOCpulse::Scheduler::Event::PluginEvent)

%description

%{name} implements an event scheduler system and a framework for 
defining event types.

%prep
%entirely_abstract_build_step

%build
echo "Nothing to build"

%install

cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%find_perl_installsitelib

mkdir -p $RPM_BUILD_ROOT$installsitelib
mkdir -p $RPM_BUILD_ROOT$installsitelib/NOCpulse/Scheduler
mkdir -p $RPM_BUILD_ROOT$installsitelib/NOCpulse/Scheduler/Event
mkdir -p $RPM_BUILD_ROOT%bin
mkdir -p $RPM_BUILD_ROOT%home/var/rw
chown nocpulse.nocpulse $RPM_BUILD_ROOT%home/var/rw

cp Scheduler.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse
cp Event.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse/Scheduler
cp Event/ProbeEvent.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse/Scheduler/Event
cp Event/TestEvent.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse/Scheduler/Event
cp Event/TimeoutEvent.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse/Scheduler/Event
cp Event/StatePushEvent.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse/Scheduler/Event
cp Message.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse/Scheduler
cp MessageDictionary.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse/Scheduler
cp Statistics.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse/Scheduler
cp kernel.pl $RPM_BUILD_ROOT%bin
# These were going to be part of the HA/LB/hot-plug worker-bee scout cluster thing
#cp ckernel.pl $RPM_BUILD_ROOT%bin
#cp scheduler.pl $RPM_BUILD_ROOT%bin

%point_scripts_to_correct_perl

%make_file_list
# Don't forget the empty but very necessary 'rw' directory
echo "%home/var/rw" >> %{name}-%{version}-%{release}-filelist


%files -f %{name}-%{version}-%{release}-filelist


%clean
%abstract_clean_script
