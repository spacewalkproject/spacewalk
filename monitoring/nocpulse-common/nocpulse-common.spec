Name:         nocpulse-common
Version:      2.1.9
Release:      1%{?dist}
Summary:      NOCpulse common
License:      GPLv2
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Group:        Applications/System
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires(pre):  httpd, /usr/sbin/useradd
Requires(post): /sbin/runuser, openssh
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
# merging this two packages together
# not backward compatible => no Provides:
Obsoletes:     NPusers <= 1.17.50-1
Obsoletes:     np-config <= 2.110.50-1

Obsoletes:     nslogs < 2.3.0
Provides:      nslogs = 2.3.0
Obsoletes:     ConfigPusher-general < 1.3.0
Provides:      ConfigPusher-general = 1.3.0

%define package_name nocpulse
%define identity %{_var}/lib/%{package_name}/.ssh/nocpulse-identity

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

mkdir -p %{buildroot}%{_sysconfdir}/%{package_name}
mkdir -p %{buildroot}%{_var}/log/%{package_name}
mkdir -p %{buildroot}%{_var}/lib/%{package_name}/.ssh

# install log rotation stuff
mkdir -p $RPM_BUILD_ROOT/etc/logrotate.d
install -m644 nocpulse.logrotate \
   $RPM_BUILD_ROOT/etc/logrotate.d/%{name}

mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}
install -m644 NOCpulse.ini $RPM_BUILD_ROOT/%{_sysconfdir}/%{package_name}/NOCpulse.ini
install -m644 forward $RPM_BUILD_ROOT/%{_var}/lib/%{package_name}/.forward
mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Config/test
mkdir -p $RPM_BUILD_ROOT%{_bindir}
install -m644 perl-API/NOCpulse/Config.pm          $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/
install -m644 perl-API/NOCpulse/NOCpulseini.pm     $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/
install -m644 perl-API/NOCpulse/test/TestConfig.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Config/test/
install -m 755 npConfigValue $RPM_BUILD_ROOT%{_bindir}/

%pre
if [ $1 -eq 1 ] ; then
  getent group %{package_name} >/dev/null || groupadd -r %{package_name}
  getent passwd %{package_name} >/dev/null || \
  useradd -r -g %{package_name} -G apache -d %{_var}/lib/%{package_name} -c "NOCpulse user" %{package_name}
  /usr/bin/passwd -l %{package_name} >/dev/null
  exit 0
fi
# Old NOCpulse packages has home in /home/nocpulse.
# We need to migrate them to new place.
if getent passwd %{package_name} >/dev/null && [ -d /home/nocpulse ]; then
  /usr/sbin/usermod -d %{_var}/lib/%{package_name} -m nocpulse
  rm -rf %{_var}/lib/nocpulse/bin
  rm -rf %{_var}/lib/nocpulse/var
fi
# if user already exist (rhnmd create it too) add nocpulse to apache group
getent group apache | grep nocpulse >/dev/null || usermod -G apache nocpulse

%post
if [ ! -f %{identity} ]
then
    /sbin/runuser -s /bin/bash -c "/usr/bin/ssh-keygen -q -t dsa -N '' -f %{identity}" - %{package_name}
fi

%files
%defattr(-, root,root,-)
%dir %{_sysconfdir}/nocpulse
%config(missingok,noreplace) %{_sysconfdir}/%{package_name}/NOCpulse.ini
%config(missingok,noreplace) %attr(-, %{package_name},%{package_name}) %{_var}/lib/%{package_name}/.forward
%{_bindir}/npConfigValue
%dir %{perl_vendorlib}/NOCpulse
%{perl_vendorlib}/NOCpulse/*
%dir %attr(775, %{package_name},apache) %{_var}/log/%{package_name}
%dir %attr(-, %{package_name},%{package_name}) %{_var}/lib/%{package_name}
%dir %attr(700, %{package_name},%{package_name})%{_var}/lib/%{package_name}/.ssh
%config(noreplace) %{_sysconfdir}/logrotate.d/%{name}
%doc README.upgrade-rhn example.pl NOCpulse.ini.txt

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Fri Apr 10 2009 Miroslav Suchý <msuchy@redhat.com> 2.1.9-1
- 494538 - remove the dependecy of rhnmd on nocpulse-common

* Wed Mar 25 2009 Miroslav Suchý <msuchy@redhat.com> 2.1.8-1
- be sure that nocpulse home is correct after upgrade

* Thu Mar  5 2009 Miroslav Suchý <msuchy@redhat.com> 2.1.7-1
- keep last 5 logs in logrotate

* Wed Mar  4 2009 Miroslav Suchý <msuchy@redhat.com> 2.1.6-1
- 435203 - set /var/log/nocpulse writeable by apache user

* Thu Feb 19 2009 Miroslav Suchý <msuchy@redhat.com> 2.1.5-1
- 435415 - redirect nocops emails to root

* Wed Jan 28 2009 Dennis Gilmore <dennis@ausil.us> 2.1.2-1
- fix Requires so we need the perl version we built against

* Wed Dec 10 2008 Miroslav Suchy <msuchy@redhat.com> 2.1.1-1
- 474551 - obsolete nslogs and ConfigPusher-General
- bump up version for 0.4 branch

* Tue Nov  4 2008 Miroslav Suchy <msuchy@redhat.com> 2.0.14-1
- 469708 - obsolete newer np-config

* Fri Oct 31 2008 Miroslav Suchy 2.0.13-1
- 469222 - add .ssh directory

* Thu Oct 30 2008 Miroslav Suchy 2.0.10-1
- renaming package macro to package_name 
- using _var instead of localstatedir

* Wed Oct 29 2008 Miroslav Suchy 2.0.9-1
- BZ 468514 - removing tcsh as explicit shell

* Fri Oct 24 2008 Miroslav Suchy <msuchy@redhat.com> 2.0.8-1
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
