Name:       dwr
Version:    3.0.2
Release:    2%{?dist}
Summary:    Direct Web Remoting
License:    Apache Software License v2
URL:        http://directwebremoting.org
Source0:    https://github.com/directwebremoting/%{name}/archive/%{version}-RELEASE.tar.gz
Patch0:     dwr-no-noncla-no-junit.patch
BuildArch:  noarch

Requires:        java-headless >= 1:1.8.0
BuildRequires:   java-1.8.0-openjdk-devel
BuildRequires:   ant
%if 0%{?fedora} >= 20 || 0%{?rhel} == 7
BuildRequires: javapackages-tools
%endif

%description
DWR is a Java library that enables Java on the server and JavaScript
in a browser to interact and call each other as simply as possible.

%prep
%autosetup -n %{name}-%{version}-RELEASE

%build
export JAVA_TOOL_OPTIONS=-Dfile.encoding=ISO-8859-1
LC_CTYPE=en_US.iso-8859-1 ant jar

%install
mkdir -p $RPM_BUILD_ROOT%{_javadir}
install -m 644 ./target/ant/dwr.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
(cd $RPM_BUILD_ROOT%{_javadir} && ln -sf %{name}-%{version}.jar %{name}.jar)

%files
%attr(0644,root,root) %{_javadir}/%{name}-%{version}.jar
%attr(0644,root,root) %{_javadir}/%{name}.jar


%changelog
* Tue Oct 01 2019 Michael Mraka <michael.mraka@redhat.com> 3.0.2-2
- workaround RHEL8 buildrequires modules issue

* Thu Mar 22 2018 Jiri Dostal <jdostal@redhat.com> 3.0.2-1
- Update dwr to 3.0.2

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 3.0rc2-9
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 3.0rc2-8
- recompile all packages with the same (latest) version of java

* Wed Jul 20 2016 Tomas Lestach <tlestach@redhat.com> 3.0rc2-7
- setting default encoding for dwr build process

* Wed Jun 25 2014 Michael Mraka <michael.mraka@redhat.com> 3.0rc2-6
- fixed deps on RHEL7

* Wed Jan 08 2014 Tomas Lestach <tlestach@redhat.com> 3.0rc2-5
- let dwr buildrequire javapackages-tools on fc20

* Mon Apr 08 2013 Jan Pazdziora 3.0rc2-4
- patch for the "A server error has occurred" issue (DWR-467)

* Mon Apr 08 2013 Jan Pazdziora 3.0rc2-3
- build from sources

* Thu Nov 29 2012 Tomas Lestach <tlestach@redhat.com> 3.0rc2-2
- define NoTgzBuilder for dwr
- define BuildRoot for dwr.spec

* Thu Nov 29 2012 Tomas Lestach <tlestach@redhat.com> 3.0rc2-1
- initial dwr build


