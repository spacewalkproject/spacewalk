Name:           nodejs-packaging
Version:        4
Release:        1.4%{?dist}
Summary:        RPM Macros and Utilities for Node.js Packaging
BuildArch:      noarch
License:        MIT
URL:            https://fedoraproject.org/wiki/Node.js/Packagers
Source0:        https://fedorahosted.org/released/%{name}/%{name}-el6-%{version}.tar.xz
ExclusiveArch:  %{ix86} x86_64 %{arm} noarch
Patch0:         nodejs-packaging-python24.patch

%global _rpmconfigdir /usr/lib/rpm

#nodejs-devel before 0.10.12 provided these macros and owned /usr/share/node
Requires:       nodejs(engine) >= 0.10.12
Requires:       redhat-rpm-config

%description
This package contains RPM macros and other utilities useful for packaging
Node.js modules and applications in RPM-based distributions.

%prep
%setup -qn %{name}-el6-%{version}
%patch0 -p0

%build
#nothing to do

%install
install -Dpm0644 macros.nodejs %{buildroot}%{_sysconfdir}/rpm/macros.nodejs
install -Dpm0755 nodejs.prov %{buildroot}%{_rpmconfigdir}/nodejs.prov
install -pm0755 nodejs.req %{buildroot}%{_rpmconfigdir}/nodejs.req
install -pm0755 nodejs-symlink-deps %{buildroot}%{_rpmconfigdir}/nodejs-symlink-deps
install -pm0755 nodejs-fixdep %{buildroot}%{_rpmconfigdir}/nodejs-fixdep
install -Dpm0644 multiver_modules %{buildroot}%{_datadir}/node/multiver_modules

%files
%{_sysconfdir}/rpm/macros.nodejs
%{_rpmconfigdir}/nodejs*
%{_datadir}/node/multiver_modules
%doc LICENSE

%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 4-1.4
- removed Group from specfile
- removed BuildRoot from specfiles
- fixed tito build warning

* Wed Nov 20 2013 Michael Mraka <michael.mraka@redhat.com> 4-1.3
- more python 2.4 fixes

* Wed Nov 20 2013 Michael Mraka <michael.mraka@redhat.com> 4-1.2
- modified for python 2.4

* Mon Jul 29 2013 T.C. Hollingsworth <tchollingsworth@gmail.com> - 4-1
- handle cases where the symlink target exists gracefully

* Wed Jul 10 2013 T.C. Hollingsworth <tchollingsworth@gmail.com> - 3-1
- dependencies and engines can be lists or strings too
- handle unversioned dependencies on multiply versioned modules correctly
  (RHBZ#982798)
- restrict to compatible arches

* Fri Jun 21 2013 T.C. Hollingsworth <tchollingsworth@gmail.com> - 2-1
- move multiple version list to /usr/share/node
- bump nodejs Requires to 0.10.12
- add Requires: redhat-rpm-config

* Thu Jun 13 2013 T.C. Hollingsworth <tchollingsworth@gmail.com> - 1-1
- initial package
