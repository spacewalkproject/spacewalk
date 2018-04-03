%if 0%{?fedora} || 0%{?rhel} >= 8
%global build_py3   1
%endif

Name:		spacewalk-client-cert
Version:	2.9.0
Release:	1%{?dist}
Summary:	Package allowing manipulation with Spacewalk client certificates

License:	GPLv2
URL:		https://github.com/spacewalkproject/spacewalk
Source0:	https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch:	noarch
%if 0%{?build_py3}
BuildRequires:  python3-devel
Requires:       python3-rhn-client-tools
Requires:       python3-rhn-setup
%else
BuildRequires:  python-devel
Requires:       python2-rhn-client-tools
Requires:       python2-rhn-setup
%endif
%description
spacewalk-client-cert contains client side functionality allowing manipulation
with Spacewalk client certificates (/etc/sysconfig/rhn/systemid)

%prep
%setup -q


%build
make -f Makefile.spacewalk-client-cert


%install
%global pypath %{?build_py3:%{python3_sitelib}}%{!?build_py3:%{python_sitelib}}
make -f Makefile.spacewalk-client-cert install PREFIX=$RPM_BUILD_ROOT \
        PYTHONPATH=%{pypath}

%clean


%files
%config  /etc/sysconfig/rhn/clientCaps.d/client-cert
%{pypath}/rhn/actions/*
%if 0%{?suse_version}
%dir /etc/sysconfig/rhn
%dir /etc/sysconfig/rhn/clientCaps.d
%dir %{pypath}/rhn
%dir %{pypath}/rhn/actions
%endif

%changelog
* Tue Feb 20 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.3-1
- use python3 on rhel8 in spacewalk-client-cert

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Tue Oct 10 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- install files into python_sitelib/python3_sitelib
- Bumping package versions for 2.8.

* Mon Jul 17 2017 Jan Dobes 2.7.1-1
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub
- Bumping package versions for 2.7.
- Bumping package versions for 2.6.

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.3-1
- updating copyright years

* Tue May 10 2016 Grant Gainey 2.5.2-1
- spacewalk-client-cert: build on openSUSE

* Tue Apr 26 2016 Gennadii Altukhov <galt@redhat.com> 2.5.1-1
- Adapt spacewalk-client-cert for Python 2/3 compatibility
- Bumping package versions for 2.5.
- Bumping package versions for 2.4.

* Thu Mar 19 2015 Grant Gainey 2.3.2-1
- Updating copyright info for 2015

* Wed Jan 14 2015 Matej Kollar <mkollar@redhat.com> 2.3.1-1
- Getting rid of Tabs and trailing spaces in Python
- Bumping package versions for 2.3.

* Mon Apr 28 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.5-1
- correct variable name

* Fri Apr 25 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.4-1
- polish the error message

* Fri Apr 25 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.3-1
- add python-devel BuildRequires

* Thu Apr 10 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.2-1
- update_client_cert() does not accept any arguments

* Thu Apr 10 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.1-1
- initial package build

