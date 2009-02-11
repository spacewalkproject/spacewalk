%define db_dir %{_var}/lib/nocpulse
%define install_prefix %{perl_vendorlib}/NOCpulse/SatConfig

Name:         SatConfig-generator
Version:      2.29.10
Release:      1%{?dist}
Summary:      Satellite Configuration System - Server
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
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

install -m 644 ConfigDocument.pm $RPM_BUILD_ROOT%{install_prefix}
install -m 644 GenerateConfig.pm $RPM_BUILD_ROOT%{install_prefix}
#install -m 644 TestGenerateConfig.pm $RPM_BUILD_ROOT%{install_prefix}/test

%{_fixperms} $RPM_BUILD_ROOT/*

%files
%defattr(-,root,root,-)
%dir %{install_prefix}
%dir %attr(-,nocpulse,nocpulse) %{db_dir}
%{install_prefix}/ConfigDocument.pm
%{install_prefix}/GenerateConfig.pm

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Wed Feb 11 2009 Miroslav Suchý <msuchy@redhat.com>
- remove dead code (apachereg)

* Tue Jan 13 2009 Miroslav Suchý <msuchy@redhat.com> 2.29.10-1
- 253506 - fix excessive "my" declaration

* Fri Jan  9 2009 Milan Zazrivec 2.29.9-1
- fixed /var/lib/nocpulse ownership

* Tue Oct 21 2008 Miroslav Suchý <msuchy@redhat.com> 2.29.8-1
- 467441 - fix namespace

* Wed Sep 24 2008 Miroslav Suchý <msuchy@redhat.com> 2.29.6-1
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

