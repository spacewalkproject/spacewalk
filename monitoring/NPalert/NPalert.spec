%define install_prefix     %{_var}/lib/notification
%define log_dir            %{_var}/log/notification
%define httpd_prefix       %{_datadir}/nocpulse
%define notif_user         nocpulse
%define log_rotate_prefix  %{_sysconfdir}/logrotate.d/

# Package specific stuff
Name:         NPalert
Summary:      NOCpulse notification system
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      2.3.0
Release:      1%{?dist}
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Group:        Applications/Communications
License:      GPLv2
Requires:     nocpulse-common smtpdaemon
Requires:     SatConfig-general
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires: /usr/bin/pod2man

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package provides NOCpulse notification system.

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
mkdir -p --mode=755 $RPM_BUILD_ROOT%{_sysconfdir}/smrsh
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/ack_queue
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/ack_queue/.new
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/alert_queue
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/alert_queue/.new
mkdir -p --mode=755 $RPM_BUILD_ROOT%{_bindir}
mkdir -p --mode=755 $RPM_BUILD_ROOT%log_dir
mkdir -p --mode=755 $RPM_BUILD_ROOT%log_dir/archive
mkdir -p --mode=755 $RPM_BUILD_ROOT%log_dir/ticketlog

# Create symlinks
ln -s ../../static                  $RPM_BUILD_ROOT%{_sysconfdir}/notification/stage/config/static
ln -s /usr/bin/ack_enqueuer.pl      $RPM_BUILD_ROOT%{_sysconfdir}/smrsh/ack_enqueuer.pl

# Install the perl modules
mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Notif
#mkdir -p --mode 755 $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Notif/test
install -p -m 644 *.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Notif
#install -m 644 test/*.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Notif/test

