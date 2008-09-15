
# CVS hacks
%define cvs_package_prefix	old-nocpulse/

# What Perl to use?
%define perl_prefix     /usr
%define perl            %perl_prefix/bin/perl
%define perlpkg         perl-rhnmon

# Macro for cpan documentation
%define doc_prefix     %perl_prefix/share/doc/%name
%define man_prefix     %perl_prefix/man 


# Macro(s) slavishly copied from autoconf's config.status.
%define _our_prefix                /usr
%define _our_exec_prefix           %{_our_prefix}
%define _our_bindir                %{_our_exec_prefix}/bin
%define _our_sbindir               %{_our_exec_prefix}/sbin
%define _our_libexecdir            %{_our_exec_prefix}/libexec
%define _our_datadir               %{_our_prefix}/share
%define _our_sysconfdir            %{_our_prefix}/etc
%define _our_sharedstatedir        %{_our_prefix}/com
%define _our_localstatedir         %{_our_prefix}/var
%define _our_lib                   lib
%define _our_libdir                %{_our_exec_prefix}/%{_lib}
%define _our_includedir            %{_our_prefix}/include
%define _our_oldincludedir         /usr/include
%define _our_infodir               %{_our_prefix}/info
%define _our_mandir                %{_our_prefix}/man


# Prep for build. This is entirely abstract - you should not need to change it.
%define entirely_abstract_build_step rm -rf $RPM_BUILD_ROOT; rm -rf $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION; cvs checkout $RPM_TAG_PARAM %cvs_package_prefix%cvs_package; [ -n %cvs_package_prefix ] && mkdir -p %cvs_package && rmdir %cvs_package && ln -s %cvs_package_prefix%cvs_package %cvs_package ; [ %cvs_package = $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION ] || mv %cvs_package $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION; find $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION -type d -name CVS | xargs rm -rf; tar -cvzf $RPM_SOURCE_DIR/$RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION.tar.gz $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION



%define perl_makefile CFLAGS="$RPM_OPT_FLAGS" %perl Makefile.PL verbose PREFIX=$RPM_BUILD_ROOT%{prefix}; make OPTIMIZE="$RPM_OPT_FLAGS"



%define makefile_build cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION; %perl_makefile


# For CPAN modules with a copyright or license that is not GPL or Artistic
%define cpan_doc_install mkdir -p $RPM_BUILD_ROOT%doc_prefix; [ -e README ]    && cp README    $RPM_BUILD_ROOT%doc_prefix; [ -e COPYING ]   && cp COPYING   $RPM_BUILD_ROOT%doc_prefix; [ -e COPYRIGHT ] && cp COPYRIGHT $RPM_BUILD_ROOT%doc_prefix


%define our_makeinstall  make prefix=%{?buildroot:%{buildroot}}%{_our_prefix} exec_prefix=%{?buildroot:%{buildroot}}%{_our_exec_prefix} bindir=%{?buildroot:%{buildroot}}%{_our_bindir} sbindir=%{?buildroot:%{buildroot}}%{_our_sbindir} sysconfdir=%{?buildroot:%{buildroot}}%{_our_sysconfdir} datadir=%{?buildroot:%{buildroot}}%{_our_datadir} includedir=%{?buildroot:%{buildroot}}%{_our_includedir} libdir=%{?buildroot:%{buildroot}}%{_our_libdir} libexecdir=%{?buildroot:%{buildroot}}%{_our_libexecdir} localstatedir=%{?buildroot:%{buildroot}}%{_our_localstatedir} sharedstatedir=%{?buildroot:%{buildroot}}%{_our_sharedstatedir} mandir=%{?buildroot:%{buildroot}}%{_our_mandir} infodir=%{?buildroot:%{buildroot}}%{_our_infodir} install



%define makefile_install eval `%perl '-V:installarchlib'`; mkdir -p $RPM_BUILD_ROOT$installarchlib; %our_makeinstall; rm -f `find $RPM_BUILD_ROOT -type f -name perllocal.pod -o -name .packlist`; [ -x /usr/lib/rpm/brp-compress ] && /usr/lib/rpm/brp-compress


# For the really ugly cases, e.g. PerlModules/CPAN/libwww-perl-5.48
%define alt_makefile_install mkdir -p $RPM_BUILD_ROOT/%{_our_prefix}/lib; make install PREFIX=$RPM_BUILD_ROOT; mv $RPM_BUILD_ROOT/lib $RPM_BUILD_ROOT%{_our_prefix}/lib/perl5



