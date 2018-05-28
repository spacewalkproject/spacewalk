%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

Name:           spacewalk-setup
Version:        2.9.2
Release:        1%{?dist}
Summary:        Initial setup tools for Spacewalk

License:        GPLv2
URL:            http://www.spacewalkproject.org/
Source0:        %{name}-%{version}.tar.gz

%if 0%{?fedora} && 0%{?fedora} > 26
BuildRequires:  perl-interpreter
%else
BuildRequires:  perl
%endif
BuildRequires:  perl(ExtUtils::MakeMaker)
## non-core
#BuildRequires:  perl(Getopt::Long), perl(Pod::Usage)
#BuildRequires:  perl(Test::Pod::Coverage), perl(Test::Pod)

BuildArch:      noarch
%if 0%{?fedora} && 0%{?fedora} > 26
Requires:       perl-interpreter
%else
Requires:       perl
%endif
Requires:       perl-Params-Validate
Requires:       perl(Term::Completion::Path)
Requires:       spacewalk-schema
Requires:       %{sbinpath}/restorecon
Requires:       spacewalk-admin
Requires:       spacewalk-certs-tools
Requires:       perl-Satcon
Requires:       spacewalk-backend-tools
Requires:       cobbler20
Requires:       PyYAML
Requires:       /usr/bin/gpg
Requires:       spacewalk-setup-jabberd
Requires:       spacewalk-base-minimal
Requires:       spacewalk-base-minimal-config
Requires:       curl
Requires:	perl-Mail-RFC822-Address
Requires:	perl-DateTime
Requires:	perl-Net-LibIDN

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
%if 0%{?rhel} == 6
cat share/tomcat.java_opts.rhel6 >>share/tomcat.java_opts
%endif
if java -version 2>&1 | grep -q IBM ; then
    cat share/tomcat.java_opts.ibm >>share/tomcat.java_opts
fi
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
* Mon May 28 2018 Jiri Dostal <jdostal@redhat.com> 2.9.2-1
- 1533052 - Declare variable for use strict

* Thu May 24 2018 Jiri Dostal <jdostal@redhat.com> 2.9.1-1
- 1533052 - Add FQDN detection to setup and config utilities.
- Bumping package versions for 2.9.

* Tue Mar 27 2018 Jiri Dostal <jdostal@redhat.com> 2.8.7-1
- Revert "1533052 - Add FQDN detection to setup and config utilities."

* Tue Mar 27 2018 Jiri Dostal <jdostal@redhat.com> 2.8.6-1
- 1533052 - Add FQDN detection to setup and config utilities.

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.5-1
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed Dec 20 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.4-1
- warn when fqdn is not in lowercase

* Thu Dec 14 2017 Eric Herget <eherget@redhat.com> 2.8.3-1
- 1456471 - PR570 - Using own certificates for installer
- 1456471 - PR570 - [RFE] Using own certifications for installer (CA, private
  key)

* Thu Sep 21 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- clean up RHEL5 specific settings
- 1483503 - disable ibm java coredumps for tomcat

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Thu Aug 10 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.12-1
- 1479849 - Requires: perl has been renamed to perl-interpreter on Fedora 27
- 1479849 - BuildRequires: perl has been renamed to perl-interpreter on Fedora
  27

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.11-1
- update copyright year

* Thu Jun 22 2017 Grant Gainey 2.7.10-1
- add ssl-set-cnames to spacewalk-setup

* Wed May 31 2017 Gennadii Altukhov <grinrag@gmail.com> 2.7.9-1
- 1455948 - use only ASCII (including extended set) characters for the progress
  spinner

* Fri May 05 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.8-1
- move sudoers configuration to /etc/sudoers.d/spacewalk

* Thu May 04 2017 Gennadii Altukhov <galt@redhat.com> 2.7.7-1
- 1415107 - change progress spinner for the installation script

* Fri Apr 21 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.6-1
- add new option skip-services-restart
- point users to proper log on tomcat 7+

* Tue Apr 11 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.5-1
- 1440818 - add option for path completion
- 1440818 - require perl-Term-Completion module
- 1440818 - remove leading and trailing spaces when asking for information

* Fri Mar 31 2017 Laurence Rochfort <laurence.rochfort@oracle.com>
- 1430747 - Add support for Oracle 12.2.

* Wed Mar 22 2017 Ondrej Gajdusek <ogajduse@redhat.com> 2.7.3-1
- require three perl libs because of failure on fc25
- Migrating Fedorahosted to GitHub

* Tue Feb 21 2017 Jan Dobes 2.7.2-1
- 1416804 - reset stdin for failed connections

