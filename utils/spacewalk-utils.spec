%define rhnroot %{_prefix}/share/rhn

Name:		spacewalk-utils
Version:	0.6.1
Release:	1%{?dist}
Summary:	Utilities that may be run against a Spacewalk server.

Group:		Applications/Internet
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk
Source0:	https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch

BuildRequires:  /usr/bin/docbook2man
BuildRequires:  docbook-utils

Requires:       python, rpm-python

%description
Generic utilities that may be run against a Spacewalk server.  This package
contains utilities that may be installed on a client and run against the
server.


%prep
%setup -q


%build
make all


%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{rhnroot}
make install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    MANDIR=%{_mandir}


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root)
%attr(755,root,root) %{_bindir}/system-snapshot
%{rhnroot}/utils/systemSnapshot.py*
%{_mandir}/man8/system-snapshot-.8*


%changelog
* Tue Apr 07 2009 Brad Buckingham <bbuckingham@redhat.com> 0.6.1-1
-
