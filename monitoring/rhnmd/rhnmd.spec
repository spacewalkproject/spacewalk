%global np_name nocpulse
%global identity %{_var}/lib/%{np_name}/.ssh/nocpulse-identity
%if 0%{!?_initddir:1}
%global _initddir %{_sysconfdir}/rc.d/init.d
%endif

Summary:        Red Hat Network Monitoring Daemon
Name:           rhnmd
URL:            https://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:        5.3.4
Release:        1%{?dist}
License:        GPLv2
BuildArch:      noarch
Group:          System Environment/Daemons
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       openssh-server openssh
BuildRequires:  pam-devel

%description
rhnmd enables secure ssh-based communication between the monitoring
scout and the monitored host. 

%prep
%setup -q

%build
#nothing to do

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{_usr}/sbin
mkdir -p $RPM_BUILD_ROOT%{_usr}/lib
mkdir -p $RPM_BUILD_ROOT%{_initddir}
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/%{np_name}
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/%{np_name}/.ssh
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/pam.d
mkdir -p $RPM_BUILD_ROOT%{_libdir}
ln -sf sshd $RPM_BUILD_ROOT%{_usr}/sbin/rhnmd
install -pm 0755 rhnmd-init $RPM_BUILD_ROOT%{_initddir}/rhnmd
install -pm 0644 rhnmd_config $RPM_BUILD_ROOT%{_sysconfdir}/%{np_name}/rhnmd_config
install -pm 0600 authorized_keys $RPM_BUILD_ROOT%{_var}/lib/%{np_name}/.ssh/authorized_keys
install -pm 0644 rhnmd-pam_config $RPM_BUILD_ROOT%{_sysconfdir}/pam.d/rhnmd

%pre
if [ $1 -eq 1 ] ; then
  getent group %{np_name} >/dev/null || groupadd -r %{np_name}
  getent passwd %{np_name} >/dev/null || \
  useradd -r -g %{np_name} -d %{_var}/lib/%{np_name} -c "NOCpulse user" %{np_name}
  /usr/bin/passwd -l %{np_name} >/dev/null
  exit 0
fi
# Old NOCpulse packages has home in /home/nocpulse.
# We need to migrate them to new place.
if getent passwd %{np_name} >/dev/null && [ -d /home/nocpulse ]; then
  /usr/sbin/usermod -d %{_var}/lib/%{np_name} -m nocpulse
  rm -rf %{_var}/lib/nocpulse/bin
  rm -rf %{_var}/lib/nocpulse/var
fi

%post
if [ ! -f %{identity} ]
then
    /sbin/runuser -s /bin/bash -c "/usr/bin/ssh-keygen -q -t dsa -N '' -f %{identity}" - %{np_name}
fi
/sbin/chkconfig --add rhnmd

%preun
if [ $1 = 0 ]; then
    /sbin/service rhnmd stop > /dev/null 2>&1
    /sbin/chkconfig --del rhnmd
fi

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root,root,-)
%config(noreplace) %{_sysconfdir}/pam.d/rhnmd
%dir %attr(-, %{np_name},%{np_name}) %{_var}/lib/%{np_name}
%dir %attr(700, %{np_name},%{np_name}) %{_var}/lib/%{np_name}/.ssh
%config(noreplace) %attr(-, %{np_name},%{np_name}) %{_var}/lib/%{np_name}/.ssh/authorized_keys
%{_usr}/sbin/rhnmd
%config(noreplace) %{_sysconfdir}/%{np_name}/rhnmd_config
%{_initddir}/rhnmd
%doc LICENSE

%changelog
* Wed Dec 16 2009 Miroslav Suchý <msuchy@redhat.com> 5.3.4-1
- 538057 - fix typo
- 538057 - use proper text indention. The content of tags like Name, Version, ... usually starts at 17 characters
- 538057 - move %%preun before %%clean and %%files
- 538057 - do not use wildcards
- 538057 - preserve timestamp of the source files
- 538057 - %%{_initrddir} is considered deprecated on Fedora, but still needed on RHEL
- 538057 - Use %%global instead of %%define

* Mon Nov  2 2009 Miroslav Suchý <msuchy@redhat.com> 5.3.3-1
- make rhnmd package noarch

* Fri Apr 10 2009 Miroslav Suchý <msuchy@redhat.com> 5.3.2-1
- 494538 - remove the dependency of rhnmd on nocpulse-common

* Tue Apr  7 2009 Miroslav Suchý <msuchy@redhat.com> 5.3.1-1
- authorized_keys should be owned by nocpulse
- bump up version to 5.3.0

* Wed Mar 11 2009 Miroslav Suchy <msuchy@redhat.com> 5.1.7-1
- 489573 - remove generating keys and leave it on nocpulse-common

* Sat Feb 28 2009 Dennis Gilmore <dennis@ausil.us> 5.1.6-1
- rebuild 

* Thu Feb 05 2009 jesus m. rodriguez <jesusr@redhat.com> 5.1.5-1
- 479541, 483867 - replaced runuser with /sbin/runuser

* Tue Jan 13 2009 Milan Zazrivec 5.1.4-1
- bz #479830 - %%post error when installing rhnmd-5.1.2-1 on RHEL-5
- package should create nocpulse user instead of rhnmd

* Wed Nov 26 2008 Miroslav Suchy <msuchy@redhat.com> 5.1.2-1
- fix spec so it can actually be build

* Tue Oct 21 2008 Michael Mraka <michael.mraka@redhat.com> 5.1.1-1
- resolves #467877 - use runuser instead of su

* Fri Oct 17 2008 Miroslav Suchy <msuchy@redhat.com> 
- cleanup spec

* Wed Sep 12 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.1.0-1
- new build

* Mon May 24 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.0.0-8
- Resolves#240764

* Mon May 14 2007 Devan Goodwin <dgoodwin@redhat.com> - 5.0.0-6
- Correcting selinux problem with userdel and /opt.

* Mon May 07 2007 Mike McCune <mmccune@redhat.com> - 5.0.0-4
- creating ssh key outside of service startup in order to keep selinux happy

* Wed Mar 07 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.0.0-1
- adding dist tag

* Thu Jun 23 2005 Nick Hansen <nhansen@redhat.com> 4.0.0-8
- enable building on multiple arches

* Thu Jun  9 2005 Nick Hansen <nhansen@redhat.com>
- BZ#159664: adding conflict on NPusers so this can't 
  be installed on Satellite or Proxy monitoring boxes

* Wed Aug  4 2004 Nick Hansen <nhansen@redhat.com>
- Initial build.

