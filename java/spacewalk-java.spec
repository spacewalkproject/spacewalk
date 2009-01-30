%{!?__redhat_release:%define __redhat_release UNKNOWN}
%define cobprofdir      %{_localstatedir}/lib/rhn/kickstarts
%define appdir          %{_localstatedir}/lib/tomcat5/webapps
%define jardir          %{_localstatedir}/lib/tomcat5/webapps/rhn/WEB-INF/lib
%define jars antlr asm bcel c3p0 cglib commons-beanutils commons-cli commons-codec commons-configuration commons-digester commons-discovery commons-el commons-fileupload commons-lang commons-logging commons-validator concurrent dom4j hibernate3 jaf jasper5-compiler jasper5-runtime javamail jcommon jdom jfreechart jspapi jpam log4j redstone-xmlrpc redstone-xmlrpc-client ojdbc14 oro oscache sitemesh struts taglibs-core taglibs-standard xalan-j2 xerces-j2 xml-commons-apis

Name: spacewalk-java
Summary: Spacewalk Java site packages
Group: Applications/Internet
License: GPLv2
Version: 0.5.7
Release: 1%{?dist}
URL:       https://fedorahosted.org/spacewalk
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd java
# make test-srpm
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
Requires: cobbler >= 0:1.4
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

%description
This package contains the code for the Java version of the Spacewalk Web Site.

%package config
Summary: Configuration files for RHN Java
Group: Applications/Internet
Obsoletes: rhn-java-config < 5.3.0
Obsoletes: rhn-java-config-sat < 5.3.0

%description config
This package contains the configuration files for the Spacewalk Java web
application and taskomatic process.

%package lib
Summary: Jar files for Spacewalk Java
Group: Applications/Internet
Obsoletes: rhn-java-lib < 5.3.0
Obsoletes: rhn-java-lib-sat < 5.3.0

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
Requires: cobbler >= 0:1.4
Obsoletes: taskomatic < 5.3.0
Obsoletes: taskomatic-sat < 5.3.0
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
install -d -m 755 $RPM_BUILD_ROOT/%{_sysconfdir}/init.d
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
install -m 755 scripts/taskomatic $RPM_BUILD_ROOT/%{_sysconfdir}/init.d
install -m 644 build/webapp/rhnjava/WEB-INF/lib/rhn.jar $RPM_BUILD_ROOT/%{_prefix}/share/rhn/lib
install -m 644 build/classes/log4j.properties $RPM_BUILD_ROOT/%{_prefix}/share/rhn/classes/log4j.properties
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
%attr(755, root, root) %{_sysconfdir}/init.d/taskomatic
%attr(755, root, root) %{_bindir}/taskomaticd

%files config
%defattr(644, root, root)
%config(noreplace) %{_sysconfdir}/rhn/default/rhn_hibernate.conf
%config(noreplace) %{_sysconfdir}/rhn/default/rhn_taskomatic_daemon.conf
%config(noreplace) %{_sysconfdir}/rhn/default/rhn_taskomatic.conf
%config(noreplace) %{_sysconfdir}/rhn/default/rhn_org_quartz.conf

%files lib
%attr(644, root, root) %{_usr}/share/rhn/classes/log4j.properties
%attr(644, root, root) %{_usr}/share/rhn/lib/rhn.jar

%changelog
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
