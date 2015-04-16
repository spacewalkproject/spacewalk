Summary: DNF plugin for Spacewalk
Name: dnf-plugin-spacewalk
Version: 2.4.1
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
install -d $RPM_BUILD_ROOT/%{python_sitelib}/dnf-plugins/
install -d $RPM_BUILD_ROOT/%{_sysconfdir}/dnf/plugins/
install -d $RPM_BUILD_ROOT/var/lib/up2date
install -d $RPM_BUILD_ROOT/%{_mandir}/man{5,8}
install -m 644 spacewalk.py $RPM_BUILD_ROOT/%{python_sitelib}/dnf-plugins/
install -m 644 spacewalk.conf $RPM_BUILD_ROOT/%{_sysconfdir}/dnf/plugins/
install -m 644 man/spacewalk.conf.5 $RPM_BUILD_ROOT/%{_mandir}/man5/
install -m 644 man/dnf.plugin.spacewalk.8 $RPM_BUILD_ROOT/%{_mandir}/man8/

#%find_lang %{name}

%clean
rm -rf $RPM_BUILD_ROOT

%pre

%post

#%files -f %{name}.lang
%files
%verify(not md5 mtime size) %config(noreplace) %{_sysconfdir}/dnf/plugins/spacewalk.conf
%dir /var/lib/up2date
%{_mandir}/man*/*
%{python_sitelib}/dnf-plugins/*
#%{_datadir}/rhn/actions/*
%dir /var/lib/up2date

%changelog
* Thu Apr 16 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.1-1
- initial build of dnf-plugin-spacewalk

