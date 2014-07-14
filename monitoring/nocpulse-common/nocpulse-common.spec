%if 0%{?fedora} || 0%{?rhel} > 6
%global sbinpath %{_sbindir}
%else
%global sbinpath /sbin
%endif

Name:         nocpulse-common
Version:      2.3.0
Release:      1%{?dist}
Summary:      NOCpulse common
License:      GPLv2
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Group:        Applications/System
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires(pre):  httpd, /usr/sbin/useradd
Requires(post): openssh
Requires(post): %{sbinpath}/runuser
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
%if 0%{?fedora}
install -m644 nocpulse.logrotate.new \
   $RPM_BUILD_ROOT/etc/logrotate.d/%{name}
%else
install -m644 nocpulse.logrotate.old \
   $RPM_BUILD_ROOT/etc/logrotate.d/%{name}
%endif
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}
install -m644 NOCpulse.ini $RPM_BUILD_ROOT/%{_sysconfdir}/NOCpulse.ini
install -m755 -d $RPM_BUILD_ROOT/%{_sysconfdir}/%{package_name}/NOCpulse/tmp
install -m644 forward $RPM_BUILD_ROOT/%{_var}/lib/%{package_name}/.forward
mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Config/test
mkdir -p $RPM_BUILD_ROOT%{_bindir}
install -m644 perl-API/NOCpulse/Config.pm          $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/
install -m644 perl-API/NOCpulse/NOCpulseini.pm     $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/
install -m644 perl-API/NOCpulse/test/TestConfig.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Config/test/
install -m 755 npConfigValue $RPM_BUILD_ROOT%{_bindir}/

%pre
# change nocpulse user & group to system user & group if needed
dirs="/home/nocpulse /opt/notification /opt/nocpulse /var/log/nocpulse /var/www/templates /var/tmp"

# Fedora guys do not want this stuff
%if ! 0%{?fedora}
if [ -d /home/nocpulse -a 0`id -u nocpulse 2> /dev/null` -ge 500 ]; then
	if [ 0`id -g nocpulse` -ge 500 ]; then
		groupmod -n nocpulse-old nocpulse
		groupadd -r nocpulse
		usermod -g nocpulse nocpulse
		# chgrp of existing fs objects owned by previous nocpulse group
		for i in $dirs; do
			find $i -group nocpulse-old -exec chgrp nocpulse '{}' ';'
		done
		groupdel nocpulse-old
	fi

	# find lowest unused system uid to change nocpulse uid to
	old_uid=`id -u nocpulse`
	useradd -r tempnoc -s /bin/bash
	uid=`id -u tempnoc`
	userdel tempnoc
	usermod -u $uid nocpulse

	# chown of existing fs objects owned by previous nocpulse user
	for i in $dirs; do
		find $i -user $old_uid -exec chown nocpulse '{}' ';'
	done
fi
%endif


getent group %{package_name} >/dev/null || groupadd -r %{package_name}
getent passwd %{package_name} >/dev/null || \
useradd -r -g %{package_name} -G apache -d %{_var}/lib/%{package_name} -s /bin/bash -c "NOCpulse user" %{package_name}
/usr/bin/passwd -l %{package_name} >/dev/null

# if user already exists (rhnmd creates it too) add nocpulse to apache group
getent group apache | grep nocpulse >/dev/null || usermod -G apache nocpulse

%post
# Fedora guys do not want this stuff
%if ! 0%{?fedora}
# migrate things from /home/nocpulse to /var/lib/nocpulse and /var/log/nocpulse
if [ `getent passwd nocpulse|awk -F ':' '{ print $6 }'` = "/home/nocpulse" ]; then
  # /var/lib/nocpulse is new homedir for nocpulse user
  usermod -d %{_var}/lib/%{package_name} nocpulse
  [ -f /home/nocpulse/etc/SatCluster.ini ] && mv /home/nocpulse/etc/SatCluster.ini %{_sysconfdir}/nocpulse
  mv /home/nocpulse/.ssh/* %{_var}/lib/%{package_name}/.ssh
  mv /home/nocpulse/.bash* /home/nocpulse/var/*.db \
     /home/nocpulse/var/scheduler.xml /home/nocpulse/var/events.frozen \
     %{_var}/lib/%{package_name} 2>/dev/null
  # archive of log files into /var/log/nocpulse
  mv /home/nocpulse/var/archives/* \
     %{_var}/log/%{package_name} 2> /dev/null
fi
%endif

if [ ! -f %{identity} ]
then
    %{sbinpath}/runuser -s /bin/bash -c "/usr/bin/ssh-keygen -q -t dsa -N '' -f %{identity}" - %{package_name}
fi

%files
%dir %{_sysconfdir}/nocpulse
%config(missingok,noreplace) %{_sysconfdir}/NOCpulse.ini
%{_sysconfdir}/%{package_name}/NOCpulse
%attr(-, %{package_name},%{package_name}) %{_sysconfdir}/%{package_name}/NOCpulse/tmp
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
* Mon Jun 23 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.9-1
- fixed runuser path on RHEL7

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.8-1
- spec file polish

* Fri Mar 22 2013 Michael Mraka <michael.mraka@redhat.com> 2.2.7-1
- 919468 - fixed path in file based Requires

* Fri Mar 08 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.2.6-1
- Fedora 19 does not provide /sbin/runuser
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Fri Nov 02 2012 Miroslav Suchý <msuchy@redhat.com> 2.2.5-1
- Fedora 19 does not provide /sbin/runuser
- %%defattr is not needed since rpm 4.4

* Wed Feb 01 2012 Jan Pazdziora 2.2.4-1
- Now we use RHN::DBI, the database handle is brand new, let's disconnect as
  well.

* Tue Jan 31 2012 Jan Pazdziora 2.2.3-1
- In monitoring, use RHN::DBI instead of RHN::DB because we do not want to
  reuse the connection.

* Fri Jan 27 2012 Jan Pazdziora 2.2.2-1
- Loading NOCpulse::Config here makes the empty content cached, removing.
- Fixing typo (%FILE_CONTENTS), fixing missing $self, adding use strict.

* Tue Nov 22 2011 Miroslav Suchý 2.2.1-1
- bump up version
- 755963 - logrotate nocpulse even on Fedora 16

* Thu Jun 02 2011 Miroslav Suchý 2.1.24-1
- 710002 - create initial NOCpulse.ini on correct place

* Mon May 02 2011 Jan Pazdziora 2.1.23-1
- The close of IO::AtomicFile can also die, we should catch it right there.

* Fri Mar 18 2011 Michael Mraka <michael.mraka@redhat.com> 2.1.22-1
- fixed ownership of NOCpulse/tmp directory
- fixed function decode does not exist (PG)
- fixed relation "config_parameter" does not exist (PG)
- fixed relation "config_group" does not exist (PG)
- fixed relation "config_macro" does not exist (PG)
- reuse RHN:DB for db connection in monitoring (PG)

* Wed Mar 02 2011 Michael Mraka <michael.mraka@redhat.com> 2.1.21-1
- 493028 - directory for notifications should be created

* Fri Feb 18 2011 Jan Pazdziora 2.1.20-1
- Localize the filehandle globs; also use three-parameter opens.

