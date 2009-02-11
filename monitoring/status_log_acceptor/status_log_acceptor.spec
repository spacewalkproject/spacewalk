Name:         status_log_acceptor
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      0.12.7
Release:      1%{?dist}
Summary:      Current state log acceptor
URL:          https://fedorahosted.org/spacewalk
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:	  SatConfig-general
Group:        Applications/Internet
License:      GPLv2
Buildroot:     %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
Provides the cgi that accepts a status log, parses it, and stores the 
information.

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT
 
mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse
#mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/AcceptStatusLog/test
 
install -m 444 AcceptStatusLog.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse
#install -m 444 test/TestAcceptStatusLog.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/AcceptStatusLog/test

%files
%defattr(-,root,root,-)
%{perl_vendorlib}/NOCpulse/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Wed Feb 11 2009 Miroslav Suchý <msuchy@redhat.com> 0.12.7-1
- remove dead code (apachereg)

* Thu Sep 25 2008 Miroslav Suchý <msuchy@redhat.com> 0.12.6-1
- spec cleanup for Fedora

* Mon Jun 16 2008 Milan Zazrivec <mzazrivec@redhat.com> 0.12.5-8
- cvs.dist import
