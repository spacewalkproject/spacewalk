Summary: An xmlrpc library
Name: redstone-xmlrpc
Version: 1.1_20071120 
Release: 23%{?dist}
License: LGPL
URL: http://xmlrpc.sourceforge.net
Source0: https://github.com/spacewalkproject/spacewalk/releases/download/%{name}-%{version}-21/%{name}-%{version}.tar.gz
Patch0: build-classpath.patch
Patch1: fault_serialization.patch
Patch2: escaping_string_serialization.path
Patch3: xxe.patch
Patch4: xxe2.patch
%if 0%{?fedora} || 0%{?rhel} >=7
BuildRequires: javapackages-tools
BuildRequires: jboss-servlet-2.5-api
Requires: jboss-servlet-2.5-api
%define third_party_jars jboss-servlet-2.5-api
%else
BuildRequires: jpackage-utils >= 0:1.5
BuildRequires: tomcat6-servlet-2.5-api
Requires: tomcat6-servlet-2.5-api
%define third_party_jars tomcat6-servlet-2.5-api
%endif
BuildRequires: ant
BuildRequires: java-1.8.0-openjdk-devel
BuildArch: noarch
Obsoletes: marquee-xmlrpc

%description 
a simple xmlrpc library for java

%prep
%setup -n xmlrpc
%patch0 -p1
%patch1 -p0
%patch2 -p0
%patch3 -p0
%patch4 -p0
rm lib/javax.servlet.jar
build-jar-repository -p lib/ %third_party_jars

%build
ant jars

%install

install -d -m 0755 $RPM_BUILD_ROOT%{_javadir}
install -m 644 build/lib/xmlrpc-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
install -m 644 build/lib/xmlrpc-client-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-client-%{version}.jar
(cd $RPM_BUILD_ROOT%{_javadir} && for jar in *-%{version}*; do ln -sf ${jar} `echo $jar| sed  "s|-%{version}||g"`; done)
install -d -m 755 $RPM_BUILD_ROOT%{_docdir}/%{name}-%{version}

%clean

%files
%{_javadir}

%changelog
* Tue Mar 17 2020 Michael Mraka <michael.mraka@redhat.com> 1.1_20071120-23
- fixed line separator

* Tue Mar 17 2020 Michael Mraka <michael.mraka@redhat.com> 1.1_20071120-22
- uploaded source tar to github

* Tue Feb 11 2020 Michael Mraka <michael.mraka@redhat.com> 1.1_20071120-21
- 1791164 - disable external entity parsing

* Wed Aug 21 2019 Michael Mraka <michael.mraka@redhat.com> 1.1_20071120-20
- 1555429 - do not download external entities

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 1.1_20071120-19
- removed %%%%defattr from specfile
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 1.1_20071120-18
- recompile all packages with the same (latest) version of java

* Mon Mar 13 2017 Michael Mraka <michael.mraka@redhat.com> 1.1_20071120-17
- use standard jboss-servlet-2.5-api on Fedora

* Tue Mar 01 2016 Gennadii Altukhov <galt@redhat.com> 1.1_20071120-16
- 1313425 Adding patch for redstone XMLRPC to escape '>'

* Mon Jun 23 2014 Michael Mraka <michael.mraka@redhat.com> 1.1_20071120-15
- use javapackages-tools instead of jpackage-utils on RHEL7

* Tue Jan 07 2014 Tomas Lestach <tlestach@redhat.com> 1.1_20071120-14
- jpackage-utils were replaced with javapackages-tools in fc20

* Thu Mar 14 2013 Michael Mraka <michael.mraka@redhat.com> 1.1_20071120-13
- merging thirdparty repo changes

* Wed Aug 11 2010 Shannon Hughes <shughes@redhat.com> 1.1_20071120-12
- fix build jar for rhel6 (shughes@redhat.com)

* Wed Aug 11 2010 Shannon Hughes <shughes@redhat.com> 1.1_20071120-11
- reference the tomcat6 api rpm for rhel6 (shughes@redhat.com)

* Tue Aug 10 2010 Shannon Hughes <shughes@redhat.com> 1.1_20071120-10
- updated redstone-xmlrpc for rhel6 (shughes@redhat.com)

* Tue Aug 10 2010 Shannon Hughes <shughes@redhat.com>
- update java-devel epoch

* Mon May 18 2009 Dennis Gilmore <dgilmore@redhat.com> 1.1_20071120-8
- rebuild in new git tree

* Wed Jan 28 2009 Dennis Gilmore <dennis@ausil.us> 1.1_20071120-7
- spec cleanups
- BR java-devel >= 1.6.0

* Tue Nov 20 2007 Jesus M. Rodriguez <jesusr@redhat.com>
- rebasing to latest svn version
- faultcode patch was accepted by maintainer
- patching fault exception serialization

* Mon Sep 17 2007 Jesus M. Rodriguez <jesusr@redhat.com>
- Initial build.
