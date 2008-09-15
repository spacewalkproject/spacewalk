%{!?__redhat_release:%define __redhat_release UNKNOWN}
%define appdir          %{_localstatedir}/lib/tomcat5/webapps
%define jardir          %{_localstatedir}/lib/tomcat5/webapps/rhn/WEB-INF/lib
%define jars antlr asm bcel bouncycastle/bcprov bouncycastle/bcpg c3p0 cglib commons-beanutils commons-cli commons-codec commons-configuration commons-digester commons-discovery commons-el commons-fileupload commons-lang commons-logging commons-validator concurrent dom4j hibernate3 jaf jasper5-compiler jasper5-runtime javamail jcommon jdom jfreechart jspapi jpam log4j redstone-xmlrpc redstone-xmlrpc-client ojdbc14 oro oscache sitemesh struts taglibs-core taglibs-standard wsdl4j xalan-j2 xerces-j2 xml-commons-apis

Name: rhn-java-sat
Summary: RHN Java site packages
Group: Applications/Internet
License: GPLv2
Source1: version
Version: %(echo `awk '{ print $1 }' %{SOURCE1}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE1}`)%{?dist}
Source0:        %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-root
BuildArch: noarch

Summary: Java web application files for RHN
Group: Applications/Internet
Requires: bcel
Requires: bouncycastle-provider
Requires: c3p0
Requires: hibernate3 >= 0:3.2.4
Requires: java >= 0:1.5.0
Requires: java-devel >= 0:1.5.0
Requires: jakarta-commons-lang
Requires: jakarta-commons-codec
Requires: jakarta-commons-configuration
Requires: jakarta-commons-logging
Requires: jakarta-taglibs-standard
Requires: jasper5
Requires: jcommon
Requires: jfreechart
Requires: jpam
Requires: log4j
Requires: redstone-xmlrpc
Requires: oscache
Requires: rhn-oracle-jdbc >= 0:1.0-10
Requires: rhn-oracle-jdbc-tomcat5
Requires: servletapi5
Requires: struts >= 0:1.2.9
Requires: tomcat5
Requires: xalan-j2 >= 0:2.6.0
Requires: xerces-j2
Requires: sitemesh
Requires: rhn-java-config-sat
Requires: rhn-java-lib-sat
Requires: jpackage-utils >= 0:1.5
BuildRequires: ant
BuildRequires: ant-apache-regexp
BuildRequires: java-devel >= 1.5.0
BuildRequires: ant-contrib
BuildRequires: ant-junit
BuildRequires: ant-nodeps
BuildRequires: antlr >= 0:2.7.6
BuildRequires: ivy
BuildRequires: jpam
BuildRequires: tanukiwrapper

# Sadly I need these to symlink the jars properly.
BuildRequires: ant-jsch
BuildRequires: asm
BuildRequires: bouncycastle-provider
BuildRequires: c3p0
BuildRequires: concurrent
BuildRequires: cglib
BuildRequires: ehcache
BuildRequires: jakarta-commons-configuration
BuildRequires: dom4j
BuildRequires: hibernate3
BuildRequires: jakarta-commons-discovery
BuildRequires: jakarta-commons-el
BuildRequires: jakarta-commons-fileupload
BuildRequires: jakarta-commons-validator
BuildRequires: jakarta-taglibs-standard
BuildRequires: jasper5
BuildRequires: jcommon
BuildRequires: jdom
BuildRequires: jsch
BuildRequires: jfreechart >= 0:0.9.21
BuildRequires: redstone-xmlrpc
BuildRequires: rhn-oracle-jdbc >= 0:1.0-10
BuildRequires: oscache
BuildRequires: quartz
BuildRequires: struts
BuildRequires: sitemesh
BuildRequires: wsdl4j
Obsoletes: rhn-java
%description -n rhn-java-sat
This package contains the code for the Java version of the Red Hat
Network Web Site.

%package -n rhn-java-config-sat
Summary: Configuration files for RHN Java
Group: Applications/Internet
Obsoletes: rhn-java-config
%description -n rhn-java-config-sat
This package contains the configuration files for the RHN Java web
application and taskomatic process.

%package -n rhn-java-lib-sat
Summary: Jar files for RHN Java
Group: Applications/Internet
Obsoletes: rhn-java-lib
%description -n rhn-java-lib-sat
This package contains the jar files for the RHN Java web application
and taskomatic process.

