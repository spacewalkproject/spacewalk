%global rhnroot /%{_datadir}/rhn
Summary: Various utility scripts and data files for Spacewalk and Red Hat Satellite installations
Name: spacewalk-admin
URL:     https://github.com/spacewalkproject/spacewalk
Version: 2.9.0
Release: 1%{?dist}
Source0: https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
License: GPLv2
Requires: spacewalk-base
Requires: perl(MIME::Base64)
Requires: lsof
BuildRequires: /usr/bin/pod2man
%if 0%{?rhel} >= 7 || 0%{?fedora} || 0%{?suse_version} >= 1210
BuildRequires: systemd
%endif
Obsoletes: satellite-utils < 5.3.0
Provides: satellite-utils = 5.3.0
Obsoletes: rhn-satellite-admin < 5.3.0
Provides: rhn-satellite-admin = 5.3.0
BuildArch: noarch
%if 0%{?suse_version}
BuildRequires: spacewalk-config
%endif

%description
Various utility scripts and data files for Spacewalk and Red Hat Satellite installations.

%prep
%setup -q

%build

%install

%if 0%{?rhel} >= 7 || 0%{?fedora} || 0%{?suse_version} >= 1210
mv -f spacewalk-service.systemd spacewalk-service
make -f Makefile.admin install_systemd PREFIX=$RPM_BUILD_ROOT
%if 0%{?suse_version} >= 1210
install -m 644 spacewalk.target.SUSE $RPM_BUILD_ROOT%{_unitdir}/spacewalk.target
install -m 644 spacewalk-wait-for-tomcat.service.SUSE $RPM_BUILD_ROOT%{_unitdir}/spacewalk-wait-for-tomcat.service
%endif
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
%if 0%{?rhel} >= 7 || 0%{?fedora} || 0%{?suse_version} >= 1210
%{_unitdir}/spacewalk.target
%{_unitdir}/spacewalk-wait-for-tomcat.service
%{_unitdir}/spacewalk-wait-for-jabberd.service
%endif

%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.4-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Fri Dec 15 2017 Jan Dobes <jdobes@redhat.com> 2.8.3-1
- 1524221 - ship systemd target on RHEL 7 too

* Mon Nov 13 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.2-1
- don't use systemctl pager for output as we have "| less"

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Mon Jul 17 2017 Jan Dobes 2.7.1-1
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub
- Bumping package versions for 2.7.

* Wed Oct 12 2016 Grant Gainey 2.6.1-1
- Update specfile to be consistent about referring to both SW and Satellite
- Bumping package versions for 2.6.

* Fri May 20 2016 Grant Gainey 2.5.3-1
- remove monitoring from SUSE spacewalk target

* Tue May 10 2016 Grant Gainey 2.5.2-1
- spacewalk-admin: build on openSUSE

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

