Name:		simple-core		
Version:	3.1.3
Release:	11%{?dist}
Summary:	Embeddable Java HTTP engine capable of handling large loads
License:	GNU
URL:	 	http://www.simpleframework.org	
Source0:	https://sourceforge.net/projects/simpleweb/files/simpleweb/%{version}/simple-core-%{version}.tar.gz	
BuildArch: noarch

BuildRequires:  ant
%if 0%{?fedora} || 0%{?rhel} >= 7
BuildRequires: javapackages-tools
Requires:      kxml
%endif
BuildRequires: java-1.8.0-openjdk-devel
Requires:      java-headless >= 1:1.8.0

%description
The core API consists of a simple.http package and various sub-packages, it also contains various utilities. This is all that is required to develop HTTP services. 

%package javadoc
Summary:       Javadoc for %{name}

%description javadoc
Javadoc for %{name}.

%prep
%setup -q

%build
export JAVA_HOME=%{java_home}
%ant

%install
install -d -m 755 $RPM_BUILD_ROOT%{_javadir}

# jars and supporting kxml lib
install -m 644 jar/%{name}-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
%if 0%{?rhel} && 0%{?rhel} < 7
install -m 644 lib/kxml.jar $RPM_BUILD_ROOT%{_javadir}/kxml.jar
%endif

(cd $RPM_BUILD_ROOT%{_javadir} && for jar in *-%{version}*; do ln -sf ${jar} `echo $jar| sed  "s|-%{version}||g"`; done)

#javadoc
install -d -m 755 $RPM_BUILD_ROOT%{_javadocdir}/%{name}-%{version}
cp -pr doc/* $RPM_BUILD_ROOT%{_javadocdir}/%{name}-%{version}

%clean

%files
%{_javadir}/%{name}-%{version}.jar
%{_javadir}/%{name}.jar
%if 0%{?rhel} && 0%{?rhel} < 7
%{_javadir}/kxml.jar
%endif

%doc
%{_javadocdir}/*

%changelog
* Tue Mar 17 2020 Michael Mraka <michael.mraka@redhat.com> 3.1.3-11
- Updated simple-core.spec Source URL

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 3.1.3-10
- removed %%%%defattr from specfile
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 3.1.3-9
- recompile all packages with the same (latest) version of java

* Wed Mar 15 2017 Michael Mraka <michael.mraka@redhat.com> 3.1.3-8
- don't bundle kxml on Fedora and RHEL7

* Mon Nov 30 2015 Tomas Lestach <tlestach@redhat.com> 3.1.3-7
- java-devel is required in simple-core fc23 buildroot

* Fri Oct 17 2014 Tomas Lestach <tlestach@redhat.com> 3.1.3-6
- change simple-core package to be noarch

* Tue Jun 24 2014 Michael Mraka <michael.mraka@redhat.com> 3.1.3-5
- update deps for RHEL7

* Tue Jan 07 2014 Tomas Lestach <tlestach@redhat.com> 3.1.3-4
- let simple-core buildrequire javapackages-tools on fc20
- let simple-core buildrequire java

* Fri Jan 18 2013 Michael Mraka <michael.mraka@redhat.com> 3.1.3-3
- rebuild simple-core from git

* Thu Jul 29 2010 Shannon Hughes <shughes@redhat.com> 3.1.3-2
- new package built with tito

* Tue Jul 27 2010 Shannon Hughes <shughes@redhat.com> 3.1.3-1
- Initial package build
