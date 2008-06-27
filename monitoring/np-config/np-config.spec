# Package specific stuff
Name:         np-config
Source9999: version
Version: %(echo `awk '{ print $1 }' %{SOURCE9999}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE9999}`)%{?dist}
Summary:      NOCpulse global configuration file
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        Applications/System
URL:          https://fedorahosted.org/spacewalk
License:      GPLv2
Vendor:       Red Hat, Inc.
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Prereq:       NPusers

%define perl_lib %{perl_vendorlib}/NOCpulse
%define doc_dir /usr/share/doc/%{name}-%{version}
%description

np-config contains the nocpulse configuration file and access libraries 
for it in perl and python

%prep
%setup

%install

mkdir -p $RPM_BUILD_ROOT/etc/
touch $RPM_BUILD_ROOT/etc/NOCpulse.ini
mkdir -p $RPM_BUILD_ROOT%{perl_lib}/Config/test
mkdir -p $RPM_BUILD_ROOT%{doc_dir}
mkdir -p $RPM_BUILD_ROOT%{_bindir}
install perl-API/NOCpulse/Config.pm          $RPM_BUILD_ROOT%{perl_lib}/
install perl-API/NOCpulse/NOCpulseini.pm     $RPM_BUILD_ROOT%{perl_lib}/
install perl-API/NOCpulse/test/TestConfig.pm $RPM_BUILD_ROOT%{perl_lib}/Config/test/
install example.pl                           $RPM_BUILD_ROOT%{doc_dir}/
install NOCpulse.ini.txt                     $RPM_BUILD_ROOT%{doc_dir}/
install -m 755 npConfigValue $RPM_BUILD_ROOT%{_bindir}/

%files
%defattr(-,root,root)
%{_bindir}/npConfigValue
%{perl_lib}/Config.pm
%{perl_lib}/NOCpulseini.pm
%{perl_lib}/Config/test/TestConfig.pm
%config(missingok,noreplace) /etc/NOCpulse.ini
%dir %{doc_dir}
%doc %{doc_dir}/example.pl
%doc %{doc_dir}/NOCpulse.ini.txt

%post
#create empty conf unless already exists
/bin/touch /etc/NOCpulse.ini

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Thu Jun 26 2008 Miroslav Suchy <msuchy@redhat.com>
- moving directories to complain LSB
- cleaning up spec file

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Wed Jun  4 2008 Milan Zazrivec <mzazrivec@redhat.com> 2.110.3-7
- fixed file permissions

* Wed May 21 2008 Miroslav Suchy <msuchy@redhat.com> 2.110.3-6
- migrate to brew / dist-cvs

