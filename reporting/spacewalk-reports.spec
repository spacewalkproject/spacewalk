Name: spacewalk-reports
Summary: Script based reporting
Group: Applications/Internet
License: GPLv2
Version: 1.5.1
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
* Thu Apr 14 2011 Jan Pazdziora 1.5.1-1
- The initCFG is no longer imported directly to spacewalk.common.

* Tue Mar 22 2011 Jan Pazdziora 1.4.5-1
- There is no cursor() function for inline cursors in PostgreSQL, using custom
  function get_hw_info_as_clob instead.
- Rewriting outer joins to ANSI syntax.

* Thu Mar 10 2011 Jan Pazdziora 1.4.4-1
- 683525 - adding flex_used and flex_total to the entitlements report.

* Tue Mar 08 2011 Jan Pazdziora 1.4.3-1
- Reporting: adding six system-history subreports.

* Mon Mar 07 2011 Jan Pazdziora 1.4.2-1
- For Initiate a kickstart action, show the label of the kickstart profile in
  the report.

* Mon Feb 21 2011 Jan Pazdziora 1.4.1-1
- Reporting: system-history proof of concept report.

* Thu Nov 25 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.1-1
- fixed namespace of imported modules

* Mon Sep 20 2010 Jan Pazdziora 1.2.3-1
- 634961 - stop null/None values from being presented as "None".

* Wed Aug 18 2010 Jan Pazdziora 1.2.2-1
- 623941, 578292 - add report channel-packages which provides full list
  of packages in channels.
- 623941, 578292 - update the report column names to be more descriptive.

* Fri Aug 13 2010 Jan Pazdziora 1.2.1-1
- Sort the list of reports to make it easier to read it.
- 623941 - add the channels report which lists channel and number of packages
  in each channel.
- 623941 - add the errata-list-all report which lists all reports in the
  Spacewalk, not just those that affect some systems.
- bumping package versions for 1.2 (mzazrivec@redhat.com)

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
