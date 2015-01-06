Summary: DNF plugin for Spacewalk
Name: dnf-plugin-spacewalk
Version: 2.3.0
Release: 1%{?dist}
License: GPLv2
Group: System Environment/Base
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
URL:     https://fedorahosted.org/spacewalk
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch

Requires: dnf >= 0.5.3
Requires: rhn-client-tools >= 1.10.3-1

%description
This DNF plugin provides access to a Spacewalk server for software updates.

%prep
%setup -q

%build


%install
rm -rf $RPM_BUILD_ROOT

%find_lang %{name}

%clean
rm -rf $RPM_BUILD_ROOT

%pre

%post

%files -f %{name}.lang
%verify(not md5 mtime size) %config(noreplace) %{_sysconfdir}/dnf/plugins/spacewalk.conf
%dir /var/lib/up2date
%{_mandir}/man*/*
%{python2_sitelib}/dnf-plugins/*
%{_datadir}/rhn/actions/*

%changelog
