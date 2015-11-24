%global rhnroot /%{_datadir}/rhn
Summary: Various utility scripts and data files for Red Hat Satellite installations
Name: spacewalk-admin
URL:     https://fedorahosted.org/spacewalk
Version: 2.5.1
Release: 1%{?dist}
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
License: GPLv2
Group: Applications/Internet
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: spacewalk-base
Requires: perl(MIME::Base64)
Requires: lsof
BuildRequires: /usr/bin/pod2man
%if 0%{?fedora}
BuildRequires: systemd
%endif
Obsoletes: satellite-utils < 5.3.0
Provides: satellite-utils = 5.3.0
Obsoletes: rhn-satellite-admin < 5.3.0
Provides: rhn-satellite-admin = 5.3.0
BuildArch: noarch

%description
Various utility scripts and data files for Spacewalk installations.

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT

%if 0%{?fedora}
mv -f spacewalk-service.systemd spacewalk-service
make -f Makefile.admin install_systemd PREFIX=$RPM_BUILD_ROOT
%endif
make -f Makefile.admin install PREFIX=$RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{_mandir}/man8/
%{_bindir}/pod2man --section=8 rhn-config-schema.pl > $RPM_BUILD_ROOT%{_mandir}/man8/rhn-config-schema.pl.8
%{_bindir}/pod2man --section=8 man/spacewalk-service.pod > $RPM_BUILD_ROOT%{_mandir}/man8/spacewalk-service.8
%{_bindir}/pod2man --section=8 man/rhn-sat-restart-silent.pod > $RPM_BUILD_ROOT%{_mandir}/man8/rhn-sat-restart-silent.8
%{_bindir}/pod2man --section=8 rhn-config-satellite.pl > $RPM_BUILD_ROOT%{_mandir}/man8/rhn-config-satellite.pl.8
%{_bindir}/pod2man --section=8 man/rhn-generate-pem.pl.pod > $RPM_BUILD_ROOT%{_mandir}/man8/rhn-generate-pem.pl.8
%{_bindir}/pod2man --section=8 man/rhn-deploy-ca-cert.pl.pod > $RPM_BUILD_ROOT%{_mandir}/man8/rhn-deploy-ca-cert.pl.8
%{_bindir}/pod2man --section=8 man/rhn-install-ssl-cert.pl.pod > $RPM_BUILD_ROOT%{_mandir}/man8/rhn-install-ssl-cert.pl.8
install -p man/rhn-satellite.8 $RPM_BUILD_ROOT%{_mandir}/man8/
chmod 0644 $RPM_BUILD_ROOT%{_mandir}/man8/*.8*
ln -s spacewalk-service $RPM_BUILD_ROOT%{_sbindir}/rhn-satellite

%clean
rm -rf $RPM_BUILD_ROOT

%files
%doc LICENSE
%dir %{rhnroot}
%{_sbindir}/spacewalk-startup-helper
%{_sbindir}/spacewalk-service
%{_sbindir}/rhn-satellite
%{_bindir}/rhn-config-satellite.pl
%{_bindir}/rhn-config-schema.pl
%{_bindir}/rhn-generate-pem.pl
%{_bindir}/rhn-deploy-ca-cert.pl
%{_bindir}/rhn-install-ssl-cert.pl
%{_sbindir}/rhn-sat-restart-silent
%{rhnroot}/RHN-GPG-KEY
%{_mandir}/man8/rhn-satellite.8*
%{_mandir}/man8/rhn-config-schema.pl.8*
%{_mandir}/man8/spacewalk-service.8*
%{_mandir}/man8/rhn-sat-restart-silent.8*
%{_mandir}/man8/rhn-config-satellite.pl.8*
%{_mandir}/man8/rhn-generate-pem.pl.8*
%{_mandir}/man8/rhn-deploy-ca-cert.pl.8*
%{_mandir}/man8/rhn-install-ssl-cert.pl.8*
%config(noreplace) %{_sysconfdir}/rhn/service-list
%if 0%{?fedora}
%{_unitdir}/spacewalk.target
%{_unitdir}/spacewalk-wait-for-tomcat.service
%{_unitdir}/spacewalk-wait-for-jabberd.service
%endif

%changelog
* Tue Nov 24 2015 Jan Dobes 2.5.1-1
- spacewalk-admin.spec: incorrect cd removed
- spacewalk-admin: drop validate-sat-cert.pl
- Bumping package versions for 2.5.

* Thu Sep 24 2015 Jan Dobes 2.4.2-1
- Bumping copyright year.

* Wed Aug 05 2015 Jan Dobes 2.4.1-1
- trust spacewalk CA certificate
- Bumping package versions for 2.4.

* Thu Mar 19 2015 Grant Gainey 2.3.4-1
- drop requires for perl-URI - seems to be unused
- Updating copyright info for 2015

* Fri Jan 16 2015 Tomas Lestach <tlestach@redhat.com> 2.3.3-1
- remove Monitoring and MonitoringScout from spacewalk.target and spacewalk-
  service

* Tue Jan 13 2015 Matej Kollar <mkollar@redhat.com> 2.3.2-1
- Getting rid of trailing spaces in Perl
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Wed Jan 07 2015 Jan Dobes 2.3.1-1
- 1179374 - do not crash if rhn.conf does not exist
- Bumping package versions for 2.3.

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.7-1
- we need to call restorecon with full path

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.6-1
- fix copyright years

* Tue Jul 08 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.5-1
- restorecon may have different path

* Wed Jun 18 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.4-1
- Set correct SELinux context on the target file

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.3-1
- Do not look at processes in containers.

* Thu May 22 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.2-1
- 1064287 - Use systemctl to get the pid since /var/run/tomcat.pid is empty.

* Mon Apr 14 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.1-1
- Add support to ConfigureSatelliteCommand to remove keys

* Mon Oct 14 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.2-1
- cleaning up old svn Ids

* Thu Aug 08 2013 Jan Dobes 2.1.1-1
- fixing decrementation
- 972626 - general waiting function
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Wed Jul 03 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.7-1
- make spacewalk-admin build-able on F19

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.6-1
- rebrading RHN Satellite to Red Hat Satellite

* Thu May 23 2013 Tomas Lestach <tlestach@redhat.com> 1.10.5-1
- 961463 - lsof workaround for mounted NFS shares

* Mon May 13 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.4-1
- 962154 - don't manage oracle service by default

* Wed Apr 10 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.3-1
- supress output to stdout

* Mon Apr 08 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.2-1
- fixed enable/disable of spacewalk services

* Thu Mar 07 2013 Miroslav Suchý <msuchy@redhat.com> 1.10.1-1
- add =back after =over
- Bumping package versions for 1.9
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Wed Feb 27 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.10-1
- let systemd report service as active

* Tue Feb 26 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.9-1
- suppress journal messages

* Fri Feb 22 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.8-1
- wait both for application and administration port to be ready

* Tue Feb 19 2013 Jan Pazdziora 1.9.7-1
- The ensure-httpd-down will sleep in the loop, no need to have it in the main
  script.
- Fixing the wait-for-tomcat-disable logic.

* Mon Feb 18 2013 Miroslav Suchý <msuchy@redhat.com> 1.9.6-1
- Buildrequire pod2man

* Thu Feb 14 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.5-1
- wait-for-tomcat has been moved to helper
- let's osa-dispatcher wait for jabberd startup
- include systemd target and services

* Tue Feb 12 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.4-1
- added systemd version of spacewalk-service
- systemd target for spacewalk
- moved waiting for jabberd to helper
- moved ensure_httpd_down() into script
- moved wait-for-tomcat into general startup helper

* Mon Dec 10 2012 Jan Pazdziora 1.9.3-1
- The systemd service files are not executable, using -e.

* Fri Dec 07 2012 Jan Pazdziora 1.9.2-1
- Fixing typo.

* Tue Dec 04 2012 Jan Pazdziora 1.9.1-1
- On Fedoras, start to use tomcat >= 7.

* Tue Oct 30 2012 Jan Pazdziora 1.8.6-1
- Update the copyright year.
- %%defattr is not needed since rpm 4.4

* Thu May 10 2012 Jan Pazdziora 1.8.5-1
- Add support for database-specific override files.

* Fri Mar 30 2012 Stephen Herr <sherr@redhat.com> 1.8.4-1
- 808580 - change service startup order so jabberd can finish before osa-
  dispatcher starts (sherr@redhat.com)

* Tue Mar 27 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.3-1
- 737972 - add man page for rhn-install-ssl-cert.pl
- 737972 - add man page for rhn-deploy-ca-cert.pl
- 737972 - add man page for rhn-generate-pem.pl
- 737972 - fix changelog entries

* Mon Mar 26 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.2-1
- sudo and restorecon is not needed any more

* Mon Mar 26 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.1-1
- 737972 - use %%global, not %%define
- 737972 - add license text
- 737972 - using packages rather than filedesps
- Bumping package versions for 1.8. (jpazdziora@redhat.com)

* Fri Mar 02 2012 Jan Pazdziora <jpazdziora@redhat.com> 1.7.4-1
- Update the copyright year info.

* Fri Feb 03 2012 Jan Pazdziora <jpazdziora@redhat.com> 1.7.3-1
- 784158 - make it possible to customize list of services managed by the
  spacewalk-service command.
- Purging trailing whitespaces.

* Fri Feb 03 2012 Jan Pazdziora <jpazdziora@redhat.com> 1.7.2-1
- Revert "cat /var/run/.pid nondeterministically failes with 'cat: write error:
  Broken pipe', thus it's better to do it in two separate steps."

* Thu Feb 02 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.1-1
- fixed write error: Broken pipe

* Mon Dec 12 2011 Martin Minar <mminar@redhat.com> 1.6.3-1
- On F16 some services are run using systemd. Some remain in old fashion
  init.d. (mminar@redhat.com)

* Thu Dec 08 2011 Miroslav Suchý <msuchy@redhat.com> 1.6.2-1
- code cleanup - rhn-load-ssl-cert and rhn-sudo-load-ssl-cert are not needed
  anymore

* Tue Oct 04 2011 Miroslav Suchý <msuchy@redhat.com> 1.6.1-1
- writing pod documentation to shell script is not smart, move it aside

* Tue Jul 19 2011 Jan Pazdziora <jpazdziora@redhat.com> 1.5.5-1
- Updating the copyright years.

* Tue Jul 19 2011 Jan Pazdziora <jpazdziora@redhat.com> 1.5.4-1
- Fixing typo.

* Mon Jul 18 2011 Miroslav Suchý <msuchy@redhat.com> 1.5.3-1
- it is recomended to not use .gz extension as this may change in future
  (msuchy@redhat.com)
- create man page for validate-sat-cert.pl.8 as alias for validate-sat-cert.8
  (msuchy@redhat.com)
- move pod documentation to man/ directory (msuchy@redhat.com)
- add man page for rhn-config-satellite.pl (msuchy@redhat.com)
- add man page for rhn-sat-restart-silent (msuchy@redhat.com)
- remove warning about obsolete rhn-satellite service (msuchy@redhat.com)

* Fri Apr 29 2011 Jan Pazdziora <jpazdziora@redhat.com> 1.5.2-1
- For config files created in /etc/rhn, do chgrp apache.

* Thu Apr 28 2011 Jan Pazdziora <jpazdziora@redhat.com> 1.5.1-1
- Disable access of other to the satellite-local-rules.conf file, as it
  contains the database password.

* Wed Mar 30 2011 Jan Pazdziora <jpazdziora@redhat.com> 1.4.2-1
- Fixing spacewalk-service start hang at waiting for tomcat.
  (dale@fedoraproject.org)

* Fri Feb 18 2011 Jan Pazdziora <jpazdziora@redhat.com> 1.4.1-1
- Explicitly require lsof in spacewalk-admin (for spacewalk-service).

* Thu Jan 20 2011 Tomas Lestach <tlestach@redhat.com> 1.3.9-1
- updating Copyright years for year 2011 (tlestach@redhat.com)
- Removing rhn-populate-database.pl, we now use the generic spacewalk-sql.
  (jpazdziora@redhat.com)

* Tue Jan 18 2011 Jan Pazdziora <jpazdziora@redhat.com> 1.3.8-1
- The rhn-config-tnsnames.pl is no longer used, removing.
- Do not call external /bin/touch to create a lockfile.

* Tue Jan 11 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.7-1
- more update of spacewalk-service man page (msuchy@redhat.com)
- Change to root directory for PostgreSQL, just like we do for sqlplus.
  (jpazdziora@redhat.com)

* Tue Jan 11 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.6-1
- add man page for spacewalk-service

* Tue Jan 11 2011 Jan Pazdziora <jpazdziora@redhat.com> 1.3.5-1
- Fixing typo -- we want to eval, not echo.

* Mon Jan 10 2011 Jan Pazdziora <jpazdziora@redhat.com> 1.3.4-1
- Wait for tomcat by default, use --no-wait-for-tomcat to skip.

* Tue Dec 14 2010 Jan Pazdziora <jpazdziora@redhat.com> 1.3.3-1
- Need to define $usage if I insist on using it.

* Tue Dec 14 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.2-1
- add man page for rhn-sudo-load-ssl-cert
- add man page for rhn-load-ssl-cert.pl
- specify section of man page
- create man page for rhn-config-schema.pl
- man3 is usually used by C library functions, we should use man8
- add man page for rhn-satellite script
- provide rhn-satellite-admin
- provide satellite-utils

* Tue Dec 14 2010 Jan Pazdziora <jpazdziora@redhat.com> 1.3.1-1
- We need to check the return value of GetOptions and die if the parameters
  were not correct.

* Tue Nov 02 2010 Jan Pazdziora <jpazdziora@redhat.com> 1.2.7-1
- Update copyright years in the rest of the repo.

* Tue Oct 19 2010 Jan Pazdziora <jpazdziora@redhat.com> 1.2.6-1
- The /usr/sbin/rhn-satellite will no longer start/stop Oracle XE.

* Wed Oct 13 2010 Jan Pazdziora <jpazdziora@redhat.com> 1.2.5-1
- 631847 - in RHN Proxy 5.4 is used jabber 2.0 where user is called jabber
  (instead of jabberd) (msuchy@redhat.com)

* Tue Sep 14 2010 Jan Pazdziora <jpazdziora@redhat.com> 1.2.4-1
- If there are some errors with overrides, exit with error code.

* Thu Sep 09 2010 Jan Pazdziora <jpazdziora@redhat.com> 1.2.3-1
- Add back support for old Spacewalk schema sources, needed for Satellite
  schema upgrade testing.

* Thu Aug 26 2010 Jan Pazdziora <jpazdziora@redhat.com> 1.2.2-1
- 626420 - chdir to root to stop sqlplus from searching the mounted devices.
- As we never fork now, the --nofork is obsolete, removing.
- We do not call the schema population from WebUI, no forking.
- The dbhome is not needed as we are using the InstantClient sqlplus.

* Tue Aug 24 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.2.1-1
- make schema overrides work with new main.sql structure

* Thu Jul 22 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.4-1
- 536989 - exit cleanly when run by non-root

* Thu Jun 24 2010 Jan Pazdziora <jpazdziora@redhat.com> 1.1.3-1
- To allow database population to create at least some database schema, do not
  stop on error for now.

* Mon Jun 21 2010 Jan Pazdziora <jpazdziora@redhat.com> 1.1.2-1
- For PostgreSQL, add support for connects to nondefault port; also, avoid
  using shell.
- PostgreSQL can use local connection just fine, no need for host to be
  specified.

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

