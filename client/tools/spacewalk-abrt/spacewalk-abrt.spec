%if 0%{?fedora} || 0%{?rhel} >= 8
%global build_py3   1
%global default_py3 1
%endif

%if ( 0%{?fedora} && 0%{?fedora} < 28 ) || ( 0%{?rhel} && 0%{?rhel} < 8 )
%global build_py2   1
%endif

%define pythonX %{?default_py3: python3}%{!?default_py3: python2}

Name:           spacewalk-abrt
Version:        2.8.5
Release:        1%{?dist}
Summary:        ABRT plug-in for rhn-check

License:        GPLv2
URL:            https://github.com/spacewalkproject/spacewalk
Source0:        https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch:      noarch
BuildRequires:  gettext
Requires:       %{pythonX}-%{name} = %{version}-%{release}
Requires:       abrt
Requires:       abrt-cli
%description
spacewalk-abrt - rhn-check plug-in for collecting information about crashes handled by ABRT.

%if 0%{?build_py2}
%package -n python2-%{name}
Summary:        ABRT plug-in for rhn-check
%{?python_provide:%python_provide python2-%{name}}
BuildRequires:  python
Requires:       python2-rhn-client-tools
Requires:       python2-rhn-check
%description -n python2-%{name}
Python 2 specific files for %{name}.
%endif

%if 0%{?build_py3}
%package -n python3-%{name}
Summary:        ABRT plug-in for rhn-check
%{?python_provide:%python_provide python3-%{name}}
BuildRequires:  python3-rpm-macros
Requires:       python3-rhn-client-tools
Requires:       python3-rhn-check
%description -n python3-%{name}
Python 3 specific files for %{name}.
%endif

%prep
%setup -q

%build
make -f Makefile.spacewalk-abrt

%install
%if 0%{?build_py2}
make -f Makefile.spacewalk-abrt install PREFIX=$RPM_BUILD_ROOT \
                PYTHON_PATH=%{python_sitelib} PYTHON_VERSION=%{python_version}
%endif
%if 0%{?build_py3}
sed -i 's|#!/usr/bin/python|#!/usr/bin/python3|' src/bin/spacewalk-abrt
make -f Makefile.spacewalk-abrt install PREFIX=$RPM_BUILD_ROOT \
                PYTHON_PATH=%{python3_sitelib} PYTHON_VERSION=%{python3_version}
%endif

%define default_suffix %{?default_py3:-%{python3_version}}%{!?default_py3:-%{python_version}}
ln -s spacewalk-abrt%{default_suffix} $RPM_BUILD_ROOT%{_bindir}/spacewalk-abrt

%find_lang %{name}

%clean

%post
service abrtd restart

%files -f %{name}.lang
%config  /etc/sysconfig/rhn/clientCaps.d/abrt
%config  /etc/libreport/events.d/spacewalk.conf
%{_bindir}/spacewalk-abrt
%{_mandir}/man8/*

%if 0%{?build_py2}
%files -n python2-%{name}
%{_bindir}/spacewalk-abrt-%{python_version}
%{python_sitelib}/spacewalk_abrt/
%endif

%if 0%{?build_py3}
%files -n python3-%{name}
%{_bindir}/spacewalk-abrt-%{python3_version}
%{python3_sitelib}/spacewalk_abrt/
%endif

%changelog
* Tue Mar 20 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.5-1
- don't build python2 subpackages on systems with default python3
- Regenerating .po and .pot files for spacewalk-abrt.
- Updating .po translations from Zanata

* Tue Feb 20 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.4-1
- use python3 on rhel8 in spacewalk-abrt

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.3-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Mon Oct 09 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- use standard rpmbuild bytecompile
- modules are now in standard sitelib path
- install files into python_sitelib/python3_sitelib
- split spacewalk-abrt into python2/python3 specific packages

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.3-1
- update copyright year

* Mon Jul 17 2017 Jan Dobes 2.7.2-1
- Updating .po translations from Zanata
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Mon Jan 23 2017 Jan Dobes 2.7.1-1
- abrt python2/3 fix
- Bumping package versions for 2.7.

* Wed Nov 09 2016 Gennadii Altukhov <galt@redhat.com> 2.6.2-1
- Revert Project-Id-Version for translations

* Tue Nov 08 2016 Gennadii Altukhov <galt@redhat.com> 2.6.1-1
- Regenerating .po and .pot files for spacewalk-abrt.
- Updating .po translations from Zanata
- Bumping package versions for 2.6.

* Tue May 24 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.5-1
- updating copyright years
- Regenerating .po and .pot files for spacewalk-abrt.
- Updating .po translations from Zanata

* Wed May 18 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.4-1
- encodestring expected bytes, not string

* Tue Apr 26 2016 Gennadii Altukhov <galt@redhat.com> 2.5.3-1
- Adapt spacewalk-abrt to Python 2/3

* Thu Feb 18 2016 Jan Dobes 2.5.2-1
- fixing warning
- do not evaluate Makefile
- do not keep this file in git
- pulling *.po translations from Zanata
- fixing current *.po translations

* Fri Nov 13 2015 Tomas Kasparek <tkasparek@redhat.com> 2.5.1-1
- python is not part of basic Fedora installation anymore
- Bumping package versions for 2.5.

* Fri Sep 25 2015 Jan Dobes 2.4.2-1
- support translations in spacewalk-abrt

* Wed Sep 23 2015 Jan Dobes 2.4.1-1
- Pulling updated *.po translations from Zanata.
- Bumping package versions for 2.4.
- Bumping package versions for 2.3.
- Bumping package versions for 2.2.

* Thu Oct 31 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.4-1
- explicitely require abrt-cli

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.3-1
- Reading only one line
- 1002041 - File content is loaded only when needed

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.2-1
- Grammar error occurred

* Tue Sep 03 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.1-1
- 1002041 - don't upload crash file if over the size limit or the upload is
  disabled
- Bumping package versions for 2.1.

