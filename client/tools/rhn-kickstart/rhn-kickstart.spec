%define rhnroot /usr/share/rhn

Summary: Support scripts for auto-kickstarting systems
Name: rhn-kickstart
Group: System Environment/Kernel
License: GPLv2
Source0: %{name}-%{version}.tar.gz
Version: 5.4.5
Release: 1%{?dist}
BuildArch: noarch
BuildRequires: python
URL: http://rhn.redhat.com/
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

Requires: %{name}-common = %{version}-%{release}
Provides: rhn.kickstart.boot_image
Conflicts: auto-kickstart

# If this is rhel 4 or less we need up2date.
%if 0%{?rhel} && "%rhel" < "5"
Requires: up2date
%else
Requires: rhn-check
%endif

%description
Support scripts for auto-kickstarting systems
 

%package common
Summary: Common support scripts for auto-kickstarting systems
Group: System Environment/Kernel

# If this is rhel 4 or less we need up2date.
%if 0%{?rhel} && "%rhel" < "5"
Requires: up2date
%else
Requires: rhn-client-tools
%endif


%description common
Common support scripts for auto-kickstarting systems.


%if 0%{?rhel} == 0 || "%rhel" >= "5"
%package virtualization
Summary: Support scripts for auto-kickstarting virtual systems
Group: System Environment/Kernel
Requires: %{name}-common = %{version}-%{release}
Requires: rhn-virtualization-host
Requires: rhn-check
Requires: libvirt >= 0.2.3

%description virtualization
Support scripts for auto-kickstarting virtual systems.

%endif

%prep
%setup -q

%build
make -f Makefile.rhn-kickstart

%install
rm -rf $RPM_BUILD_ROOT

# Don't build virt stuff on rhel 4 and under.
%if 0%{?rhel} && "%rhel" < "5"
make -f Makefile.rhn-kickstart install PREFIX=$RPM_BUILD_ROOT NOVIRT=1
%else
make -f Makefile.rhn-kickstart install PREFIX=$RPM_BUILD_ROOT
%endif


%clean
rm -rf $RPM_BUILD_ROOT

%files
/usr/sbin/*
%config(noreplace)  /etc/sysconfig/rhn/clientCaps.d/kickstart

%{rhnroot}/actions/kickstart.py*

%{rhnroot}/rhnkickstart/lilo.py*
%{rhnroot}/rhnkickstart/kickstart.py*


%files common
%dir %{rhnroot}/rhnkickstart
%{rhnroot}/rhnkickstart/__init__.py*
%{rhnroot}/rhnkickstart/kickstart_exceptions.py*
%{rhnroot}/rhnkickstart/common.py*
%{rhnroot}/rhnkickstart/config.py*


%if 0%{?rhel} == 0 || "%rhel" >= "5"
%files virtualization

%{rhnroot}/actions/kickstart_guest.py*

%{rhnroot}/rhnkickstart/virtualization_kickstart_exceptions.py*
%{rhnroot}/rhnkickstart/kickstart_guest.py*

%endif

%changelog
* Tue Nov 02 2010 Jan Pazdziora 5.4.5-1
- Update copyright years in the rest of the repo.

* Fri Oct 29 2010 Jan Pazdziora 5.4.4-1
- removed unused class LiloConfiguration (michael.mraka@redhat.com)

* Tue Jul 20 2010 Miroslav Suchý <msuchy@redhat.com> 5.4.3-1
- add parameter cache_only to all client actions (msuchy@redhat.com)

