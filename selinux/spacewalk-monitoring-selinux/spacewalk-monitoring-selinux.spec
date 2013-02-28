
%define selinux_variants mls strict targeted
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define POLICYCOREUTILSVER 1.33.12-1

%define moduletype apps
%define modulename spacewalk-monitoring

Name:           spacewalk-monitoring-selinux
Version:        1.9.1
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
%doc %{modulename}.fc %{modulename}.if %{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
%attr(0755,root,root) %{_sbindir}/%{name}-enable

%changelog
* Fri Jan 04 2013 Jan Pazdziora 1.9.1-1
- Allow rhnmd to traverse /var/lib/nocpulse on Spacewalk server.

* Thu Aug 02 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.4-1
- 650735 - fix context of /usr/share/nocpulse/cgi-bin

* Fri Jul 27 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.3-1
- 650735 - set proper context for cgi scripts

* Thu Jul 19 2012 Jan Pazdziora 1.8.2-1
- Allow monitoring to use local PostgreSQL.

* Fri Jun 29 2012 Jan Pazdziora 1.8.1-1
- Make java_t bits optional, as Fedora 17 does not have this type.
- %%defattr is not needed since rpm 4.4

* Tue Feb 07 2012 Miroslav Suchý 1.7.2-1
- set selinux context for /etc/NOCpulse.ini

* Tue Feb 07 2012 Miroslav Suchý 1.7.1-1
- allow monitoring to connect to PostgreSQL
- Bumping package versions for 1.7. (mzazrivec@redhat.com)

* Fri Aug 05 2011 Jan Pazdziora 1.6.2-1
- 588923 - Allow sendmail to use Mail::Mailer (and send email).

* Thu Jul 21 2011 Jan Pazdziora 1.6.1-1
- Revert "Fedora 15 uses oracledb_port_t instead of oracle_port_t."

* Mon Jul 18 2011 Jan Pazdziora 1.5.1-1
- Fedora 15 uses oracledb_port_t instead of oracle_port_t.

* Thu Jan 20 2011 Tomas Lestach <tlestach@redhat.com> 1.3.1-1
- Bumping package versions for 1.3. (jpazdziora@redhat.com)

* Tue Oct 12 2010 Jan Pazdziora 1.2.3-1
- Make the Oracle part of the spacewalk-monitoring SELinux policy module
  optional as well.

* Fri Oct 08 2010 Jan Pazdziora 1.2.2-1
- Since the package SatConfig-dbsynch is gone, remove dependencies that were
  requiring it.

* Mon Oct 04 2010 Jan Pazdziora 1.2.1-1
- 619014 - allow monitoring to read usr files as that's where some perl module
  now live.

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to future 1.1 packages

