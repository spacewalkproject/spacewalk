#
# spec file for package simple-xml
#
# Copyright (c) 2012 SUSE LLC
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

%define third_party_jars bea-stax-api xpp3

Name:           simple-xml
Summary:        An XML serialization framework for Java
Version:        2.6.7
Release:        7%{?dist}
%if 0%{?suse_version}
License:        Apache-2.0
%else
License:        ASL 2.0
%endif
Url:            https://simple.sourceforge.net
Source0:        https://downloads.sourceforge.net/simple/%{name}-%{version}.zip
BuildRequires:  ant
%if 0%{?suse_version}
BuildRequires:  bea-stax
%else
BuildRequires:  bea-stax-api
%endif
BuildRequires:  java-1.8.0-openjdk-devel
%if 0%{?fedora} >= 20 || 0%{?rhel} >= 7
BuildRequires: javapackages-tools
%else
BuildRequires:  jpackage-utils >= 1.6
%endif
BuildRequires:  xpp3
BuildArch:      noarch
Provides:       java(org.simpleframework:simple-xml) == 2.6.3

%description
Simple is a high performance XML serialization and configuration framework for
Java. Its goal is to provide an XML framework that enables rapid development
of XML configuration and communication systems.

%package        javadoc
%if 0%{?suse_version}
License:        Apache-2.0
%else
License:        ASL 2.0
%endif
Summary:        Javadocs for Simple XML Serialization Framework

%description    javadoc
Simple is a high performance XML serialization and configuration framework for
Java. Its goal is to provide an XML framework that enables rapid development 
of XML configuration and communication systems.

%prep
%setup -q
rm lib/*.jar
build-jar-repository -p lib/ %third_party_jars

%build
ant

%install
#jars
install -d -m 0755 $RPM_BUILD_ROOT%{_javadir}
install -m 644 jar/simple-xml-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
(cd $RPM_BUILD_ROOT%{_javadir} && for jar in *-%{version}*; do ln -sf ${jar} `echo $jar| sed "s|-%{version}||g"`; done)
#javadoc
install -d -m 755 $RPM_BUILD_ROOT%{_javadocdir}/%{name}-%{version}
ln -s %{name}-%{version} $RPM_BUILD_ROOT%{_javadocdir}/%{name}

%clean

%files
%{_javadir}/*.jar

%files javadoc
%doc %{_javadocdir}/%{name}-%{version}
%doc %{_javadocdir}/%{name}

%changelog
* Fri Feb 21 2020 Stefan Bluhm <stefan.bluhm@clacee.eu> 2.6.7-7
- Updated source URLs to https

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.6.7-6
- removed %%%%defattr from specfile
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 2.6.7-5
- recompile all packages with the same (latest) version of java

* Wed May 06 2015 Tomas Lestach <tlestach@redhat.com> 2.6.7-4
- Copyright texts updated to SUSE LLC

* Tue Jun 24 2014 Michael Mraka <michael.mraka@redhat.com> 2.6.7-3
- updated deps on RHEL7

* Tue Jan 07 2014 Tomas Lestach <tlestach@redhat.com> 2.6.7-2
- add tito.props to simple-xml directory
- jpackage-utils were replaced with javapackages-tools in fc20

* Mon Oct 08 2012 Jan Pazdziora 2.6.7-1
- Updating simple-xml to latest version (2.6.7).

* Thu May 17 2012 Miroslav Suchy <msuchy@redhat.com> 2.6.3-1
- initial release for Fedora