%define find_perl_installsitelib eval `%perl '-V:installsitelib'`; echo installsitelib is $installsitelib; if [ "$installsitelibX" = "X" ] ; then echo "ERROR: installsitelib is undefined"; exit 1; fi



%define point_scripts_to_correct_perl find $RPM_BUILD_ROOT -type f -print | xargs perl -pi -e 's,^#\\\!/usr/bin/perl,#\\\!%perl, if ($ARGV ne $lf); $lf = $ARGV;'


%define make_file_list find $RPM_BUILD_ROOT -type f -print | sed "s@^$RPM_BUILD_ROOT@@g" > %{name}-%{version}-%{release}-filelist; if [ "$(cat %{name}-%{version}-%{release}-filelist)X" = "X" ] ; then echo "ERROR: EMPTY FILE LIST"; exit 1; fi


%define abstract_clean_script rm -rf $RPM_BUILD_ROOT; cd $RPM_BUILD_DIR; rm -rf $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION; [ -n %cvs_package_prefix ] && [ -e %cvs_package_prefix ] && rm -rf %cvs_package_prefix; [ -e %cvs_package ] && rm -rf %cvs_package; [ -e %{name}-%{version}-%{release}-filelist ] && rm %{name}-%{version}-%{release}-filelist
# Macros

%define cvs_package tsdb
%define apache_home /opt/apache
%define init_script /etc/rc.d/init.d/tsdb_local_queue
%define registry    /etc/rc.d/np.d/apachereg
%define optdir      /opt/nocpulse
%define lqdir       %optdir/TSDBLocalQueue
%define bdbdir      /nocpulse/tsdb/bdb
%define npbin       /opt/home/nocpulse/bin

Name:         tsdb
Source2:      sources
%define       main_source %(awk '{ print $2 ; exit }' %{SOURCE2})
Source0:      %{main_source}
Source1:      version
Version:      %(echo `awk '{ print $1 }' %{SOURCE1}`)
Release:      %(echo `awk '{ print $2 }' %{SOURCE1}`)%{?dist}
Summary:      Time Series Database
Requires:     perl-NOCpulse-Utils perl(NOCpulse::Debug) perl(IO::Stringy) perl(Class::MethodMaker) perl(Date::Manip)
BuildArch:    noarch
Group:        unsorted
License:      GPLv2
Vendor:       Red Hat, Inc.
BuildRoot:    %{_tmppath}/%cvs_package
Prereq:       NPusers

%description

Time Series Database


%prep
%define build_sub_dir %(echo %{main_source} | sed 's/\.tar\.gz$//')
%setup -n %build_sub_dir

%build
echo "Nothing to build"

%install

%find_perl_installsitelib
pkgdir="$installsitelib/NOCpulse"


# Directories

install -d $RPM_BUILD_ROOT%registry
install -d $RPM_BUILD_ROOT/$pkgdir/TSDB/LocalQueue/test
mkdir -p $RPM_BUILD_ROOT%bdbdir
mkdir -p $RPM_BUILD_ROOT%lqdir
mkdir -p $RPM_BUILD_ROOT%lqdir/queue
mkdir -p $RPM_BUILD_ROOT%lqdir/archive
mkdir -p $RPM_BUILD_ROOT%lqdir/failed
mkdir -p $RPM_BUILD_ROOT%npbin/tsdb_test

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
%attr(755,apache,apache) %dir %bdbdir
%attr(755,apache,apache) %dir %lqdir
%attr(755,apache,apache) %dir %lqdir/queue
%attr(755,apache,apache) %dir %lqdir/archive
%attr(755,apache,apache) %dir %lqdir/failed

%clean
%abstract_clean_script

%post
make_link()
{
    # if we are remove the package and install againg this files already exist
    if test -f /opt/home/nocpulse/var/$FNAME -a ! -L /opt/home/nocpulse/var/$FNAME -a ! -f /var/log/nocpulse/$FNAME
    then
        mv /opt/home/nocpulse/var/$FNAME /var/log/nocpulse/$FNAME
    fi

    if test ! -f /opt/home/nocpulse/var/$FNAME -a ! -L /opt/home/nocpulse/var/$FNAME
    then
        ln -s /var/log/nocpulse/$FNAME /opt/home/nocpulse/var/$FNAME
    fi
}

mkdir -p /var/log/nocpulse

FNAME=TSDBLocalQueue.log
make_link

FNAME=TSDBLocalQueue-errors.log
make_link

%changelog
* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Tue Jun 10 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.27.13-19
- cvs.dist import
