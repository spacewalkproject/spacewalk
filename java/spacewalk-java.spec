%{!?__redhat_release:%define __redhat_release UNKNOWN}
%define cobprofdir      %{_localstatedir}/lib/rhn/kickstarts
%define appdir          %{_localstatedir}/lib/tomcat5/webapps
%define jardir          %{_localstatedir}/lib/tomcat5/webapps/rhn/WEB-INF/lib
%define jars antlr asm bcel c3p0 cglib commons-beanutils commons-cli commons-codec commons-configuration commons-digester commons-discovery commons-el commons-fileupload commons-lang commons-logging commons-validator concurrent dom4j hibernate3 jaf jasper5-compiler jasper5-runtime javamail jcommon jdom jfreechart jspapi jpam log4j redstone-xmlrpc redstone-xmlrpc-client ojdbc14 oro oscache sitemesh struts taglibs-core taglibs-standard xalan-j2 xerces-j2 xml-commons-apis

Name: spacewalk-java
Summary: Spacewalk Java site packages
Group: Applications/Internet
License: GPLv2
Version: 0.5.21
Release: 1%{?dist}
URL:       https://fedorahosted.org/spacewalk
Source0:   https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz 
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch

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
Requires: jfreechart
Requires: jpam
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
Requires: cobbler >= 1.4.2
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
BuildRequires: c3p0
BuildRequires: concurrent
BuildRequires: cglib
BuildRequires: ehcache
BuildRequires: jakarta-commons-configuration
BuildRequires: dom4j
BuildRequires: hibernate3
BuildRequires: jakarta-commons-cli
BuildRequires: jakarta-commons-discovery
BuildRequires: jakarta-commons-el
BuildRequires: jakarta-commons-fileupload
BuildRequires: jakarta-commons-validator
BuildRequires: jakarta-taglibs-standard
BuildRequires: jasper5
BuildRequires: jcommon
BuildRequires: jdom
BuildRequires: jfreechart >= 0:0.9.21
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
Requires: jfreechart >= 0:0.9.21
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
Requires: cobbler >= 1.4.2
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
install -m 755 conf/rhn.xml $RPM_BUILD_ROOT/%{_sysconfdir}/tomcat5/Catalina/localhost/rhn.xml
install -m 644 conf/default/rhn_hibernate.conf $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/default/rhn_hibernate.conf
install -m 644 conf/default/rhn_taskomatic_daemon.conf $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/default/rhn_taskomatic_daemon.conf
install -m 644 conf/default/rhn_taskomatic.conf $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/default/rhn_taskomatic.conf
install -m 644 conf/default/rhn_org_quartz.conf $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/default/rhn_org_quartz.conf
install -m 755 scripts/taskomatic $RPM_BUILD_ROOT/%{_initrddir}
install -m 644 build/webapp/rhnjava/WEB-INF/lib/rhn.jar $RPM_BUILD_ROOT/%{_datadir}/rhn/lib
install -m 644 build/classes/log4j.properties $RPM_BUILD_ROOT/%{_datadir}/rhn/classes/log4j.properties
ln -s -f /usr/sbin/tanukiwrapper $RPM_BUILD_ROOT/%{_bindir}/taskomaticd
ln -s -f %{_javadir}/ojdbc14.jar $RPM_BUILD_ROOT%{jardir}/ojdbc14.jar

%clean
rm -rf $RPM_BUILD_ROOT

%post -n spacewalk-taskomatic
# This adds the proper /etc/rc*.d links for the script
/sbin/chkconfig --add taskomatic

%preun
if [ $1 = 0 ] ; then
   /sbin/service taskomatic stop >/dev/null 2>&1
   /sbin/chkconfig --del taskomatic
fi

%files
%defattr(644,tomcat,tomcat,775)
%dir %{appdir}
%dir %{cobprofdir}
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

%files lib
%attr(644, root, root) %{_datadir}/rhn/classes/log4j.properties
%attr(644, root, root) %{_datadir}/rhn/lib/rhn.jar

%changelog
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