%package -n taskomatic-sat
Summary: Java version of taskomatic
Group: Applications/Internet
Requires: bcel
Requires: bouncycastle-provider
Requires: c3p0
Requires: cglib
Requires: hibernate3 >= 0:3.2.4
Requires: java >= 0:1.5.0
Requires: java-devel >= 0:1.5.0
Requires: jakarta-commons-lang
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
Requires: rhn-oracle-jdbc >= 0:1.0-10
Requires: xalan-j2 >= 0:2.6.0
Requires: xerces-j2
Requires: tanukiwrapper
Requires: rhn-java-config-sat
Requires: rhn-java-lib-sat
Requires: concurrent
Requires: quartz
Obsoletes: taskomatic
%description -n taskomatic-sat
This package contains the Java version of taskomatic.

%prep
%setup -n %(echo %{main_source} | sed 's/\.tar\.gz//')

%install
ant -Dprefix=$RPM_BUILD_ROOT install
install -d -m 755 $RPM_BUILD_ROOT/%{_sysconfdir}/tomcat5/Catalina/localhost/
install -d -m 755 $RPM_BUILD_ROOT/etc/init.d
install -d -m 755 $RPM_BUILD_ROOT/usr/bin
install -d -m 755 $RPM_BUILD_ROOT/etc/rhn
install -d -m 755 $RPM_BUILD_ROOT/etc/rhn/default
install -d -m 755 $RPM_BUILD_ROOT/usr/share/rhn
install -d -m 755 $RPM_BUILD_ROOT/usr/share/rhn/lib
install -d -m 755 $RPM_BUILD_ROOT/usr/share/rhn/classes
install -m 755 conf/rhn.xml $RPM_BUILD_ROOT/%{_sysconfdir}/tomcat5/Catalina/localhost/rhn.xml
install -m 644 conf/default/rhn_hibernate.conf $RPM_BUILD_ROOT/etc/rhn/default/rhn_hibernate.conf
install -m 644 conf/default/rhn_taskomatic_daemon.conf $RPM_BUILD_ROOT/etc/rhn/default/rhn_taskomatic_daemon.conf
install -m 644 conf/default/rhn_taskomatic.conf $RPM_BUILD_ROOT/etc/rhn/default/rhn_taskomatic.conf
install -m 644 conf/default/rhn_org_quartz.conf $RPM_BUILD_ROOT/etc/rhn/default/rhn_org_quartz.conf
install -m 755 scripts/taskomatic $RPM_BUILD_ROOT/etc/init.d
install -m 644 build/webapp/rhnjava/WEB-INF/lib/rhn.jar $RPM_BUILD_ROOT/%{_usr}/share/rhn/lib
install -m 644 build/classes/log4j.properties $RPM_BUILD_ROOT/%{_usr}/share/rhn/classes/log4j.properties
ln -s -f /usr/sbin/tanukiwrapper $RPM_BUILD_ROOT/%{_usr}/bin/taskomaticd

%clean
rm -rf $RPM_BUILD_ROOT

#%post -n rhn-java-sat
#/usr/bin/build-jar-repository --preserve-naming -s %{jardir} %{jars}
#/bin/chown tomcat %{jardir}/*.jar
#/bin/chgrp tomcat %{jardir}/*.jar

%files -n rhn-java-sat
%defattr(644,tomcat,tomcat,775)
%dir %{appdir}
%{appdir}/*
%config(noreplace) %{_sysconfdir}/tomcat5/Catalina/localhost/rhn.xml

%files -n taskomatic-sat
%attr(755, root, root) %{_sysconfdir}/init.d/taskomatic
%attr(755, root, root) %{_usr}/bin/taskomaticd

%files -n rhn-java-config-sat
%defattr(644, root, root)
%config(noreplace) %{_sysconfdir}/rhn/default/rhn_hibernate.conf
%config(noreplace) %{_sysconfdir}/rhn/default/rhn_taskomatic_daemon.conf
%config(noreplace) %{_sysconfdir}/rhn/default/rhn_taskomatic.conf
%config(noreplace) %{_sysconfdir}/rhn/default/rhn_org_quartz.conf

%files -n rhn-java-lib-sat
%attr(644, root, root) %{_usr}/share/rhn/classes/log4j.properties
%attr(644, root, root) %{_usr}/share/rhn/lib/rhn.jar

%changelog
* Thu May 22 2008 Jan Pazdziora 5.2.0-5
- weaken hibernate3 version requirement

* Fri May 16 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-3
- fixed file ownership
- fixed optimizer settings for Oracle 10g

* Thu May 15 2008 Jan Pazdziora - 5.2.0-1
- spec updated for brew builds
