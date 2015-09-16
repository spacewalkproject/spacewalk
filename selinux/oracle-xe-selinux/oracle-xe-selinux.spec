
%define selinux_variants mls strict targeted 
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define moduletype apps
%define modulename oracle-xe
%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

Name:            oracle-xe-selinux
Version:         10.2.0.41
Release:         1%{?dist}
Summary:         SELinux policy module supporting Oracle XE
Group:           System Environment/Base
License:         GPLv2+
# This src.rpm is canonical upstream.
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd spacewalk
# make srpm TAG=%{name}-%{version}-%{release}
URL:             http://fedorahosted.org/spacewalk
Source0:         https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:       %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires:   checkpolicy, selinux-policy-devel, hardlink
BuildArch:       noarch

%if "%{selinux_policyver}" != ""
Requires:         selinux-policy >= %{selinux_policyver}
%endif
Requires(post):   /usr/sbin/semodule, %{sbinpath}/restorecon, /sbin/ldconfig, /usr/sbin/selinuxenabled
Requires(postun): /usr/sbin/semodule, %{sbinpath}/restorecon
Requires:         /etc/init.d/oracle-xe
Requires:         oracle-nofcontext-selinux
Requires:         oracle-lib-compat

%description
SELinux policy module supporting Oracle XE server.

%prep
%setup -q

%build
# Build SELinux policy modules
perl -i -pe 'BEGIN { $VER = join ".", grep /^\d+$/, split /\./, "%{version}.%{release}"; } s!\@\@VERSION\@\@!$VER!g;' %{modulename}.te
%if 0%{?fedora} || 0%{?rhel} >= 7
cat %{modulename}.te.fedora17 >> %{modulename}.te
%endif
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

%define extra_restorecon /usr/lib/oracle/xe/oradata /usr/lib/oracle/xe/app /var/tmp/.oracle /u01/app/oracle
sed -i -e 's!%%extra_restorecon!%extra_restorecon!g' %{name}-enable

# Install SELinux interfaces
install -d %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}
install -p -m 644 %{modulename}.if \
  %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

# Hardlink identical policy module packages together
/usr/sbin/hardlink -cv %{buildroot}%{_datadir}/selinux

# Install oracle-xe-selinux-enable which will be called in %posttrans
install -d %{buildroot}%{_sbindir}
install -p -m 755 %{name}-enable %{buildroot}%{_sbindir}/%{name}-enable

%clean
rm -rf %{buildroot}

%pre

%if 0%{?fedora} || 0%{?rhel} >= 7
%define min_uid 1000
%else
%define min_uid 500
%endif

ORACLE_UID=`id -u oracle`
if [ -z "$ORACLE_UID" ] ; then
    echo "The oracle user has to exist with uid < %{min_uid} before installing this package."
    exit 1
elif [ $ORACLE_UID -ge %{min_uid} ] ; then
    echo "The oracle user has to exist with uid < %{min_uid} before installing this package."
    echo "User with uid [$ORACLE_UID] found which is not good."
    exit 1
fi

%post
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/%{name}-enable
fi

%posttrans
#this may be safely remove when BZ 505066 is fixed
if /usr/sbin/selinuxenabled ; then
  # Relabel oracle-xe-univ/oracle-xe's files
  rpm -qlf /etc/init.d/oracle-xe | while read i ; do [ -e $i ] && echo $i ; done | xargs -n 100 %{sbinpath}/restorecon -Rivv
  # Fix up additional directories, not owned by oracle-xe-univ/oracle-xe
  %{sbinpath}/restorecon -Rivv %extra_restorecon
fi

%postun
# Clean up after package removal
if [ $1 -eq 0 ]; then
  # Remove SELinux policy modules
  for selinuxvariant in %{selinux_variants}
    do
      /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 \
        && /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} || :
    done

  /usr/sbin/semanage port -d -t oracle_port_t -p tcp 9000 || :
  /usr/sbin/semanage port -d -t oracle_port_t -p tcp 9055 || :

  # Clean up oracle-xe-univ/oracle-xe's files
  rpm -qlf /etc/init.d/oracle-xe | while read i ; do [ -e $i ] && echo $i ; done | xargs -n 100 %{sbinpath}/restorecon -Rivv

  # Clean up additional directories, not owned by oracle-xe-univ/oracle-xe
  %{sbinpath}/restorecon -Rivv %extra_restorecon
