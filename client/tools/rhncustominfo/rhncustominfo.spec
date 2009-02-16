Name: rhn-custom-info
Summary: set and list custom values for RHN-enabled machines
Group: RHN/Client
License: GPLv2
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 0.4.4
Release: 1%{?dist}
BuildRoot: /var/tmp/%{name}-%{version}-root
BuildArch: noarch
BuildRequires: python
Requires: python
Requires: python-optik
Requires: rhnlib

%if 0%{?rhel} >= 5 || 0%{?fedora} == 1
Requires: yum-rhn-plugin
%else
Requires: up2date
%endif

%description 
Allows for the setting and listing of custom key/value pairs for an RHN-enabled system.

%prep
%setup -q

%build
make -f Makefile.rhn-custom-info all

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT
make -f Makefile.rhn-custom-info install PREFIX=$RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
/usr/bin/rhn-custom-info
%dir /usr/share/rhn/custominfo
/usr/share/rhn/custominfo/rhn-custom-info.py*

# $Id$
%changelog
* Tue Jan 27 2009 Miroslav Suchý <msuchy@redhat.com> 0.4.4-1
- fix typo in Source0

* Thu Jan 22 2009 Dennis Gilmore <dennis@ausil.us> 0.4.3-1
- BuildRequires python
- clean up handling of requires for up2date or yum-rhn-plugin

* Wed Jan 14 2009 Pradeep Kilambi <pkilambi@redhat.com> - 0.4.2-1
Resolves - #251060

* Thu Sep  4 2008 Pradeep Kilambi <pkilambi@redhat.com> - 0.2.2-1
- adding dist tag

* Wed Mar 07 2007 Pradeep Kilambi <pkilambi@redhat.com> 5.0.0-1
- adding dist tag

* Mon May 17 2004 Bret McMillan <bretm@redhat.com>
- friendlier commandline usage
- change the executable from rhncustominfo to rhn-custom-info
- use up2date's config settings

* Mon Sep 24 2003 Bret McMillan <bretm@redhat.com>
- Initial build
