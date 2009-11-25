%{!?__redhat_release:%define __redhat_release UNKNOWN}

Name: spacewalk-search
Summary: Spacewalk Full Text Search Server
Group: Applications/Internet
License: GPLv2
Version: 0.7.1
Release: 1%{?dist}
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd search-server
# make test-srpm
URL: https://fedorahosted.org/spacewalk
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch

#Requires: apache-ibatis-sqlmap
Requires: doc-indexes
Requires: jakarta-commons-cli
Requires: jakarta-commons-codec
Requires: jakarta-commons-httpclient
Requires: jakarta-commons-lang >= 0:2.1
Requires: jakarta-commons-logging
Requires: jpackage-utils >= 0:1.5
Requires: log4j
Requires: oro
#Requires: lucene
Requires: quartz
Requires: redstone-xmlrpc
#Requires: picocontainer
Requires: tanukiwrapper
Obsoletes: rhn-search < 5.3.0
BuildRequires: ant
#BuildRequires: apache-ibatis-sqlmap
BuildRequires: jakarta-commons-cli
BuildRequires: jakarta-commons-codec
BuildRequires: jakarta-commons-httpclient
BuildRequires: jakarta-commons-lang >= 0:2.1
BuildRequires: jakarta-commons-logging
BuildRequires: java-devel >= 1.6.0
BuildRequires: log4j
BuildRequires: oro
#BuildRequires: lucene
BuildRequires: quartz
BuildRequires: redstone-xmlrpc
#BuildRequires: picocontainer
BuildRequires: tanukiwrapper
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts

%description
This package contains the code for the Full Text Search Server for
Spacewalk Server.

%prep
%setup -n %{name}-%{version}

