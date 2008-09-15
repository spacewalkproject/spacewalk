
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
%define cvs_package NPalert
%define install_prefix     /opt/notification
%define cron_prefix        %install_prefix/cron
%define httpd_prefix       /var/www
%define notif_user         nocpulse
%define registry           /etc/rc.d/np.d/apachereg
%define log_rotate_prefix  /etc/logrotate.d/

# Package specific stuff
Name:         %cvs_package
Summary:      NOCpulse notification system
Source2:      sources
%define main_source %(awk '{ print $2 ; exit }' %{SOURCE2})
Source0:      %{main_source}
Source1:      version
Version:      %(echo `awk '{ print $1 }' %{SOURCE1}`)
Release:      %(echo `awk '{ print $2 }' %{SOURCE1}`)%{?dist}
BuildArch:    noarch
Requires:     perl perl(Config::IniFiles) perl(DBI) perl(DBD::Oracle) perl(Class::MethodMaker) perl(Error) perl(Date::Manip) perl-TimeDate perl-MailTools perl-NOCpulse-Probe perl-libwww-perl perl(URI) perl(HTML::Parser) perl(FreezeThaw)
Provides:     NPalert
Group:        unsorted
License:    GPLv2
Vendor:       Red Hat, Inc.
Prefix:	      %install_prefix
Prereq:       NPusers smtpdaemon
Buildroot:    %{_tmppath}/%cvs_package


%description

The NOCpulse notification system.

%prep
%setup -n %(echo %{main_source} | sed 's/\.tar\.gz//')

%build

%install
rm -rf $RPM_BUILD_ROOT

# Create directories
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/config/archive
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/config/generated
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/config/static
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/config/stage/config
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/etc
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/ack_queue
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/ack_queue/.new
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/alert_queue
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/alert_queue/.new
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/scripts
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/tmp
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/var
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/var/archive
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/var/ticketlog

# Create symlinks
ln -s ../../scripts                 $RPM_BUILD_ROOT%install_prefix/config/stage/scripts
ln -s ../../static                  $RPM_BUILD_ROOT%install_prefix/config/stage/config/static
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/scripts/NOCpulse
ln -s ../../config                  $RPM_BUILD_ROOT%install_prefix/scripts/NOCpulse/config
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/etc/NOCpulse
ln -s ../../config                  $RPM_BUILD_ROOT%install_prefix/etc/NOCpulse/config

