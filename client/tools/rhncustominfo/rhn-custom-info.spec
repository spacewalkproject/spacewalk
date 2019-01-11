%if 0%{?fedora} || 0%{?rhel} >= 8
%global build_py3   1
%endif

Name: rhn-custom-info
Summary: Set and list custom values for RHN-enabled machines
Version: 5.4.44
Release: 1%{?dist}
License: GPLv2
Source0: https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
URL:     https://github.com/spacewalkproject/spacewalk
BuildArch: noarch
%if 0%{?build_py3}
BuildRequires: python3-devel
Requires: python3-rhnlib
%else
BuildRequires: python-devel
Requires: rhnlib
%endif

%if 0%{?fedora} || 0%{?rhel} >= 8
Requires: dnf-plugin-spacewalk
%else
%if 0%{?suse_version}
Requires: zypp-plugin-spacewalk
# provide rhn directories for filelist check
BuildRequires: rhn-client-tools
%else
Requires: yum-rhn-plugin
%endif
%endif

%description 
Allows for the setting and listing of custom key/value pairs for 
an RHN-enabled system.

%prep
%setup -q

%build
make -f Makefile.rhn-custom-info all
%if 0%{?build_py3}
    sed -i 's|#!/usr/bin/python|#!/usr/bin/python3|' *.py
%endif

%install
install -d $RPM_BUILD_ROOT
%global pypath %{?build_py3:%{python3_sitelib}}%{!?build_py3:%{python_sitelib}}
make -f Makefile.rhn-custom-info install PREFIX=$RPM_BUILD_ROOT ROOT=%{pypath}
install -d $RPM_BUILD_ROOT%{_mandir}/man8/
install -m 644 rhn-custom-info.8 $RPM_BUILD_ROOT%{_mandir}/man8/

%clean

%files
%{_bindir}/rhn-custom-info
%{pypath}/custominfo/
%doc LICENSE
%{_mandir}/man8/rhn-custom-info.*

%changelog
* Fri Jan 11 2019 Michael Mraka <michael.mraka@redhat.com> 5.4.44-1
- package rebuild

* Tue Feb 20 2018 Tomas Kasparek <tkasparek@redhat.com> 5.4.43-1
- require dnf-plugin-spacewalk on rhel8 instead of yum
- use python3 on rhel8 in rhncustominfo

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 5.4.42-1
- remove install/clean section initial cleanup
- removed Group from specfile

* Tue Oct 10 2017 Michael Mraka <michael.mraka@redhat.com> 5.4.41-1
- extra path is not needed anymore

* Fri Oct 06 2017 Michael Mraka <michael.mraka@redhat.com> 5.4.40-1
- install files into python_sitelib/python3_sitelib

* Thu Sep 07 2017 Michael Mraka <michael.mraka@redhat.com> 5.4.39-1
- removed unnecessary BuildRoot tag

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 5.4.38-1
- purged changelog entries for Spacewalk 2.0 and older

* Wed Aug 09 2017 Michael Mraka <michael.mraka@redhat.com> 5.4.37-1
- fixed python3 buildrequires

* Wed Aug 09 2017 Michael Mraka <michael.mraka@redhat.com> 5.4.36-1
- precompile py3 bytecode on Fedora 23+
- use standard brp-python-bytecompile

* Tue Jul 18 2017 Michael Mraka <michael.mraka@redhat.com> 5.4.35-1
- move version and release before sources

* Mon Jul 17 2017 Jan Dobes 5.4.34-1
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Tue Dec 06 2016 Eric Herget <eherget@redhat.com> 5.4.33-1
- 1386615 - rhn-custom-info should not require CA cert for non-https server

* Tue Jun 07 2016 Jan Dobes 5.4.32-1
- print() prints '()' in python 2 instead of expected empty line
- fix fedora macro usage

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 5.4.31-1
- updating copyright years

* Thu May 12 2016 Tomas Kasparek <tkasparek@redhat.com> 5.4.30-1
- use python-devel in buildtime on all OS

* Tue Apr 12 2016 Gennadii Altukhov <galt@redhat.com> 5.4.29-1
- Wrong dependency for building on Fedora 23
- basestring is str and bytes in python3
- removed unused module string in  rhn-custom-info
- modified rhn-custom-info to work in python 2/3

* Mon Jun 08 2015 Michael Mraka <michael.mraka@redhat.com> 5.4.28-1
- switch to dnf on Fedora 22

* Wed Jan 14 2015 Matej Kollar <mkollar@redhat.com> 5.4.27-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.4.26-1
- fix copyright years

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.4.25-1
- spec file polish

* Mon Apr 14 2014 Michael Mraka <michael.mraka@redhat.com> 5.4.24-1
- 1066163 - rhn-custom-info man page is incomplete.

* Fri Mar 14 2014 Michael Mraka <michael.mraka@redhat.com> 5.4.23-1
- Don't print newline after 'Username:' prompt

* Fri Feb 14 2014 Tomas Lestach <tlestach@redhat.com> 5.4.22-1
- 1063808 - Custom info with empty value added

