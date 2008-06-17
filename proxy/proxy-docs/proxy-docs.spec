%{!?__redhat_release:%define __redhat_release UNKNOWN}

Name: rhns-proxy-docs
Summary: Red Hat Network Proxy Server Documentation
Group: RHN/Server
License: GPLv2
Source0: %{name}-%{version}.tar.gz
Source1: version
Version: %(echo `awk '{ print $1 }' %{SOURCE1}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE1}`)%{?dist}
BuildRoot: /var/tmp/%{name}-%{version}-root
BuildArch: noarch

%define docdir /usr/share/doc/rhns-proxy-%{version}

%description
This package includes the installation/configuration guide,
and whitepaper in support of an RHN Proxy Server. Also included
are the Client Configuration, Channel Management,
and Enterprise User Reference guides.

%prep
%setup -q

%install
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
* Thu Apr 10 2008 Miroslav Suchy <msuchy@redhat.com>
- Isolate from rhns-proxy

