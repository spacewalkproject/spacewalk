# Macros

%define cvs_package rhnmd
%define buildroot /tmp/%cvs_package

Summary:   Red Hat Network Monitoring Daemon
Name:      rhnmd
URL:       http://rhn.redhat.com/
Source0:   rhnmdwrap.c
Source1:   rhnmd-init
Source2:   rhnmd_config
Source3:   authorized_keys
Source4:   rhnmd-wrap
Source5:   rhnmd-pam_config
Version:   5.1.0
Release:   1%{?dist}
License:   GPL
Group:     System Environment/Daemons
BuildRoot: /tmp/%buildroot
Requires:  openssh-server openssh
Conflicts: NPusers
BuildRequires: pam-devel

%description
rhnmd package for use with the RHN Monitoring Scout.
This package enables secure ssh-based communication between the monitoring
scout and the monitored host. 

%prep

%build
gcc -Wall -shared %{SOURCE0} -o librhnmdwrap.so -fPIC
strip librhnmdwrap.so

%pre
mkdir -p /opt/nocpulse > /dev/null 2>&1
/usr/sbin/groupadd -g 79 nocpulse > /dev/null 2>&1
/usr/sbin/useradd -c "RHNMD Daemon" -d /opt/nocpulse -u 79 -g nocpulse -r -s /bin/sh nocpulse 2> /dev/null || :          

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT/usr/sbin
mkdir -p $RPM_BUILD_ROOT/usr/lib
mkdir -p $RPM_BUILD_ROOT/etc/init.d
mkdir -p $RPM_BUILD_ROOT/opt/nocpulse/etc
mkdir -p $RPM_BUILD_ROOT/opt/nocpulse/.ssh
mkdir -p $RPM_BUILD_ROOT/etc/pam.d
mkdir -p $RPM_BUILD_ROOT%{_libdir}
ln -sf sshd $RPM_BUILD_ROOT/usr/sbin/rhnmd
install -m 0755 %{SOURCE1} $RPM_BUILD_ROOT/etc/init.d/rhnmd
install -m 0644 %{SOURCE2} $RPM_BUILD_ROOT/opt/nocpulse/etc/rhnmd_config
install -m 0600 %{SOURCE3} $RPM_BUILD_ROOT/opt/nocpulse/.ssh/authorized_keys
install -m 0755 %{SOURCE4} $RPM_BUILD_ROOT/usr/sbin/rhnmd-wrap
install -m 0644 %{SOURCE5} $RPM_BUILD_ROOT/etc/pam.d/rhnmd
install -m 0755 librhnmdwrap.so $RPM_BUILD_ROOT%{_libdir}/librhnmdwrap.so

%clean
rm -rf $RPM_BUILD_ROOT

%files
%attr(-,root,root) /etc/pam.d/rhnmd
%attr(750,nocpulse,nocpulse) /opt/nocpulse
%attr(700,nocpulse,nocpulse) /opt/nocpulse/.ssh
%attr(600,nocpulse,nocpulse) /opt/nocpulse/.ssh/authorized_keys
%config(noreplace) /opt/nocpulse/.ssh/authorized_keys
%defattr(-,nocpulse,nocpulse)
/usr/sbin/rhnmd
/usr/sbin/rhnmd-wrap
%{_libdir}/librhnmdwrap.so
/opt/nocpulse/etc/rhnmd_config
%dir /etc/init.d/rhnmd

%post 
su -s /bin/bash - nocpulse -c "/usr/bin/ssh-keygen -q -t dsa -f /opt/nocpulse/etc/ssh_host_dsa_key -C '' -N ''"
/sbin/chkconfig --add rhnmd
/sbin/service rhnmd start > /dev/null 2>&1

%preun
if [ $1 = 0 ]; then
    /sbin/service rhnmd stop > /dev/null 2>&1
    /sbin/chkconfig --del rhnmd
    /usr/sbin/userdel nocpulse
    rm -rf /opt/nocpulse
fi

%changelog
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

