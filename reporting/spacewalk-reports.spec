Name: spacewalk-reports
Summary: Script based reporting
License: GPLv2
Version: 2.9.0
Release: 1%{?dist}
URL: https://github.com/spacewalkproject/spacewalk
Source0: https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch: noarch
Requires: python
Requires: spacewalk-branding
BuildRequires: /usr/bin/docbook2man

%description
Script based reporting to retrieve data from Spacewalk server in CSV format.

%prep
%setup -q

%build
/usr/bin/docbook2man *.sgml

%install
install -d $RPM_BUILD_ROOT/%{_bindir}
install -d $RPM_BUILD_ROOT/%{_prefix}/share/spacewalk
install -d $RPM_BUILD_ROOT/%{_prefix}/share/spacewalk/reports/data
install -d $RPM_BUILD_ROOT/%{_mandir}/man8
install spacewalk-report $RPM_BUILD_ROOT/%{_bindir}
install reports.py $RPM_BUILD_ROOT/%{_prefix}/share/spacewalk
install -m 644 reports/data/* $RPM_BUILD_ROOT/%{_prefix}/share/spacewalk/reports/data
install *.8 $RPM_BUILD_ROOT/%{_mandir}/man8

%clean

%files
%attr(755,root,root) %{_bindir}/spacewalk-report
%{_datadir}/spacewalk/reports.py*
%{_datadir}/spacewalk/reports
%{_mandir}/man8/spacewalk-report.8*
%doc COPYING
%if 0%{?suse_version}
%dir %{_datadir}/spacewalk
%endif

%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.4-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Fri Oct 20 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.3-1
- Revert "use SQL bind parameter"

* Wed Oct 18 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.2-1
- use SQL bind parameter

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Mon Jul 17 2017 Jan Dobes 2.7.6-1
- Remove unused imports.

* Tue Mar 07 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.5-1
- Add issue date to errata-list-all report
- date is a keyword on oracle

* Fri Mar 03 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.4-1
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub
- errata-list-all report: add date

* Wed Feb 22 2017 Jan Dobes 2.7.3-1
- 1401497 - fixing query

* Tue Dec 20 2016 Gennadii Altukhov <galt@redhat.com> 2.7.2-1
- 1405351 - spacewalk-report return placeholder to SQL request for repositories
  report

* Tue Dec 20 2016 Gennadii Altukhov <galt@redhat.com> 2.7.1-1
- 1405351 - spacewalk-report should reports repositories for a non-null
  organizations only
- Bumping package versions for 2.7.

* Thu Oct 20 2016 Jan Dobes 2.6.3-1
- fixing occurences in code

* Mon Jun 13 2016 Grant Gainey 2.6.2-1
- spacewalk-reports: build on openSUSE

* Fri Jun 10 2016 Jan Dobes 2.6.1-1
- fix rhnContentSourceSsl -> rhnContentSsl in code
- Bumping package versions for 2.6.

* Tue Nov 24 2015 Jan Dobes 2.5.1-1
- audit-server-groups report: remove reporting of max_members
- entitlements report: dropped
- report: remove channel entitlements from report
- fix typo
- Bumping package versions for 2.5.

* Thu Sep 24 2015 Jan Dobes 2.4.5-1
- Bumping copyright year.

* Thu Aug 13 2015 Grant Gainey 2.4.4-1
- 1225220 - find proxies via rhnProxyInfo

* Wed Aug 12 2015 Grant Gainey 2.4.3-1
- 1225220 - handle proxies-with-no-servers correctly

* Tue Jul 14 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.2-1
- remove Except KeyboardInterrupt from imports

* Wed May 27 2015 Grant Gainey 2.4.1-1
- 1225220 - add new spacewalk-report for proxies-info
- Bumping package versions for 2.4.

* Tue Jan 13 2015 Matej Kollar <mkollar@redhat.com> 2.3.7-1
- Getting rid of Tabs and trailing spaces in Python

* Thu Oct 16 2014 Matej Kollar <mkollar@redhat.com> 2.3.6-1
- 1150982 - Update man page
- Tab vs. Spaces
- 1150982 - Column named "group" can be a little complicated...
- Add summary info about scan results

* Sat Oct 11 2014 Matej Kollar <mkollar@redhat.com> 2.3.5-1
- 1150982 - coping with old python
- 1150982 - forgotten WHERE
- 1150982 - Change gt to ge and lt to le
- 1150982 - Add more filtering options
- 1150982 - Add org_id to report
* Mon Aug 25 2014 Tomas Lestach <tlestach@redhat.com> 2.3.4-1
- 1132868 - avoid getting multiple host_system_id(s) per server

* Wed Aug 06 2014 Tomas Lestach <tlestach@redhat.com> 2.3.3-1
- fix system-profiles report to expect multiple virtual guests per host

* Thu Jul 31 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.2-1
- 1122706 - Add channel_id to config-file* reports

* Wed Jul 23 2014 Grant Gainey 2.3.1-1
- 1122706 - Added config-files and config-files-latest reports
- Add id column to channel export
- Bumping package versions for 2.3.

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.15-1
- fix copyright years

* Wed Jul 02 2014 Tomas Lestach <tlestach@redhat.com> 2.2.14-1
- let roles sort within the user spacewalk-report

* Tue Jul 01 2014 Tomas Lestach <tlestach@redhat.com> 2.2.13-1
- introduce system-profiles report

* Mon Jun 30 2014 Tomas Lestach <tlestach@redhat.com> 2.2.12-1
- do not sort multival values within one column to match other multival values
  (in another columns)
- process all the multival values on row

* Fri Jun 20 2014 Tomas Lestach <tlestach@redhat.com> 2.2.11-1
- intorduce kickstart-scripts reports

* Thu Jun 19 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.10-1
- 1054342 - added hostname and IP address to scap-scan
- 1053876 - added system_id to scap-scan-results

* Tue Jun 03 2014 Tomas Lestach <tlestach@redhat.com> 2.2.9-1
- we need base_channel_id and child_channel_id instead of channel_id in
  activation_key report

* Tue May 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.8-1
- Add channel- and server-group-ids to activation-keys

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.7-1
- fix activation-key info

* Wed May 21 2014 Stephen Herr <sherr@redhat.com> 2.2.6-1
- 1099938 - add spacewalk-report for systems with extra packages

* Fri May 16 2014 Tomas Lestach <tlestach@redhat.com> 2.2.5-1
- fix spacewalk-report multival issue
- Add activation-keys-config report
- Adding reports for activation-keys

* Mon May 12 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.4-1
- remove semicolon at the end of the query
- Add ids to labels (handy)
- Add report for custom-channels
- Add report on repositories
- Add org-id to channels

* Tue Apr 15 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.3-1
- system-md5-certificate: list of systems with MD5 client certificate

* Thu Apr 10 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.2-1
- add report for schedule/actions

* Tue Apr 08 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.1-1
- users-md5: a report showing users with MD5 encrypted password

* Mon Oct 14 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.14-1
- fixing indentation - expandtabs vs noexpandtab

* Tue Oct 01 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.13-1
- 1012261 - report system virtualization type
- 1009462 - display error message for --(like|where)=<column-id>

* Tue Oct 01 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.12-1
- using bind variable in postgres

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.11-1
- select from rhnServerNeededCache instead of rhnServerNeededPackageCache

* Tue Sep 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.10-1
- 1008309 - further imporove postgresql performance

* Mon Sep 16 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.9-1
- 1008309 - further imporove postgresql performance

* Mon Sep 16 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.8-1
- 1008309 - fix postgresql performance

* Mon Sep 09 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.7-1
- 914902 - fixing grammar

* Wed Sep 04 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.6-1
- updating help text - forgotten "-" sign

* Mon Aug 19 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.5-1
- 997909 - updating man page
- 997909 - report all dates in spacewalk-report as UTC by default

* Wed Aug 14 2013 Stephen Herr <sherr@redhat.com> 2.1.4-1
- 997027 - spacewalk-reports host-guests shouldn't fail on oracle databases

* Thu Aug 08 2013 Jiri Mikulka <jmikulka@redhat.com> 2.1.3-1
- sort multival columns iff there's any content

* Wed Aug 07 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.2-1
- sort multival columns to make reports consistent

* Tue Jul 23 2013 Stephen Herr <sherr@redhat.com> 2.1.1-1
- 987640 - Add new field to splice-export report
- Bumping package versions for 2.1.