* Mon Feb 20 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.1-1
- 1175596 - don't leak output of cobbler sync into installer
- 1420744 - change RHN on RHSM in installer script
- Bumping package versions for 2.7.

* Fri Oct 14 2016 Grant Gainey 2.6.2-1
- Updated specfile to remove extraneous 'Red Hat'

* Fri Sep 30 2016 Jan Dobes 2.6.1-1
- require spacewalk-base-minimal-config from spacewalk-setup
- Bumping package versions for 2.6.

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.5-1
- updating copyright years

* Mon May 16 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.4-1
- try to reuse values from rhn.conf

* Mon Dec 07 2015 Jan Dobes 2.5.3-1
- removing create first org code from installer

* Tue Nov 24 2015 Jan Dobes 2.5.2-1
- Use the same name for the first org as before
- remove trailing whitespaces
- Remove unused Cert class from spacewalk-setup
- Remove unused load_satellite_certificate function and satellite-cert-file
  parameter
- Remove certificate handling from setup
- rhn-satellite-activate: dropped

* Tue Oct 13 2015 Tomas Kasparek <tkasparek@redhat.com> 2.5.1-1
- use --upgrade option for sw-dump-schema during migrations
- Bumping package versions for 2.5.

* Fri Aug 07 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.6-1
- Modified setup string to make it clearer that Oracle EZconnect requires the
  Global Database Name, not the SID. The two values are the same for XE.

* Wed Aug 05 2015 Jan Dobes 2.4.5-1
- trust spacewalk CA certificate

* Fri Jul 24 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.4-1
- require cobbler20 - Spacewalk is not working with upstream cobbler anyway

* Fri Jun 26 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.3-1
- Recommend cobbler20 with all packages requiring cobbler on Fedora 22

* Wed Jun 03 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.2-1
- use ls -Z instead of ls --scontext

* Mon May 25 2015 Tomas Lestach <tlestach@redhat.com> 2.4.1-1
- spacewalk-setup spec: add spacewalk-base-minimal as an explicit dependency
- Bumping package versions for 2.4.

* Thu Mar 19 2015 Grant Gainey 2.3.14-1
- Updating copyright info for 2015

* Thu Mar 12 2015 Tomas Lestach <tlestach@redhat.com> 2.3.13-1
- removing unused rhn_web.conf options

* Wed Mar 04 2015 Jan Dobes 2.3.12-1
- 1198708 - disable embedded postgresql service when installing external oracle
- 1198708 - configure tomcat earlier to work with database migrations
- 1180251 - append oracle driver path only if spacewalk-oracle is installed

* Thu Feb 26 2015 Tomas Lestach <tlestach@redhat.com> 2.3.11-1
- Added Oracle RDBMS 12.1.0 to the list of allowed database versions.

* Mon Feb 16 2015 Stephen Herr <sherr@redhat.com> 2.3.10-1
- spacewalk-setup upgrade dir no longer exists after monitoring removal

* Mon Feb 16 2015 Stephen Herr <sherr@redhat.com> 2.3.9-1
- remove setup of dropped monitoring feature

* Fri Jan 16 2015 Tomas Lestach <tlestach@redhat.com> 2.3.8-1
- Fix configuration of tomcat-service for CentOS7. Tomcat7 on CentOS7 uses
  /etc/tomcat/server.xml. Adjust regex to match.

* Tue Jan 13 2015 Matej Kollar <mkollar@redhat.com> 2.3.7-1
- Getting rid of Tabs and trailing spaces in Python
- Getting rid of trailing spaces in Perl
- Getting rid of Tabs in Perl
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Wed Jan 07 2015 Jan Dobes 2.3.6-1
- 1179374 - set more database specific values and move hibernate strings into
  function
- 1179374 - do not erase complete original configuration
- 1179374 - move write_config function into module
- 1020952 - Certificates need to set up sooner
- remember to populate db
- don't run spacewalk-setup-cobbler in verbose mode

* Wed Dec 17 2014 Stephen Herr <sherr@redhat.com> 2.3.5-1
- drop monitoring code and monitoring schema
- Useful comment

* Tue Dec 16 2014 Matej Kollar <mkollar@redhat.com> 2.3.4-1
- 1020952 -- Check for existence of cert file

* Mon Dec 15 2014 Jan Dobes 2.3.3-1
- 1172541 - do not use embedded db defaults if not installing embedded db
- 1172541 - fix filtering files with defaults

* Thu Dec 11 2014 Matej Kollar <mkollar@redhat.com> 2.3.2-1
- 1020952 - Include SSL configuration in setup

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

