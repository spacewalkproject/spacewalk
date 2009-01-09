%define rhnroot /usr/share/rhn
%define rhnconf /etc/sysconfig/rhn
%define client_caps_dir /etc/sysconfig/rhn/clientCaps.d

Summary: Support package for spacewalk koan interaction.
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd client/tools/spacewalk-koan
# make srpm
Name: spacewalk-koan
Group: System Environment/Kernel
License: GPLv2
Source0: %{name}-%{version}.tar.gz
Version: 0.1.3
Release: 1%{?dist}
BuildArch : noarch
URL:            https://fedorahosted.org/spacewalk
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch:      noarch
BuildRequires:  python
Requires:       python >= 2.3
Requires:       koan >= 1.2.6

Provides: rhn.kickstart.boot_image
Conflicts: rhn-kickstart
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
make -f Makefile.spacewalk-koan all

%install
# rm -rf $RPM_BUILD_ROOT
# install -d $RPM_BUILD_ROOT/

rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{rhnroot}
make -f Makefile.spacewalk-koan install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    MANDIR=%{_mandir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%config(noreplace)  /etc/sysconfig/rhn/clientCaps.d/kickstart
/usr/sbin/*
%{rhnroot}/spacewalkkoan/*
%{rhnroot}/actions/kickstart.py*
%{rhnroot}/actions/kickstart_guest.py*

%changelog
* Thu Jan 08 2009 Mike McCune <mmccune@gmail.com> 0.1.3-1
- minor virt fixes
* Tue Dec 23 2008 Mike McCune <mmccune@gmail.com> 0.1.2-1
- tagging release with support for virt
* Tue Nov 25 2008 Mike McCune - 0.1.1-1
- tagging release
* Tue Oct 28 2008 Mike McCune - 1.0.0-1
- Initial creation.
