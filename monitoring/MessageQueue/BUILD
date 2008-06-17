# Macros

%define cvs_package MessageQueue

%define install_prefix /home/nocpulse
%define exe_dir        %install_prefix/bin
%define startup_root   /etc/rc.d
%define queue_dir      %install_prefix/var/queue
%define notif_qdir     %queue_dir/notif
%define states_qdir    %queue_dir/sc_db
%define trends_qdir    %queue_dir/ts_db
%define commands_qdir  %queue_dir/commands
%define snmp_qdir      %queue_dir/snmp

# Package specific stuff
Name:         MessageQueue
Version:      3.25.0
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      Message buffer/relay system
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Provides:     dequeue perl(NOCpulse::CommandOutput) perl(NOCpulse::CommandOutputQueue) perl(NOCpulse::Notification) perl(NOCpulse::NotificationQueue) perl(NOCpulse::PersistentConnection) perl(NOCpulse::QueueEntry) perl(NOCpulse::SMON) perl(NOCpulse::SMONQueue) perl(NOCpulse::SNMPQueue) perl(NOCpulse::StateChange) perl(NOCpulse::StateChangeQueue) perl(NOCpulse::TimeSeriesDatapoint) perl(NOCpulse::TimeSeriesQueue)

Requires:     perl ProgAGoGo NOCpulse::Debug NOCpulse::Gritch NPusers
Group:        unsorted
Copyright:    (c) 2002-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:	      %install_prefix
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers

%description

MessageQueue is a mechanism by which satellite plugins and event handlers
can safely and quickly buffer outbound messages.  The system provides
a dequeue daemon that reliably dequeues messages to internal systems.



%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%find_perl_installsitelib

mkdir -p $RPM_BUILD_ROOT$installsitelib/NOCpulse
mkdir -p $RPM_BUILD_ROOT%exe_dir
mkdir -p $RPM_BUILD_ROOT%notif_qdir
mkdir -p $RPM_BUILD_ROOT%states_qdir
mkdir -p $RPM_BUILD_ROOT%trends_qdir
mkdir -p $RPM_BUILD_ROOT%commands_qdir
mkdir -p $RPM_BUILD_ROOT%snmp_qdir

# Install libraries
install -o root -g root -m 644 QueueEntry.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse
install -o root -g root -m 644 SMON.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse
install -o root -g root -m 644 SMONQueue.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse
install -o root -g root -m 644 Notification.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse
install -o root -g root -m 644 NotificationQueue.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse
install -o root -g root -m 644 StateChange.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse
install -o root -g root -m 644 StateChangeQueue.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse
install -o root -g root -m 644 TimeSeriesDatapoint.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse
install -o root -g root -m 644 TimeSeriesQueue.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse
install -o root -g root -m 644 CommandOutput.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse
install -o root -g root -m 644 CommandOutputQueue.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse
install -o root -g root -m 644 SNMPQueue.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse


# Install binaries
install -o root -g root -m 755 dequeue $RPM_BUILD_ROOT%exe_dir
install -o nocpulse -g nocpulse -m 755 queuetool $RPM_BUILD_ROOT%exe_dir

%point_scripts_to_correct_perl
%make_file_list 

%files -f %{name}-%{version}-%{release}-filelist
%attr(755,nocpulse,nocpulse) %dir %queue_dir
%attr(755,nocpulse,nocpulse) %dir %states_qdir
%attr(755,nocpulse,nocpulse) %dir %notif_qdir
%attr(755,nocpulse,nocpulse) %dir %trends_qdir
%attr(755,nocpulse,nocpulse) %dir %commands_qdir
%attr(755,nocpulse,nocpulse) %dir %snmp_qdir


%exe_dir/dequeue
%exe_dir/queuetool



%clean
%abstract_clean_script
