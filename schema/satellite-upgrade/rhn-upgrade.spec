Name: rhn-upgrade
Summary: RHN Satellite Server upgrade documentation
Group: RHN/Server
License: RHN Subscription License
Url: http://rhn.redhat.com/
Source0: %{name}-%{version}.tar.gz
Source1: version
Version: %(echo `awk '{ print $1 }' %{SOURCE1}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE1}`)
BuildRoot: /var/tmp/%{name}-%{version}-root
BuildArch: noarch
%define rhnroot /etc/sysconfig/rhn/satellite-upgrade/

%description
The rhn-upgrade package is all the documentation needed to upgrade a RHN 
Satellite Server. Start with file %{rhnroot}README. 
Please contact your Red Hat Support representative with any questions on 
following the documentation.  

%prep
%setup -q

%build 
rm -rf $RPM_BUILD_ROOT

%install
rm -rf $RPM_BUILD_ROOT
install -m 0750 -d $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 README $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 rhn-satellite-5-upgrade-scenario-1a.txt $RPM_BUILD_ROOT%{rhnroot}
install -m 0400 rhn-satellite-5-upgrade-scenario-1b.txt $RPM_BUILD_ROOT%{rhnroot}
install -m 0750 rhn-enable-monitoring.pl $RPM_BUILD_ROOT%{rhnroot}
install -m 0750 rhn-enable-push.pl $RPM_BUILD_ROOT%{rhnroot}
install -m 0750 rhn-load-config.pl $RPM_BUILD_ROOT%{rhnroot}
install -m 0750 rhn-schema-version $RPM_BUILD_ROOT%{rhnroot}
install -m 0750 rhn-charsets $RPM_BUILD_ROOT%{rhnroot}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{rhnroot}/*

%changelog
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
