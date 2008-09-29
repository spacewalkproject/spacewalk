%define install_prefix     %{_var}/lib/notification
%define log_dir            %{_var}/log/notification
%define httpd_prefix       %{_var}/www
%define notif_user         nocpulse
%define registry           %{_sysconfdir}/rc.d/np.d/apachereg
%define log_rotate_prefix  %{_sysconfdir}/logrotate.d/

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
Requires:     SatConfig-general
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
mkdir -p --mode=755 $RPM_BUILD_ROOT%{_sysconfdir}/notification/archive
mkdir -p --mode=755 $RPM_BUILD_ROOT%{_sysconfdir}/notification/generated
mkdir -p --mode=755 $RPM_BUILD_ROOT%{_sysconfdir}/notification/static
mkdir -p --mode=755 $RPM_BUILD_ROOT%{_sysconfdir}/notification/stage/config
mkdir -p --mode=755 $RPM_BUILD_ROOT%{_sysconfdir}/notification
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/ack_queue
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/ack_queue/.new
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/alert_queue
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/alert_queue/.new
mkdir -p --mode=755 $RPM_BUILD_ROOT%{_bindir}
mkdir -p --mode=755 $RPM_BUILD_ROOT%log_dir
mkdir -p --mode=755 $RPM_BUILD_ROOT%log_dir/archive
mkdir -p --mode=755 $RPM_BUILD_ROOT%log_dir/ticketlog

# Create symlinks
#ln -s ../../scripts                 $RPM_BUILD_ROOT%{_sysconfdir}/notification/stage/scripts
ln -s ../../static                  $RPM_BUILD_ROOT%{_sysconfdir}/notification/stage/config/static
#mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/scripts/NOCpulse
#ln -s ../../config                  $RPM_BUILD_ROOT%install_prefix/scripts/NOCpulse/config
#mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/etc/NOCpulse
#ln -s ../../config                  $RPM_BUILD_ROOT%install_prefix/etc/NOCpulse/config

# Install the perl modules
mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Notif
#mkdir -p --mode 755 $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Notif/test
install -m 644 *.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Notif
#install -m 644 test/*.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Notif/test

# Install the scripts
install -m 755 scripts/* $RPM_BUILD_ROOT%{_bindir}

# Install the config stuff
install config/*.ini $RPM_BUILD_ROOT%{_sysconfdir}/notification/static


# Make sure everything is owned by the right user/group and critical dirs
# have the right permissions
chmod 755 $RPM_BUILD_ROOT%install_prefix
chmod -R 755 $RPM_BUILD_ROOT%{_bindir}

# Install the html and cgi scripts
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/htdocs
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/cgi-bin
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/cgi-mod-perl
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/templates

ln -s %log_dir           $RPM_BUILD_ROOT%httpd_prefix/htdocs/alert_logs

install -m 755 httpd/cgi-bin/redirmgr.cgi $RPM_BUILD_ROOT%httpd_prefix/cgi-bin/
install -m 755 httpd/cgi-mod-perl/*.cgi $RPM_BUILD_ROOT%httpd_prefix/cgi-mod-perl/
install -m 755 httpd/html/*.html        $RPM_BUILD_ROOT%httpd_prefix/htdocs/
install -m 755 httpd/html/*.css         $RPM_BUILD_ROOT%httpd_prefix/htdocs/
install -m 755 httpd/templates/*.html   $RPM_BUILD_ROOT%httpd_prefix/templates/

# Install the cron stuff
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/cron.d/
install -m 644 cron/notification        $RPM_BUILD_ROOT%{_sysconfdir}/cron.d/notification

# Install apache registration entries
mkdir -p $RPM_BUILD_ROOT%registry
install -m 644 Apache.NPalert $RPM_BUILD_ROOT%registry

# Install logrotate stuff
mkdir -p %buildroot%{_sysconfdir}/logrotate.d/
install -m 644 logrotate.d/notification  $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/

%files
%defattr(-,root,root,-)
%{_sysconfdir}/logrotate.d/notification
%{_sysconfdir}/cron.d/notification
%{registry}/Apache.NPalert
%{httpd_prefix}/*
%dir %install_prefix
%dir %{perl_vendorlib}/NOCpulse/Notif
%{perl_vendorlib}/NOCpulse/Notif/*
%{_bindir}/*
%attr (755,%notif_user,%notif_user) %dir %{_sysconfdir}/notification
%attr (755,%notif_user,%notif_user) %dir %{_sysconfdir}/notification/archive
%attr (755,%notif_user,%notif_user) %dir %{_sysconfdir}/notification/generated
%attr (755,%notif_user,%notif_user) %dir %{_sysconfdir}/notification/static
%attr (755,%notif_user,%notif_user) %dir %{_sysconfdir}/notification/stage
%attr (755,%notif_user,%notif_user) %dir %{_sysconfdir}/notification/stage/config
%attr (755,%notif_user,%notif_user) %dir %install_prefix/queue
%attr (775,mail,       %notif_user) %dir %install_prefix/queue/ack_queue
%attr (775,mail,       %notif_user) %dir %install_prefix/queue/ack_queue/.new
%attr (775,apache,     %notif_user) %dir %install_prefix/queue/alert_queue
%attr (775,apache,     %notif_user) %dir %install_prefix/queue/alert_queue/.new
%attr (755,%notif_user,%notif_user) %dir %log_dir
%attr (755,%notif_user,%notif_user) %dir %log_dir/archive
%attr (755,%notif_user,%notif_user) %dir %log_dir/ticketlog
%attr(644,%notif_user,%notif_user) %{_sysconfdir}/notification/static/*
%{_sysconfdir}/notification/stage/config/static

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Mon Sep 29 2008 Miroslav Suchý <msuchy@redhat.com> 
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