# Install the scripts
install -p -m 755 scripts/* $RPM_BUILD_ROOT%{_bindir}

# Install the config stuff
install -p config/*.ini $RPM_BUILD_ROOT%{_sysconfdir}/notification/static


# Make sure everything is owned by the right user/group and critical dirs
# have the right permissions
chmod 755 $RPM_BUILD_ROOT%install_prefix
chmod -R 755 $RPM_BUILD_ROOT%{_bindir}

# Install the html and cgi scripts
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/htdocs
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/cgi-bin
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/cgi-mod-perl
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/templates

ln -s ../../../../%log_dir           $RPM_BUILD_ROOT%httpd_prefix/htdocs/alert_logs

install -p -m 755 httpd/cgi-bin/redirmgr.cgi $RPM_BUILD_ROOT%httpd_prefix/cgi-bin/
install -p -m 755 httpd/cgi-mod-perl/*.cgi $RPM_BUILD_ROOT%httpd_prefix/cgi-mod-perl/
install -p -m 644 httpd/html/*.html        $RPM_BUILD_ROOT%httpd_prefix/htdocs/
install -p -m 644 httpd/html/*.css         $RPM_BUILD_ROOT%httpd_prefix/htdocs/
install -p -m 644 httpd/templates/*.html   $RPM_BUILD_ROOT%httpd_prefix/templates/

# Install the cron stuff
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/cron.d/
install -p -m 644 cron/notification        $RPM_BUILD_ROOT%{_sysconfdir}/cron.d/notification

mkdir -p $RPM_BUILD_ROOT%{_mandir}/man3
/usr/bin/pod2man $RPM_BUILD_ROOT/%{_bindir}/monitor-queue | gzip > $RPM_BUILD_ROOT%{_mandir}/man3/monitor-queue.3pm.gz
/usr/bin/pod2man $RPM_BUILD_ROOT/%{_bindir}/queue_remote_check.pl | gzip > $RPM_BUILD_ROOT%{_mandir}/man3/queue_remote_check.pl.3pm.gz

%post
if [ $1 -eq 2 ]; then
  ls /opt/notification/config/generated/* 2>/dev/null | xargs -I file mv file %{_sysconfdir}/notification/generated
  ls /opt/notification/config/static/notif.ini 2>/dev/null | xargs -I file mv file %{_sysconfdir}/notification/static
  ls /opt/notification/var/GenerateNotifConfig-error.log 2>/dev/null | xargs -I file mv file %{_var}/log/nocpulse
  ls /opt/notification/var/archive/* 2>/dev/null | xargs -I file mv file %log_dir/archive
  ls /opt/notification/var/ticketlog/* 2>/dev/null | xargs -I file mv file %log_dir/ticketlog
fi

%files
%{_sysconfdir}/cron.d/notification
%{httpd_prefix}
%attr(755, nocpulse, nocpulse) %dir %{httpd_prefix}/templates
%dir %attr(-, %notif_user,%notif_user) %install_prefix
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
%{_sysconfdir}/smrsh/ack_enqueuer.pl
%{_sysconfdir}/notification/stage/config/static
%{_mandir}/man3/monitor-queue*
%{_mandir}/man3/queue_remote_check.pl*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.127.12-1
- rebrading RHN Satellite to Red Hat Satellite

* Tue Mar 26 2013 Jan Pazdziora 1.127.11-1
- Use to_timestamp instead of to_date which should bring the second precision
  to PostgreSQL.

* Mon Feb 18 2013 Miroslav Suchý <msuchy@redhat.com> 1.127.10-1
- Buildrequire pod2man

* Mon Jan 21 2013 Michael Mraka <michael.mraka@redhat.com> 1.127.8-1
- specify permission on /usr/share/nocpulse/templates

* Wed Aug 01 2012 Jan Pazdziora 1.127.7-1
- 844992 - force the array context so that Class::MethodMaker behaves the same
  in both versions 1 and 2.
- %%defattr is not needed since rpm 4.4

* Fri Mar 09 2012 Miroslav Suchý 1.127.6-1
- remove RHN_DB_USERNAME from monitoring scout configuration

* Thu Feb 23 2012 Jan Pazdziora 1.127.5-1
- Removing usage of rhn_current_alerts as it's never inserted to.

* Wed Feb 22 2012 Jan Pazdziora 1.127.4-1
- Method select_current_alert not used, removing.
- Removal of update_current_alert_by_ticket_id makes update_current_alert not
  used, removing.
- Removal of update_current_alert_by_ticket_id makes
  select_current_alert_by_ticket_id not used, removing.
- Method update_current_alert_by_ticket_id not used in our product, removing.

* Wed Feb 08 2012 Michael Mraka <michael.mraka@redhat.com> 1.127.3-1
- fixed synonyms and sequences for postgresql in notification filters

* Wed Feb 01 2012 Miroslav Suchý 1.127.2-1
- bump up version (msuchy@redhat.com)
- get rid of PhoneContactMethod - is is not even in DB
- rip off SNMP notification method

* Tue Jan 31 2012 Jan Pazdziora 1.126.31-1
- In monitoring, use RHN::DBI instead of RHN::DB because we do not want to
  reuse the connection.

* Mon Jan 30 2012 Jan Pazdziora 1.126.30-1
- Avoid having the messages on different lines than their timestamps.
- Avoid having the output both in generate_config.log and GenerateNotifConfig-
  error.log.

* Fri Jan 27 2012 Jan Pazdziora 1.126.29-1
- 730305 - Upon start, wait for generate-config to generate the config.

* Tue Jan 24 2012 Jan Pazdziora 1.126.28-1
- When we rollback before going to sleep, we won't keep transaction active.

* Mon Jan 16 2012 Miroslav Suchý 1.126.27-1
- Avoid using CURRENT_ALERTS_RECID_SEQ.NEXTVAL Oracle syntax.

* Mon Dec 12 2011 Michael Mraka <michael.mraka@redhat.com> 1.126.26-1
- use real table name rhn_check_probe

* Mon Aug 15 2011 Michael Mraka <michael.mraka@redhat.com> 1.126.25-1
- 700385 - use standard ANSI join
- 700385 - use current_timestamps instead of sysdate
- 700385 - replaced synonym with original table_name
- 700385 - use standard ANSI join
- 700385 - created compatibility views for monitoring
- 700385 - reuse RHN::DB for db connection in NotificationDB.pm

* Thu Jul 21 2011 Miroslav Suchý 1.126.24-1
- 723899 - run that cron task only if /etc/NOCpulse.ini contains something else
  then comments

* Fri May 13 2011 Miroslav Suchý 1.126.23-1
- removing unmaintained file with dependencies

* Wed Apr 27 2011 Jan Pazdziora 1.126.22-1
- Neither functions from File::Basename nor from File::Copy seem to be used by
  ack-processor, removing the uses.

* Fri Mar 18 2011 Michael Mraka <michael.mraka@redhat.com> 1.126.21-1
- reuse RHN:DB for db connection in AlertDB.pm (PG)

* Wed Mar 02 2011 Michael Mraka <michael.mraka@redhat.com> 1.126.20-1
- 493028 - ack_enqueuer.pl must be linked from /etc/smrsh
- 493028 - select all but expired redirects 
- 493028 - empty TZ is interpreted as GMT not local timezone; it must be unset
- 493028 - dates in db are in localtime not GMT
- 493028 - fixed active redirects query condition

* Fri Feb 18 2011 Jan Pazdziora 1.126.19-1
- Localize the filehandle globs; also use three-parameter opens.

* Tue Jan 25 2011 Jan Pazdziora 1.126.18-1
- 493028 - simplified email check regexp (michael.mraka@redhat.com)

* Sat Nov 20 2010 Miroslav Suchý <msuchy@redhat.com> 1.126.17-1
- 474591 - move web data to /usr/share/nocpulse (msuchy@redhat.com)

* Mon Sep 27 2010 Miroslav Suchý <msuchy@redhat.com> 1.126.16-1
- 636211 - include man page for queue_remote_check.pl
- 636211 - include man page for monitor-queue

* Mon Jul 19 2010 Miroslav Suchý <msuchy@redhat.com> 1.126.15-1
- $self->dbh is method from MethodMaker and not attribute (msuchy@redhat.com)

* Mon Jul 12 2010 Miroslav Suchý <msuchy@redhat.com> 1.126.14-1
- remove unused module (msuchy@redhat.com)

* Mon Jul 12 2010 Miroslav Suchý <msuchy@redhat.com> 1.126.13-1
- break dependency of NPalert on perl(NOCpulse::Probe::DataSource::Oracle)
  (msuchy@redhat.com)

* Mon Jul 12 2010 Miroslav Suchý <msuchy@redhat.com> 1.126.12-1
- remove dependency on DBD::Oracle (msuchy@redhat.com)

