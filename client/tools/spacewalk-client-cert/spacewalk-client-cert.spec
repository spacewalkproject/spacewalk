Name:		spacewalk-client-cert
Version:	2.5.0
Release:	1%{?dist}
Summary:	Package allowing manipulation with Spacewalk client certificates

Group:		Applications/System
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk
Source0:	https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:	noarch
BuildRequires:  python-devel
Requires:       rhnlib
Requires:       rhn-check
Requires:       rhn-setup
%description
spacewalk-client-cert contains client side functionality allowing manipulation
with Spacewalk client certificates (/etc/sysconfig/rhn/systemid)

%prep
%setup -q


%build
make -f Makefile.spacewalk-client-cert


%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.spacewalk-client-cert install PREFIX=$RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT


%files
%config  /etc/sysconfig/rhn/clientCaps.d/client-cert
%{_datadir}/rhn/actions/clientcert.*


%changelog
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

