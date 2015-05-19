Summary: DNF plugin for Spacewalk
Name: dnf-plugin-spacewalk
Version: 2.4.4
Release: 1%{?dist}
License: GPLv2
Group: System Environment/Base
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
URL:     https://fedorahosted.org/spacewalk
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch

%if 0%{?fedora}
BuildRequires: python3-devel
%endif
Requires: dnf >= 0.5.3
Requires: librepo >= 1.7.15
Requires: rhn-client-tools >= 1.10.3-1
Conflicts: yum-rhn-plugin

%description
This DNF plugin provides access to a Spacewalk server for software updates.

%prep
%setup -q

%build


%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{python_sitelib}/dnf-plugins/
install -d $RPM_BUILD_ROOT%{_sysconfdir}/dnf/plugins/
install -d $RPM_BUILD_ROOT/usr/share/rhn/actions
install -d $RPM_BUILD_ROOT/var/lib/up2date
install -d $RPM_BUILD_ROOT%{_mandir}/man{5,8}
install -m 644 spacewalk.py $RPM_BUILD_ROOT%{python_sitelib}/dnf-plugins/
%if 0%{?fedora}
install -d $RPM_BUILD_ROOT%{python3_sitelib}/dnf-plugins/
ln -s %{python_sitelib}/dnf-plugins/spacewalk.py \
        $RPM_BUILD_ROOT%{python3_sitelib}/dnf-plugins/spacewalk.py
%endif
install -m 644 actions/packages.py $RPM_BUILD_ROOT/usr/share/rhn/actions/
install -m 644 actions/errata.py $RPM_BUILD_ROOT/usr/share/rhn/actions/
install -m 644 spacewalk.conf $RPM_BUILD_ROOT%{_sysconfdir}/dnf/plugins/
install -m 644 man/spacewalk.conf.5 $RPM_BUILD_ROOT%{_mandir}/man5/
install -m 644 man/dnf.plugin.spacewalk.8 $RPM_BUILD_ROOT%{_mandir}/man8/

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
%if 0%{?fedora}
%{python3_sitelib}/dnf-plugins/*
%endif
%{_datadir}/rhn/actions/*
%dir /var/lib/up2date

%changelog
* Tue May 12 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.4-1
- fixed rpmbuild issues

* Mon May 11 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.2-1
- add action files for packages/errata installation
- put spacewalk both into python2 and python3 setelibs

* Thu Apr 16 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.1-1
- initial build of dnf-plugin-spacewalk

