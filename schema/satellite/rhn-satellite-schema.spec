Group: RHN/Server
Name: rhn-satellite-schema
Source999: version
Version: %(awk '{ print $1 }' %{SOURCE999})
Release: %(awk '{ print $2 }' %{SOURCE999})%{?dist}
Source0: universe.satellite.sql
Source1: clean-tablespace

License: RHN Subscription License
Url: http://rhn.redhat.com/
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-root
Summary: SQL schema for RHN Satellite

%define rhnroot /etc/sysconfig/rhn/

%description
rhn-satellite-schema is the SQL schema for the RHN Satellite Server.
Oracle tablespace name conversions have NOT been applied.

%prep
%setup -c -T

%build
rm -rf $RPM_BUILD_ROOT

%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d $RPM_BUILD_ROOT%{rhnroot}
install -m 0644 %{SOURCE0} $RPM_BUILD_ROOT%{rhnroot}
install -m 0755 %{SOURCE1} $RPM_BUILD_ROOT%{rhnroot}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{rhnroot}/*

%changelog
* Mon Jun  9 2008 Michael Mraka <michael.mraka@redhat.com>
- fixed build issue

* Tue Jun  3 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-1
- purged unused code
- rebuilt via brew / dist-cvs

