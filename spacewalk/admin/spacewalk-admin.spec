%define rhnroot /%{_datadir}/rhn
Summary: Various utility scripts and data files for RHN Satellite installations
Name: spacewalk-admin
URL:     https://fedorahosted.org/spacewalk
Version: 1.0.1
Release: 1%{?dist}
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
License: GPLv2
Group: Applications/Internet
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: spacewalk-base
Requires: perl-URI, perl(MIME::Base64)
Requires: sudo
Requires: /sbin/restorecon
Obsoletes: satellite-utils < 5.3.0
Obsoletes: rhn-satellite-admin < 5.3.0
BuildArch: noarch

%description
Various utility scripts and data files for Spacewalk installations.

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.admin install PREFIX=$RPM_BUILD_ROOT

(cd $RPM_BUILD_ROOT/%{_bindir} && ln -s validate-sat-cert.pl validate-sat-cert)

mkdir -p $RPM_BUILD_ROOT%{_mandir}/man3/
%{_bindir}/pod2man validate-sat-cert.pod | gzip -c - > $RPM_BUILD_ROOT%{_mandir}/man3/validate-sat-cert.3.gz
chmod 0644 $RPM_BUILD_ROOT%{_mandir}/man3/validate-sat-cert.3.gz
ln -s spacewalk-service $RPM_BUILD_ROOT%{_sbindir}/rhn-satellite

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%dir %{rhnroot}
%{_sbindir}/spacewalk-service
%{_sbindir}/rhn-satellite
%{_initrddir}/rhn-satellite
%{_bindir}/validate-sat-cert.pl
%{_bindir}/validate-sat-cert
%{_bindir}/rhn-config-satellite.pl
%{_bindir}/rhn-config-schema.pl
%{_bindir}/rhn-config-tnsnames.pl
%{_bindir}/rhn-populate-database.pl
%{_bindir}/rhn-generate-pem.pl
%{_bindir}/rhn-sudo-load-ssl-cert
%{_bindir}/rhn-load-ssl-cert.pl
%{_bindir}/rhn-deploy-ca-cert.pl
%{_bindir}/rhn-install-ssl-cert.pl
%{_sbindir}/rhn-sat-restart-silent
%{rhnroot}/RHN-GPG-KEY
%{_mandir}/man3/validate-sat-cert.3.gz

%changelog
* Mon Apr 19 2010 Shannon Hughes <shughes@redhat.com> 1.0.1-1
- version changes for spacewalk 1.0 release (shughes@redhat.com)

* Wed Mar 24 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.2-1
- improved spacewalk-service script

* Tue Feb 16 2010 Justin Sherrill <jsherril@redhat.com> 0.9.1-1
- changing rhn-satellite service script to support tomcat6
  (jsherril@redhat.com)
- let's start Spacewalk 0.9 (michael.mraka@redhat.com)

* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- rebuild for spacewalk 0.8

* Tue Jul 28 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.3-1
- Fix Oracle db population logging. (dgoodwin@redhat.com)

* Mon Jul 27 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.2-1
- Fix Oracle logging to populate-db.log. (dgoodwin@redhat.com)
- Fix some merge errors in rhn-populate-database.pl. (dgoodwin@redhat.com)
- Fix Oracle rhn-populate-db.pl issue. (dgoodwin@redhat.com)
- Update spacewalk-setup to deploy new PostgreSQL schema layout.
  (dgoodwin@redhat.com)

* Mon Apr 20 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.1-1
- bump Versions to 0.6.0 (jesusr@redhat.com)

* Wed Mar 25 2009 Milan Zazrivec <mzazrivec@redhat.com> 0.5.15-1
- rhn-satellite restarts oracle service rather than rhn-database

* Wed Mar 25 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.14-1
- some jabberd installs use jabberd, while others use jabber, check for both.

* Wed Mar 25 2009 Jan Pazdziora 0.5.13-1
- 491687 - wrapper around sudo rhn-load-ssl-cert.pl, to change SELinux domain

* Fri Mar 13 2009 Jan Pazdziora 0.5.12-1
- 486738 - change to root's home directory before running sqlplus

* Wed Mar 11 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.11-1
- added chkconfig option and improved database detection in rhn-satellite script

* Thu Feb 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.10-1
- fix typo

* Thu Feb 19 2009 Jan Pazdziora 0.5.9-1
- rhn-populate-database.pl: fix the LOGFILE logic

