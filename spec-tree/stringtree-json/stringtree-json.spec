%define base_package stringtree
Summary: An json string library
Name: stringtree-json
Version: 2.0.9
Release: 9%{?dist}
License: LGPL
Group: Development/Library
URL: http://stringtree.org/stringtree-json.html
Source0: %{base_package}-%{version}-src.zip
Patch0: stringtree-2.0.9-build-xml.patch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
%if 0%{?fedora} >= 20
BuildRequires: javapackages-tools
%else
BuildRequires: jpackage-utils >= 0:1.5
%endif
BuildRequires: ant
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
rm -rf $RPM_BUILD_ROOT

install -d -m 0755 $RPM_BUILD_ROOT%{_javadir}
install -m 644 dist/%{name}-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
(cd $RPM_BUILD_ROOT%{_javadir} && for jar in *-%{version}*; do ln -sf ${jar} `echo $jar| sed  "s|-%{version}||g"`; done)
install -d -m 755 $RPM_BUILD_ROOT%{_docdir}/%{name}-%{version}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0644,root,root,0755)
%{_javadir}

%changelog
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
