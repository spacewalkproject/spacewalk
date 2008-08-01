Group: RHNS/Satellite
Name: rhn-%(echo `awk '{ print $1 }' %{_sourcedir}/schema-info`)-schema
Version: %(echo `awk '{ print $2 }' %{_sourcedir}/schema-info`)
Release: %(echo `awk '{ print $3 }' %{_sourcedir}/schema-info`)
Source0: %{name}-%{version}.tar.gz
Source1: schema-info
License: GPLv2
Url: http://rhn.redhat.com/
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-root
Summary: SQL schema for RHN Satellite

%define rhnroot /etc/sysconfig/rhn/

%description
rhn-satellite-schema is the SQL schema for the RHN Satellite Server.  
Oracle tablespace name conversions have NOT been applied.

%prep
%setup

%build 
rm -rf $RPM_BUILD_ROOT

%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d $RPM_BUILD_ROOT%{rhnroot}
install -m 0644 *.sql $RPM_BUILD_ROOT%{rhnroot}
install -m 0755 clean-tablespace $RPM_BUILD_ROOT%{rhnroot}
install -m 0644 Makefile.deploy $RPM_BUILD_ROOT%{rhnroot}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{rhnroot}/*

%changelog
* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Wed Sep 22 2004 Todd Warner <taw@redhat.com>
- satellite-upgrade is no longer part of the build. Don't want upgrade schema
  scripts as part of the satellite.

