Name: spacewalk-proxy-docs
Summary: Spacewalk Proxy Server Documentation
Group: Applications/Internet
License: GPLv2
URL:     https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 0.4.1
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-root-%(%{__id_u} -n)
BuildArch: noarch
Obsoletes: rhns-proxy-docs < 5.3.0
Provides: rhns-proxy-docs = 5.3.0

%define docdir %{_defaultdocdir}/rhns-proxy-%{version}

%description
This package includes the installation/configuration guide,
and whitepaper in support of an Spacewalk Proxy Server. Also included
are the Client Configuration, Channel Management,
and Enterprise User Reference guides.

%prep
%setup -q

%build
#nothing to do here

%install
rm -rf $RPM_BUILD_ROOT
# want to install the documentation in a versioned directory
install -m 755 -d $RPM_BUILD_ROOT%{docdir}
install -m 644 squid.conf.sample $RPM_BUILD_ROOT%{docdir}/squid.conf.sample
install -m 644 *.pdf $RPM_BUILD_ROOT%{docdir}/
install -m 644 LICENSE $RPM_BUILD_ROOT%{docdir}/

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%dir %{docdir}
%{docdir}/*.pdf
%{docdir}/LICENSE
%{docdir}/squid.conf.sample

# $Id: proxy.spec,v 1.290 2007/08/08 07:03:05 msuchy Exp $
%changelog
* Tue Dec  9 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.1-1
- fixed Obsoletes: rhns-* < 5.3.0

* Thu Aug  7 2008 Miroslav Suchy <msuchy@redhat.com> 0.1-2
- Rename to spacewalk-proxy-docs
- clean up spec

* Thu Apr 10 2008 Miroslav Suchy <msuchy@redhat.com>
- Isolate from rhns-proxy

