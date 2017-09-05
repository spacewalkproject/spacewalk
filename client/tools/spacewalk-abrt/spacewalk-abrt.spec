Name:           spacewalk-abrt
Version:        2.8.0
Release:        1%{?dist}
Summary:        ABRT plug-in for rhn-check

Group:	        Applications/System
License:        GPLv2
URL:            https://github.com/spacewalkproject/spacewalk
Source0:        https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  gettext
BuildRequires:  python
Requires:       abrt
Requires:       abrt-cli
Requires:       rhn-client-tools
Requires:       rhn-check
%description
spacewalk-abrt - rhn-check plug-in for collecting information about crashes handled by ABRT.

%prep
%setup -q

%build
make -f Makefile.spacewalk-abrt
%if 0%{?fedora} >= 23
sed -i 's|#!/usr/bin/python|#!/usr/bin/python3|' src/bin/spacewalk-abrt
%endif

%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.spacewalk-abrt install PREFIX=$RPM_BUILD_ROOT

%find_lang %{name}

%clean
rm -rf $RPM_BUILD_ROOT

%post
service abrtd restart

%files -f %{name}.lang
%config  /etc/sysconfig/rhn/clientCaps.d/abrt
%config  /etc/libreport/events.d/spacewalk.conf
%{_bindir}/spacewalk-abrt
%{_datadir}/rhn/spacewalk_abrt/*
%{_mandir}/man8/*

%changelog
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

