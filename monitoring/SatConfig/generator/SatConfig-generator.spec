%define db_dir %{_var}/lib/nocpulse
%define registry %{_sysconfdir}/rc.d/np.d/apachereg
%define install_prefix %{perl_vendorlib}/NOCpulse/SatConfig

Name:         SatConfig-generator
Version:      2.29.6
Release:      1%{?dist}
Summary:      Satellite Configuration System - Server
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/SatConfig/generator
# make srpm
URL:          https://fedorahosted.org/spacewalk
Source:	      %{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:     SatConfig-dbsynch
Requires:     nocpulse-common
Group:        Applications/Internet
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
SatConfig-generator is the cgi mechanism by which Netsaint configuration files
are generated and propagated.

%prep
%setup -q

%build
# Nothing to build

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p          $RPM_BUILD_ROOT%{install_prefix}
#mkdir -p          $RPM_BUILD_ROOT%{install_prefix}/test
mkdir -p          $RPM_BUILD_ROOT%{db_dir}
mkdir -p          $RPM_BUILD_ROOT%{registry}

install -m 644 ConfigDocument.pm $RPM_BUILD_ROOT%{install_prefix}
install -m 644 GenerateConfig.pm $RPM_BUILD_ROOT%{install_prefix}
#install -m 644 TestGenerateConfig.pm $RPM_BUILD_ROOT%{install_prefix}/test
install -m 644 Apache.SatConfig-generator $RPM_BUILD_ROOT%{registry}

%{_fixperms} $RPM_BUILD_ROOT/*

%files
%defattr(-,root,root,-)
%dir %{install_prefix}
%dir %{db_dir}
%dir %{registry}
%{install_prefix}/ConfigDocument.pm
%{install_prefix}/GenerateConfig.pm
%{registry}/Apache.SatConfig-generator

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Wed Sep 24 2008 Miroslav Suchý <msuchy@redhat.com> 2.29.6-1
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

