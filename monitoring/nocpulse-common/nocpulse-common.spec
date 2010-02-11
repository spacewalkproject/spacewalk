Name:         nocpulse-common
Version:      2.1.19
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
* Thu Feb 11 2010 Miroslav Suchý <msuchy@redhat.com> 2.1.19-1
- Fedora guys do not want to have migration code in theirs spec
 
* Thu Sep 17 2009 Miroslav Suchý <msuchy@redhat.com> 2.1.18-1
- 476851 - removal of tables: rhn_db_environment, rhn_environment

* Mon Jul 27 2009 John Matthews <jmatthew@redhat.com> 2.1.17-1
- specify login shell for useradd (msuchy@redhat.com)
- 457011 - add warning to top of file. This file should not be edited manualy
  (msuchy@redhat.com)
- 457011 - create NOCpulse-ini - tool to handle NOCpulse.ini
  (msuchy@redhat.com)

* Thu Jun 25 2009 John Matthews <jmatthew@redhat.com> 2.1.16-1
- don't print error when files to be moved don't exist (mzazrivec@redhat.com)
- Don't to migrate log files from /home/nocpulse/var (mzazrivec@redhat.com)

* Tue Jun 16 2009 Miroslav Suchý <msuchy@redhat.com> 2.1.15-1
- fix problem when nocpulse user do not exist

* Wed Jun 03 2009 Milan Zazrivec <mzazrivec@redhat.com> 2.1.14-1
- switch nocpulse to a system user if needed

* Mon May 11 2009 Milan Zazrivec <mzazrivec@redhat.com> 2.1.13-1
- 498257 - migrate existing files into new nocpulse homedir

* Mon May 11 2009 Miroslav Suchý <msuchy@redhat.com> 2.1.12-1
- 499568 - require scout_shared_key for requesting NOCpulse.ini

* Wed Apr 22 2009 Jan Pazdziora 2.1.10-1
- 497064 - do not inherit crond's stdin

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