%install
rm -fr ${RPM_BUILD_ROOT}
ant -Djar.version=%{version} install
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/rhn/search
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/search
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/search/indexes
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/search/lib
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/search/classes/com/redhat/satellite/search/db
install -d -m 755 $RPM_BUILD_ROOT/etc/init.d
install -d -m 755 $RPM_BUILD_ROOT%{_bindir}
install -d -m 755 $RPM_BUILD_ROOT%{_var}/log/rhn/search
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/search/nutch
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d
install -p -m 644 dist/%{name}-%{version}.jar $RPM_BUILD_ROOT%{_prefix}/share/rhn/search/lib/
# using install -m does not preserve the symlinks
cp -d lib/* $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/lib
install -p -m 644 src/config/log4j.properties $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/classes/log4j.properties
install -p -m 644 src/config/etc/logrotate.d/rhn-search $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/rhn-search
install -p -m 644 src/config/com/redhat/satellite/search/db/* $RPM_BUILD_ROOT%{_prefix}/share/rhn/search/classes/com/redhat/satellite/search/db
install -p -m 755 src/config/rhn-search $RPM_BUILD_ROOT%{_sysconfdir}/init.d
ln -s -f /usr/sbin/tanukiwrapper $RPM_BUILD_ROOT%{_bindir}/rhnsearchd
install -p -m 644 src/config/search/rhn_search.conf $RPM_BUILD_ROOT%{_sysconfdir}/rhn/search/rhn_search.conf
install -p -m 644 src/config/search/rhn_search_daemon.conf $RPM_BUILD_ROOT%{_sysconfdir}/rhn/search/rhn_search_daemon.conf
ln -s -f %{_prefix}/share/rhn/search/lib/spacewalk-search-%{version}.jar $RPM_BUILD_ROOT%{_prefix}/share/rhn/search/lib/spacewalk-search.jar

%clean
rm -rf $RPM_BUILD_ROOT

%post
# This adds the proper /etc/rc*.d links for the script
/sbin/chkconfig --add rhn-search

%preun
if [ $1 = 0 ] ; then
    /sbin/service rhn-search stop >/dev/null 2>&1
    /sbin/chkconfig --del rhn-search
fi

%files
%defattr(644,root,root,755)
%attr(755, root, root) %{_var}/log/rhn/search
%{_prefix}/share/rhn/search/lib/*
%{_prefix}/share/rhn/search/classes/log4j.properties
%{_prefix}/share/rhn/search/classes/com/*
%attr(755, root, root) %{_prefix}/share/rhn/search/indexes
%attr(755, root, root) %{_sysconfdir}/init.d/rhn-search
%attr(755, root, root) %{_bindir}/rhnsearchd
%dir %{_sysconfdir}/rhn/search/
%config(noreplace) %{_sysconfdir}/rhn/search/rhn_search.conf
%config(noreplace) %{_sysconfdir}/rhn/search/rhn_search_daemon.conf
%{_sysconfdir}/logrotate.d/rhn-search

%changelog
* Wed Nov 25 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.1-1
- 516872 - Fixed search server's log properties (paji@redhat.com)
- Update doc indexes to reside in "en-US" (jmatthew@redhat.com)
- bumping versions to 0.7.0 (jmatthew@redhat.com)

* Thu Jun 25 2009 John Matthews <jmatthew@redhat.com> 0.6.11-1
- 487014 - SystemSearch remove score requirement to redirect to SDC on 1 result
  (jmatthew@redhat.com)
- DocumentationSearch fixing returned links so they are relative and update for
  segment dir (jmatthew@redhat.com)

* Mon Jun 01 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.10-1
- added java debugger options for local dev config (jesusr@redhat.com)
- store pid file locally. (jesusr@redhat.com)
- 487014 - SystemSearch reducing scrore threshold for a single result to
  redirect to SDC page (jmatthew@redhat.com)

* Tue May 26 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.9-1
- 501925 - "rhn-search cleanindex" will now restart search after cleaning index
  (jmatthew@redhat.com)

* Thu May 21 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.8-1
- 457350 - added package search apis to match functionality webui provides (jmatthew@redhat.com)
- Fixing "free form" search.  Adding a boolean flag which when passed (jmatthew@redhat.com)

* Fri May 08 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.7-1
- clean up javadoc in AdminHandler (jesusr@redhat.com)

* Tue May 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.6-1
- cleanup ScheduleManager, fix potential null pointer, added a testcase.

* Wed Apr 22 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.5-1
- Add /etc/rhn/search/ %dir directive in search spec. (dgoodwin@redhat.com)

* Fri Apr 17 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.4-1
- Search server adding a xmlrpc call that will allow updates to be triggered
  immediately (jmatthew@redhat.com)
- 487209 - enhanced system search for hardware devices (jmatthew@redhat.com)
- 495921 -  Limit results returned from Errata Search by Advisory
  (jmatthew@redhat.com)
- 487158 - SystemSearch fixed search by customInfo (jmatthew@redhat.com)
- Search Server adding a debug option to print out explanation of searches
  (jmatthew@redhat.com)
- 442439 - enhancing csv for systemsearch (jmatthew@redhat.com)
- 487189 -  System Search fixed search by checkin (jmatthew@redhat.com)

* Sun Apr 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.3-1
- 487424 - add logrotate to %%files section (jesusr@redhat.com)

* Sat Apr 04 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.2-1
- install logrotate.d directory
- remove / after RPM_BUILD_ROOT it's not needed
- search requires doc-indexes, sw-doc-indexes provides doc-indexes (jesusr@redhat.com)
- 492624 - "rhn-search cleanindex" checks db connection is up (jmatthew@redhat.com)
- bump Versions to 0.6.0 (jesusr@redhat.com)

* Tue Mar 31 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.10-1
- 487424 - defined logrotate for rhn_search.log

* Thu Mar 31 2009 jesus m. rodriguez <jesusr@redhat.com>
- 487424 - define logrotate for rhn_search.log

* Thu Feb 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.9-1
- systems query changed to no longer require anything more than rhnServer.

* Thu Feb 19 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.8-1
- Fixing problem which broke unique documents in the lucene index.
- SearchServer - SystemSearch lowering minimum score threshold

* Thu Feb 19 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.7-1
- 486182 -  SystemSearch "id" is now tokenized, allows flexible 'ngram' s
- 485820 -  System Search: Isn't reindexing when system data is modified 

* Thu Feb 12 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.6-1
- 484610 - doc search results were reversed, displaying worst results first
- Cleaned up "tabs" which got added into some files previously.
- Removed "orig" as a field from DocResults

* Thu Feb 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.5-1
- 479541, 483867 - replaced runuser with /sbin/runuser

* Mon Jan 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.4-1
- allow search-server to run in degraded mode if nutch isn't installed
- fixing rpmlint warning:  summary-ended-with-dot
- allow multiple language search 

* Fri Jan 23 2009 Devan Goodwin <dgoodwin@redhat.com> 0.5.3-1
- Fix bad install command.

* Thu Jan 22 2009 Dennis Gilmore <dennis@ausil.us> 0.5.2-1
- update java-devel BuildRequires to 1.6.0
- preserve timestamps on install

* Wed Jan 21 2009 Milan Zazrivec <mzazrivec@redhat.com> 0.5.1-1
- obsolete rhn-search before 5.3.0 (for satellite's benefit)

* Tue Jan 13 2009 John Matthews <jmatthews@redhat.com> 0.4.10-1
- Added SystemSearch parameter, running kernel

* Thu Dec 18 2008 John Matthews <jmatthews@redhat.com> 0.4.7-1
- rebuild for spacewalk 0.4
- added doc search

* Mon Dec 8 2008 John Matthews <jmatthews@redhat.com> 0.4.1-1
- updates for "make test-srpm" to function

* Fri Oct 24 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.3.4-1
- rebuild
- added a "cleanindex" option to init.d script for rhn-search

* Tue Oct 21 2008 Michael Mraka <michael.mraka@redhat.com> 0.3.3-1
- resolves #467717 - fixed sysvinit scripts
- resolves #467877 - use runuser instead of su

* Tue Sep 23 2008 Milan Zazrivec 0.3.1-1
- fixed package obsoletes

* Wed Sep  3 2008 Milan Zazrivec 0.2.6-1
- config file needs to point to correct spacewalk-search.jar

* Tue Sep  2 2008 Jesus Rodriguez 0.2.5-1
- tagged for rebuild
- includes errata search capability
- fix setup and source0 to be name-version
- removed unnecessary bloat from libsrc directory
- removed apache-ibatis-sqlmap as a requires for now. FIXME

* Mon Aug 11 2008 Jesus Rodriguez 0.1.2-1
- tagged for rebuild after rename, also bumping version

* Tue Aug  5 2008 Jan Pazdziora 0.1.2-0
- tagged for rebuild after rename, also bumping version

* Mon Aug  4 2008 Jan Pazdziora 0.1.1-0
- rebuilt with BuildRequires: java-devel >= 1.5.0
