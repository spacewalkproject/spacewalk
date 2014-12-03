%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

Name:           spacewalk-setup
Version:        2.3.1
Release:        1%{?dist}
Summary:        Initial setup tools for Red Hat Spacewalk

Group:          Applications/System
License:        GPLv2
URL:            http://www.spacewalkproject.org/
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  perl
BuildRequires:  perl(ExtUtils::MakeMaker)
## non-core
#BuildRequires:  perl(Getopt::Long), perl(Pod::Usage)
#BuildRequires:  perl(Test::Pod::Coverage), perl(Test::Pod)

BuildArch:      noarch
Requires:       perl
Requires:       perl-Params-Validate
Requires:       spacewalk-schema
Requires:       %{sbinpath}/restorecon
Requires:       spacewalk-admin
Requires:       spacewalk-certs-tools
Requires:       perl-Satcon
Requires:       spacewalk-backend-tools
Requires:       cobbler >= 2.0.0
Requires:       PyYAML
Requires:       /usr/bin/gpg
Requires:       spacewalk-setup-jabberd
Requires:       curl

%description
A collection of post-installation scripts for managing Spacewalk's initial
setup tasks, re-installation, and upgrades.

%prep
%setup -q


%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}


%install
rm -rf %{buildroot}
make pure_install PERL_INSTALL_ROOT=%{buildroot}
find %{buildroot} -type f -name .packlist -exec rm -f {} ';'
find %{buildroot} -type d -depth -exec rmdir {} 2>/dev/null ';'
%if 0%{?rhel} == 5
cat share/tomcat.java_opts.rhel5 >>share/tomcat.java_opts
%endif
%if 0%{?rhel} == 6
cat share/tomcat.java_opts.rhel6 >>share/tomcat.java_opts
%endif
rm -f share/tomcat.java_opts.*

