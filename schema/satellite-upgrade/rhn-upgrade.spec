Name: rhn-upgrade
Summary: RHN Satellite Server upgrade documentation
Group: RHN/Server
License: RHN Subscription License
Url: http://rhn.redhat.com/
Source2: sources
%define main_source %(awk '{ print $2 ; exit }' %{SOURCE2})
Source0: %{main_source}
Source1: version
Version: %(echo `awk '{ print $1 }' %{SOURCE1}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE1}`)%{?dist}
BuildRoot: %{_tmppath}/%{name}-%{version}-root
BuildArch: noarch
%define rhnroot /etc/sysconfig/rhn/satellite-upgrade/

%description
The rhn-upgrade package is all the documentation needed to upgrade a RHN 
Satellite Server. Start with file %{rhnroot}README. 
Please contact your Red Hat Support representative with any questions on 
following the documentation.  

%prep
%setup -q -n %(echo %{main_source} | sed 's/\.tar\.gz//')

%build 

%install
rm -rf $RPM_BUILD_ROOT
install -m 0750 -d $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 README $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 rhn-satellite-5-upgrade-scenario-1a.txt $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 rhn-satellite-5-upgrade-scenario-1b.txt $RPM_BUILD_ROOT%{rhnroot}
install -m 0750 rhn-enable-monitoring.pl $RPM_BUILD_ROOT%{rhnroot}
install -m 0750 rhn-enable-push.pl $RPM_BUILD_ROOT%{rhnroot}
install -m 0750 rhn-load-config.pl $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-2.6.0-to-2.7.0.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-2.7.0-to-3.2.0.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-3.1.5-to-3.2.0.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-3.2.0-2-to-3.2.0-4.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-3.2-to-3.4.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-3.4-to-3.6.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-3.6-199-to-3.6-214.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-3.6-214-to-3.6-215.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-3.6-215-to-3.6-216.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-3.6-to-3.7.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-3.7-to-4.0.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-4.0-to-4.1.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-4.1-to-4.2.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-4.2.0-4-to-4.2.1-2.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-4.2-to-5.0.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-5.0-to-5.1.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 satellite-5.1-to-5.2.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0750 rhn-schema-version $RPM_BUILD_ROOT%{rhnroot}
install -m 0750 rhn-charsets $RPM_BUILD_ROOT%{rhnroot}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{rhnroot}/*

%changelog
* Thu Sep  4 2008 Miroslav Suchý <msuchy@redhat.com> 5.2.0-12
- add notes about rhel5 and Oracle 10g

* Thu Aug 28 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-11
- fixed #460382

* Tue Jul 22 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-10
- 5.2 branch rebuild

* Tue Jul 15 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-8
- Package rebuild to support 5.2 Satellite upgrades
- rebuild in dist.cvs

* Tue Nov 27 2007 Jan Pazdziora
- Package rebuild to support 5.1 Satellite upgrades
- Added sql upgrade for 5.0 to 5.1

* Fri May 18 2007 Clifford Perry <cperry@redhat.com>
- Package rebuild to support 5.0 Satellite upgrades
- Added sql upgrade for 4.2 to 5.0
- Files renamed from -4 to -5 and content

* Fri Apr 20 2007 Clifford Perry <cperry@redhat.com> 
- Added sql upgrade for 4.2.0-4 to 4.2.1-2

* Thu Jan 25 2007 Miroslav Suchy <msuchy@redhat.com>
- sql upgrade from 4.1 to 4.2

* Mon Jun 19 2006 Clifford Perry <cperry@redhat.com>
- Initial build into rpm from tar.gz format. 
