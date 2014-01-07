# Copyright (c) 2000-2006, JPackage Project
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

%define gcj_support %{?_with_gcj_support:1}%{!?_with_gcj_support:%{?_without_gcj_support:0}%{!?_without_gcj_support:%{?_gcj_support:%{_gcj_support}}%{!?_gcj_support:0}}}

%if 0%{?rhel} >= 5
%define gcj_support 1
%endif

%define build_subpackages 0
%define section	free

Name:		tanukiwrapper
Version:	3.2.3
Release:	12%{?dist}
Summary:	Java Service Wrapper
Epoch:		0
License:	BSD
URL:		http://wrapper.tanukisoftware.org/
Source0:	http://download.sourceforge.net/wrapper/wrapper_3.2.3_src.tar.gz
Patch1:		%{name}-build.patch
Patch2:		%{name}-crosslink.patch
Patch3:		%{name}-makefile-linux-x86-32.patch
#Add Makefiles so package builds for all FC architectures.
Patch4:		%{name}-Makefile-s390-s390x-ppc.patch
Patch5:         %{name}-Makefile-sparc-sparc64.patch
# The following patch is only needed for GCJ.
Patch6:		%{name}-nosun-jvm-64.patch
Patch7:     %{name}-compilewithfpic.patch
Group:		Development/Java
%if 0%{?fedora} >= 20
BuildRequires: javapackages-tools
Requires:      javapackages-tools
%else
BuildRequires:	ant-nodeps >= 0:1.6.1
BuildRequires:  jpackage-utils >= 0:1.6
Requires:       jpackage-utils >= 0:1.6
%endif
BuildRequires:	glibc-devel
BuildRequires:	ant >= 0:1.6.1
BuildRequires:	ant-junit
BuildRequires:	xerces-j2
BuildRequires:	xml-commons-apis
BuildRequires:	%{__perl}
BuildRequires:	java-javadoc
Obsoletes:	%{name}-demo < 0:3.1.2-2jpp
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%if %{gcj_support}
BuildRequires:		java-gcj-compat-devel
Requires(post):		java-gcj-compat
Requires(postun):	java-gcj-compat
%endif

%description
The Java Service Wrapper is an application which has 
evolved out of a desire to solve a number of problems 
common to many Java applications: 
- Run as a Windows Service or Unix Daemon
- Application Reliability
- Standard, Out of the Box Scripting
- On Demand Restarts
- Flexible Configuration
- Ease Application installations
- Logging

%if %{build_subpackages}
%package javadoc
Summary:        Javadoc for %{name}
Group:          Development/Documentation
# For /bin/rm and /bin/ln
Requires(post): coreutils
Requires(postun): coreutils

%description javadoc
%{summary}.

%package manual
Summary:        Documents for %{name}
Group:          Development/Documentation

%description manual
%{summary}.
%endif

%prep
%setup -q -n wrapper_%{version}_src
%patch1
%patch2
%patch3
%patch4
%patch5 -p1
# The following patch is only needed for GCJ.
%if %{gcj_support}
%patch6
%endif
%patch7
find . -name "*.jar" -exec %__rm -f {} \;
%__perl -p -i -e 's|-O3|%optflags|' src/c/Makefile*

%build
export CLASSPATH=$(build-classpath ant junit xerces-j2 xml-commons-apis)
%ifarch x86_64 ia64 ppc64 sparc64 s390x
bits=64
%else
bits=32
%endif
%if %{build_subpackages}
%ant -Dbuild.sysclasspath=first -Djdk.api=%{_javadocdir}/java -Dbits=$bits \
  main jdoc
%else
%ant -Dbuild.sysclasspath=first -Djdk.api=%{_javadocdir}/java -Dbits=$bits \
  main
%endif

%install
%__rm -rf %{buildroot}

