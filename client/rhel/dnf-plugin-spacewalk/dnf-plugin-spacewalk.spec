%if 0%{?fedora} || 0%{?rhel} >= 8
%global build_py3   1
%global default_py3 1
%endif

%if ( 0%{?fedora} && 0%{?fedora} < 28 ) || ( 0%{?rhel} && 0%{?rhel} < 8 )
%global build_py2   1
%endif

%define pythonX %{?default_py3: python3}%{!?default_py3: python2}

Summary: DNF plugin for Spacewalk
Name: dnf-plugin-spacewalk
Version: 2.8.8
Release: 1%{?dist}
License: GPLv2
Source0: https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
URL:     https://github.com/spacewalkproject/spacewalk
BuildArch: noarch

Requires: %{pythonX}-%{name} = %{version}-%{release}
%if 0%{?fedora} && 0%{?fedora} <= 25
Requires: dnf >= 0.5.3
%else
Requires: dnf >= 2.0.0
%endif
Requires: dnf-plugins-core
Requires: librepo >= 1.7.15
%if 0%{?fedora}
Obsoletes: yum-rhn-plugin < 2.7
%endif

%description
This DNF plugin provides access to a Spacewalk server for software updates.

%if 0%{?build_py2}
%package -n python2-%{name}
Summary: DNF plugin for Spacewalk
%{?python_provide:%python_provide python2-%{name}}
BuildRequires: python-devel
Requires: %{name} = %{version}-%{release}
Requires: python2-rhn-client-tools >= 2.8.4
%description -n python2-%{name}
Python 2 specific files for %{name}.
%endif

%if 0%{?build_py3}
%package -n python3-%{name}
Summary: DNF plugin for Spacewalk
%{?python_provide:%python_provide python3-%{name}}
BuildRequires: python3-devel
Requires: %{name} = %{version}-%{release}
Requires: python3-rhn-client-tools >= 2.8.4

%description -n python3-%{name}
Python 3 specific files for %{name}.
%endif

%prep
%setup -q

%build
%if 0%{?fedora} && 0%{?fedora} <= 25
patch -p4 < dnf-plugin-spacewalk-revert-to-1.0.patch
%endif

%install
install -d %{buildroot}%{_sysconfdir}/dnf/plugins/
install -d %{buildroot}/var/lib/up2date
install -d %{buildroot}%{_mandir}/man{5,8}
install -m 644 spacewalk.conf %{buildroot}%{_sysconfdir}/dnf/plugins/
install -m 644 man/spacewalk.conf.5 %{buildroot}%{_mandir}/man5/
install -m 644 man/dnf.plugin.spacewalk.8 %{buildroot}%{_mandir}/man8/

# python2
%if 0%{?build_py2}
install -d %{buildroot}%{python2_sitelib}/rhn/actions
install -d %{buildroot}%{python2_sitelib}/dnf-plugins/
install -m 644 spacewalk.py %{buildroot}%{python2_sitelib}/dnf-plugins/
install -m 644 actions/packages.py %{buildroot}%{python2_sitelib}/rhn/actions/
install -m 644 actions/errata.py %{buildroot}%{python2_sitelib}/rhn/actions/
%endif

%if 0%{?build_py3}
install -d %{buildroot}%{python3_sitelib}/rhn/actions
install -d %{buildroot}%{python3_sitelib}/dnf-plugins/
install -m 644 spacewalk.py %{buildroot}%{python3_sitelib}/dnf-plugins/
install -m 644 actions/packages.py %{buildroot}%{python3_sitelib}/rhn/actions/
install -m 644 actions/errata.py %{buildroot}%{python3_sitelib}/rhn/actions/
%endif

%pre

%post

%files
%verify(not md5 mtime size) %config(noreplace) %{_sysconfdir}/dnf/plugins/spacewalk.conf
%license LICENSE
%dir /var/lib/up2date
%{_mandir}/man*/*

%if 0%{?build_py2}
%files -n python2-%{name}
%{python_sitelib}/dnf-plugins/*
%{python_sitelib}/rhn/actions/*
%endif

%if 0%{?build_py3}
%files -n python3-%{name}
%{python3_sitelib}/dnf-plugins/*
%{python3_sitelib}/rhn/actions/*
%endif

%changelog
* Mon Mar 19 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.8-1
- don't build python2 subpackages on systems with default python2

* Tue Feb 20 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.7-1
- %%if 0%%{?fedora} <= 25 is always true on rhel

* Tue Feb 20 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.6-1
- rhel8 utilizes python3

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.5-1
- removed Group from specfile

* Mon Nov 27 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.4-1
- 1512582 - don't fail on empty installroot

* Fri Sep 29 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.3-1
- require new version of rhn-client-tools
- move client actions to rhn namespace

* Fri Sep 22 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- install files into python_sitelib/python3_sitelib
- split dnf-plugin-spacewalk into python2/python3 specific packages

* Thu Sep 07 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.1-1
- unload function has been renamed to _unload() in DNF 2
- Bumping package versions for 2.8.

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.9-1
- update copyright year

* Fri Jul 21 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.8-1
- 1437864 - base.plugins has been renamed to base._plugins

* Tue May 30 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.7-1
- 1236609 - update to dnf's new config module

* Fri May 26 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.6-1
- 1308493 - actually fix duplicated channel even for dnf 1.X

* Fri May 26 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.5-1
- 1308493 - fixed plugin initialization in dnf 2.X
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Fri Feb 17 2017 Jan Dobes 2.7.4-1
- fix bz1422518 - request failed: error reading the headers (CVE-2016-8743)

* Wed Feb 15 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.3-1
- allow building both dnf 1.0 and 2.0 version from the same source
- 1308493 - initialize spacewalk channels before --enablerepo/--disablerepo
  handler
- dnf-plugin-spacewalk updated to dnf 2.0

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