# Install the perl modules
%find_perl_installsitelib
pm_prefix=$installsitelib/NOCpulse/Notif
mkdir -p --mode 755 $RPM_BUILD_ROOT$pm_prefix/test
install -m 444 *.pm $RPM_BUILD_ROOT$pm_prefix/
install -m 444 test/*.pm $RPM_BUILD_ROOT$pm_prefix/test

# Install the scripts
install scripts/* $RPM_BUILD_ROOT%install_prefix/scripts/

# Install the config stuff
install config/*.ini $RPM_BUILD_ROOT%install_prefix/config/static


# Make sure everything is owned by the right user/group and critical dirs
# have the right permissions
chmod 755 $RPM_BUILD_ROOT%install_prefix
chmod -R 755 $RPM_BUILD_ROOT%install_prefix/scripts

# Install the html and cgi scripts
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/htdocs
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/cgi-bin
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/cgi-mod-perl
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/templates

ln -s %install_prefix/var           $RPM_BUILD_ROOT%httpd_prefix/htdocs/alert_logs

install -m 755 httpd/cgi-bin/redirmgr.cgi $RPM_BUILD_ROOT%httpd_prefix/cgi-bin/
install -m 755 httpd/cgi-mod-perl/*.cgi $RPM_BUILD_ROOT%httpd_prefix/cgi-mod-perl/
install -m 755 httpd/html/*.html        $RPM_BUILD_ROOT%httpd_prefix/htdocs/
install -m 755 httpd/html/*.css         $RPM_BUILD_ROOT%httpd_prefix/htdocs/
install -m 755 httpd/templates/*.html   $RPM_BUILD_ROOT%httpd_prefix/templates/

# Install the cron stuff
mkdir -p $RPM_BUILD_ROOT%cron_prefix
install -m 644 cron/notification        $RPM_BUILD_ROOT%cron_prefix


# Install apache registration entries
mkdir -p $RPM_BUILD_ROOT%registry
install -m 644 Apache.NPalert $RPM_BUILD_ROOT%registry

# Install logrotate stuff
mkdir -p %buildroot%log_rotate_prefix
install -m 444 logrotate.d/notification  $RPM_BUILD_ROOT%log_rotate_prefix

# Fix up the perl scripts and build the filelist
%point_scripts_to_correct_perl
%make_file_list


%files -f %{name}-%{version}-%{release}-filelist
%defattr(-,root,root)
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/archive
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/generated
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/static
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/stage
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/stage/config
%attr (755,%notif_user,%notif_user) %dir %install_prefix/etc
%attr (755,%notif_user,%notif_user) %dir %install_prefix/queue
%attr (775,mail,       %notif_user) %dir %install_prefix/queue/ack_queue
%attr (775,mail,       %notif_user) %dir %install_prefix/queue/ack_queue/.new
%attr (775,apache,     %notif_user) %dir %install_prefix/queue/alert_queue
%attr (775,apache,     %notif_user) %dir %install_prefix/queue/alert_queue/.new
%attr (755,%notif_user,%notif_user) %dir %install_prefix/scripts
%attr (755,%notif_user,%notif_user) %dir %install_prefix/tmp
%attr (755,%notif_user,%notif_user) %dir %install_prefix/var
%attr (755,%notif_user,%notif_user) %dir %install_prefix/var/archive
%attr (755,%notif_user,%notif_user) %dir %install_prefix/var/ticketlog
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/stage/scripts
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/stage/config/static
%attr (755,%notif_user,%notif_user) %dir %install_prefix/scripts/NOCpulse
%attr (755,%notif_user,%notif_user) %dir %install_prefix/scripts/NOCpulse/config
%attr (755,%notif_user,%notif_user) %dir %install_prefix/etc/NOCpulse
%attr (755,%notif_user,%notif_user) %dir %install_prefix/etc/NOCpulse/config
%dir %httpd_prefix/htdocs/alert_logs
%attr(755,%notif_user,%notif_user) %install_prefix/scripts/*
%attr(644,%notif_user,%notif_user) %install_prefix/config/static/*

%clean
%abstract_clean_script

%pre
if [ -h /opt/notification/etc/NOCpulse ] ; then
	rm /opt/notification/etc/NOCpulse
fi
if [ -h /opt/notification/scripts/NOCpulse ] ; then
	rm /opt/notification/scripts/NOCpulse
fi

%post
make_link()
{
    # if we are remove the package and install againg this files already exist
    if test -f /opt/notification/var/$FNAME -a ! -L /opt/notification/var/$FNAME -a ! -f /var/log/nocpulse/$FNAME
    then
        mv /opt/notification/var/$FNAME /var/log/nocpulse/$FNAME
    fi

    if test ! -f /opt/notification/var/$FNAME -a ! -L /opt/notification/var/$FNAME
    then
        ln -s /var/log/nocpulse/$FNAME /opt/notification/var/$FNAME
    fi
}

mkdir -p /var/log/nocpulse

FNAME=generate_config.log
make_link

FNAME=notif-escalator.log
make_link

FNAME=notif-launcher.log
make_link

FNAME=notifier.log
make_link

FNAME=ack-processor.log
make_link

FNAME=NotifEscalator-error.log
make_link

FNAME=NotifLauncher-error.log
make_link

FNAME=Notifier-error.log
make_link

FNAME=AckProcessor-error.log
make_link

%changelog
* Wed Jun  4 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.125.17-21
- fixed files permissions

* Mon Jun 2 2008 Pradeep Kilambi <pkilambi@redhat.com> 
- new build

* Fri May 30 2008 Pradeep Kilambi <pkilambi@redhat.com> 1.125.17-20-
- new build

* Tue May 27 2008 Jan Pazdziora <jpazdziora@redhat.com> 1.125.17-19
- fixed bugzilla 438770
- rebuild in dist.cvs
