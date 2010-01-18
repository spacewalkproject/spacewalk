Name: rhn-custom-info
Summary: Set and list custom values for RHN-enabled machines
Group: Applications/System
License: GPLv2 and Python
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
URL:     https://fedorahosted.org/spacewalk
Version: 5.4.2
Release: 1%{?dist}
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch
BuildRequires: python-devel
Requires: python
Requires: rhnlib

%if 0%{?rhel} >= 5 || 0%{?fedora} >= 1
Requires: yum-rhn-plugin
%else
Requires: up2date
%endif

%description 
Allows for the setting and listing of custom key/value pairs for 
an RHN-enabled system.

%prep
%setup -q

%build
make -f Makefile.rhn-custom-info all

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT
make -f Makefile.rhn-custom-info install PREFIX=$RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{_mandir}/man8/
install -m 644 rhn-custom-info.8 $RPM_BUILD_ROOT%{_mandir}/man8/

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{_bindir}/rhn-custom-info
%dir %{_datadir}/rhn/custominfo
%{_datadir}/rhn/custominfo/rhn-custom-info.py*
%doc LICENSE PYTHON-LICENSES.txt
%{_mandir}/man8/rhn-custom-info.*

%changelog
* Mon Jan 18 2010 Miroslav Suchy <msuchy@redhat.com> 5.4.2-1
- polished spec for Fedora Review

* Fri Jan  8 2010 Miroslav Suchy <msuchy@redhat.com> 5.4.1-1
- added man page
- polished spec for Fedora Review

* Tue Jun 16 2009 Brad Buckingham <bbuckingham@redhat.com> 5.4.0-1
- bumping version (bbuckingham@redhat.com)

* Thu Apr 23 2009 jesus m. rodriguez <jesusr@redhat.com> 0.4.6-1
- update copyright and licenses (jesusr@redhat.com)

* Thu Feb 19 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.4.5-1
- 485459 - constructed url should now point to right handler

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
