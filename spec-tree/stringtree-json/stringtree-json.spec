%define base_package stringtree
Summary: An json string library
Name: stringtree-json
Version: 2.0.9
Release: 14%{?dist}
License: LGPL
URL: http://stringtree.org/stringtree-json.html
Source0: https://sourceforge.net/projects/stringtree/files/%{base_package}/%{version}/%{base_package}-%{version}-src.zip
Patch0: stringtree-2.0.9-build-xml.patch
%if 0%{?fedora} >= 20 || 0%{?rhel} >= 7
BuildRequires: javapackages-tools
%else
BuildRequires: jpackage-utils >= 0:1.5
%endif
BuildRequires: ant
BuildRequires: java-1.8.0-openjdk-devel
BuildRequires: unzip
BuildArch: noarch
ExcludeArch: ia64

%description
a simple json reader/writer library for java

%prep
%setup -n %{base_package}
%patch0 -p1


%build
ant -f src/build.xml dist-json

%install

install -d -m 0755 $RPM_BUILD_ROOT%{_javadir}
install -m 644 dist/%{name}-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
(cd $RPM_BUILD_ROOT%{_javadir} && for jar in *-%{version}*; do ln -sf ${jar} `echo $jar| sed  "s|-%{version}||g"`; done)
install -d -m 755 $RPM_BUILD_ROOT%{_docdir}/%{name}-%{version}

%clean

%files
%{_javadir}

%changelog
* Tue Mar 17 2020 Michael Mraka <michael.mraka@redhat.com> 2.0.9-14
- Updated springtree-json.spec Source link.

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.0.9-13
- removed %%%%defattr from specfile
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 2.0.9-12
- recompile all packages with the same (latest) version of java

* Mon Nov 30 2015 Tomas Lestach <tlestach@redhat.com> 2.0.9-11
- java-devel is required in stringtree-json fc23 buildroot

* Wed Jun 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.0.9-10
- updated deps for RHEL7

* Tue Jan 07 2014 Tomas Lestach <tlestach@redhat.com> 2.0.9-9
- jpackage-utils were replaced with javapackages-tools in fc20

* Sat Jan 19 2013 Michael Mraka <michael.mraka@redhat.com> 2.0.9-8
- rebuild stringtree-json from git

* Fri Feb 27 2009 Dennis Gilmore 2.0.9-7
- ExcludeArch: ia64

* Thu Feb 26 2009 Devan Goodwin <dgoodwin@redhat.com> 2.0.9-6
- Rebuild for new rel-eng tools.

* Fri Nov 28 2008 Miroslav Suchy <msuchy@redhat.com> 2.0.9-4
- add unzip to buildreq

* Wed Oct 22 2008 Jesus M. Rodriguez <jesusr@redhat.com> 2.0.9-3
- First build

* Mon Sep 25 2008 Partha Aji <paji@redhat.com>
- Initial build.
