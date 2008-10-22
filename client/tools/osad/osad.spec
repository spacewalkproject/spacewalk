%define rhnroot /usr/share/rhn
%define rhnconf /etc/sysconfig/rhn
%define client_caps_dir /etc/sysconfig/rhn/clientCaps.d
%{!?pythongen:%define pythongen %(%{__python} -c "import sys ; print sys.version[:3]")}

Name: osad
Summary: OSAD agent
Group: RHN/Server
License: GPLv2
Source0: %{name}-%{version}.tar.gz
Version: 0.3.2
Release: 1%{?dist}
BuildRoot: /var/tmp/%{name}-%{version}-root
BuildArch: noarch
Requires: python
Requires: rhnlib >= 1.8-3
Requires: jabberpy
Requires: python-optik
# This should have been required by rhnlib
Requires: PyXML
%if "%{pythongen}" == "1.5"
Requires: python-iconv
%endif
Conflicts: osa-dispatcher < %{version}-%{release}
Conflicts: osa-dispatcher > %{version}-%{release}
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts

%description 
OSAD agent

%package -n osa-dispatcher
Summary: OSA dispatcher
Group: RHN/Server
Requires: spacewalk-backend-server
Requires: jabberpy
Conflicts: %{name} < %{version}-%{release}
Conflicts: %{name} > %{version}-%{release}
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts

%description -n osa-dispatcher
OSA dispatcher

%prep
%setup -q

%build
make -f Makefile.osad all

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{rhnroot}
make -f Makefile.osad install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot}
# Create the auth file
touch $RPM_BUILD_ROOT%{_sysconfdir}/sysconfig/rhn/osad-auth.conf

%clean
rm -rf $RPM_BUILD_ROOT

%post
if [ -f %{_sysconfdir}/init.d/osad ]; then
    /sbin/chkconfig --add osad
fi

%preun
if [ $1 = 0 ]; then
    /sbin/service osad stop > /dev/null 2>&1
    /sbin/chkconfig --del osad
fi

%post -n osa-dispatcher
if [ -f %{_sysconfdir}/init.d/osa-dispatcher ]; then
    /sbin/chkconfig --add osa-dispatcher
fi

%preun -n osa-dispatcher
if [ $1 = 0 ]; then
    /sbin/service osa-dispatcher stop > /dev/null 2>&1
    /sbin/chkconfig --del osa-dispatcher
fi

%files
%defattr(-,root,root)
%dir %{rhnroot}/osad
%attr(755,root,root) %{_sbindir}/osad
%{rhnroot}/osad/__init__.py*
%{rhnroot}/osad/_ConfigParser.py*
%{rhnroot}/osad/jabber_lib.py*
%{rhnroot}/osad/osad.py*
%{rhnroot}/osad/osad_client.py*
%{rhnroot}/osad/osad_config.py*
%{rhnroot}/osad/rhn_log.py*
%{rhnroot}/osad/rhnLockfile.py*
%{rhnroot}/osad/rhn_fcntl.py*
%config(noreplace) %{_sysconfdir}/sysconfig/rhn/osad.conf
%config(noreplace) %attr(600,root,root) %{_sysconfdir}/sysconfig/rhn/osad-auth.conf
%{client_caps_dir}/*
%attr(755,root,root) %{_sysconfdir}/init.d/osad

%files -n osa-dispatcher
%defattr(-,root,root)
%dir %{rhnroot}/osad
%attr(755,root,root) %{_sbindir}/osa-dispatcher
%{rhnroot}/osad/__init__.py*
%{rhnroot}/osad/jabber_lib.py*
%{rhnroot}/osad/osa_dispatcher.py*
%{rhnroot}/osad/dispatcher_client.py*
%{rhnroot}/osad/rhn_log.py*
%config(noreplace) %{_sysconfdir}/logrotate.d/osa-dispatcher
%config(noreplace) %{_sysconfdir}/rhn/default/rhn_osa-dispatcher.conf
%attr(755,root,root) %{_sysconfdir}/init.d/osa-dispatcher

# $Id$
%changelog
* Tue Oct 21 2008 Michael Mraka <michael.mraka@redhat.com> 0.3.2-1
- resolves #467717 - fixed sysvinit scripts

* Wed Sep 24 2008 Milan Zazrivec 0.3.1-1
- bumped version for spacewalk 0.3

* Tue Sep  2 2008 Pradeep Kilambi <pkilambi@redhat.com> 0.2-1
- fix osa-dispatcher to depend on new server package

* Thu Jun 12 2008 Pradeep Kilambi <pkilambi@redhat.com>  - 5.2.0-1
- new build

* Tue Jan  25 2008 Jan Pazdziora - 5.1.0-7
- Resolves #429578, OSAD suspending

* Tue Jan  8 2008 Jan Pazdziora - 5.1.0-6
- Resolves #367031, OSAD daemon hard looping
- Resolves #426201, Osad connects to Satellite at times instead of Proxy

* Thu Oct 18 2007 James Slagle <jslagle@redhat.com> - 5.1.0-4
- Resolves #185476

* Tue Oct 08 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.1.0-3
- new build

* Tue Sep 25 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.1.0-2
- get rid of safe-rhn-check and use rhn_check

* Tue Sep 25 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.1.0-1
- bumping version for consistency

* Thu Apr 12 2007 Pradeep Kilambi <pkilambi@redhat.com> - 0.9.2-1
- adding dist tags

* Thu Oct 05 2006 James Bowes <jbowes@redhat.com> - 0.9.1-2
- Get python version dynamically.

* Wed Sep 20 2006 James Bowes <jbowes@redhat.com> - 0.9.1-1
- Set logrotate to limit the log file to 100M.

* Wed Jun 30 2004 Mihai Ibanescu <misa@redhat.com>
- First build
