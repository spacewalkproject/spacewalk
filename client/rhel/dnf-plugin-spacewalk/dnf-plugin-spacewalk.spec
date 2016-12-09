Summary: DNF plugin for Spacewalk
Name: dnf-plugin-spacewalk
Version: 2.7.2
Release: 1%{?dist}
License: GPLv2
Group: System Environment/Base
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
URL:     https://fedorahosted.org/spacewalk
BuildArch: noarch

%if 0%{?fedora}
BuildRequires: python3-devel
%else
BuildRequires: python-devel
%endif
Requires: dnf >= 2.0.0
Requires: dnf-plugins-core
Requires: librepo >= 1.7.15
Requires: rhn-client-tools >= 2.5.5
%if 0%{?fedora} >= 22
Obsoletes: yum-rhn-plugin < 2.7
%endif

%description
This DNF plugin provides access to a Spacewalk server for software updates.

%prep
%setup -q

%build


%install
install -d %{buildroot}%{_sysconfdir}/dnf/plugins/
install -d %{buildroot}/usr/share/rhn/actions
install -d %{buildroot}/var/lib/up2date
install -d %{buildroot}%{_mandir}/man{5,8}
%if 0%{?fedora}
install -d %{buildroot}%{python3_sitelib}/dnf-plugins/
install -m 644 spacewalk.py %{buildroot}%{python3_sitelib}/dnf-plugins/
%else
install -d %{buildroot}%{python2_sitelib}/dnf-plugins/
install -m 644 spacewalk.py %{buildroot}%{python2_sitelib}/dnf-plugins/
%endif
install -m 644 actions/packages.py %{buildroot}/usr/share/rhn/actions/
install -m 644 actions/errata.py %{buildroot}/usr/share/rhn/actions/
install -m 644 spacewalk.conf %{buildroot}%{_sysconfdir}/dnf/plugins/
install -m 644 man/spacewalk.conf.5 %{buildroot}%{_mandir}/man5/
install -m 644 man/dnf.plugin.spacewalk.8 %{buildroot}%{_mandir}/man8/

%pre

%post

%files
%verify(not md5 mtime size) %config(noreplace) %{_sysconfdir}/dnf/plugins/spacewalk.conf
%license LICENSE
%dir /var/lib/up2date
%{_mandir}/man*/*
%if 0%{?fedora}
%{python3_sitelib}/dnf-plugins/*
%else
%{python2_sitelib}/dnf-plugins/*
%endif
%{_datadir}/rhn/actions/*

%changelog
* Wed Nov 16 2016 Gennadii Altukhov <galt@redhat.com> 2.7.2-1
- reverted 2030f2f6b1efb82bda06676fbf22ab3716e890e5. A new API call is not
  available yet in Fedora 23/24.

* Tue Nov 15 2016 Gennadii Altukhov <galt@redhat.com> 2.7.1-1
- remove workaround  for BZ 1218071
- Bumping package versions for 2.7.

* Fri Sep 23 2016 Michael Mraka <michael.mraka@redhat.com> 2.6.1-1
- fixed rpmlint warnings
- 1342491 - remove dependency on python2 on F23+

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.8-1
- updating copyright years

* Thu May 12 2016 Gennadii Altukhov <galt@redhat.com> 2.5.7-1
- fix: wrong converting of exception to string

* Wed May 11 2016 Gennadii Altukhov <galt@redhat.com> 2.5.6-1
- replace has_key to work in python 3

* Mon May 09 2016 Gennadii Altukhov <galt@redhat.com> 2.5.5-1
- 1323028 - fix upgrade from Fedora 21 to 22

* Wed May 04 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.4-1
- Fix code via PEP8
- AK does not install packages via dnf-client

* Tue Jan 19 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.3-1
- yet another python3 fixes

* Fri Jan 08 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.2-1
- updated dnf / rhnlib / rhn-client-tools dependencies

* Fri Jan 08 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.1-1
- 1286555 - updated to work in python3
- Bumping package versions for 2.5.

* Thu Aug 20 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.15-1
- 1254551 - fixed error message output

* Wed Aug 19 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.14-1
- 1254551 - fixed missing InvalidGpgKeyLocation exception

* Mon Jul 13 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.13-1
- require on dnf-plugins-core is needed for docker images

* Thu Jun 11 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.12-1
- bz1230251: do nothing if enabled=0
- bz1226986: accept options from plugin configuration file

* Mon Jun 01 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.11-1
- global name 'CHANNELS_DISABLED' is not defined

* Fri May 29 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.10-1
- fixed variable asignment

* Fri May 29 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.9-1
- koji does not define python_sitelib

* Mon May 25 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.7-1
- added license
- be consistent in using macros vs. shell variables
- make spec complient with fedora packaging guidlines

* Tue May 19 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.5-1
- minimal needed version of librepo

* Tue May 12 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.4-1
- fixed rpmbuild issues

* Mon May 11 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.2-1
- add action files for packages/errata installation
- put spacewalk both into python2 and python3 setelibs

* Thu Apr 16 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.1-1
- initial build of dnf-plugin-spacewalk

