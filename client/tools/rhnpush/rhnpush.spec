%define rhnroot /usr/share/rhn

Name: rhnpush
Summary: Common programs needed to be installed on the RHN servers/proxies.
Group: Applications/System
License: GPLv2
Url: http://rhn.redhat.com
Version: 0.2.2
Release: 1%{?dist}
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
Requires: python, rpm-python
BuildRequires: /usr/bin/msgfmt
BuildRequires: /usr/bin/docbook2man

Summary: Package uploader for the Red Hat Network Satellite Server


%description
rhnpush uploads package headers to the Red Hat Network servers into
various channels and allows for several other channel management
operations relevant to controlling what packages are available from
which channel.


%prep
%setup -q

%build
make -f Makefile.rhnpush all

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{rhnroot}
make -f Makefile.rhnpush install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    MANDIR=%{_mandir}

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root)
%dir %{rhnroot}/rhnpush
%{rhnroot}/rhnpush/*
%attr(755,root,root) /usr/bin/rhnpush
%attr(755,root,root) /usr/bin/rpm2mpm
%attr(755,root,root) /usr/bin/solaris2mpm
%config(noreplace) %attr(644,root,root) /etc/sysconfig/rhn/rhnpushrc
%{_mandir}/man8/rhnpush.8*
%{_mandir}/man8/solaris2mpm.8*

%changelog
* Tue Sep  2 2008 Milan Zazrivec 0.2.2-1
- Bumped version for spacewalk 0.2

* Thu Nov 02 2006 James Bowes <jbowes@redhat.com> - 4.2.0-48
- Initial seperate packaging.