# jar
%__mkdir_p %{buildroot}%{_javadir}
%__install -p -m 0644 lib/wrapper.jar %{buildroot}%{_javadir}/%{name}-%{version}.jar
(cd %{buildroot}%{_javadir} && for jar in *-%{version}*; do %{__ln_s}f ${jar} `echo $jar| sed  "s|-%{version}||g"`; done)

# jni
%__install -d -m 755 %{buildroot}%{_libdir}
%__install -p -m 755 lib/libwrapper.so %{buildroot}%{_libdir}

# commands
%__install -d -m 755 %{buildroot}%{_sbindir}
%__install -p -m 755 bin/wrapper %{buildroot}%{_sbindir}/%{name}

%if %{build_subpackages}
# javadoc
%__install -d -m 755 %{buildroot}%{_javadocdir}/%{name}-%{version}
%__cp -a jdoc/* %{buildroot}%{_javadocdir}/%{name}-%{version}
%__ln_s %{name}-%{version} %{buildroot}%{_javadocdir}/%{name} # ghost symlink
%endif

%if %{gcj_support}
%{_bindir}/aot-compile-rpm
%endif

%clean
%__rm -rf %{buildroot}

%if %{build_subpackages}
%post javadoc
%__rm -f %{_javadocdir}/%{name}
%{__ln_s}f %{name}-%{version} %{_javadocdir}/%{name}

%postun javadoc
if [ "$1" = "0" ]; then
  %__rm -f %{_javadocdir}/%{name}
fi
%endif

%if %{gcj_support}
%post
if [ -x %{_bindir}/rebuild-gcj-db ]
then
  %{_bindir}/rebuild-gcj-db
fi
%endif

%if %{gcj_support}
%postun
if [ -x %{_bindir}/rebuild-gcj-db ]
then
  %{_bindir}/rebuild-gcj-db
fi
%endif

%files
%defattr(-,root,root,-)
%doc doc/license.txt
%{_sbindir}/%{name}
%{_libdir}/libwrapper.so
%{_javadir}/%{name}*.jar

%if %{gcj_support}
%attr(-,root,root) %{_libdir}/gcj/%{name}/tanukiwrapper-%{version}.jar.*
%endif

%if %{build_subpackages}
%files javadoc
%defattr(0644,root,root,0755)
%{_javadocdir}/%{name}-%{version}
%ghost %doc %{_javadocdir}/%{name}

%files manual
%defattr(0644,root,root,0755)
%doc doc/*
%endif

%changelog
* Tue Jan 07 2014 Tomas Lestach <tlestach@redhat.com> 3.2.3-12
- jpackage-utils were replaced with javapackages-tools in fc20
- there's not ant-nodeps on fc20

* Wed Mar 20 2013 Tomas Lestach <tlestach@redhat.com> 3.2.3-11
- Revert "set fuzz=1 for tanukiwrapper patch application"

* Tue Mar 19 2013 Tomas Lestach <tlestach@redhat.com> 3.2.3-10
- set fuzz=1 for tanukiwrapper patch application

* Tue Mar 19 2013 Tomas Lestach <tlestach@redhat.com> 3.2.3-9
- remove unused sample files from tanukiwrapper
- disable building tanukiwrapper subpackages
- explicitelly enable gcj_support on RHEL

* Fri Jan 18 2013 Michael Mraka <michael.mraka@redhat.com> 3.2.3-8
- fixed typo in spec

* Fri Jan 18 2013 Michael Mraka <michael.mraka@redhat.com> 3.2.3-7
- use gcj_support on RHEL

* Fri Jan 18 2013 Michael Mraka <michael.mraka@redhat.com> 3.2.3-6
- rebuild package via standard process from git

* Sun Oct 25 2009 Dennis Gilmore <dennis@ausil.us> - 0:3.2.3-5
- add patch with sparc support

* Fri Jul 31 2009 Deepak Bhole <dbhole@redhat.com> - 0:3.2.3-4.4
- Fix bug #480189 Compile files with -fPIC

* Sun Jul 26 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0:3.2.3-4.3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Wed Feb 25 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0:3.2.3-3.3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Wed Sep 24 2008 Deepak Bhole <dbhole@redhat.com> 3.2.3-2.3
- Update nosun-jvm-64.patch to remove fuzz

* Thu Jul 10 2008 Tom "spot" Callaway <tcallawa@redhat.com> - 0:3.2.3-2.2
- drop repotag

* Tue Feb 19 2008 Fedora Release Engineering <rel-eng@fedoraproject.org> - 0:3.2.3-2jpp.1
- Autorebuild for GCC 4.3

* Sat Aug 11 2007 Vivek Lakshmanan <vivekl at redhat.com> - 0:3.2.3-1jpp.1
- Update to latest from JPackage
- Fedora-ize the spec file

* Tue Oct 17 2006 Ville Skyttä <scop at jpackage.org> - 0:3.2.3-1jpp
- 3.2.3.
- Drop unneeded xml-commons-apis and xerces-j2 dependencies.
- Fix gcj lib name.

* Fri Oct 13 2006 Ville Skyttä <scop at jpackage.org> - 0:3.2.2-1jpp
- 3.2.2.

* Fri Aug 04 2006 Vivek Lakshmanan <vivekl@redhat.com> - 0:3.2.1-2jpp
- Add conditional AOT compilation with GCJ.
- Add Requires(X) where appropriate.
- Add patch to add -lm in x86-32 Makefile.
- Conditionally apply patch to avoid use of obscure property 
  not supported on GCJ.
- Add missing makefiles for architectures pertinent to FC.

* Tue Jul 11 2006 Ville Skyttä <scop at jpackage.org> - 0:3.2.1-1jpp
- 3.2.1.

* Mon May 29 2006 Ralph Apel <r.apel at r-apel.de> - 0:3.2.0-2jpp
- Bring to JPP-1.7

* Tue May  9 2006 Ville Skyttä <scop at jpackage.org> - 0:3.2.0-1jpp
- 3.2.0.

* Fri Apr 28 2006 Fernando Nasser <fnasser@redhat.com> - 0:3.1.2-5jpp
- First JPP 1.7 build

* Mon Jul 18 2005 Ville Skyttä <scop at jpackage.org> - 0:3.1.2-4jpp
- BuildRequires ant-junit and java-javadoc.
- Fix description.

* Mon Jul  4 2005 Ville Skyttä <scop at jpackage.org> - 0:3.1.2-3jpp
- Fix bogus versioned jpackage-utils build dependency.

* Tue Jun 28 2005 Ville Skyttä <scop at jpackage.org> - 0:3.1.2-2jpp
- Fix install locations and build dependencies.
- Drop -demo subpackage and test jars, include samples in main package's docs.
- Fix build with newer Java/Ant and ant-nodeps not built with Sun's JDK.
- Crosslink with local JDK javadocs.

* Wed Apr 14 2005 David Walluck <david@jpackage.org> 0:3.1.2-1jpp
- 3.1.2
- fix ant dependencies
- change %%section to free
- macros

* Tue Mar 29 2005 David Walluck <david@jpackage.org> 0:3.1.1-5jpp
- remove BuildArch

* Sat Nov 27 2004 Ville Skyttä <scop at jpackage.org> - 0:3.1.1-4jpp
- Fix libwrapper.so permissions.

* Sat Nov 27 2004 Ville Skyttä <scop at jpackage.org> - 0:3.1.1-3jpp
- Fix build when no $JAVA_HOME is set.
- Honor $RPM_OPT_FLAGS.

* Fri Sep 03 2004 Fernando Nasser <fnasser@redhat.com> 0:3.1.1-2jpp
- Rebuilt with Ant 1.6.2

* Fri Jul 30 2004 Ralph Apel <r.apel at r-apel.de> 0:3.1.1-1jpp
- First JPackage release
