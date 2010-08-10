
%define selinux_variants mls strict targeted
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define POLICYCOREUTILSVER 1.33.12-1

%define moduletype apps
%define modulename spacewalk-monitoring

Name:           spacewalk-monitoring-selinux
Version:        1.2.0
Release:        1%{?dist}
Summary:        SELinux policy module supporting Spacewalk monitoring

Group:          System Environment/Base
License:        GPLv2+
# This src.rpm is cannonical upstream. You can obtain it using
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd spacewalk
# make srpm TAG=%{name}-%{version}-%{release}
URL:            http://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  checkpolicy, selinux-policy-devel, hardlink
BuildRequires:  policycoreutils >= %{POLICYCOREUTILSVER}
BuildArch:      noarch

%if "%{selinux_policyver}" != ""
Requires:       selinux-policy >= %{selinux_policyver}
%endif
%if 0%{?rhel} == 5
Requires:        selinux-policy >= 2.4.6-80
%endif
Requires(post):   /usr/sbin/semodule, /sbin/restorecon, /usr/sbin/selinuxenabled
Requires(postun): /usr/sbin/semodule, /sbin/restorecon
Requires:       oracle-instantclient-selinux
Requires:       nocpulse-common
Requires:       nocpulse-db-perl
Requires:       eventReceivers
Requires:       MessageQueue
Requires:       NOCpulsePlugins
Requires:       NPalert
Requires:       perl-NOCpulse-CLAC
Requires:       perl-NOCpulse-Debug
Requires:       perl-NOCpulse-Gritch
Requires:       perl-NOCpulse-Object
Requires:       perl-NOCpulse-OracleDB
Requires:       perl-NOCpulse-PersistentConnection
Requires:       perl-NOCpulse-Probe
Requires:       perl-NOCpulse-ProcessPool
Requires:       perl-NOCpulse-Scheduler
Requires:       perl-NOCpulse-SetID
Requires:       perl-NOCpulse-Utils
Requires:       ProgAGoGo
Requires:       SatConfig-bootstrap
Requires:       SatConfig-bootstrap-server
Requires:       SatConfig-cluster
Requires:       SatConfig-dbsynch
Requires:       SatConfig-general
Requires:       SatConfig-generator
Requires:       SatConfig-installer
Requires:       SatConfig-spread
Requires:       scdb
Requires:       SNMPAlerts
Requires:       SputLite-client
Requires:       SputLite-server
Requires:       ssl_bridge
Requires:       status_log_acceptor
Requires:       tsdb


%description
SELinux policy module supporting Spacewalk monitoring.

%prep
%setup -q

%build
# Build SELinux policy modules
perl -i -pe 'BEGIN { $VER = join ".", grep /^\d+$/, split /\./, "%{version}.%{release}"; } s!\@\@VERSION\@\@!$VER!g;' %{modulename}.te
for selinuxvariant in %{selinux_variants}
do
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile
    mv %{modulename}.pp %{modulename}.pp.${selinuxvariant}
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile clean
done

%install
rm -rf %{buildroot}

# Install SELinux policy modules
for selinuxvariant in %{selinux_variants}
  do
    install -d %{buildroot}%{_datadir}/selinux/${selinuxvariant}
    install -p -m 644 %{modulename}.pp.${selinuxvariant} \
           %{buildroot}%{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp
  done

# Install SELinux interfaces
install -d %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}
install -p -m 644 %{modulename}.if \
  %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

# Hardlink identical policy module packages together
/usr/sbin/hardlink -cv %{buildroot}%{_datadir}/selinux

# Install spacewalk-monitoring-selinux-enable which will be called in %post
install -d %{buildroot}%{_sbindir}
install -p -m 755 %{name}-enable %{buildroot}%{_sbindir}/%{name}-enable

%clean
rm -rf %{buildroot}

%post
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/%{name}-enable
fi

%posttrans
#this may be safely remove when BZ 505066 is fixed
if /usr/sbin/selinuxenabled ; then
  /sbin/restorecon -rv /etc/rc.d/np.d /etc/notification /var/lib/nocpulse /var/lib/notification /var/log/nocpulse
  /sbin/restorecon -rvi /var/log/SysVStep.* /var/run/SysVStep.*
fi

%postun
# Clean up after package removal
if [ $1 -eq 0 ]; then
  for selinuxvariant in %{selinux_variants}
    do
      /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 \
        && /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} || :
    done
fi

/sbin/restorecon -rvi /etc/rc.d/np.d /etc/notification /var/lib/nocpulse /var/lib/notification /var/log/nocpulse
/sbin/restorecon -rvi /var/log/SysVStep.* /var/run/SysVStep.*

