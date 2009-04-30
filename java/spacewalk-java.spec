%{!?__redhat_release:%define __redhat_release UNKNOWN}
%define cobprofdir      %{_localstatedir}/lib/rhn/kickstarts
%define cobprofdirup    %{_localstatedir}/lib/rhn/kickstarts/upload
%define cobprofdirwiz   %{_localstatedir}/lib/rhn/kickstarts/wizard
%define cobdirsnippets  %{_localstatedir}/lib/rhn/kickstarts/snippets
%define appdir          %{_localstatedir}/lib/tomcat5/webapps
%define jardir          %{_localstatedir}/lib/tomcat5/webapps/rhn/WEB-INF/lib
%define jars antlr asm bcel c3p0 cglib commons-beanutils commons-cli commons-codec commons-configuration commons-digester commons-discovery commons-el commons-fileupload commons-lang commons-logging commons-validator concurrent dom4j hibernate3 jaf jasper5-compiler jasper5-runtime javamail jcommon jdom jfreechart jspapi jpam log4j redstone-xmlrpc redstone-xmlrpc-client ojdbc14 oro oscache sitemesh struts taglibs-core taglibs-standard xalan-j2 xerces-j2 xml-commons-apis commons-collections

Name: spacewalk-java
Summary: Spacewalk Java site packages
Group: Applications/Internet
License: GPLv2
Version: 0.6.10
Release: 1%{?dist}
URL:       https://fedorahosted.org/spacewalk
Source0:   https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz 
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
ExcludeArch: ia64

Summary: Java web application files for Spacewalk
Group: Applications/Internet
Requires: bcel
Requires: c3p0
Requires: hibernate3 >= 0:3.2.4
Requires: java >= 0:1.6.0
Requires: java-devel >= 0:1.6.0
Requires: jakarta-commons-lang >= 0:2.1
Requires: jakarta-commons-codec
Requires: jakarta-commons-configuration
Requires: jakarta-commons-cli
Requires: jakarta-commons-logging
Requires: jakarta-taglibs-standard
Requires: jasper5
Requires: jcommon
Requires: jfreechart >= 1.0.9
Requires: jpam
Requires: jta
Requires: log4j
Requires: redstone-xmlrpc
Requires: oscache
Requires: ojdbc14
Requires: servletapi5
Requires: struts >= 0:1.2.9
Requires: tomcat5
Requires: xalan-j2 >= 0:2.6.0
Requires: xerces-j2
Requires: sitemesh
Requires: stringtree-json
Requires: spacewalk-java-config
Requires: spacewalk-java-lib
Requires: jpackage-utils >= 0:1.5
Requires: cobbler >= 1.6.3
BuildRequires: ant
BuildRequires: ant-apache-regexp
BuildRequires: java-devel >= 1.6.0
BuildRequires: ant-contrib
BuildRequires: ant-junit
BuildRequires: ant-nodeps
BuildRequires: antlr >= 0:2.7.6
BuildRequires: jpam
BuildRequires: tanukiwrapper
BuildRequires: javamail
BuildRequires: jsp

# Sadly I need these to symlink the jars properly.
BuildRequires: asm
BuildRequires: bcel
BuildRequires: c3p0
BuildRequires: concurrent
BuildRequires: cglib
BuildRequires: ehcache
BuildRequires: jakarta-commons-configuration
BuildRequires: dom4j
BuildRequires: hibernate3
BuildRequires: jakarta-commons-cli
BuildRequires: jakarta-commons-collections
BuildRequires: jakarta-commons-discovery
BuildRequires: jakarta-commons-el
BuildRequires: jakarta-commons-fileupload
BuildRequires: jakarta-commons-validator
BuildRequires: jakarta-taglibs-standard
BuildRequires: jasper5
BuildRequires: jcommon
BuildRequires: jdom
BuildRequires: jfreechart >= 0:1.0.9
BuildRequires: jta
BuildRequires: redstone-xmlrpc
BuildRequires: oscache
BuildRequires: quartz
BuildRequires: stringtree-json
BuildRequires: struts
BuildRequires: sitemesh
Obsoletes: rhn-java < 5.3.0
Obsoletes: rhn-java-sat < 5.3.0
Obsoletes: rhn-oracle-jdbc-tomcat5 <= 1.0
Provides: rhn-java = %{version}-%{release}
Provides: rhn-java-sat = %{version}-%{release}
Provides: rhn-oracle-jdbc-tomcat5 = %{version}-%{release}

%description
This package contains the code for the Java version of the Spacewalk Web Site.

%package config
Summary: Configuration files for RHN Java
Group: Applications/Internet
Obsoletes: rhn-java-config < 5.3.0
Obsoletes: rhn-java-config-sat < 5.3.0
Provides: rhn-java-config = %{version}-%{release}
Provides: rhn-java-config-sat = %{version}-%{release}

%description config
This package contains the configuration files for the Spacewalk Java web
application and taskomatic process.

%package lib
Summary: Jar files for Spacewalk Java
Group: Applications/Internet
Obsoletes: rhn-java-lib < 5.3.0
Obsoletes: rhn-java-lib-sat < 5.3.0
Provides: rhn-java-lib = %{version}-%{release}
Provides: rhn-java-lib-sat = %{version}-%{release}

%description lib
This package contains the jar files for the Spacewalk Java web application
and taskomatic process.

