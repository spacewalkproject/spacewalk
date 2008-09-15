# Copyright (c) 2000-2005, JPackage Project
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the
#    distribution.
# 3. Neither the name of the JPackage Project nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
%define section free

Summary:        Dependency manager
Name:           ivy
Version:        1.4.1
Release:        1
Epoch:          0
License:        BSD
URL:            http://www.jayasoft.org/ivy
Group:          Development/Libraries/Java
Vendor:         JPackage Project
Distribution:   JPackage
Source0:        ivy-1.4.1-src.zip
Source1:        ivy-buildlist.tar.gz
Patch0:         ivy-fixtestForJDK6.patch

BuildRequires:  jpackage-utils >= 0:1.6
BuildRequires:  ant >= 0:1.6
BuildRequires:  ant-junit
BuildRequires:  oro
BuildRequires:  jakarta-commons-codec
BuildRequires:  jakarta-commons-httpclient >= 1:3.0
BuildRequires:  jakarta-commons-logging
BuildRequires:  jakarta-commons-cli
Requires:  oro
Requires:  jakarta-commons-codec
Requires:  jakarta-commons-httpclient >= 1:3.0
Requires:  jakarta-commons-logging
Requires:  jakarta-commons-cli

BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-buildroot

%description
Ivy is a free java based dependency manager, with powerful features such 
as transitive dependencies, ant integration, maven repository compatibility,
continuous integration, html reports and many more.

%package javadoc
Summary:        Javadoc for %{name}
Group:          Development/Documentation

%description javadoc
%{summary}.

%package manual
Summary:        Documents for %{name}
Group:          Development/Documentation

%description manual
%{summary}.

%prep
%setup -q -n %{name}-%{version}
mkdir lib
pushd lib
rm -f *.jar
ln -sf $(build-classpath junit) .
ln -sf $(build-classpath oro) .
ln -sf $(build-classpath commons-codec) .
ln -sf $(build-classpath commons-httpclient) .
ln -sf $(build-classpath commons-logging) .
ln -sf $(build-classpath commons-cli) .
popd
pushd test
gzip -dc %{SOURCE1} | tar xf -
popd

%patch0 -b .sav

%build
export OPT_JAR_LIST="ant/ant-junit junit"
# javadoc not currently working
#ant test javadoc
ant test 

%install
rm -rf $RPM_BUILD_ROOT

# jars
mkdir -p $RPM_BUILD_ROOT%{_javadir}
cp -p build/artifact/%{name}.jar \
  $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
(cd $RPM_BUILD_ROOT%{_javadir} && for jar in *-%{version}.jar; do ln -sf ${jar} `echo $jar| sed "s|-%{version}||g"`; done)
mkdir -p $RPM_BUILD_ROOT%{_datadir}/%{name}-%{version}
cp LICENSE.txt $RPM_BUILD_ROOT%{_datadir}/%{name}-%{version}

# javadoc
#mkdir -p $RPM_BUILD_ROOT%{_javadocdir}/%{name}-%{version}
#cp -pr build/javadoc/* $RPM_BUILD_ROOT%{_javadocdir}/%{name}-%{version}
#ln -s %{name}-%{version} $RPM_BUILD_ROOT%{_javadocdir}/%{name} # ghost symlink

# manual
mkdir -p $RPM_BUILD_ROOT%{_docdir}/%{name}-%{version}
rm -rf doc/build/api
cp -pr doc/* $RPM_BUILD_ROOT%{_docdir}/%{name}-%{version}


%clean
rm -rf $RPM_BUILD_ROOT

#%post javadoc
#rm -f %{_javadocdir}/%{name}
#ln -s %{name}-%{version} %{_javadocdir}/%{name}

#%postun javadoc
#if [ "$1" = "0" ]; then
#  rm -f %{_javadocdir}/%{name}
#fi

%files
%defattr(0644,root,root,0755)
%doc %{_datadir}/%{name}-%{version}
%{_javadir}/*

%files javadoc
#%defattr(0644,root,root,0755)
#%doc %{_javadocdir}/%{name}-%{version}
#%ghost %{_javadocdir}/%{name}

%files manual
%defattr(0644,root,root,0755)
%doc %{_docdir}

# -----------------------------------------------------------------------------

%changelog
* Fri Jul 11 2008 John Matthews <jmatthew@redhat.com> - 0:1.4.1-1
- Upgrade to 1.4.1
- AddPatch: XmlModuleDescriptorWriterTest not working with Java 6 (IVY-374)
https://issues.apache.org/jira/browse/IVY-374
- Broke javadoc generation

* Tue Apr 05 2006 Ralph Apel <r.apel at r-apel.de> - 0:1.3.1-1jpp
- Upgrade to 1.3.1 final and adapt to j-c-httpclient = 3.0 final

* Wed Feb 22 2006 Ralph Apel <r.apel at r-apel.de> - 0:1.3-0.rc2.2jpp
- Patch to build/run with java-1.4.2-bea (doesn't tolerate double slash in path)

* Fri Feb 17 2006 Ralph Apel <r.apel at r-apel.de> - 0:1.3-0.rc2.1jpp
- First JPackage release

