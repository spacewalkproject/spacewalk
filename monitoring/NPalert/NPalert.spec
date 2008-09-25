%define cvs_package NPalert
%define install_prefix     /opt/notification
%define cron_prefix        %install_prefix/cron
%define httpd_prefix       /var/www
%define notif_user         nocpulse
%define registry           /etc/rc.d/np.d/apachereg
%define log_rotate_prefix  /etc/logrotate.d/

# Package specific stuff
Name:         NPalert
Summary:      NOCpulse notification system
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/NPalert
# make srpm
URL:          https://fedorahosted.org/spacewalk
Source0:      %{name}-%{version}.tar.gz
Version:      1.125.18
Release:      1%{?dist}
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
#Requires:     perl perl(Config::IniFiles) perl(DBI) perl(DBD::Oracle) perl(Class::MethodMaker) perl(Error) perl(Date::Manip) perl-TimeDate perl-MailTools perl-NOCpulse-Probe perl-libwww-perl perl(URI) perl(HTML::Parser) perl(FreezeThaw)
Group:        Applications/Communications
License:      GPLv2
Requires:     nocpulse-common smtpdaemon
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This pacakge provides NOCpulse notification system.

%prep
%setup -q

%build
#nothing to do here

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
ln -s $RPM_BUILD_ROOT%cron_prefix/notification %{_sysconfdir}/cron.d/notification

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
rm -rf $RPM_BUILD_ROOT

%pre
if [ -h /opt/notification/etc/NOCpulse ] ; then
	rm /opt/notification/etc/NOCpulse
fi
if [ -h /opt/notification/scripts/NOCpulse ] ; then
	rm /opt/notification/scripts/NOCpulse
fi

%changelog
* Thu Sep 25 2008 Miroslav Suchý <msuchy@redhat.com> 
- spec cleanup for Fedora

* Wed Sep  3 2008 Jesus Rodriguez <jesusr@redhat.com> 1.125.18-1
- rebuild for spacewalk
- move version from file to spec file

* Wed Aug 20 2008 Milan Zazrivec <mzazrivec@redhat.com>
- fix for bugzilla #253966

* Wed Jun  4 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.125.17-21
- fixed files permissions

* Mon Jun 2 2008 Pradeep Kilambi <pkilambi@redhat.com> 
- new build

* Fri May 30 2008 Pradeep Kilambi <pkilambi@redhat.com> 1.125.17-20-
- new build

* Tue May 27 2008 Jan Pazdziora <jpazdziora@redhat.com> 1.125.17-19
- fixed bugzilla 438770
- rebuild in dist.cvs