%package -n spacewalk-taskomatic
Summary: Java version of taskomatic
Group: Applications/Internet
Requires: bcel
Requires: c3p0
Requires: cglib
Requires: hibernate3 >= 0:3.2.4
Requires: java >= 0:1.6.0
Requires: java-devel >= 0:1.6.0
Requires: jakarta-commons-lang >= 0:2.1
Requires: jakarta-commons-cli
Requires: jakarta-commons-codec
Requires: jakarta-commons-configuration
Requires: jakarta-commons-logging
Requires: jakarta-taglibs-standard
Requires: jcommon
Requires: jfreechart >= 0:1.0.9
Requires: jpam
Requires: log4j
Requires: oscache
Requires: ojdbc14
Requires: xalan-j2 >= 0:2.6.0
Requires: xerces-j2
Requires: tanukiwrapper
Requires: spacewalk-java-config
Requires: spacewalk-java-lib
Requires: concurrent
Requires: quartz
Requires: cobbler >= 1.6.3
Obsoletes: taskomatic < 5.3.0
Obsoletes: taskomatic-sat < 5.3.0
Provides: taskomatic = %{version}-%{release}
Provides: taskomatic-sat = %{version}-%{release}
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts

%description -n spacewalk-taskomatic
This package contains the Java version of taskomatic.

%prep
%setup -q

%build
#nothing to do here, move on

%install
rm -rf $RPM_BUILD_ROOT
ant -Dprefix=$RPM_BUILD_ROOT install
install -d -m 755 $RPM_BUILD_ROOT/%{_sysconfdir}/tomcat5/Catalina/localhost/
install -d -m 755 $RPM_BUILD_ROOT/%{_initrddir}
install -d -m 755 $RPM_BUILD_ROOT/%{_bindir}
install -d -m 755 $RPM_BUILD_ROOT/%{_sysconfdir}/rhn
install -d -m 755 $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/default
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/lib
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/classes
install -d -m 755 $RPM_BUILD_ROOT/%{cobprofdir}
install -d -m 755 $RPM_BUILD_ROOT/%{cobprofdirup}
install -d -m 755 $RPM_BUILD_ROOT/%{cobprofdirwiz}
install -d -m 755 $RPM_BUILD_ROOT/%{cobdirsnippets}

install -d -m 755 $RPM_BUILD_ROOT/%{_sysconfdir}/logrotate.d
install -m 755 conf/rhn.xml $RPM_BUILD_ROOT/%{_sysconfdir}/tomcat5/Catalina/localhost/rhn.xml
install -m 644 conf/default/rhn_hibernate.conf $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/default/rhn_hibernate.conf
install -m 644 conf/default/rhn_taskomatic_daemon.conf $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/default/rhn_taskomatic_daemon.conf
install -m 644 conf/default/rhn_taskomatic.conf $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/default/rhn_taskomatic.conf
install -m 644 conf/default/rhn_org_quartz.conf $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/default/rhn_org_quartz.conf
install -m 755 conf/logrotate/rhn_web_api $RPM_BUILD_ROOT/%{_sysconfdir}/logrotate.d/rhn_web_api
install -m 755 scripts/taskomatic $RPM_BUILD_ROOT/%{_initrddir}
install -m 644 build/webapp/rhnjava/WEB-INF/lib/rhn.jar $RPM_BUILD_ROOT/%{_datadir}/rhn/lib
install -m 644 build/classes/log4j.properties $RPM_BUILD_ROOT/%{_datadir}/rhn/classes/log4j.properties
ln -s -f /usr/sbin/tanukiwrapper $RPM_BUILD_ROOT/%{_bindir}/taskomaticd
ln -s -f %{_javadir}/ojdbc14.jar $RPM_BUILD_ROOT%{jardir}/ojdbc14.jar


%clean
rm -rf $RPM_BUILD_ROOT

%postun
rm -f /var/lib/cobbler/snippets/spacewalk

%post
ln -s -f %{cobdirsnippets} /var/lib/cobbler/snippets/spacewalk 

%post -n spacewalk-taskomatic
# This adds the proper /etc/rc*.d links for the script
/sbin/chkconfig --add taskomatic

%preun -n spacewalk-taskomatic
if [ $1 = 0 ] ; then
   /sbin/service taskomatic stop >/dev/null 2>&1
   /sbin/chkconfig --del taskomatic
fi

