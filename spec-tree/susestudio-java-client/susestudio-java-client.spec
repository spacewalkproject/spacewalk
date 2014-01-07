#
# spec file for package susestudio-java-client
#
# Copyright (c) 2012 SUSE LINUX Products GmbH, Nuremberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

%define third_party_jars simple-xml

Name:           susestudio-java-client
Summary:        Java client library for SUSE Studio
Version:        0.1.2
Release:        2%{?dist}
License:        MIT
Group:          Development/Libraries/Java
Url:            https://github.com/susestudio/susestudio-lib-java
Source0:        %{name}-%{version}.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  ant
BuildRequires:  java-devel
%if 0%{?fedora} >= 20
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
%setup
rm lib/*.jar
build-jar-repository -p lib/ %third_party_jars

%build
ant -Dant.build.javac.source=1.5 -Dant.build.javac.target=1.5

%install
install -d -m 0755 $RPM_BUILD_ROOT%{_javadir}
install -m 644 dist/%{name}-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
(cd $RPM_BUILD_ROOT%{_javadir} && for jar in *-%{version}*; do ln -sf ${jar} `echo $jar| sed "s|-%{version}||g"`; done)

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0644,root,root,0755)
%{_javadir}/*.jar

%changelog
* Tue Jan 07 2014 Tomas Lestach <tlestach@redhat.com> 0.1.2-2
- jpackage-utils were replaced with javapackages-tools in fc20

* Sat Jan 19 2013 Michael Mraka <michael.mraka@redhat.com> 0.1.2-1
- rebuild susestudio-java-client from git


