Name:         nocpulse-config
Version:      2.110.3
Release:      7%{?dist}
Summary:      NOCpulse global configuration file
BuildArch:    noarch
Group:        Applications/System
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/np-config
# make test-srpm
Source0:      %{name}-%{version}-%{release}.tar.gz
URL:          https://fedorahosted.org/spacewalk
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:     nocpulse-users
Requires:     perl(:MODULE_COMPAT_%(eval "<code>%{__perl} -V:version</code>"; echo $version))

%define doc_dir %{_docdir}/%{name}

%description
Contains the NOCpulse configuration file and access libraries 
for it in perl and python.

%prep
%setup -q

%build
# nothing to do

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT/etc/
install NOCpulse.ini $RPM_BUILD_ROOT/etc/NOCpulse.ini
mkdir -p $RPM_BUILD_ROOT%{perl_vendorarch}/Config/test
mkdir -p $RPM_BUILD_ROOT%{doc_dir}
mkdir -p $RPM_BUILD_ROOT%{_bindir}
install perl-API/NOCpulse/Config.pm          $RPM_BUILD_ROOT%{perl_vendorlib}/
install perl-API/NOCpulse/NOCpulseini.pm     $RPM_BUILD_ROOT%{perl_vendorlib}/
install perl-API/NOCpulse/test/TestConfig.pm $RPM_BUILD_ROOT%{perl_vendorlib}/Config/test/
#install example.pl                           $RPM_BUILD_ROOT%{doc_dir}/
#install NOCpulse.ini.txt                     $RPM_BUILD_ROOT%{doc_dir}/
install -m 755 npConfigValue $RPM_BUILD_ROOT%{_bindir}/

%files
%defattr(-,root,root,-)
%{_bindir}/npConfigValue
%{perl_vendorlib}/Config.pm
%{perl_vendorlib}/NOCpulseini.pm
%{perl_vendorlib}/Config/test/TestConfig.pm
%config(missingok,noreplace) /etc/NOCpulse.ini
%doc example.pl NOCpulse.ini.txt

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

