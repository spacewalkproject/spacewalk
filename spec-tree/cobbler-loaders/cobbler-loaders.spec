%define _binaries_in_noarch_packages_terminate_build   0
%define loaders_root /var/lib/cobbler/loaders
Summary: Bootloaders to make cobbler buildiso work
Name: cobbler-loaders
License: GPLv2+
AutoReq: no
Version: 1.0.2
Release: 1%{?dist}
Url: http://fedorahosted.org/cobbler
Source0: cobbler-loaders-%{version}.tar.gz
Group: Applications/System
Requires: cobbler2
Requires: syslinux > 4.00
Provides: cobbler-loaders = %{version}-%{release}
Obsoletes: cobbler-loaders < %{version}-%{release}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch: noarch

%description

Cobbler-loaders is an add-on package to Cobble
that gives Cobbler the various bootloader files
it needs to build a boot iso file. Unless you
are providing your own loader files this package
is necessary for 'cobbler buildiso' to work.

%prep
%setup -q -c cobbler-loaders-%{version}

%build

%install
echo "pre-install"
mkdir -p $RPM_BUILD_ROOT%{loaders_root}
install -m644 * $RPM_BUILD_ROOT%{loaders_root}/
ln -s /usr/share/syslinux/menu.c32 $RPM_BUILD_ROOT%{loaders_root}/menu.c32
ln -s /usr/share/syslinux/pxelinux.0 $RPM_BUILD_ROOT%{loaders_root}/pxelinux.0
echo "post-install"

%post
echo "post"

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%dir %{loaders_root}
%{loaders_root}/*

%changelog
* Tue Apr 30 2013 Stephen Herr <sherr@redhat.com> 1.0.2-1
- 506485 - Pull cobbler-loader files from Red Hat signed rpms
- replace legacy name of Tagger with new one

* Fri Apr 12 2013 Stephen Herr <sherr@redhat.com> 1.0.1-2
- 506485 - settings to make builds happen correctly

* Thu Apr 11 2013 Stephen Herr <sherr@redhat.com> 1.0.1-1
- Bootloaders for 'cobbler buildiso'
