Name:		spacewalk-client-cert
Version:	2.2.0
Release:	1%{?dist}
Summary:	Package allowing manipulation with Spacewalk client certificates

Group:		Applications/System
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk
Source0:	https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:	noarch
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