fi

%files
%doc %{modulename}.fc %{modulename}.if %{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
%attr(0755,root,root) %{_sbindir}/%{name}-enable

%changelog
* Wed Sep 16 2015 Tomas Kasparek <tkasparek@redhat.com> 10.2.0.41-1
- bz1258563 - selinux fix for fedora 21/22

* Tue Jun 16 2015 Jan Dobes 10.2.0.40-1
- glibc is still providing /sbin/ldconfig

* Thu Feb 19 2015 Tomas Lestach <tlestach@redhat.com> 10.2.0.39-1
- allow oracle_sqlplus_t to search through the rhnsd_conf_t directories

* Wed Feb 18 2015 Tomas Lestach <tlestach@redhat.com> 10.2.0.38-1
- addressing AVC denials on RHEL7

* Fri Sep 26 2014 Michael Mraka <michael.mraka@redhat.com> 10.2.0.37-1
- fixed typo in macro

* Thu Sep 25 2014 Michael Mraka <michael.mraka@redhat.com> 10.2.0.36-1
- updated system uid limit for RHEL7

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 10.2.0.35-1
- spec file polish

* Fri Mar 22 2013 Michael Mraka <michael.mraka@redhat.com> 10.2.0.34-1
- 919468 - fixed path in file based Requires
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Mon Oct 29 2012 Jan Pazdziora 10.2.0.33-1
- Setsebool without -P is rarely needed.

* Tue Oct 16 2012 Jan Pazdziora 10.2.0.32-1
- Lsnrctl wants to search as well.

* Sat Oct 13 2012 Jan Pazdziora 10.2.0.31-1
- corenet_udp_bind_compat_ipv4_node no available on newer OSes.

* Sat Oct 13 2012 Jan Pazdziora 10.2.0.30-1
- Configure of Oracle XE 11 on RHEL 5.

* Tue Oct 09 2012 Jan Pazdziora 10.2.0.29-1
- The auth_read_passwd is not available everywhere.
- We need lib_t.

* Tue Oct 09 2012 Jan Pazdziora 10.2.0.28-1
- Addressing AVC denials on Fedora 17.

* Thu Oct 04 2012 Jan Pazdziora 10.2.0.27-1
- Allowing Oracle XE 11 to read sysfs.

* Thu Oct 04 2012 Jan Pazdziora 10.2.0.26-1
- Allowing Oracle XE 11 to read sysfs.

* Mon Oct 01 2012 Jan Pazdziora 10.2.0.25-1
- Adding file contexts and stuff for oracle-xe-11.2.0-1.0.x86_64.
- %%defattr is not needed since rpm 4.4

* Tue Apr 10 2012 Jan Pazdziora 10.2.0.24-1
- The rman is more like the database server process.
- The backup.sh and restore.sh need to run as sqlplus, so that their log files
  can be used by sqlplus.
- The backup.sh from Oracle XE 10g seems to want to access urandom.
- Allow Oracle database to ptrace self.

* Wed Nov 30 2011 Michael Mraka <michael.mraka@redhat.com> 10.2.0.23-1
- system user uids are < 1000 on Fedora 16

* Thu Jul 21 2011 Jan Pazdziora 10.2.0.22-1
- Revert "Fedora 15 uses oracledb_port_t instead of oracle_port_t."

* Mon Jul 18 2011 Jan Pazdziora 10.2.0.21-1
- Fedora 15 uses oracledb_port_t instead of oracle_port_t.

* Wed Apr 06 2011 Jan Pazdziora 10.2.0.20-1
- 489548, 565417 - upon ORA-3136, database writes to network/log/sqlnet.log.

* Thu Sep 23 2010 Michael Mraka <michael.mraka@redhat.com> 10.2.0.19-1
- switched to default VersionTagger

* Wed Sep 01 2010 Jan Pazdziora 10.2-18
- 629232 - only restorecon files that exist.

* Mon Jul 19 2010 Jan Pazdziora 10.2-17
- 615901 - dontaudit Oracle XE's access to /dev/console.

