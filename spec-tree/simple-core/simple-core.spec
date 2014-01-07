Name:		simple-core		
Version:	3.1.3
Release:	4%{?dist}
Summary:	Embeddable Java HTTP engine capable of handling large loads
Group:	 	Development/Libraries	
License:	GNU
URL:	 	http://www.simpleframework.org	
Source0:	simple-core-%{version}.tar.gz	
BuildRoot:	%{_tmppath}/%{origname}-%{version}-%{release}-buildroot

BuildRequires:  ant
%if 0%{?fedora} >= 20
BuildRequires: javapackages-tools
%endif
BuildRequires:  java >= 1.5
Requires:       java >= 1.5

%description
The core API consists of a simple.http package and various sub-packages, it also contains various utilities. This is all that is required to develop HTTP services. 

%package javadoc
Summary:       Javadoc for %{name}
Group:         Documentation

%description javadoc
Javadoc for %{name}.

%prep
%setup -q

%build
export JAVA_HOME=%{java_home}
%ant

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT%{_javadir}

# jars and supporting kxml lib
install -m 644 jar/%{name}-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
install -m 644 lib/kxml.jar $RPM_BUILD_ROOT%{_javadir}/kxml.jar

(cd $RPM_BUILD_ROOT%{_javadir} && for jar in *-%{version}*; do ln -sf ${jar} `echo $jar| sed  "s|-%{version}||g"`; done)

#javadoc
install -d -m 755 $RPM_BUILD_ROOT%{_javadocdir}/%{name}-%{version}
cp -pr doc/* $RPM_BUILD_ROOT%{_javadocdir}/%{name}-%{version}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0644,root,root,0755)
%{_javadir}/%{name}-%{version}.jar
%{_javadir}/%{name}.jar
%{_javadir}/kxml.jar

%doc
%{_javadocdir}/*

%changelog
* Tue Jan 07 2014 Tomas Lestach <tlestach@redhat.com> 3.1.3-4
- let simple-core buildrequire javapackages-tools on fc20
- let simple-core buildrequire java

* Fri Jan 18 2013 Michael Mraka <michael.mraka@redhat.com> 3.1.3-3
- rebuild simple-core from git

* Thu Jul 29 2010 Shannon Hughes <shughes@redhat.com> 3.1.3-2
- new package built with tito

* Tue Jul 27 2010 Shannon Hughes <shughes@redhat.com> 3.1.3-1
- Initial package build
