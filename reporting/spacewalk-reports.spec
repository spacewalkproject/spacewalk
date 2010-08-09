Name: spacewalk-reports
Summary: Script based reporting
Group: Applications/Internet
License: GPLv2
Version: 1.1.2
Release: 1%{?dist}
URL: https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
Requires: python
BuildRequires: /usr/bin/docbook2man

%description
Script based reporting to retrieve data from Spacewalk server in CSV format.

%prep
%setup -q

%build
/usr/bin/docbook2man *.sgml

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{_bindir}
install -d $RPM_BUILD_ROOT/%{_prefix}/share/spacewalk
install -d $RPM_BUILD_ROOT/%{_prefix}/share/spacewalk/reports/data
install -d $RPM_BUILD_ROOT/%{_mandir}/man8
install spacewalk-report $RPM_BUILD_ROOT/%{_bindir}
install reports.py $RPM_BUILD_ROOT/%{_prefix}/share/spacewalk
install reports/data/* $RPM_BUILD_ROOT/%{_prefix}/share/spacewalk/reports/data
install *.8 $RPM_BUILD_ROOT/%{_mandir}/man8

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%attr(755,root,root) %{_bindir}/spacewalk-report
%{_prefix}/share/spacewalk/reports.py*
%{_prefix}/share/spacewalk/reports/data/*
%{_mandir}/man8/spacewalk-report.8*

%changelog
* Mon Aug 09 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.2-1
- 601984 - use clob for the concatting operation, to overcome the varchar
  length limit. (jpazdziora@redhat.com)

* Fri Jul 16 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.1-1
- bumping spec files to future 1.1 packages

* Thu Apr 15 2010 Jan Pazdziora 0.9.1-1
- 580924 - Fix number of CPUs in the inventory report.

* Thu Feb 04 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.2-1
- updated copyrights

* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- rebuild for spacewalk 0.8

* Mon Jan 04 2010 Jan Pazdziora 0.7.1-1
- 549370 - set lineending to be just LF, not CRLF
- 548751 - handle IOError: [Errno 32] Broken pipe when piping to head
- Add defattr to spacewalk-reports.spec

* Mon Dec 14 2009 Jan Pazdziora 0.7.0-1
- moved reports from spacewalk-backend-0.8.10-1 separate package
