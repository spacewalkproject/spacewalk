Name: spacewalk-proxy-docs
Summary: Spacewalk Proxy Server Documentation
Group: Applications/Internet
License: GPLv2
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd proxy/proxy-docs
# make test-srpm
URL:     https://fedorahosted.org/spacewalk
Source0: %{name}-%{version}.tar.gz
Version: 0.1
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-root-%(%{__id_u} -n)
BuildArch: noarch

%define docdir %{_defaultdocdir}/rhns-proxy-%{version}

%description
This package includes the installation/configuration guide,
and whitepaper in support of an Spacewalk Proxy Server. Also included
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
* Thu Aug  7 2008 Miroslav Suchy <msuchy@redhat.com>
- Rename to spacewalk-proxy-docs
- clean up spec

* Thu Apr 10 2008 Miroslav Suchy <msuchy@redhat.com>
- Isolate from rhns-proxy

