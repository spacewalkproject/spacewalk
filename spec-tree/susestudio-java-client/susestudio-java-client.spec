#
# spec file for package susestudio-java-client
#
# Copyright (c) 2014 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

%define third_party_jars simple-xml

Name:           susestudio-java-client
Summary:        Java client library for SUSE Studio
Version:        0.1.4
Release:        6%{?dist}
License:        MIT
Url:            https://github.com/susestudio/susestudio-lib-java
Source0:        https://github.com/susestudio/susestudio-lib-java/archive/v%{version}.tar.gz#/susestudio-lib-java-%{version}.tar.gz
BuildRequires:  ant
BuildRequires:  java-1.8.0-openjdk-devel
%if 0%{?fedora} >= 20 || 0%{?rhel} >=7
BuildRequires: javapackages-tools
%else
BuildRequires:  jpackage-utils >= 1.6
%endif
BuildRequires:  simple-xml
BuildArch:      noarch
Provides:       java(com.suse.studio:susestudio-java-client) == %{version}

%description
A Java client library for accessing SUSE Studio via its REST API.

%prep
%setup -n susestudio-lib-java-%{version}
rm lib/*.jar
build-jar-repository -p lib/ %third_party_jars

%build
ant -Dant.build.javac.source=1.5 -Dant.build.javac.target=1.5 dist-jar

%install
install -d -m 0755 $RPM_BUILD_ROOT%{_javadir}
install -m 644 dist/%{name}-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
(cd $RPM_BUILD_ROOT%{_javadir} && for jar in *-%{version}*; do ln -sf ${jar} `echo $jar| sed "s|-%{version}||g"`; done)

%clean

%files
%{_javadir}/*.jar

%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 0.1.4-6
- removed %%%%defattr from specfile
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 0.1.4-5
- recompile all packages with the same (latest) version of java

* Wed May 06 2015 Tomas Lestach <tlestach@redhat.com> 0.1.4-4
- Copyright texts updated to SUSE LLC

* Wed Jun 25 2014 Michael Mraka <michael.mraka@redhat.com> 0.1.4-3
- fixed deps on RHEL7

* Wed Feb 05 2014 Michael Mraka <michael.mraka@redhat.com> 0.1.4-2
- source file is named differently

* Wed Feb 05 2014 Michael Mraka <michael.mraka@redhat.com> 0.1.4-1
- Update susestudio-java-client spec file for building version 0.1.4

* Tue Jan 07 2014 Tomas Lestach <tlestach@redhat.com> 0.1.2-2
- jpackage-utils were replaced with javapackages-tools in fc20

* Sat Jan 19 2013 Michael Mraka <michael.mraka@redhat.com> 0.1.2-1
- rebuild susestudio-java-client from git


