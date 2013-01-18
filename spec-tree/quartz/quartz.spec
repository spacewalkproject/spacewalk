Name: quartz
Summary: Quartz Enterprise Job Scheduler
Version:        1.8.4
Release:        3%{?dist}
Summary:        Quartz Enterprise Job Scheduler
License:        ASL 2.0
URL:            http://www.quartz-scheduler.org/
Group:          Development/Libraries/Java
Source0:        %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch: noarch

Requires: java >= 1.5
Requires: jakarta-commons-collections
%if 0%{?fedora}
Requires: apache-commons-logging
%else
Requires: jakarta-commons-logging
%endif

Requires: slf4j

%description
Quartz is a job scheduling system that can be integrated with, or used
along side virtually any J2EE or J2SE application. Quartz can be used
to create simple or complex schedules for executing tens, hundreds, or
even tens-of-thousands of jobs; jobs whose tasks are defined as standard
Java components or EJBs.

%package oracle
Summary: Oracle JDBC driver delegate for %{name}
Group:   Development/Libraries/Java
Requires: %{name}
Requires: slf4j
Requires: ojdbc14
Requires: quartz = %{version}

%description oracle
Oracle driver delegate for %{name}

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{_javadir}

# main quartz
cp -p %{name}-%{version}.jar \
  $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
# oracle driver
cp -p %{name}-oracle-%{version}.jar \
  $RPM_BUILD_ROOT%{_javadir}/%{name}-oracle-%{version}.jar

(cd $RPM_BUILD_ROOT%{_javadir} && for jar in *-%{version}*; do ln -sf ${jar} `echo $jar| sed  "s|-%{version}||g"`; done)

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0644,root,root,0755)
%{_javadir}/%{name}.jar
%{_javadir}/%{name}-%{version}.jar

%files oracle
%defattr(0644,root,root,0755)
%{_javadir}/%{name}-oracle.jar
%{_javadir}/%{name}-oracle-%{version}.jar

%changelog
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
