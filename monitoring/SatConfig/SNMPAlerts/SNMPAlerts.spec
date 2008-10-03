%define ap_home        %{_var}/www
%define cgi_bin        %ap_home/cgi-bin
%define cgi_mod_perl   %ap_home/cgi-mod-perl
%define registry       %{_sysconfdir}/rc.d/np.d/apachereg
Name:         SNMPAlerts
Version:      0.5.2
Release:      1%{?dist}
Summary:      Download and clear SNMP alerts from the database
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/SatConfig/SNMPAlerts
# make srpm
URL:          https://fedorahosted.org/spacewalk
Source:	      %{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package provides ability to download and clear SNMP alerts from the 
database.

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT

# CGI bin and mod-perl bin
mkdir -p $RPM_BUILD_ROOT%cgi_mod_perl
mkdir -p $RPM_BUILD_ROOT%registry
install -m 555 fetch_snmp_alerts.cgi $RPM_BUILD_ROOT%cgi_mod_perl
install -m 444 Apache.SatConfig-SNMPAlerts $RPM_BUILD_ROOT%registry

%{_fixperms} $RPM_BUILD_ROOT/*

%files
%defattr(-,root,root,-)
%config(noreplace) %registry/Apache.SatConfig-SNMPAlerts
%cgi_mod_perl/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Tue Sep 23 2008 Miroslav Suchý <msuchy@redhat.com> 0.5.2-1
- spec cleanup for Fedora
