%define np_name nocpulse
%define identity %{_var}/lib/%{np_name}/.ssh/ssh_host_dsa_key

Summary:   Red Hat Network Monitoring Daemon
Name:      rhnmd
URL:       https://fedorahosted.org/spacewalk
Source0:   https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:   5.1.4
Release:   1%{?dist}
License:   GPL
Group:     System Environment/Daemons
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:  openssh-server openssh
Conflicts: NPusers nocpulse-common
BuildRequires: pam-devel gcc

%description
rhnmd enables secure ssh-based communication between the monitoring
scout and the monitored host. 

%prep
%setup -q

%build
gcc %{optflags} -Wall -shared rhnmdwrap.c -o librhnmdwrap.so -fPIC

%pre
if [ $1 -eq 1 ] ; then
  getent group %{np_name} >/dev/null || groupadd -r %{np_name}
  getent passwd %{np_name} >/dev/null || \
  useradd -r -g %{np_name} -d %{_var}/lib/%{np_name} -c "RHNMD daemon" %{np_name}
fi

%post
/sbin/chkconfig --add rhnmd

if [ ! -f %{identity} ]
then
    /sbin/runuser -s /bin/bash -c "/usr/bin/ssh-keygen -q -t dsa -N '' -f %{identity}" - %{np_name}
fi

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{_usr}/sbin
mkdir -p $RPM_BUILD_ROOT%{_usr}/lib
mkdir -p $RPM_BUILD_ROOT%{_initrddir}
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/%{np_name}
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/%{np_name}/.ssh
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/pam.d
mkdir -p $RPM_BUILD_ROOT%{_libdir}
ln -sf sshd $RPM_BUILD_ROOT%{_usr}/sbin/rhnmd
install -m 0755 rhnmd-init $RPM_BUILD_ROOT%{_initrddir}/rhnmd
install -m 0644 rhnmd_config $RPM_BUILD_ROOT%{_sysconfdir}/%{np_name}/rhnmd_config
install -m 0600 authorized_keys $RPM_BUILD_ROOT%{_var}/lib/%{np_name}/.ssh/authorized_keys
install -m 0755 rhnmd-wrap $RPM_BUILD_ROOT%{_usr}/sbin/rhnmd-wrap
install -m 0644 rhnmd-pam_config $RPM_BUILD_ROOT%{_sysconfdir}/pam.d/rhnmd
install -m 0755 librhnmdwrap.so $RPM_BUILD_ROOT%{_libdir}/librhnmdwrap.so

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root,root,-)
%{_sysconfdir}/pam.d/rhnmd
%dir %{_var}/lib/%{np_name}
%attr(750,nocpulse,nocpulse) %{_var}/lib/%{np_name}
%attr(700,nocpulse,nocpulse) %{_var}/lib/%{np_name}/.ssh
%config(noreplace) %{_var}/lib/%{np_name}/.ssh/authorized_keys
%{_usr}/sbin/*
%{_libdir}/librhnmdwrap.so
%dir %attr(710,nocpulse,nocpulse) %{_sysconfdir}/%{np_name}
%{_sysconfdir}/%{np_name}/*
%{_initrddir}/rhnmd

%preun
if [ $1 = 0 ]; then
    /sbin/service rhnmd stop > /dev/null 2>&1
    /sbin/chkconfig --del rhnmd
    /usr/sbin/userdel nocpulse
    rm -rf /opt/nocpulse
fi

%changelog
* Tue Jan 13 2009 Milan Zazrivec 5.1.4-1
- bz #479830 - %post error when installing rhnmd-5.1.2-1 on RHEL-5
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

