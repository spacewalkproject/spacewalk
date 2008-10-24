Name:         nocpulse-common
Version:      2.0.7
Release:      1%{?dist}
Summary:      NOCpulse common
License:      GPLv2
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/nocpulse-common
# make srpm
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Group:        Applications/System
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires(pre):  httpd, /usr/sbin/useradd
Requires(post): /sbin/runuser, openssh
# merging this two packages together
# not backward compatible => no Provides:
Obsoletes:     NPusers <= 1.17.11-6
Obsoletes:     np-config <= 2.110.3-7

%define package nocpulse
%define identity %{_localstatedir}/lib/%{package}/.ssh/nocpulse-identity

%description
NOCpulse provides application, network, systems and transaction monitoring, 
coupled with a comprehensive reporting system including availability, 
historical and trending reports in an easy-to-use browser interface.

This package installs NOCpulse user shared by other NOCpulse packages, set 
up logrotate script, contains the NOCpulse configuration file and access 
libraries for it in perl.

%prep
%setup -q

%build
# nothing to do

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p %{buildroot}%{_sysconfdir}/%{package}
mkdir -p %{buildroot}%{_localstatedir}/log/%{package}
mkdir -p %{buildroot}%{_localstatedir}/lib/%{package}/.ssh

# install log rotation stuff
mkdir -p $RPM_BUILD_ROOT/etc/logrotate.d
install -m644 nocpulse.logrotate \
   $RPM_BUILD_ROOT/etc/logrotate.d/%{name}

mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}
install -m644 NOCpulse.ini $RPM_BUILD_ROOT/%{_localstatedir}/lib/%{package}/NOCpulse.ini
mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Config/test
mkdir -p $RPM_BUILD_ROOT%{_bindir}
install -m644 perl-API/NOCpulse/Config.pm          $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/
install -m644 perl-API/NOCpulse/NOCpulseini.pm     $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/
install -m644 perl-API/NOCpulse/test/TestConfig.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Config/test/
install -m 755 npConfigValue $RPM_BUILD_ROOT%{_bindir}/

%pre
if [ $1 -eq 1 ] ; then
  getent group %{package} >/dev/null || groupadd -r %{package}
  getent passwd %{package} >/dev/null || \
  useradd -r -g %{package} -G apache -d %{_localstatedir}/lib/%{package} -s /sbin/tcsh -c "NOCpulse user" %{package}
  /usr/bin/passwd -l %{package} >/dev/null
  exit 0
fi

%post
if [ ! -f %{identity} ]
then
    runuser -s /bin/bash -c "/usr/bin/ssh-keygen -q -t dsa -N '' -f %{identity}" - %{package}
fi

%files
%defattr(-, root,root,-)
%dir %{_sysconfdir}/nocpulse
%config(missingok,noreplace) %{_localstatedir}/lib/%{package}/NOCpulse.ini
%{_bindir}/npConfigValue
%dir %{perl_vendorlib}/NOCpulse
%{perl_vendorlib}/NOCpulse/*
%dir %attr(-, %{package},%{package}) %{_localstatedir}/log/%{package}
%dir %attr(-, %{package},%{package}) %{_localstatedir}/lib/%{package}
%config(noreplace) %{_sysconfdir}/logrotate.d/%{name}
%doc README.upgrade-rhn example.pl NOCpulse.ini.txt

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Fri Oct 24 2008 Miroslav Suchy <msuchy@redhat.com> 2.0.7-1
- add direct link to tar.gz

* Thu Oct 16 2008 Miroslav Suchy <msuchy@redhat.com> 2.0.6-1
- remove docdir from %%build
- run %%pre only if we install package

* Mon Aug 18 2008 Miroslav Suchy <msuchy@redhat.com> 2.0.4-1
- fix perl modules location

* Tue Aug 12 2008 Miroslav Suchy <msuchy@redhat.com> 2.0.1-2
- make passwd silent
- fix runuser command

* Mon Aug 11 2008 Miroslav Suchy <msuchy@redhat.com>
- fix %%files section

* Fri Aug  8 2008 Miroslav Suchy <msuchy@redhat.com> 2.0.1-1
- add README.upgrade-rhn

* Fri Aug  8 2008 Miroslav Suchy <msuchy@redhat.com> 2.0.1-0
- rewrite %%description
- add logrotate script
- rename to nocpulse-common
- merge with np-config

* Fri Jul  4 2008 Dan Horak <dan[at]danny.cz> 1.17.11-7
- clean spec for initial Fedora package

* Thu Jun 26 2008 Miroslav Suchy <msuchy@redhat.com>
- moving directories to complain LSB
- removing nocops user
- cleaning up spec file
- remove setting up root password

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Wed May 21 2008 Miroslav Suchy <msuchy@redhat.com> 1.17.11-6
- migrate to brew / dist-cvs
