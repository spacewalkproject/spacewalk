Name:       dwr
Version:    3.0rc2
Release:    2%{?dist}
Summary:    Direct Web Remoting
Group:      Development/Libraries/Java
License:    Apache Software License v2
URL:        http://directwebremoting.org
Source0:    %{name}-%{version}.tar.gz
BuildArch:  noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

Requires:   java

%description
DWR is a Java library that enables Java on the server and JavaScript in a browser to interact and call each other as simply as possible.

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{_javadir}
install -m 644 %{name}-%{version}.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
(cd $RPM_BUILD_ROOT%{_javadir} && ln -sf %{name}-%{version}.jar %{name}.jar)

%files
%attr(0644,root,root) %{_javadir}/dwr-3.0rc2.jar
%attr(0644,root,root) %{_javadir}/dwr.jar


%changelog
* Thu Nov 29 2012 Tomas Lestach <tlestach@redhat.com> 3.0rc2-2
- define NoTgzBuilder for dwr
- define BuildRoot for dwr.spec

* Thu Nov 29 2012 Tomas Lestach <tlestach@redhat.com> 3.0rc2-1
- initial dwr build


