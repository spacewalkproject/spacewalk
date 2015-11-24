Name: spacewalk-reports
Summary: Script based reporting
Group: Applications/Internet
License: GPLv2
Version: 2.5.1
Release: 1%{?dist}
URL: https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
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
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{_bindir}
install -d $RPM_BUILD_ROOT/%{_prefix}/share/spacewalk
install -d $RPM_BUILD_ROOT/%{_prefix}/share/spacewalk/reports/data
install -d $RPM_BUILD_ROOT/%{_mandir}/man8
install spacewalk-report $RPM_BUILD_ROOT/%{_bindir}
install reports.py $RPM_BUILD_ROOT/%{_prefix}/share/spacewalk
install -m 644 reports/data/* $RPM_BUILD_ROOT/%{_prefix}/share/spacewalk/reports/data
install *.8 $RPM_BUILD_ROOT/%{_mandir}/man8

%clean
rm -rf $RPM_BUILD_ROOT

%files
%attr(755,root,root) %{_bindir}/spacewalk-report
%{_datadir}/spacewalk/reports.py*
%{_datadir}/spacewalk/reports
%{_mandir}/man8/spacewalk-report.8*
%doc COPYING

%changelog
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

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Tue Jul 16 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.13-1
- adding audit-servers report for logging feature
- adding audit-server-groups report for logging feature
- reports should not have 0755 permissions

* Fri Jul 12 2013 Tomas Lestach <tlestach@redhat.com> 1.10.12-1
- Example audit report for the user (web_contact) table.

* Mon Jun 24 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.11-1
- 972759 - add support for sql like predicates into spacewalk-report

* Tue Jun 11 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.10-1
- 963754 - inventory report should now display correct number of errata

* Tue Jun 11 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.9-1
- typo fix
- 768074 - performance fix for spacewalk-report

* Wed Jun 05 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.8-1
- 477631 - fix of system group reports

* Wed Jun 05 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.7-1
- 745342 - display more meaningful description

* Fri May 24 2013 Stephen Herr <sherr@redhat.com> 1.10.6-1
- Report for host-guest mappings for splice integration
- Reports to support enhanced reporting

* Tue May 07 2013 Jan Pazdziora 1.10.5-1
- report patterns should have 644 in git
- deploying /data/* content with 644 instead 755

* Tue Apr 09 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.4-1
- moving system currency config defaults from separate file to rhn_java.conf

* Wed Mar 20 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.3-1
- making system-currency work on postgres
- making system-crash-details work on postgres

* Fri Mar 15 2013 Jan Pazdziora 1.10.2-1
- Fixing Oracle-specific nvl and single-parameter to_char.

* Thu Mar 07 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.1-1
- spacewalk-report: added reports for spacewalk-abrt
- Bumping package versions for 1.9
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Thu Feb 28 2013 Jan Pazdziora 1.9.6-1
- Removing the dsn parameter from initDB, removing support for --db option.

* Tue Feb 26 2013 Tomas Kasparek <tkasparek@redhat.com> 1.9.5-1
- 914902 - system currency report

* Fri Feb 15 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.4-1
- Updating copyright info for 2013

* Mon Jan 28 2013 Tomas Kasparek <tkasparek@redhat.com> 1.9.3-1
- 237581 - OSAD status report

* Tue Jan 22 2013 Tomas Kasparek <tkasparek@redhat.com> 1.9.2-1
- 768074 - report of package upgrades available for systems
  (tkasparek@redhat.com)
- 745342 - system custom info report (tkasparek@redhat.com)

* Thu Jan 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.9.1-1
- parametrization of spacewalk-report with spacewalk config
- security fix + fixing typo
- 703629 - spacewalk-report inactive-systems RFE
- 662773 - spacewalk-report system-packages-installed
- 745342 - additional column in spacewalk-report inventory
- removing unnecesarry whitespaces
- 477631 - spacewalk-report RFE
- Bumping package versions for 1.9.

* Sat Jun 16 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.4-1
- 827022 - add COPYING file

* Mon May 21 2012 Jan Pazdziora 1.8.3-1
- %%defattr is not needed since rpm 4.4
- require spacewalk-branding
- simplify spec and own directory /usr/share/spacewalk/reports

* Tue Apr 03 2012 Jan Pazdziora 1.8.2-1
- Rework reporting to correspond with 0-n rule/ident mapping
  (slukasik@redhat.com)

* Wed Mar 14 2012 Jan Pazdziora 1.8.1-1
- 803228 - concatenation with null gives null on PostgreSQL, fixing.

* Mon Feb 27 2012 Simon Lukasik <slukasik@redhat.com> 1.7.1-1
- OpenSCAP integration -- Spacewalk reports. (slukasik@redhat.com)
- Bumping package versions for 1.7. (mzazrivec@redhat.com)

* Tue Nov 29 2011 Miroslav Suchý 1.6.3-1
- IPv6: reporting - make inventory report IPv6 aware
- IPv6: reporting - make errata-systems report IPv6 aware

* Thu Aug 11 2011 Miroslav Suchý 1.6.2-1
- do not mask original error by raise in execption

* Mon Aug 08 2011 Jan Pazdziora 1.6.1-1
- Add the --where-<column-id> option to help and man page.
- New reports: errata-channels and kickstartable-trees.

* Tue Jul 19 2011 Jan Pazdziora 1.5.4-1
- Updating the copyright years.

* Fri Jun 24 2011 Jan Pazdziora 1.5.3-1
- Add support for the --where-column-id=value parameter.

* Wed Jun 01 2011 Jan Pazdziora 1.5.2-1
- Fixing the SGML source of the spacewalk-report man page.

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