chmod -R u+w %{buildroot}/*
install -d -m 755 %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0755 share/embedded_diskspace_check.py %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/sudoers.* %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/mod_ssl.conf.* %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/tomcat.* %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/server.xml.xsl %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/server-external-authentication.xml.xsl %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/web.xml.patch %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/old-jvm-list %{buildroot}/%{_datadir}/spacewalk/setup/
install -d -m 755 %{buildroot}/%{_datadir}/spacewalk/setup/defaults.d/
install -d -m 755 %{buildroot}/%{_datadir}/spacewalk/setup/upgrade
install -m 0755 share/upgrade/* %{buildroot}/%{_datadir}/spacewalk/setup/upgrade
install -m 0644 share/defaults.d/defaults.conf %{buildroot}/%{_datadir}/spacewalk/setup/defaults.d/
install -d -m 755 %{buildroot}/%{_datadir}/spacewalk/setup/cobbler
install -m 0644 share/cobbler/* %{buildroot}/%{_datadir}/spacewalk/setup/cobbler/

# create a directory for misc. Spacewalk things
install -d -m 755 %{buildroot}/%{_var}/spacewalk

mkdir -p $RPM_BUILD_ROOT%{_mandir}/man8
/usr/bin/pod2man --section=8 $RPM_BUILD_ROOT/%{_bindir}/spacewalk-make-mount-points | gzip > $RPM_BUILD_ROOT%{_mandir}/man8/spacewalk-make-mount-points.8.gz
/usr/bin/pod2man --section=1 $RPM_BUILD_ROOT/%{_bindir}/spacewalk-setup-cobbler | gzip > $RPM_BUILD_ROOT%{_mandir}/man1/spacewalk-setup-cobbler.1.gz
/usr/bin/pod2man --section=1 $RPM_BUILD_ROOT/%{_bindir}/spacewalk-setup-tomcat | gzip > $RPM_BUILD_ROOT%{_mandir}/man1/spacewalk-setup-tomcat.1.gz
/usr/bin/pod2man --section=1 $RPM_BUILD_ROOT/%{_bindir}/spacewalk-setup-httpd | gzip > $RPM_BUILD_ROOT%{_mandir}/man1/spacewalk-setup-httpd.1.gz
/usr/bin/pod2man --section=1 $RPM_BUILD_ROOT/%{_bindir}/spacewalk-setup-sudoers| gzip > $RPM_BUILD_ROOT%{_mandir}/man1/spacewalk-setup-sudoers.1.gz
/usr/bin/pod2man --section=1 $RPM_BUILD_ROOT/%{_bindir}/spacewalk-setup-ipa-authentication| gzip > $RPM_BUILD_ROOT%{_mandir}/man1/spacewalk-setup-ipa-authentication.1.gz

%check
make test


%clean
rm -rf %{buildroot}


%files
%doc Changes README answers.txt
%{perl_vendorlib}/*
%{_bindir}/spacewalk-setup
%{_bindir}/spacewalk-setup-httpd
%{_bindir}/spacewalk-make-mount-points
%{_bindir}/spacewalk-setup-cobbler
%{_bindir}/spacewalk-setup-tomcat
%{_bindir}/spacewalk-setup-sudoers
%{_bindir}/spacewalk-setup-ipa-authentication
%{_bindir}/spacewalk-setup-db-ssl-certificates
%{_bindir}/cobbler20-setup
%{_mandir}/man[13]/*.[13]*
%{_datadir}/spacewalk/*
%attr(755, apache, root) %{_var}/spacewalk
%{_mandir}/man8/spacewalk-make-mount-points*
%doc LICENSE

%changelog
* Mon Nov 24 2014 Tomas Lestach <tlestach@redhat.com> 2.3.1-1
- fix condition
- add spacewalk-setup-ipa-authentication script to Makefile
- Add spacewalk-setup-ipa-authentication to make the external authentication
  easier.

* Mon Aug 18 2014 Tomas Kasparek <tkasparek@redhat.com> 2.3.0-1
- Bumping package versions for 2.3.

* Wed Jun 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.13-1
- Do not enable spacewalk-service in runlevel 4 (bnc#879992)

* Fri Jun 13 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.12-1
- extract the sudo setup into a separate script/tool

* Tue May 27 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.11-1
- spacewalk-setup: require curl

* Tue May 27 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.10-1
- use curl instead of libwww-perl

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.9-1
- Fix SELinux capitalization.

* Fri Apr 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.8-1
- editarea has been replaced with ace-editor

* Wed Apr 02 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.7-1
- use SHA-256 for session secrets

* Mon Mar 17 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.6-1
- 1072784 - jpam.so is in /usr/lib even on x86_64

* Thu Mar 06 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.5-1
- manual page for spacewalk-setup-httpd

* Thu Mar 06 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.4-1
- spacewalk-setup-httpd: utility to configure httpd for Spacewalk

* Tue Mar 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.3-1
- clear-db needs to be present in answers for it to be used
- Clean up - embedded Oracle related code

* Mon Mar 03 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.2-1
- 484950 - clear-db flag does not do what in --help

* Mon Mar 03 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.1-1
- 460556 - option clear-db missing in answer file

* Thu Feb 06 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.14-1
- removed embedded oracle code

* Wed Jan 29 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.13-1
- fixed typo in library path
- tomcat on RHEL5 and RHEL6 needs more parameters

* Mon Jan 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.12-1
- preserve standard library path

* Fri Jan 24 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.11-1
- add oracle library path directly to commandline

* Wed Jan 22 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.10-1
- 1039877 - disable ehcache check for updates

* Wed Jan 22 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.9-1
- modified tomcat setup to work also on Fedora 20

* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.8-1
- Updating the copyright years info

* Fri Jan 03 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.7-1
- 964323 - external PG: remove postgresql from spacewalk services

* Mon Oct 07 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.6-1
- setting up configuration for editarea for apache >= 2.4

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.5-1
- Grammar error occurred

* Fri Aug 23 2013 Tomas Lestach <tlestach@redhat.com> 2.1.4-1
- 997749 - help text for --managed-db

* Tue Jul 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.3-1
- recognize external/embedded variant

* Wed Jul 24 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.2-1
- single parameter system_debug is not supported

* Tue Jul 23 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.1-1
- make sure selinux is working and files are labeled

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Fri Jul 12 2013 Tomas Lestach <tlestach@redhat.com> 1.10.22-1
- skip db schema population only for non-migration upgrade scenarios

* Fri Jul 12 2013 Tomas Lestach <tlestach@redhat.com> 1.10.21-1
- drop and backup logging schema

* Fri Jul 12 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.20-1
- skip db schema population only for non-migration upgrade scenarios
- 959078 - polished database connection error output

* Thu Jul 11 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.19-1
- 983561 - clean tomcat cache during upgrades

* Thu Jul 11 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.18-1
- support for new db migration paths

* Tue Jul 09 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.17-1
- Revert "980355 - delete pg_log before installation starts"

* Tue Jul 09 2013 Jan Dobes 1.10.16-1
- 980355 - delete pg_log before installation starts
- use for cycle instead of map

* Fri Jun 21 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.15-1
- Don't use embedded db default settings for a managed db setup

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.14-1
- removed old CVS/SVN version ids

* Wed Jun 12 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.13-1
- The Satellite ISO no longer contains PostgreSQL directory

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.12-1
- rebrading RHN Satellite to Red Hat Satellite

* Fri Jun 07 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.11-1
- is_embedded_db: support for manage-db switch

* Wed Jun 05 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.10-1
- spacewalk-setup: correctly recognize --managed-db switch
- modify spacewalk-setup to use spacewalk-setup-postgresql

* Thu May 09 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.9-1
- 958677 - suppress uninitialized value messages

* Mon Apr 29 2013 Jan Pazdziora 1.10.8-1
- Support migrations from Satellite 5.5

* Tue Apr 23 2013 Jan Pazdziora 1.10.7-1
- Make HEAD work even against AAAA hostname.

* Tue Apr 16 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.6-1
- restore should not shutdown services automatically

* Fri Apr 12 2013 Jan Pazdziora 1.10.5-1
- Avoid duplicating the Connector element upon subsequent runs.

* Tue Mar 26 2013 Jan Dobes 1.10.4-1
- Updating docs, we don't ship Spacewalk for RHEL 4.

* Fri Mar 22 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.3-1
- 919468 - fixed path in file based Requires

* Fri Mar 22 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.2-1
- supress systemd messages during setup
- Use multiparameter system to better predictability.
- We do not want to run cobbler sync when cobblerd is not running.

* Thu Mar 21 2013 Jan Pazdziora 1.10.1-1
- Silence new LWP which is not happy about SSL verification (fix the
  redirects).

* Wed Feb 20 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.6-1
- perevent parseOptions from failure

* Tue Feb 19 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.5-1
- export oracle path only if we have oracle

* Mon Feb 18 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.4-1
- update tftp dependency for systemd

* Fri Feb 15 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.3-1
- make installation script shorter
- setup /etc/sysconfig/tomcat*
- move setting from tomcat.conf to /etc/sysconfig/tomcat

* Mon Feb 11 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.2-1
- cleanup old CVS files

* Fri Nov 30 2012 Jan Pazdziora 1.9.1-1
- Allow tomcat config file without number.
- Prefer three-parameter open.
- Stop repeated dir/file concatenation.

* Wed Oct 31 2012 Jan Pazdziora 1.8.24-1
- Advertise the www.spacewalkproject.org.

* Tue Oct 30 2012 Jan Pazdziora 1.8.23-1
- Update the copyright year.

* Thu Oct 25 2012 Jan Pazdziora 1.8.22-1
- Exit if spacewalk-setup-embedded-postgresql is not installed.
- Only start database for embedded scenario.

* Mon Oct 22 2012 Jan Pazdziora 1.8.21-1
- 562287 - pass proxy configuration to spacewalk-setup to store it into
  rhn.conf file
- upgrade: start pg server only when migrating
- don't restart services when upgrading
- set upgrade_db.log size to 22M
- don't duplicate database upgrade log
- don't support custom db-name in an answer file
- don't pass db-name to upgrade-db.sh
- When not using tnsnames.ora, the full service name has to be used.
- Revert oracle_setup_embedded_db part of "added embedded postgresql
  installation part"
- Installation is with embedded database if not told otherwise.
- No migration if the ISO has embedded Oracle software.

* Mon Oct 22 2012 Jan Pazdziora 1.8.20-1
- don't remove Oracle stuff during oracle->postgresql migration
- run db migration in upgrade mode only
- set pipefail to correctly detect failed schema migration
- remove oracle-rhnsat-selinux during oracle -> postgresql migration
- Logic for embedded database migration

* Mon Oct 22 2012 Michael Mraka
- check free space under /var/lib/pgsql/data
- modified embedded_diskspace_check to support non default directories
- don't print error messages if postgresql is not set up yet
- setup embedded db also during upgrade

* Mon Oct 22 2012 Michael Mraka
- merge spacewalk-setup-embedded-postgresql and remove-db.sh
- added script to remove database
- added embedded postgresql installation part
- embedded database is now postgresql
- implement on-line backup and restore on PG

* Wed Aug 22 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.17-1
- fix memory settings on 24+ cpu machines
- 847276 - pull http proxy settings from up2date conf.

* Fri Aug 10 2012 Jan Pazdziora 1.8.16-1
- 847011 - document --external-db option

* Wed Aug 01 2012 Jan Pazdziora 1.8.15-1
- 751678 - Make sure we chown the directory structure if /rhnsat is a symlink.

* Fri Jul 13 2012 Tomas Lestach <tlestach@redhat.com> 1.8.14-1
- increase allowed parameter count

* Wed Jun 27 2012 Jan Pazdziora 1.8.13-1
- Exit if starting tomcat did not pass.

* Sat Jun 16 2012 Miroslav Suchý 1.8.12-1
- 827022 - add LICENSE file and change mention Artistic licence to GPLv2

* Wed Jun 06 2012 Jan Pazdziora 1.8.11-1
- Suppress db notices when clearing the schema

* Thu May 31 2012 Jan Pazdziora 1.8.10-1
- get rid of jabberd xsl templates in spacewalk-setup

* Mon May 21 2012 Jan Pazdziora 1.8.9-1
- %%defattr is not needed since rpm 4.4
- remove usage of rhn_quota package

* Fri May 04 2012 Jan Pazdziora 1.8.8-1
- spacewalk-setup-cobbler: extend verbose output (mzazrivec@redhat.com)

* Tue Apr 24 2012 Milan Zazrivec <mzazrivec@redhat.com> 1.8.7-1
- spacewalk-setup-cobbler: script to configure cobbler for Spacewalk
- Rename cobbler-setup to cobbler20-setup

* Tue Apr 17 2012 Jan Pazdziora 1.8.6-1
- Create deploy.sql on PostgreSQL as well (mzazrivec@redhat.com)

* Tue Apr 10 2012 Jan Pazdziora 1.8.5-1
- To support the whole Unicode with idn_to_ascii, we need to specify utf8.
- The spacewalk-setup script does not seem to need Net::LibIDN directly.

* Thu Apr 05 2012 Jan Pazdziora 1.8.4-1
- fixed clearing db for postgresql installation (michael.mraka@redhat.com)

* Mon Mar 19 2012 Jan Pazdziora 1.8.3-1
- rhn-config-satellite.pl does not like to be invoked with no --option
  specified.

* Mon Mar 19 2012 Jan Pazdziora 1.8.2-1
- We no longer have /install/index.pxt, so satellite_install cannot be used.

* Fri Mar 09 2012 Miroslav Suchý 1.8.1-1
- monitoringDOTdbname is not used anymore
- remove RHN_DB_USERNAME from monitoring scout configuration
- remove RHN_DB_PASSWD from monitoring scout configuration
- remove RHN_DB_NAME from monitoring scout configuration
- remove tableowner from monitoring scout configuration
- Bumping package versions for 1.8. (jpazdziora@redhat.com)

* Fri Mar 02 2012 Jan Pazdziora 1.7.9-1
- Update the copyright year info.

* Tue Feb 28 2012 Miroslav Suchý 1.7.8-1
- do not ignore missing answer-file (msuchy@redhat.com)

* Tue Feb 28 2012 Jan Pazdziora 1.7.7-1
- Make sure /etc/cobbler/settings has 644.

* Mon Feb 20 2012 Jan Pazdziora 1.7.6-1
- The valid_countries_tl has no en records and its columns are not used in the
  select anyway.

* Mon Feb 20 2012 Jan Pazdziora 1.7.5-1
- Add stopping of Spacewalk services to postgresql_clear_db as well.

* Tue Feb 14 2012 Tomas Lestach <tlestach@redhat.com> 1.7.4-1
- rename rhn-installation.log to rhn_installation.log (tlestach@redhat.com)

* Tue Jan 31 2012 Jan Pazdziora 1.7.3-1
- Monitoring uses RHN::DB, so no need to have the extra connect parameters.

* Thu Jan 26 2012 Jan Pazdziora 1.7.2-1
- If you have for example NIS before passwd in nsswitch.conf, the usermod will
  not modify what the system uses. Let's check.

* Tue Jan 17 2012 Jan Pazdziora 1.7.1-1
- Prevent LWP 6 from checking the hostname.
- We need LWP::Protocol::https for HEAD to pass since it gets redirected to
  https.
- We want to exit the loop if we have managed to connect to the localhost
  tomcat.

* Wed Dec 14 2011 Jan Pazdziora 1.6.5-1
- Update the target populate_db.log sizes.
- We do not need any async progressbar code (which seems to break on perl
  5.14).
- Optimize where optimization is due.

* Sun Dec 11 2011 Aron Parsons <aronparsons@gmail.com> 1.6.4-1
- add support for Cobbler 2.2 in the installer (aronparsons@gmail.com)

* Thu Dec 08 2011 Miroslav Suchý 1.6.3-1
- code cleanup - rhn-load-ssl-cert and rhn-sudo-load-ssl-cert are not needed
  anymore

* Fri Nov 04 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.2-1
- 679335 - remove osa-dispatcher login credentials from rhn.conf

* Fri Oct 07 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.1-1
- 715271 - define AJP connector on [::1]:8009

* Tue Jul 19 2011 Jan Pazdziora 1.5.11-1
- Updating the copyright years.

* Tue Jul 19 2011 Jan Pazdziora 1.5.10-1
- We kinda need the use Spacewalk::Setup if we plan to call functions from it.

* Mon Jul 18 2011 Jan Pazdziora 1.5.9-1
- Fireworks for the spinning pattern.
- add man page for spacewalk-make-mount-points (msuchy@redhat.com)
- remove macro from changelog (msuchy@redhat.com)

* Mon Jul 11 2011 Jan Pazdziora 1.5.8-1
- Check for cases when loading of the DBD driver fails (so there is no DBI
  error itself).

* Fri May 27 2011 Jan Pazdziora 1.5.7-1
- 708357 - If the mountpoint is on NFS, set cobbler_use_nfs.

* Mon May 16 2011 Jan Pazdziora 1.5.6-1
- We only want to source the setenv.sh if it exists.

* Wed May 11 2011 Jan Pazdziora 1.5.5-1
- Actually package the new tomcatX.conf.3 (for the tomcat6 setenv.sh issue) in
  the rpm.

* Wed May 04 2011 Jan Pazdziora 1.5.4-1
- On RHEL 6, tomcat6 no longer sources the setenv.sh so we need to source it
  ourselves.

* Wed Apr 27 2011 Simon Lukasik <slukasik@redhat.com> 1.5.3-1
- Drop the schema only if exists (slukasik@redhat.com)

* Fri Apr 15 2011 Jan Pazdziora 1.5.2-1
- redirect upgrade log to correct file (mzazrivec@redhat.com)
- move the m4 template at the end of cmd line parameters (mzazrivec@redhat.com)

* Tue Apr 12 2011 Miroslav Suchý 1.5.1-1
- fix rhnConfig namespace
- suppress warning
- Bumping package versions for 1.5

* Tue Apr 05 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.8-1
- fixed typo in answer file option name

* Fri Apr 01 2011 Jan Pazdziora 1.4.7-1
- 683200 - fixing broken commit 695e8f7a792996b7e51f9fd2b11789d26e625753.

* Fri Apr 01 2011 Jan Pazdziora 1.4.6-1
- 683200 - fix more syntax errors.

* Thu Mar 31 2011 Miroslav Suchý 1.4.5-1
- 683200 - fix syntax error

* Wed Mar 30 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.4-1
- fixed missing output redirection
- oracle_sqlplus_t is not able to write to logs

* Wed Mar 30 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.3-1
- 683200 - convert db-host from IDN to ascii

* Mon Mar 07 2011 Jan Pazdziora 1.4.2-1
- Removing rhn-enable-push.pl as it is not referenced from anywhere.
- Removing rhn-load-config.pl as it is not referenced from anywhere.

* Fri Feb 18 2011 Jan Pazdziora 1.4.1-1
- Localize globs used for filehandles; use three-parameter opens.

* Wed Jan 26 2011 Jan Pazdziora 1.3.10-1
- PostgreSQL start/stop is no longer handled by spacewalk-service, neither is
  Oracle XE.
- Make all system_debug invocations multiparameter.

* Tue Jan 25 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.9-1
- 636458 - reuse db version check via dbms_utility.db_version()
- updating Copyright years for year 2011

* Wed Jan 19 2011 Jan Pazdziora 1.3.8-1
- Call spacewalk-sql instead of rhn-populate-database.pl.

* Tue Jan 18 2011 Jan Pazdziora 1.3.7-1
- The db-sid is long gone, using db-name now.
- As db-protocol is no longer processed (supported), removing.
- Refactored oracle_get_database_answers.
- Creating empty file is not that useful, dropping.

* Tue Jan 11 2011 Tomas Lestach <tlestach@redhat.com> 1.3.6-1
- replace any LD_LIBRARY_PATH by given content (tlestach@redhat.com)
- Removing Oracle-ism from postgresql_populate_db. (jpazdziora@redhat.com)
- The installation on PostgreSQL is now supported. (jpazdziora@redhat.com)
- Removing code which was commented out since 2009. (jpazdziora@redhat.com)
- All three invocations of write_config in spacewalk-setup specify the target,
  no need to have the default. (jpazdziora@redhat.com)

* Fri Jan 07 2011 Jan Pazdziora 1.3.5-1
- Setup InstantClient 11 path for tomcat.

* Sun Dec 26 2010 Jan Pazdziora 1.3.4-1
- 665693: convert sysdate to current_timestamp (colin.coe@gmail.com)

* Thu Dec 23 2010 Jan Pazdziora 1.3.3-1
- The rhn_package package (schema in PostgreSQL) is now gone.

* Thu Dec 16 2010 Jan Pazdziora 1.3.2-1
- 636458 - check that the Oracle database instance is version 10 or 11.

* Mon Dec 13 2010 Jan Pazdziora 1.3.1-1
- 640971 - when waiting for tomcat, try to connect directly to 8009.
- We need to check the return value of GetOptions and die if the parameters
  were not correct.

* Fri Nov 05 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.16-1
- 491331 - move /etc/sysconfig/rhn-satellite-prep to /var/lib/rhn/rhn-
  satellite-prep (msuchy@redhat.com)

* Tue Nov 02 2010 Jan Pazdziora 1.2.15-1
- Update copyright years in the rest of the repo.

* Fri Oct 29 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.14-1
- change ascii art animation to bow, arrow and target

* Tue Oct 26 2010 Jan Pazdziora 1.2.13-1
- When run with the --db-only option, stop after populating the database.

* Fri Oct 22 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.12-1
- 612581 - use new spacewalk namespace for spacewalk-setup

* Fri Oct 15 2010 Jan Pazdziora 1.2.11-1
- Revert "avoid people install packages for different os"
- Revert "valid require format is name = version"

* Thu Oct 14 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.10-1
- avoid people install packages for different os

* Tue Oct 12 2010 Jan Pazdziora 1.2.9-1
- Move the cobbler requirement to version 2.0.0.

* Mon Oct 11 2010 Jan Pazdziora 1.2.8-1
- Do not require perl-DBD-Pg in spacewalk-setup, save it for spacewalk-
  postgresql.

* Mon Sep 27 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.7-1
- do not restart whole satellite when enabling monitoring
  (mzazrivec@redhat.com)
- use bind variables (mzazrivec@redhat.com)
- don't use RHN::Utils in spacewalk-setup (mzazrivec@redhat.com)
- need_oracle_9i_10g_upgrade is no longer needed (mzazrivec@redhat.com)
- unify embedded database upgrades (mzazrivec@redhat.com)
- use standard perl dbi in update_monitoring_scout (mzazrivec@redhat.com)

* Tue Sep 14 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.2.6-1
- re-link /etc/smrsh/ack_enqueuer.pl during upgrade
- update monitoring scout setup directly by spacewalk-setup
- added --external-db option to installer

* Wed Sep 01 2010 Jan Pazdziora 1.2.5-1
- 594513 - only listen on localhost (connectors at 8080 and 8009).
- 531719 - fixing cobbler setup to set pxe_just_once (jsherril@redhat.com)

* Thu Aug 26 2010 Justin Sherrill <jsherril@redhat.com> 1.2.4-1
- small fix for broken perl code (jsherril@redhat.com)

* Thu Aug 26 2010 Justin Sherrill <jsherril@redhat.com> 1.2.3-1
- making patch command silent (jsherril@redhat.com)
- 533527 - having spacewalk-setup patch the web.xml for tomcat to turn off
  development mode (jsherril@redhat.com)

* Thu Aug 26 2010 Justin Sherrill <jsherril@redhat.com> 1.2.2-1
- 533527 - having spacewalk-setup patch the web.xml for tomcat to turn off
  development mode (jsherril@redhat.com)

* Thu Aug 26 2010 Jan Pazdziora 1.2.1-1
- As we never fork now, the --nofork is obsolete, removing.

* Thu Jul 29 2010 Justin Sherrill <jsherril@redhat.com> 1.1.14-1
- 531719 - making pxe_just_once set to 1 by default on a spacewalk install
  (jsherril@redhat.com)

* Fri Jul 23 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.13-1
- db-sid is now db-name

* Fri Jul 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.12-1
- renamed db_sid to SID db_name to be consistent with PostgreSQL

* Fri Jul 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.11-1
- renamed db_sid to SID db_name to be consistent with PostgreSQL

* Fri Jul 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.10-1
- unified database connection information

* Mon Jul 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.9-1
- fixed tomcat5.conf pattern

* Wed Jul 14 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.8-1
- let jdbc use network service name

* Wed Jul 14 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.7-1
- tomcat config files should be modified not replaced

* Fri Jul 09 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.6-1
- add example of answers.txt file (msuchy@redhat.com)

* Thu Jul 01 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.5-1
- For local database, we shall use the syntax without slashes. Even if the jdbc
  driver goes via TCP anyway. (jpazdziora@redhat.com)

* Mon Jun 28 2010 Jan Pazdziora 1.1.4-1
- The default_db has username and password in Oracle case, let's make it the
  same for PostgreSQL.
- Some values (db-sid) can be undef, do not pass them to rhn-config-
  satellite.pl.
- Some values (db-sid) can be undef, leading to warnings, there does not need
  to be a host a port, and the default_db is different for PostgreSQL.
- Let's do a slightly better formatting of our terminal output.
- Fix postgresql_clear_db to clear the content of the PostgreSQL database.

* Mon Jun 21 2010 Jan Pazdziora 1.1.3-1
- Minor fixes for PostgreSQL code paths.
- Unused code cleanup.

* Thu Jun 17 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.2-1
- fun aside, swimmer meet shark (msuchy@redhat.com)

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages
- Move systemlogs directory out of /var/satellite
- Remove audit review cruft from spacewalk-setup

