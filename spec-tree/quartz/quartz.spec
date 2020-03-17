Name: quartz
Summary: Quartz Enterprise Job Scheduler
Version:        1.8.4
Release:        12%{?dist}
Summary:        Quartz Enterprise Job Scheduler
License:        ASL 2.0
URL:            http://www.quartz-scheduler.org/
Source0:        https://github.com/spacewalkproject/spacewalk/releases/download/%{name}-%{version}-11/%{name}-%{version}.tar.gz
BuildArch: noarch

Requires: java-headless >= 1:1.8.0
%if 0%{?fedora} || 0%{?rhel} >= 7
Requires: apache-commons-logging
Requires: apache-commons-collections
%else
Requires: jakarta-commons-logging
Requires: jakarta-commons-collections
%endif

Requires: slf4j > 1.6

%description
Quartz is a job scheduling system that can be integrated with, or used
along side virtually any J2EE or J2SE application. Quartz can be used
to create simple or complex schedules for executing tens, hundreds, or
even tens-of-thousands of jobs; jobs whose tasks are defined as standard
Java components or EJBs.

%package oracle
Summary: Oracle JDBC driver delegate for %{name}
Requires: %{name}
Requires: slf4j > 1.6
Requires: ojdbc14
Requires: quartz = %{version}

%description oracle
Oracle driver delegate for %{name}

%prep
%setup -q

%install
mkdir -p $RPM_BUILD_ROOT%{_javadir}

# main quartz
cp -p %{name}-%{version}.jar \
  $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
# oracle driver
cp -p %{name}-oracle-%{version}.jar \
  $RPM_BUILD_ROOT%{_javadir}/%{name}-oracle-%{version}.jar

(cd $RPM_BUILD_ROOT%{_javadir} && for jar in *-%{version}*; do ln -sf ${jar} `echo $jar| sed  "s|-%{version}||g"`; done)

%clean

%files
%{_javadir}/%{name}.jar
%{_javadir}/%{name}-%{version}.jar

%files oracle
%{_javadir}/%{name}-oracle.jar
%{_javadir}/%{name}-oracle-%{version}.jar

%changelog
* Tue Mar 17 2020 Michael Mraka <michael.mraka@redhat.com> 1.8.4-12
- uploaded source tar to github

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 1.8.4-11
- removed %%%%defattr from specfile
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 1.8.4-10
- recompile all packages with the same (latest) version of java

* Thu Apr 06 2017 Michael Mraka <michael.mraka@redhat.com> 1.8.4-9
- Revert "updated RHEL6 Requires after jpackage removal"

* Tue Apr 04 2017 Michael Mraka <michael.mraka@redhat.com> 1.8.4-8
- updated RHEL6 Requires after jpackage removal

* Mon Mar 13 2017 Michael Mraka <michael.mraka@redhat.com> 1.8.4-7
- require standard apache-commons-collecitons on Fedora

* Wed Aug 27 2014 Michael Mraka <michael.mraka@redhat.com> 1.8.4-6
- fixed requires for RHEL7

* Fri Mar 15 2013 Michael Mraka <michael.mraka@redhat.com> 1.8.4-5
- fixed builder definition

* Tue Jan 29 2013 Michael Mraka <michael.mraka@redhat.com> 1.8.4-4
- require at least slf4j-1.6

* Fri Jan 18 2013 Michael Mraka <michael.mraka@redhat.com> 1.8.4-3
- rebased to newer version

* Mon Mar 28 2011 Michael Mraka <michael.mraka@redhat.com> 1.8.4-2
- require standard slf4j

* Fri Mar 04 2011 Jan Pazdziora 1.8.4-1
- 681006 - rebase quartz to 1.8.4 to address high CPU usage.
- replace jakarta-commons-logging with apache-commons-logging on F14
  (tlestach@redhat.com)

* Fri Jul 30 2010 Tomas Lestach <tlestach@redhat.com> 1.8.1-3
- changing quartz spec to require spacewalk-slf4j (tlestach@redhat.com)

* Wed Jun 16 2010 Shannon Hughes <shughes@redhat.com> 1.8.1-2
- new package

* Fri Jun 11 2010 Shannon HUghes <shughes@redhat.com> 1.8.1
- Initial package build
