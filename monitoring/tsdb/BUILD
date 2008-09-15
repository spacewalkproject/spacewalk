# Macros

%define cvs_package tsdb
%define apache_home /opt/apache
%define init_script /etc/rc.d/init.d/tsdb_local_queue
%define registry    /etc/rc.d/np.d/apachereg
%define optdir      /opt/nocpulse
%define lqdir       %optdir/TSDBLocalQueue
%define bdbdir      /nocpulse/tsdb/bdb
%define npbin       /home/nocpulse/bin

Name:         tsdb
Version:      1.27.14
Release:      1
Packager:     Heather Adkins <hadkins@nocpulse.com>
Summary:      Time Series Database
Requires:     bdb_perl perl-NOCpulse-Utils perl(NOCpulse::Debug) perl(IO::Stringy) perl(Class::MethodMaker) perl(Date::Manip)
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        unsorted
Copyright:    (c) 2001-2003 Red Hat, Inc.  All rights reserved.
Vendor:       Red Hat, Inc.
BuildRoot:    %{_tmppath}/%cvs_package
Prereq:       NPusers

%description

Time Series Database


%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%find_perl_installsitelib
pkgdir="$installsitelib/NOCpulse"


# Directories

install -d $RPM_BUILD_ROOT%registry
install -d $RPM_BUILD_ROOT/$pkgdir/TSDB/LocalQueue/test
install -o apache -g apache -d $RPM_BUILD_ROOT%bdbdir
install -o apache -g apache -d $RPM_BUILD_ROOT%lqdir
install -o apache -g apache -d $RPM_BUILD_ROOT%lqdir/queue
install -o apache -g apache -d $RPM_BUILD_ROOT%lqdir/archive
install -o apache -g apache -d $RPM_BUILD_ROOT%lqdir/failed
install -o apache -g apache -d $RPM_BUILD_ROOT%npbin/tsdb_test

# Code
install -m 644 TSDB.pm $RPM_BUILD_ROOT/$pkgdir
install -m 644 LocalQueue/*.pm $RPM_BUILD_ROOT/$pkgdir/TSDB/LocalQueue
install -m 644 LocalQueue/test/*.pm $RPM_BUILD_ROOT/$pkgdir/TSDB/LocalQueue/test
install -m 755 LocalQueue/TSDBLocalQueue.pl $RPM_BUILD_ROOT%npbin/TSDBLocalQueue.pl
install -m 755 LocalQueue/test/enqueue.pl   $RPM_BUILD_ROOT%npbin/tsdb_test/enqueue.pl
install -m 755 LocalQueue/test/replaylog.pl $RPM_BUILD_ROOT%npbin/tsdb_test/replaylog.pl
install -m 644 -D LocalQueue/logrotate      $RPM_BUILD_ROOT/etc/logrotate.d/TSDBLocalQueue

# Ops utilities
install -m 755 LocalQueue/drainer $RPM_BUILD_ROOT%optdir
install -m 755 LocalQueue/rebalance_cron $RPM_BUILD_ROOT%optdir

# Apache startup file
install -m 644 Apache.tsdb $RPM_BUILD_ROOT%registry

# Local queue init script (temporary, will be superseded by sysv stuff)
install -d $RPM_BUILD_ROOT/etc/rc.d/init.d
install -m 755 LocalQueue/init_script $RPM_BUILD_ROOT%init_script

%point_scripts_to_correct_perl
%make_file_list

echo "%dir %bdbdir"                 >> %{name}-%{version}-%{release}-filelist
echo "%dir %lqdir"                  >> %{name}-%{version}-%{release}-filelist
echo "%dir %lqdir/archive"          >> %{name}-%{version}-%{release}-filelist
echo "%dir %lqdir/failed"           >> %{name}-%{version}-%{release}-filelist
echo "%dir %lqdir/queue"            >> %{name}-%{version}-%{release}-filelist
echo "%dir $pkgdir/TSDB/LocalQueue" >> %{name}-%{version}-%{release}-filelist
echo "%dir $pkgdir/TSDB/LocalQueue/test" >> %{name}-%{version}-%{release}-filelist


%files -f %{name}-%{version}-%{release}-filelist


%clean
%abstract_clean_script