%files
%defattr(644,tomcat,tomcat,775)
%dir %{appdir}
%dir %{cobprofdir}
%dir %{cobprofdirup}
%dir %{cobprofdirwiz}
%dir %{cobdirsnippets}
%{appdir}/*
%config(noreplace) %{_sysconfdir}/tomcat5/Catalina/localhost/rhn.xml

%files -n spacewalk-taskomatic
%attr(755, root, root) %{_initrddir}/taskomatic
%attr(755, root, root) %{_bindir}/taskomaticd

%files config
%defattr(644, root, root)
%config(noreplace) %{_sysconfdir}/rhn/default/rhn_hibernate.conf
%config(noreplace) %{_sysconfdir}/rhn/default/rhn_taskomatic_daemon.conf
%config(noreplace) %{_sysconfdir}/rhn/default/rhn_taskomatic.conf
%config(noreplace) %{_sysconfdir}/rhn/default/rhn_org_quartz.conf
%config %{_sysconfdir}/logrotate.d/rhn_web_api

%files lib
%attr(644, root, root) %{_datadir}/rhn/classes/log4j.properties
%attr(644, root, root) %{_datadir}/rhn/lib/rhn.jar

%changelog
* Thu Apr 30 2009 Tomas Lestach <tlestach@redhat.com> 0.6.10-1
- 454876 - not setting cookie domain (tlestach@redhat.com)
- 497458 - fixing ISE with errata cloning (jsherril@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- 219179 - setting redhat_management_server for the system records like we do
  for server (jsherril@redhat.com)
- 480011 - Added organization to the top header near the username.
  (jason.dobies@redhat.com)
- 497867 - fixed bug in logic after changing hibernate mappings
  (jsherril@redhat.com)
- 497917 - fixing issue where select all did not work on errata list/remove
  packages (jsherril@redhat.com)
- 497867 - fixing reboots taking place even if provisioning fails
  (jsherril@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- 219179 - fixed some issues related to reprovisioning through proxy
  (jsherril@redhat.com)
- 481578 - Ported manage software channels page from perl to java
  (jason.dobies@redhat.com)
- 498208 - cobbler webui string correction (shughes@redhat.com)
- 461704 - clean time_series when deleting a monitoring probe
  (mzazrivec@redhat.com)
- 497925 - we search and replace the cobbler host with proxy
  (mmccune@gmail.com)
- Added code to ensure name is required .... (paji@redhat.com)
- 497872 - skip 'fake' interfaces when looking up system records.
  (mmccune@gmail.com)
- Updated the Kickstart Advanced mode page to include edit area instead of the
  standard text area for uploading kicktstart information.. (paji@redhat.com)
- 497964 - Made the config file create and file details page use edit area..
  Fancy editor... (paji@redhat.com)
- 444221 - Updated the Create/Modify and the delete snippets pages based on
  Mizmo's suggestions (paji@redhat.com)
- 489902 - fix help links to work with rhn-il8n-guides (bbuckingham@redhat.com)
- Checkstyle fixes (jason.dobies@redhat.com)
- 494627 - Added more fine grained error messages for invalid channel data.
  (jason.dobies@redhat.com)
- 485849 - merging RELEASE-5.1 bug into spacewalk (mmccune@gmail.com)
- 496259 - greatly improved errata deletion time (jsherril@redhat.com)
- 444221 - Cobbler Snippet Create page redesign (paji@redhat.com)
- 444221 - Initial improvement on Cobbler Snippets List page based on the bug..
  (paji@redhat.com)

* Fri Apr 24 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.8-1
- removing some debug statements (jsherril@redhat.com)
- 495961 - greatly improving performance of add errata page (jsherril@redhat.com)
- Removed outdated @version requirement (jason.dobies@redhat.com)
- 497119 - support to remove child channel subscriptions from orgs that have
  systems subscribed when denied access to protected channel (shughes@redhat.com)
- 495846 - Oops, missed a file (jason.dobies@redhat.com)
- 495847 - New ListTag 3 functionality to add selected servers to SSM.
  (jason.dobies@redhat.com)
- 497538 - remove shared child channel subscriptions when removing subscription
  from parent (shughes@redhat.com)

* Thu Apr 23 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.7-1
- 496080 - Fix channel with package lookup to filter on org.
  (dgoodwin@redhat.com)

* Wed Apr 22 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.6-1
- 496719 - generate error for invalid keys in input maps (bbuckingham@redhat.com)
- 494976 - adding missing file (jsherril@redhat.com)
- 496303 - 'select all' button fixed on errata list/remove packages page (jsherril@redhat.com)
- 480010 - minor syntax changes to organization channel sharing consumption (shughes@redhat.com)
- Fixed a couple of bugs related to the snippets page. (paji@redhat.com)
- 496272 - Updates/clean up to relogin text. (jason.dobies@redhat.com)
- 496710 - system.listSystemEvents - convert dates in return to use Date (bbuckingham@redhat.com)
- 494976 - adding cobbler system record name usage to reprovisioning (jsherril@redhat.com)
- 495506 - Fixed issue when determining package ACLs. (jason.dobies@redhat.com)
- Removed a couple of needless if statements (paji@redhat.com)
- Added some unit tests for the cobbler snippets (paji@redhat.com)
- 495946 - Rewrite of Cobbler Snippets. (paji@redhat.com)
- 496318 - api - unable to register system using key generated by
  system.obtainReactivationKey (bbuckingham@redhat.com)
- 467063 - Fixed issue where the form variables were reset when the page size
  was changed. (jason.dobies@redhat.com)
- 496666 - apidoc - add some deprecations to the activation key handler
  (bbuckingham@redhat.com)
- 443500 - Changed logic to determine packages to remove to include the
  server's current package information. (jason.dobies@redhat.com)
- 495897 - Fix broken Activated Systems links. (dgoodwin@redhat.com)
- adding fallbackAppender for log4j (jsherril@redhat.com)
- fixing checkstyle and a commit that did not seem to make it related with
  log4j (jsherril@redhat.com)
- 496104 - fixing double slash and downloads with ++ in the filename. (mmccune@gmail.com)
- 495616 - throw permission error if url is modified (jesusr@redhat.com)
- fixing error in specfile after accidental commit of
  d8903258b897c9d6527a1a64b70b8a2610c2e3ce (jsherril@redhat.com)

* Mon Apr 20 2009 Partha Aji <paji@redhat.com> 0.6.5-1
- 495946 - Got a workable edition of cobbler snippets.

* Fri Apr 17 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.4-1
- 495789 - changing the way apis are logged to fall back to RootAppender if
  there is an error (jsherril@redhat.com)
- logrotate (jsherril@redhat.com)
- 496161 - fixing broken system group links (jsherril@redhat.com)
- 495789 - enabling api logging by default (jsherril@redhat.com)
- 494649 - fix resource bundle text for changing channel to protected
  (bbuckingham@redhat.com)
- 496003 - api - fix system.isNvreInstalled(n,v,r) to properly handle packages
  that have an epoch (bbuckingham@redhat.com)
- 494450 - api - add permissions_mode to ConfigRevisionSerializer & fix doc on
  system.config.createOrUpdatePath (bbuckingham@redhat.com)
- 493163 - fixing ISE when renaming distros and profiles (jsherril@redhat.com)

* Thu Apr 16 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.3-1
- remove Proxy Release Notes link and unused Developer's area. (jesusr@redhat.com)
- 487209 - enhanced system search for hardware devices (jmatthew@redhat.com)
- 450954 - changing reprovisioning to allow reactivation with an activation key
  of a conflicting base channel (jsherril@redhat.com)
- 487185 - Fixed system-search by needed package (jmatthew@redhat.com)
- 494920 - fixing ISE when cloning errata, after channel was cloned
  (jsherril@redhat.com)
- Fix null pointer in scheduleAutoUpdates(). (jortel@redhat.com)
- SystemSearch lowering threshold of a single match to cause a redirect to SDC.
  (jmatthew@redhat.com)
- 495133 - changing send notifications button to populate channel id as well
  (jsherril@redhat.com)
- 495133 - fixing errata mailer such that mails are only sent for a particular
  channel that was changed (jsherril@redhat.com)
- 495065 - channel name appears on private/protected confirm page
  (jesusr@redhat.com)
- 492906 - Fixed spacewalk reference in cobbler config (paji@redhat.com)
- 491130 - improved a kickstart edit page message a little more..
  (paji@redhat.com)
- 491130 - improved a kickstart edit page message.. (paji@redhat.com)
- 494673 - update system migration to support null config channels
  (bbuckingham@redhat.com)
- Clarifying that search must be restarted after running cleanindex
  (jmatthew@redhat.com)
- 487158 - SystemSearch fixed search by customInfo (jmatthew@redhat.com)
- 458205 - Fixed KS Ipranges URL (paji@redhat.com)
- 495786 - fixing issue where some updates were being ignored for RHEL 4
  systems (jsherril@redhat.com)
- 487192 - Fixed system search, search by registration (jmatthew@redhat.com)
- 490904 - change all references to /rhn/help/*/en/ -> /rhn/help/*/en-US/
  (jesusr@redhat.com)
- fix duplicate string resource entry (jesusr@redhat.com)
- 480674 - allow shared channels to appear in act. keys creation
  (jesusr@redhat.com)
- 495585 - fixing Errata Search by Issue Date (jmatthew@redhat.com)
- SystemSearch fix hwdevice result gathering.  Keep highest scoring match per
  system-id (jmatthew@redhat.com)
- 488603 - Fix to deal with blank space interpreter for post scripts
  (paji@redhat.com)
- 234449 - moved block of code to only count real downloads (mmccune@gmail.com)
- 488603 - KickstartFileFormat fix, to deal with blank space interpreter
  (paji@redhat.com)
- 492902 - Fixed 2 queries for Config Target Systems page (paji@redhat.com)
- 486029 - being more consistent with the kickstart label  string
  (jsherril@redhat.com)
- 493163 - fixing ise on update distro page with RHEL 4 distros
  (jsherril@redhat.com)
- 494884 - sub class needs to have protected method to behave as desired
  (jsherril@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- 493647 - Fix for unselect all malfunction... (paji@redhat.com)
- 443500 - Refactored SSM remove packages to only create a single action for
  all servers/packages selected. (jason.dobies@redhat.com)
- 494914 - fix to create a network interface for cobbler system records on
  guest provisioning (jsherril@redhat.com)
- 493718 - minor syntax message change for private channel access
  (shughes@redhat.com)
- 493110 - Changed package installation through SSM to only create one action
  (jason.dobies@redhat.com)
- 494686 - changing it such that you have to provide a virt guest name, not
  letting koan make one (jsherril@redhat.com)
- Fixed the cobbler MockConnection to work with find_* calls (paji@redhat.com)
- api doclet - enhanced to support a 'since' tag, tagged snapshot apis and
  bumped api version (bbuckingham@redhat.com)
- 487566 - fix broken junit in ServerFactoryTest (bbuckingham@redhat.com)
- 442439 - internationalize strings for system search csv export
  (jmatthew@redhat.com)
- 442439 - enhancing csv for systemsearch (jmatthew@redhat.com)
- 494593 - fixing the repofile compare to use the right type for java date
  object obtained through hibernate (pkilambi@redhat.com)
- Updated documentation (jason.dobies@redhat.com)
- 493744 - Added configuration admin ACL to configuration tab
  (jason.dobies@redhat.com)
- 487566 - api/script - initial commit of snapshot script and mods to snapshot
  apis (bbuckingham@redhat.com)
- bumping the protocol version on exporter (pkilambi@redhat.com)
- 492206-Fix for Kickstart Profile Template parse error. (paji@redhat.com)
- 492206-Fix for Kickstart Profile Template parse error. (paji@redhat.com)
- 484435 - add union to query to allow shared child channel subscription access
  (shughes@redhat.com)
- 442439 - system search CSV update to dataset name (jmatthew@redhat.com)
- Removing the last bastions of 1.4 code.. Where logic went like if cobbler
  version < 1.6 do one set else do other wise... (paji@redhat.com)
- Made the configuraiton manager instance static final instead of just static..
  Made no sense for it to be static... (paji@redhat.com)
- 494409 - unsubscribe affected systems after trust removal
  (shughes@redhat.com)
- 494475,460136 - remove faq & feedback code which used customerservice emails.
  (jesusr@redhat.com)
- 487189 -  System Search fixed search by checkin (jmatthew@redhat.com)
- fixing small NPE possibility (jsherril@redhat.com)
- 492949 - setting cobblerXenId appropriately (jsherril@redhat.com)
- 492949 - having CobblerSync task, reuse existing distros if they already
  exist (by name) (jsherril@redhat.com)
- adding single page doclet supporting macros (jsherril@redhat.com)
- 443132 - couple of small fixes for the revamped action pages
  (jsherril@redhat.com)

* Sun Apr 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.2-1
- 470991 - remove unused jar files from taskomatic_daemon.conf (jesusr@redhat.com)
- 437547 - include instructions for regenerating indexes (jmatthew@redhat.com)
- 483611 - Remove search links from YourRhn tasks module (jmatthew@redhat.com)
- 480060 - improve performance of All and Relevant (mmccune@gmail.com)
- 494066 - removed the trailing \n from strings returned from cobbler. (mmccune@gmail.com)
- 489792 - listErrata api docuementation corrected (jsherril@redhat.com)
- 484659 - taskmoatic no longer throws cobbler errors on restart (jsherril@redhat.com)
- 221637 - Removed no-op channels from SSM subscribe config channels (jason.dobies@redhat.com)
- 490866 - distros now properly synced after sat-sync (jsherril@redhat.com)
- 493173 - add redirect in struts config for errata/manage/Delete (bbuckingham@redhat.com)
- 487418 - Added a 'None' option to the available virt type (paji@redhat.com)
- 493187 - Changed empty list message to be a variable and set in calling pages specific to need (published v. unpublished) (jason.dobies@redhat.com)
- fix junit assertion error in testDeleteTreeAndProfiles (bbuckingham@redhat.com)
- 485317 - phantom kickstart sessions no longer show up on kickstart overview (jsherril@redhat.com)

* Thu Apr 02 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.1-1
- 481130 - Move preun scriptlet to taskomatic subpackage. (dgoodwin@redhat.com)
- 487393 - fixed issue where list count was wrong on provisioning page
  (jsherril@redhat.com)
- 493111 - api - errata.delete added & fixed add/removePackages & setDetails to
  only modify custom errata (bbuckingham@redhat.com)
- 493421 - api - kickstart.tree.deleteTreeAndProfiles fixed to delete
  associated profiles (bbuckingham@redhat.com)
- 487688 - adding text during ks tree creation to explain more detail of what
  is needed (jsherril@redhat.com)
- 462593 - fixing issue where creating or renaming a profile with a name that
  already exists would give ISE (jsherril@redhat.com)
- 492903 - api - channel.software.create - updates so that new channels will
  show on Channel tab (bbuckingham@redhat.com)
- 492980 - api - errata.getDetails - add release, product and solution to
  return and clarify last_modified_date in docs (bbuckingham@redhat.com)
- 458838 - adding new files for kickstart exception 404 (jsherril@redhat.com)
- 490987 - fixed issue where errata files werent being refreshed, by removing
  the need for errata files (jsherril@redhat.com)
- 458838 - changing kickstart download 404s to have a descriptive message
  (jsherril@redhat.com)
- removed jasper5* from run time dependencies and made them build time
  instead. (paji@redhat.com)
- 489532 - unsubscribe multiorg shared channel when moving access from public
  to protected with deny selection (shughes@redhat.com)

* Mon Mar 30 2009 Mike McCune <mmccune@gmail.com> 0.5.44-1
- 472595 - ported query forgot to check child channels
- 144325 - converting system probe list to the new list tag, featuring all the bells and 
  whistles the new list tag has to offer
- 492478 - modifying the system applicable errata page so that you can filter on the 
  type of errata you want to see, also linking a couple of critical errata li
- 467063 - Port of clone errata functionality to new list tag
- 492418 - adding missing channel title when creating new software channels
- 492476 - fixing issue where critical  plus non-critical errata for a system (on the system details page) did not  total errata
- 492146 - fixing issue where system icons are not clickable


* Thu Mar 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.41-1
- 437359 - redirect org creation to the orgsystemsubscription page
- 489007 - add system.getConnectionPath for listing proxies a server connected through
- 489736 - generate non-expiring kickstart package download url
- 489736 - download_url_lifetime of 0 disables expiration server wide
- 489736 - can disable expiration by package name by non_expirable_package_urls
- 489486 - added updated message when changing channel access from public to private
- Adding support for comps info to be added to repomd.xml.
- Updated documentation

* Thu Mar 26 2009 Mike McCune <mmccune@gmail.com> 0.5.40-1
- 492137 - fixing ISE for virt 

* Thu Mar 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.39-1
- 484852 - user taken to meaningful error pages instead of ISEs.

* Wed Mar 25 2009 Partha Aji <paji@redhat.com> 0.5.38-1
- Added code to take advantage of cobbler 1.6 perf enhancements
- if the customer has that installed.

* Wed Mar 25 2009 Mike McCune <mmccune@gmail.com> 0.5.37-1
- 491978 - fixing status reporting in webui for kickstarts.
- Added resource bundle entries for admin/config/Cobbler.do
- 467063 - Ported published and unpublished errata to new list tag to get new navigation features
- 446269 - fixed issue where you could not remove a package from a system 

* Fri Mar 20 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.36-1
- bring over jta from satellite build.
- fix the jfreechart requires to be 0:1.0.9 everywhere

* Thu Mar 19 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.34-1
- ServerFactory - fix wording in method header
- 486212 - api - added system.deleteCustomValues

* Thu Mar 19 2009 Mike McCune <mmccune@gmail.com> 0.5.33-1
- 474774 - adding jfreechart 1.0 version requires

* Wed Mar 18 2009 Mike McCune <mmccune@gmail.com> 0.5.31-1
- 486186 - Update spacewalk spec files to require cobbler >= 1.4.3

* Thu Mar 12 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.30-1
- fixed iprange delete URLs weren't being correctly rendered
- 480432 - fixed kickstart urls: .../rhn/kickstart/ks/cfg/org/1/org_default
- 489792 - fixing incorrect api return types
- 489775 - fixing listErrata api due to bad query
- 481180 - update KickstartFormatter to use StringUtils on --interpreter check

* Wed Mar 11 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.29-1
- 489760 - used cheetah's #errorCatcher Echo to handle escaping in ks files.
- 249459 - fixing issue where org trust page was busted
- 488137 - refer to cobbler_api instead of cobbler_api_rw to support cobbler >= 1.6
- update deprecated methods in ChannelSoftwareHandler to be more consistent
- 484463 - added more cobbler bits to the kickstart formatter that were missing
- 488830 - api - auth handler - remove the public doc for checkAuthToken
- apidoc generation now ignores an individual call using @xmlrpc.ignore
- added taskomatic task to regenerate deleted kickstart wizard files
- Fixed the ks-setup.py script to function correctly w.r.t space05 changes
- 481180 - do not include --interpreter in profile for scripts without scripting lang
- fix indentations to make it more readable
- Removed code that was getting ignored.
- 489577 - fixing issue that caused taskomatic tracebacks when talking to cobbler
- 489363 - add missing exception class...
- 489363 - api - system.createPackageProfile did not include pkg arch in profile
- 489426 - fixing cloning of kickstarts for regular and raw style
- 489347 - fixing "File Location" field on OS tab to show the --url param
- 483287 - Added ability to do a cobbler sync thru the UI
- adding missing param, for channel name to show up in header
- 483776 - fixing ISE (NPE) on clone errata page
- 462079 - fixed issue where an auto-scheduled errata had name of  "null - null"
- 467265 - fixing issue where errata list was sorting date incorrectly
- fixing package delete to delete from a couple more tables
- 489042 - api - org.setSystemEntitlements - supports setting base entitlements.
- added list of supported entitlements to the api doc
- 488999 - c.s.setUserSubscribable documented value as string while impl
- expected a primitive boolean as input instead of Boolean
- 488148 - test fixes related to bugzilla
- 488148 - use pre-existing system record if there is one.
- 489033 - correcting type of trustOrgId in org.trust.addTrust and removeTrust
- 488990 - api - remove addTrust, removeTrust, listTrusts apis from org handler.
- 488548 - api - org.migrateSystems - fix reactivationkeys, custom info and config
- 488348 - use channel org_id to prevent returning RH channels in addition to custom
- Fixed variable name typo.
 
* Fri Mar 06 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.28-1
- added ExcludeArch: ia64

* Thu Mar 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.27-1
- revert commit ba62c229
- changing MockConnection and MockXmlrpcInvoker to handle multiple entities
- 488723 - handling ise for channel packages listing
- 488379 - Syntax error in sql query causing ISE corrected
- 487317 - entitlement verbage change for error message
- 484284 - fixing create/updates messages for custom channel edit actions
- 488622 - api - kickstart.profile.addIpRange updated to validate input
- 487563 - switching take_snapshots to enable_snapshots
- 193788 - converting a few pages to java, so we can sort better
- adding check to looking up cobbler id if its null
- 466195 - apis - rename system.listBaseChannels and system.listChildChannels
- 488277 - remove rhn-highlight from href address
- 485313 - update string to remove extra space
- 484305 - Refactored to keep the package deletion heavy lifting in the DB, avoids OutOfMemoryErrors.
- 480012 - allow sharing org to see shared errata.
- 487234 - fix the query used by the system->software->upgrade page

* Mon Mar 02 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.26-1
- add bcel to BuildRequires

* Fri Feb 27 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.25-1
- Profile rename has been finally fixed
- 469921 - system.scheduleSyncPackagesWithSystems generated a NullPointerException
- fixing mistake in method name
- 485120 - fixed issue where changing org
- name or changing profile name breaks kickstarts (including raw).  Also moved kickstart file location

* Thu Feb 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.24-1
- removing listScripts, addScript, removeScript and downloadKickstart APIs from KickstartHandler
- 486749 - Add symlinks for jakarta-commons-collections and jta jars.
- 484942 - "Satellite" is in monitoring schema and have to be translated to product name

* Thu Feb 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.23-1
- modifying list tag to not clear set during a select all()
- fixing some issues with converting rhnset to implement set
- Fix to a cobbler rename profile issue...
- making edit command a bit more relaxed if there is no associated cobbler profile
- 486606 - Changed query and page to load/display arch for each package selected
- 487066 - change create link to be lowercase (create new key).
- 482879 - fixing compile error and syncing whenever we update a ksdata
- 482879 - make sure we add all the activation keys to the cobbler profile
- 486982 - fixed ise on software upgrade list
- 480191 - fix query used by systems->software->packages->install
- 487174 - fixing issue where clearing the filter, resulted in the page being submitted
- 241070 - select all on filtered list would select the entire list and not just what was filtered.
- 483555 - Ported to new list tag to get Select All functionality correct when a filter is active.

* Tue Feb 24 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.22-1
- fixing the repodata task queries to avoid tempspace issues
 
* Thu Feb 19 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.21-1
- 486502 - Changed order when list a group of systemIds so top result is highest.
- Fixing problem which broke unique documents in the lucene index.
- 486502 - Sort similar results by systemId with highest ID on the bottom
- SystemSearch change redirect behavior if only 1 result is found.

* Thu Feb 19 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.20-1
- 484768 - Basically fixed a query and DTO and a Translator to correctly 
- 486174 - Was using the incorrect key in the filterattr attribute on the
- kickstart session status where ks is syncing to a profile has an correc
- 456315 - refixing this bug, changing kickstart commands to be a Collect
- Changed the hard coded 500 value to BATCH size :)
- 444517 - Added snapshot hook to configuration channel subscription via 
- 485047 - adding back the Task_queries find_channel_in_task_queue query
- 437547, 485313 - Added exception message for when index files are missi
- Adding 'Errata' search to Tasks under YourRhn.do
- 483607 -  Adding documentation as an option to the search bar
- 219844 -  Add 'legend' for Errata Search
- Cleanup, removed commented out code

* Wed Feb 18 2009 Dave Parker <dparker@redhat.com> 0.5.19-1
- 486186 - Update spacewalk spec files to require cobbler >= 1.4.2

* Mon Feb 16 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.18-1
- yum repodata regen changes to taskomatic

* Mon Feb 16 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.16-1
- 458355 - show Monitoring tabs only if Monitoring Backend or Monitoring Scout is enabled
- 481766 - Corrected the text on Ks Distribution page to reflect the exact nature of the value to be
- 483796 - fixed bug where ip address would show up as 0
- 469957 - Updated getDetails to use first_name instead of first_names
- 485500 - fixed ISE when deleting errata
- 469957 - Added translation in XMLRPC API layer to accept first_name instead of "first_names"
- handler-manifest.xml used by xmlrpc api was pointing to wrong location for a class...:(
- 466295 - Added date format as description on the property
- Removing duplicate setKickstartTree API

* Thu Feb 12 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.13-1
- 484312 - more cleanup for kickstart AUTO virt type removal
- 484312 - massive cleanup of virt types.  getting rid of useless AUTO type.

* Thu Feb 12 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.12-1
- 484911 - fixed issue where taskomatic won't sync to cobbler newly sat-synced
- Moving SystemDetailsHandler.java and its junit test out of kickstart.profile
- 199560 - Fix epoch being returned as ' ' in channel.software.list_all_package
- 484262 - Updated documentation as per the bz
- 483815 - minor messaging change for custom channel pkg removal
- 452956 - Need to check to make sure the DMI actually contains data before at
- 484435 - needed parent_channel is null when selecting from rhnsharedchannelv
- 480674 - fixed query in Channel.hbm.xml to know about shared channels. Chang
- 485122 - api - kickstart.profile.system.getPartitioningScheme was incorrectl
- 485039 - apidoc - channel.software.removePackages - fix wording on return va
- remove + which hoses the urls in org trusts page

* Wed Feb 11 2009 Dave Parker <dparker@redhat.com> 0.5.11-1
- 484659 remove error messages due to incorrect startup sequences from sysv and from the rhn-satellite tool
* Thu Feb 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.10-1
- Properly run the status through the message bundle for i18n

* Thu Feb 05 2009 Mike McCune <mmccune@gmail.com> 0.5.9-1
- 481767 - be more forgiving of busted kickstart distros during a sync and also report errors in an email.
- 442601 - api - adding access to server lock/unlock
- Restructured to an inversion of control pattern to make it more clear that the mode/summary key are not meant to be attributes.
- 443718 - fixing a view mistage and having a query just use the view
- 483603 - Added details page for listing servers involved in a particular SSM operation
- update the header to 2009 and fix the very annoying whitespace after the *.
- fixing Action classes that have non-final member variables
- 251767 - api - channel.software.setSystemChannels - throw better exception when user passes multiple base channels as input
- 467063 - Added page decorator to allow variable amount of items to be shown
- 437872 - added multiorg messaging suggestion for entitlement warnings
- 483603 - First pass at display of async SSM operations in the UI
- 437563 - adding success message for sat admin toggles
- 479541, 483867 - replaced runuser with /sbin/runuser
- 483603 - Renamed query file; added ability to retrieve servers associated with an operation
- 481200 - api - fix minor issues in apidoc for activationkey apis
- 483689 - api doc updates for channel.software listAllPackages and listAllPackagesByDate apis
- 483806 - updating more iso country codes
- 482929 - fixing messaging with global channel subscriptions per user
- 480016 - adding ID to org details page for information (assist with migration scripts)
- 443718 - improving errata cache calcs when pushing a single errata

* Mon Feb  2 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.8-1
- 480126 - deactivate proxy different way
- 477532 - fixed issue where channels would dissappear after hiding the children

* Fri Jan 30 2009 Mike McCune <mmccune@gmail.com> 0.5.7-1
- removing requirement for spacewalk-branding-jar

* Fri Jan 30 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.6-1
- 483058 - subscribe to proxy channel if requested
- 482923 - splitting out the java branding jar file into its own subpackage
- 459085 - Added (and defaulted) option for Do Nothing
- 469984 - Restructuring to avoid DB hits entirely if there are no channels selected to either subscribe or unsubscribe.

* Wed Jan 28 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.5-1
- 468052 - throw exception if proxy do not has provisioning entitlement
- 481671 - improved the performance of a query
- 469984 - speeding up the bulk channel subscription changes
- 481778 - fix NPE when deleting an unpublished errata
- 480003 - minor grammar change for private channel access
- 428419 - always use the cobbler server when showing URLs for kickstarts
- added ks-setup.py script to add a profile, channel, distro and activation key ..

* Thu Jan 22 2009 Dennis Gilmore <dennis@ausil.us> 0.5.4-1
- update java and java-devel Requires and BuildRequires to 1.6.0

* Wed Jan 21 2009 Devan Goodwin <dgoodwin@redhat.com> 0.5.3-1
- Remove dependency on spacewalk-taskomatic and spacewalk-search.

* Wed Jan 21 2009 Michael Mraka <michael.mraka@redhat.com> 0.5.2-1
- fixed branding stuff

* Tue Jan 20 2009 Mike McCune <mmccune@gmail.com> 0.4.17-1
- 480636 - simplifying the commands vs options into one real collection 
  managed by hibernate vs 2 that both contained the same things

* Thu Jan 15 2009 jesus m. rodriguez <jesusr@redhat.com> 0.4.16-1
- 456467 - Fixed bug where the set of packages to remove was being cleared
- before scheduling

* Wed Jan 14 2009 Mike McCune <mmccune@gmail.com> 0.4.15-1
- 461162 - properly fetch guest name from form

* Tue Jan 13 2009 Mike McCune <mmccune@gmail.com> 0.4.14-1
- 461162 - adding org to system record name
- 461162 - unit test fixes.

* Mon Jan 12 2009 Mike McCune <mmccune@gmail.com> 0.4.12-1
- Boatload of changes from end of 0.4 set of bugs/features

* Tue Jan 06 2009 Mike McCune <mmccune@gmail.com> 0.4.11-1
- Latest spacewalk 0.4 changes.

* Tue Dec 23 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.10-1
- modified layout decorators

* Mon Dec 22 2008 Mike McCune <mmccune@gmail.com> 0.4.9-1
- Adding proper cobbler requirement with version

* Fri Dec 19 2008 Mike McCune <mmccune@gmail.com> 0.4.8-1
- latest changes

* Thu Dec 11 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.7-1
- resolved #471225 - moved rhn-sat-restart-silent to /usr/sbin

* Mon Dec  8 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.6-1
- fixed Obsoletes: rhns-* < 5.3.0

* Fri Dec  5 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.5-1
- removed rhn-oracle-jdbc

* Thu Nov 20 2008 Miroslav Suchy <msuchy@redhat.com> 0.4.2-1
- 472346 - Bump up API version and make the versioning independent on web.version

* Tue Nov  4 2008 Miroslav Suchy <msuchy@redhat.com>
- 461517 - password and db name are swapped

* Fri Oct 31 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.3.7-1
- 467945 - fixed issue where part of the ssm required you to be an org admin

* Thu Oct 23 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.3.6-1
- comment the logdriver statements again.
- Fixed some set related issues.
- Updated query to only count outranked channels if the channel
- contains the file.

* Wed Oct 22 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.3.5-1
- fix stringtree-spec Requires

* Wed Oct 22 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.3.4-1
- add stringtree-spec (Build)Requires

* Tue Oct 21 2008 Michael Mraka <michael.mraka@redhat.com> 0.3.3-1
- resolves #467717 - fixed sysvinit scripts
- resolves #467877 - use runuser instead of su

* Wed Sep 17 2008 Devan Goodwin <dgoodwin@redhat.com> 0.3.1-1
- Re-version for 0.3.x.
- Add BuildRequires: jsp for RHEL 4.

* Fri Sep  5 2008 Jan Pazdziora 0.2.7-1
- add BuildRequires: javamail, needed on RHEL 4.

* Tue Sep  2 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.6-1
- Rebuild to include new kickstart profile options.

* Fri Aug 29 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.2.5-1
- Remove dependency on jsch and ant-jsch.

* Fri Aug 29 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.4-1
- Remove dependency on bouncycastle and wsdl4j.

* Wed Aug 27 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.2-1
- Build fix for velocity.jar.

* Tue Aug 26 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.1-1
- Bumping to 0.2.0.

* Mon Aug 25 2008 Mike McCune 0.2-1
- remove ivy BuildRequires and adding jakarta-commons-cli

* Tue Aug 20 2008 Mike McCune <mmccune@redhat.com> 0.2-1
- more work on rename to spacewalk-java

* Tue Aug  5 2008 Miroslav Suchy <msuchy@redhat.com> 0.2-0
- Renamed to spacewalk-java
- cleanup spec

* Thu May 22 2008 Jan Pazdziora 5.2.0-5
- weaken hibernate3 version requirement

* Fri May 16 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-3
- fixed file ownership
- fixed optimizer settings for Oracle 10g

* Thu May 15 2008 Jan Pazdziora - 5.2.0-1
- spec updated for brew builds
