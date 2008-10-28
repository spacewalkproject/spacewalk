%define rhnroot /usr/share/rhn

Summary: Support package for spacewalk koan interaction.
Name: spacewalk-koan
Group: System Environment/Kernel
License: GPLv2
Source0: %{name}-%{version}.tar.gz
Version: 0.1.0
Release: 1%{?dist}
BuildArch : noarch
URL: http://rhn.redhat.com/
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

Provides: rhn.kickstart.boot_image
Obsoletes: rhn-kickstart
Requires: koan

# If this is rhel 4 or less we need up2date.
%if 0%{?rhel} && "%rhel" < "5"
Requires: up2date
%else
Requires: rhn-check
%endif

%description
Support package for spacewalk koan interaction.
 
%prep
%setup -q

%build
#nothing to do here

%install
rm -rf $RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/usr/sbin/*
%config(noreplace)  /etc/sysconfig/rhn/clientCaps.d/kickstart
%{rhnroot}/spacewalkkoan/spacewalkkoan.py*

#%{rhnroot}/actions/kickstart.py*

%changelog
* Tue Oct 28 2008 Mike McCune - 1.0.0-1
- Initial creation.