%files
%defattr(-,root,root,0755)
%doc %{modulename}.fc %{modulename}.if %{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
%attr(0755,root,root) %{_sbindir}/%{name}-enable

%changelog
* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to future 1.1 packages

* Mon Feb 01 2010 Jan Pazdziora 0.8.3-1
- 529570 - allow monitoring to use winbind

* Mon Feb 01 2010 Jan Pazdziora 0.8.2-1
- 558448 - define context for /etc/nocpulse/SatCluster.ini

* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- rebuild for spacewalk 0.8

* Mon Nov 30 2009 Jan Pazdziora 0.7.1-1
- allow dequeue to utime the log file, to achieve heartbeating
- bumping Version to 0.7.0 (jmatthew@redhat.com)

* Mon Aug 10 2009 Jan Pazdziora 0.6.13-1
- 516073 - allow monitoring to setpgid self

* Thu Jun 18 2009 Jan Pazdziora 0.6.12-1
- 505606 - Require at least selinux-policy 2.4.6-80

* Mon Jun 15 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.11-1
- 498611 - run "semodule -i" in %%post and restorecon in %%posttrans

* Wed Jun 10 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.10-1
- 504649 - give /var/tmp/escalator.state context of spacewalk_monitoring_var_lib_t
- 498611 - Require all monitoring packages so the files already exist when we run restorecon
- 498611 - Require perl-NOCpulse-Scheduler so /var/lib/nocpulse/NPkernel.out already exist when we run restorecon
- spacewalk_monitoring_conf_t for /etc/NOCpulse.ini (mzazrivec@redhat.com)
- 501546 - Require tsdb so that /var/log/nocpulse/TSDBLocalQueue already exists when we run restorecon (jpazdziora@redhat.com)
- 500330 - allow httpd_sys_script_t to bind to loopback as well (jpazdziora@redhat.com)
- 498611 - run restorecon in %%posttrans

* Tue May 26 2009 Jan Pazdziora 0.6.8-1
- 498941 - allow monitoring to connect to ftp
- 498930 - allow monitoring to do rpc
- 498458 - allow monitoring to run df

* Tue May 12 2009 Jan Pazdziora 0.6.7-1
- 498936 - allow monitoring to run ssh probe (connect to sshd port)

* Tue May 12 2009 Jan Pazdziora 0.6.6-1
- 498053 - allow monitoring to read MySQL's files and connect to database

* Mon May 11 2009 Jan Pazdziora 0.6.5-1
- Move Requires of oracle-instantclient-selinux from
  spacewalk(-proxy)-monitoring to spacewalk-monitoring-selinux

* Tue May 05 2009 Jan Pazdziora 0.6.4-1
- 499189 - spacewalk-selinux is not needed, do not Require it

* Mon Apr 27 2009 Jan Pazdziora <jpazdziora@redhat.com> 0.6.3-1
- move the %%post SELinux activation to /usr/sbin/spacewalk-monitoring-selinux-enable
- use src.rpm packaging with single Source0

* Thu Apr 09 2009 Jan Pazdziora 0.6.2-1
- 489576 - address SELinux issues related to monitoring probes
- other SELinux-monitoring fixes.

* Tue Apr 07 2009 Jan Pazdziora 0.6.1-1
- 489554 - fix AVC denial of httpd_sys_script_t (upload_results.cgi)
- bump Versions to 0.6.0 (jesusr@redhat.com)

* Mon Mar 16 2009 Jan Pazdziora 0.5.6-1
- donatudit sys_tty_config
- 487221 - allow monitoring to use NIS

* Fri Mar 13 2009 Jan Pazdziora 0.5.5-1
- 487280 - allow monitoring to write to console and communicate with initrc_t

* Tue Feb 10 2009 Jan Pazdziora 0.5.4-1
- allow httpd to manage /var/lib/notification

* Mon Feb  9 2009 Jan Pazdziora 0.5.3-1
- dontaudit attempts to read /etc/shadow
- allow CGI scripts to read monitoring configuration
- allow monitoring to manage spacewalk_monitoring_var_lib_t directories as well
- allow Apache to read monitoring's configuration
- allow npBootstrap.pl to connect to https
- relabel existing /var/log and /var/run files

* Sun Feb  1 2009 Jan Pazdziora 0.5.2-1
- enabled monitoring services start and stop without SELinux errors
  except for read of /etc/shadow

* Sat Jan 31 2009 Jan Pazdziora 0.5.1-1
- disabled monitoring services start and stop without SELinux errors
- monitoring can be enabled on the WebUI without SELinux errors

* Fri Jan 30 2009 Jan Pazdziora 0.5.0-1
- the initial release
- base on spacewalk-selinux
