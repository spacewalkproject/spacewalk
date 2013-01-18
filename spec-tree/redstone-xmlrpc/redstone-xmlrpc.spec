%define third_party_jars servletapi5
Summary: An xmlrpc library
Name: redstone-xmlrpc
Version: 1.1_20071120 
Release: 9%{?dist}
License: LGPL
Group: Development/Library
URL: http://xmlrpc.sourceforge.net
Source0: %{name}-%{version}.tar.gz
Patch0: build-classpath.patch
Patch1: fault_serialization.patch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildRequires: jpackage-utils >= 0:1.5
BuildRequires: servletapi5
BuildRequires: ant
BuildRequires: java-devel >= 1.6.0
BuildArch: noarch
Requires: servletapi5
Obsoletes: marquee-xmlrpc

%description 
a simple xmlrpc library for java

%prep
%setup -n xmlrpc
%patch0 -p1
%patch1 -p0
rm lib/javax.servlet.jar
build-jar-repository -p lib/ %third_party_jars

%build
ant jars

%install
rm -rf $RPM_BUILD_ROOT

install -d -m 0755 $RPM_BUILD_ROOT%{_javadir}
install -m 644 build/lib/xmlrpc-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
install -m 644 build/lib/xmlrpc-client-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-client-%{version}.jar
(cd $RPM_BUILD_ROOT%{_javadir} && for jar in *-%{version}*; do ln -sf ${jar} `echo $jar| sed  "s|-%{version}||g"`; done)
install -d -m 755 $RPM_BUILD_ROOT%{_docdir}/%{name}-%{version}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0644,root,root,0755)
%{_javadir}

%changelog
* Fri Jan 18 2013 Michael Mraka <michael.mraka@redhat.com> 1.1_20071120-9
- rebuild redstone-xmlrpc from git

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