* Wed Feb 11 2009 Dave Parker <dparker@redhat.com> 0.5.8-1
- 484659 remove error messages due to incorrect startup sequence in sysv and rhn-satellite utility
* Tue Feb 10 2009 Jan Pazdziora 0.5.7-1
- rhn-config-satellite.pl: use hardlink to create original backup
- rhn-config-satellite.pl: code cleanup

* Mon Feb  9 2009 Jan Pazdziora 0.5.6-1
- rhn-config-schema.pl mustn't die if the override directory does not exist

* Wed Feb  4 2009 Jan Pazdziora 0.5.5-1
- only run restorecon on RHEL 5+ and with SELinux enabled

* Thu Jan 29 2009 Jan Pazdziora 0.5.4-1
- rhn-config-schema.pl: add check that all the overrides were used
- rhn-config-schema.pl: turn spaces (two) to tabs
- rhn-populate-database.pl: only write to logfile if --log specified.
- rhn-populate-database.pl: use parameter log_file in get_next_backup_filename
- .spec changes, silence rpmlint warnings

* Fri Jan 23 2009 Jan Pazdziora 0.5.3-1
- add support for schema overrides

* Wed Jan 21 2009 Michael Mraka <michael.mraka@redhat.com> 0.5.2-1
- fixed branding stuff
 
* Mon Jan 19 2009 Jan Pazdziora 0.5.1-1
- rebuilt for 0.5, after repository reorg

* Fri Jan  9 2009 Jan Pazdziora 0.4.8-1
- restart "stock" httpd rather than satellite-httpd (by Milan Z.)

* Thu Dec 11 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.6-1
- resolved #471225 - moved /sbin stuff to /usr/sbin

* Wed Dec 10 2008 Miroslav Suchy <msuchy@redhat.com> 0.4.4-1
- 470590 - warn user that /etc/init.d/rhn-satellite is obsolete.

* Tue Dec  9 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.3-1
- fixed Obsoletes: rhns-* < 5.3.0

* Wed Nov 19 2008 Devan Goodwin <dgoodwin@redhat.com> 0.4.2-1
- Replace use of perl-crypt-OpenPGP and perl-crypt-RIPEMD160 with gpg system call.
- Validate certificates using gpg on the command line.
- Delete perl-Crypt-OpenPGP and perl-Crypt-RIPEMD160 packages.
- Remove RHN::GPG.

* Thu Oct 30 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.1-1
- resolved #455421 

* Tue Oct 21 2008 Michael Mraka <michael.mraka@redhat.com> 0.3.2-1
- resolved #467717 - fixed sysvinit scripts

* Tue Sep 23 2008 Milan Zazrivec 0.3.1-1
- fixed package obsoletes

* Tue Sep  2 2008 Milan Zazrivec 0.2.1-1
- bumped version for make tag-release

* Tue Aug  5 2008 Jan Pazdziora 0.1.1-0
- tagged for rebuild after rename, also bumping version

* Mon Aug  4 2008 Miroslav Suchy <msuchy@redhat.com>
- Renamed to spacewalk-admin
- reworked .spec to use macros
- fixed BuildRoot

* Mon Aug  4 2008 Jan Pazdziora 0.1-1
- removed version and sources files

* Wed May 21 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-3%{?dist}
- fixed * expansion in rhn-populate-database.pl

* Tue May 20 2008 Jan Pazdziora - 5.2.0-2%{?dist}
- rebuild via dist-cvs

* Thu Dec 20 2007 Justin Sherrill <jsherril@redhat.com>
- Adding rhn-sat-restart-silent sript in order for the webUI restart to work

* Wed Oct  6 2004 Robin Norwood <rnorwood@redhat.com>
- switch to using a Makefile instead of specifying each script

* Mon Aug  2 2004 Robin Norwood <rnorwood@redhat.com>
- add more perl scripts
- need to change this to use a Makefile RSN

* Tue Jul  6 2004 Robin Norwood <rnorwood@redhat.com>
- add perl scripts for web based install

* Fri Oct 31 2003 Chip Turner <cturner@redhat.com>
- add symlink of validate-sat-cert -> validate-sat-cert.pl

* Tue Aug 20 2002 Cristian Gafton <gafton@redhat.com>
- make it a noarch package

* Mon Jun  3 2002 Chip Turner <cturner@redhat.com>
- new versions

* Thu Apr 25 2002 Chip Turner <cturner@redhat.com>
- Initial build.
