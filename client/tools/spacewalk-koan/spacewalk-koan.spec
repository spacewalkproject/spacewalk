Summary: Support package for spacewalk koan interaction
Name: spacewalk-koan
Group: System Environment/Kernel
License: GPLv2
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 0.1.8
Release: 1%{?dist}
BuildArch : noarch
URL:            https://fedorahosted.org/spacewalk
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch:      noarch
BuildRequires:  python
Requires:       python >= 2.3
Requires:       koan >= 1.2.6

Provides: rhn.kickstart.boot_image = 5.3.0
Provides: rhn-kickstart = 5.3.0
Obsoletes: rhn-kickstart < 5.3.0
Requires: koan

# If this is rhel 4 or less we need up2date.
%if 0%{?rhel} && 0%{?rhel} < 5
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
rm -rf $RPM_BUILD_ROOT
make -f Makefile.spacewalk-koan install PREFIX=$RPM_BUILD_ROOT ROOT=%{_datadir}/rhn/ \
    MANDIR=%{_mandir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%config(noreplace)  %{_sysconfdir}/sysconfig/rhn/clientCaps.d/kickstart
%{_sbindir}/*
%{_datadir}/rhn/spacewalkkoan/
%{_datadir}/rhn/actions/

%changelog
* Tue Feb 10 2009 Mike McCune <mmccune@gmail.com> 0.1.8-1
- 484793: Adde a basic setter to get rid of embed_kickstart check on koan

* Mon Jan 26 2009 Mike McCune <mmccune@gmail.com> 0.1.7-1
- spec file cleanups

* Tue Jan 13 2009 Mike McCune <mmccune@gmail.com> 0.1.6-1
- 461162 - missing var for koan

* Mon Jan 12 2009 Mike McCune <mmccune@gmail.com> 0.1.5-1
- 461162 - get the virtualization provisioning tracking system to work with a :virt system record.
- 461162 - Quick fix to get spacewalk koan going with a ks....

* Thu Jan 08 2009 Mike McCune <mmccune@gmail.com> 0.1.3-1
- minor virt fixes
* Tue Dec 23 2008 Mike McCune <mmccune@gmail.com> 0.1.2-1
- tagging release with support for virt
* Tue Nov 25 2008 Mike McCune - 0.1.1-1
- tagging release
* Tue Oct 28 2008 Mike McCune - 1.0.0-1
- Initial creation.
