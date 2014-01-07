#
# spec file for package simple-xml
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

%define third_party_jars bea-stax-api xpp3

Name:           simple-xml
Summary:        An XML serialization framework for Java
Version:        2.6.7
Release:        2%{?dist}
%if 0%{?suse_version}
License:        Apache-2.0
Group:          Development/Libraries/Java
%else
License:        ASL 2.0
Group:          Development/Libraries
%endif
Url:            http://simple.sourceforge.net
Source0:        http://downloads.sourceforge.net/simple/%{name}-%{version}.zip
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  ant
%if 0%{?suse_version}
BuildRequires:  bea-stax
%else
BuildRequires:  bea-stax-api
%endif
BuildRequires:  java-devel
%if 0%{?fedora} >= 20
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
Group:          Development/Languages/Java
%else
License:        ASL 2.0
Group:          Documentation
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
ant -Dant.build.javac.source=1.5 -Dant.build.javac.target=1.5

%install
#jars
install -d -m 0755 $RPM_BUILD_ROOT%{_javadir}
install -m 644 jar/simple-xml-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
(cd $RPM_BUILD_ROOT%{_javadir} && for jar in *-%{version}*; do ln -sf ${jar} `echo $jar| sed "s|-%{version}||g"`; done)
#javadoc
install -d -m 755 $RPM_BUILD_ROOT%{_javadocdir}/%{name}-%{version}
ln -s %{name}-%{version} $RPM_BUILD_ROOT%{_javadocdir}/%{name}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0644,root,root,0755)
%{_javadir}/*.jar

%files javadoc
%defattr(0644,root,root,0755)
%doc %{_javadocdir}/%{name}-%{version}
%doc %{_javadocdir}/%{name}

%changelog
* Tue Jan 07 2014 Tomas Lestach <tlestach@redhat.com> 2.6.7-2
- add tito.props to simple-xml directory
- jpackage-utils were replaced with javapackages-tools in fc20

* Mon Oct 08 2012 Jan Pazdziora 2.6.7-1
- Updating simple-xml to latest version (2.6.7).

* Thu May 17 2012 Miroslav Suchy <msuchy@redhat.com> 2.6.3-1
- initial release for Fedora
