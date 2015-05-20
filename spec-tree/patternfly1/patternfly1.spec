%global make_common_opts \\\
	PACKAGE_NAME=%{name} \\\
	RPM_VERSION=%{version} \\\
	RPM_RELEASE=%{release} \\\
	DISPLAY_VERSION=%{version}-%{release} \\\
	PREFIX=%{_prefix} \\\
	DATAROOT_DIR=%{_datadir} \\\
	PKG_DATA_DIR=%{_datadir}/%{name} \\\
	%{nil}

Name:		patternfly1
Summary:	PatternFly open interface project and its dependencies
Version:	1.0.5
Release:	7%{?release_suffix}%{?dist}
License:	ASL 2.0
Group:      Applications/Internet
URL:		https://github.com/patternfly/patternfly
Source:		patternfly-1.0.5.tar.gz
Patch0:   fix_paths.patch

BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:	noarch

%description
PatternFly open interface project, with dependencies bundled

%prep
%setup -q -n patternfly-1.0.5
%patch0 -p1

%build
make %{?_smp_mflags} %{make_common_opts}

%install
rm -rf "%{buildroot}"
make %{?_smp_mflags} %{make_common_opts} install DESTDIR="%{buildroot}"
cp -pR less/ %{buildroot}%{_datadir}/%{name}/resources/less

%files
%{_datadir}/%{name}/

%changelog
* Wed May 20 2015 Tomas Kasparek <tkasparek@redhat.com> 1.0.5-7
- fix fonts paths for usage in Spacewalk

* Fri Sep 26 2014 Tomas Kasparek <tkasparek@redhat.com> 1.0.5-6
- move less files into resources directory

* Fri Sep 26 2014 Tomas Kasparek <tkasparek@redhat.com> 1.0.5-5
- 

* Fri Sep 26 2014 Tomas Kasparek <tkasparek@redhat.com> 1.0.5-4
- less files are also for Spacewalk purposes

* Wed Sep 24 2014 Tomas Kasparek <tkasparek@redhat.com> 1.0.5-3
- group should be present in the specfile

* Wed Sep 24 2014 Tomas Kasparek <tkasparek@redhat.com> 1.0.5-2
- rename specfile to match package name

* Wed Sep 24 2014 Tomas Kasparek <tkasparek@redhat.com> 1.0.5-1
- new package built with tito

* Fri Jun 20 2014 Greg Sheremeta <gshereme@redhat.com> - 1.0.3-1
- Initial version.

