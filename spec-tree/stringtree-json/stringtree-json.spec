%define base_package stringtree
Summary: An json string library
Name: stringtree-json
Version: 2.0.9
Release: 5%{?dist}
License: LGPL
Group: Development/Library
URL: http://stringtree.org/stringtree-json.html
Source0: %{base_package}-%{version}-src.zip
Patch0: stringtree-2.0.9-build-xml.patch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildRequires: jpackage-utils >= 0:1.5
BuildRequires: ant
BuildRequires: unzip
BuildArch: noarch

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
* Thu Feb 26 2009 jesus m. rodriguez <jesusr@redhat.com> 2.0.9-5
- Remove some variables in Patch lines of spec files.
- Define builder and tagger classes in build.py.props.
- Distribute build.py.props anywhere a Makefile with NO_TAR_GZ exists.

* Fri Nov 28 2008 Miroslav Suchy <msuchy@redhat.com> 2.0.9-4
- add unzip to buildreq

* Wed Oct 22 2008 Jesus M. Rodriguez <jesusr@redhat.com> 2.0.9-3
- First build

* Mon Sep 25 2008 Partha Aji <paji@redhat.com>
- Initial build.
