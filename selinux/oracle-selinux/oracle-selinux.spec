
#
# change oracle_base in case of non-standard installation path
#
%define oracle_base /opt/oracle

%define selinux_variants mls strict targeted 
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define modulename oracle
%define moduletype apps
%define default_oracle_base /opt/oracle

#
# tag to be used in release to differentiate rpms with the same policy but
# with different oracle_bases
#
%if "%{oracle_base}" != "%{default_oracle_base}"
%define obtag %(echo %{?oracle_base} | sed 's#/#.#g' 2>/dev/null)
%endif

Name:            oracle-selinux
Version:         0.1.23.34
Release:         1%{?obtag}%{?dist}%{?repo}
Summary:         SELinux policy module supporting Oracle
Group:           System Environment/Base
License:         GPLv2+
URL:             http://www.stl.gtri.gatech.edu/rmyers/oracle-selinux/
Source0:         https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:       %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires:   checkpolicy, selinux-policy-devel, hardlink
BuildArch:       noarch

%if "%{selinux_policyver}" != ""
Requires:         selinux-policy >= %{selinux_policyver}
%endif
Requires(post):   /usr/sbin/semanage, /usr/sbin/semodule, /sbin/restorecon
Requires(postun): /usr/sbin/semanage, /usr/sbin/semodule, /sbin/restorecon
Obsoletes:        oracle-10gR2-selinux

%description
SELinux policy module supporting Oracle.

%package -n oracle-nofcontext-selinux
Summary:         SELinux policy module supporting Oracle, without file contexts
Group:           System Environment/Base
%if "%{selinux_policyver}" != ""
Requires:         selinux-policy >= %{selinux_policyver}
%endif
%if 0%{?rhel} == 5
Requires:        selinux-policy-base >= 2.4.6-267
%endif
Requires(post):   /usr/sbin/semanage, /usr/sbin/semodule, /sbin/restorecon, /usr/sbin/selinuxenabled
Requires(postun): /usr/sbin/semanage, /usr/sbin/semodule, /sbin/restorecon
Conflicts:       oracle-selinux

%description -n oracle-nofcontext-selinux
SELinux policy module defining types and interfaces for
Oracle RDBMS, without specifying any file contexts.

%prep
%setup -q

%build
perl -pi -e 's#%{default_oracle_base}#%{oracle_base}#g' %{modulename}.fc

# Create oracle-nofcontext source files
cp %{modulename}.if %{modulename}-nofcontext.if
cp %{modulename}.te %{modulename}-nofcontext.te
sed -i 's!^policy_module(oracle,!policy_module(oracle-nofcontext,!' %{modulename}-nofcontext.te

# Build SELinux policy modules
for selinuxvariant in %{selinux_variants}
do
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile
    mv %{modulename}.pp %{modulename}.pp.${selinuxvariant}
    mv %{modulename}-nofcontext.pp %{modulename}-nofcontext.pp.${selinuxvariant}
    mv %{modulename}-port.pp %{modulename}-port.pp.${selinuxvariant}
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
    install -p -m 644 %{modulename}-nofcontext.pp.${selinuxvariant} \
           %{buildroot}%{_datadir}/selinux/${selinuxvariant}/%{modulename}-nofcontext.pp
    install -p -m 644 %{modulename}-port.pp.${selinuxvariant} \
           %{buildroot}%{_datadir}/selinux/${selinuxvariant}/%{modulename}-port.pp
  done

# Install SELinux interfaces
install -d %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}
install -p -m 644 %{modulename}.if \
  %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
install -p -m 644 %{modulename}-nofcontext.if \
  %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}-nofcontext.if

# Hardlink identical policy module packages together
/usr/sbin/hardlink -cv %{buildroot}%{_datadir}/selinux

# Install oracle-nofcontext-selinux-enable which will be called in %posttrans
install -d %{buildroot}%{_sbindir}
install -p -m 755 oracle-nofcontext-selinux-enable %{buildroot}%{_sbindir}/oracle-nofcontext-selinux-enable

%clean
rm -rf %{buildroot}

%post
# Install SELinux policy modules
for selinuxvariant in %{selinux_variants}
  do
    if /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 ; then
      /usr/sbin/semodule -s ${selinuxvariant} \
        -i %{_datadir}/selinux/${selinuxvariant}/%{modulename}-port.pp \
        -i %{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp > /dev/null 2>&1 \
      || /usr/sbin/semodule -s ${selinuxvariant} \
        -i %{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp || :
    fi
  done

# add an oracle port if it does not already exist
SEPORT_STATUS=`semanage port -l | grep -c ^oracle`
test ${SEPORT_STATUS} -lt 1 && semanage port -a -t oracle_port_t -p tcp 1521 || :

# Fix up non-standard file contexts
/sbin/restorecon -R -v %{oracle_base} || :
/sbin/restorecon -R -v /u0? || :
/sbin/restorecon -R -v /etc || :
/sbin/restorecon -R -v /var/tmp || :

%posttrans
#this may be safely removed when BZ 505066 is fixed
if /usr/sbin/selinuxenabled ; then
  # Fix up non-standard file contexts
  /sbin/restorecon -R -v %{oracle_base} || :
  /sbin/restorecon -R -v /u0? || :
  /sbin/restorecon -R -v /etc || :
  /sbin/restorecon -R -v /var/tmp || :
fi

%post -n oracle-nofcontext-selinux
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/oracle-nofcontext-selinux-enable
fi

%posttrans -n oracle-nofcontext-selinux
if /usr/sbin/selinuxenabled ; then
  # add an oracle port if it does not already exist
  SEPORT_STATUS=`semanage port -l | grep -c ^oracle`
  test ${SEPORT_STATUS} -lt 1 && semanage port -a -t oracle_port_t -p tcp 1521 || :
fi

%postun
# Clean up after package removal
if [ $1 -eq 0 ]; then
 # remove an existing oracle port
 SEPORT_STATUS=`semanage port -l | grep -c ^oracle`
 test ${SEPORT_STATUS} -gt 0 && semanage port -d -t oracle_port_t -p tcp 1521 || :

  # Remove SELinux policy modules
  for selinuxvariant in %{selinux_variants}
    do
      if /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 ; then
        /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} || :
        /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename}-port || :
      fi
    done
  # Clean up any remaining file contexts (shouldn't be any really)
  [ -d %{oracle_base} ] && \
    /sbin/restorecon -R -v %{oracle_base} &> /dev/null || :
  /sbin/restorecon -R -v /u0? || :
  /sbin/restorecon -R -v /etc || :
  /sbin/restorecon -R -v /var/tmp || :
fi

%postun -n oracle-nofcontext-selinux
# Clean up after package removal
if [ $1 -eq 0 ]; then
 # remove an existing oracle port
 SEPORT_STATUS=`semanage port -l | grep -c ^oracle`
 test ${SEPORT_STATUS} -gt 0 && semanage port -d -t oracle_port_t -p tcp 1521 || :

  # Remove SELinux policy modules
  for selinuxvariant in %{selinux_variants}
    do
      if /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 ; then
        /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename}-nofcontext || :
        /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename}-port || :
      fi
    done
fi

%files
%doc %{modulename}.fc %{modulename}.if %{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/*/%{modulename}-port.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

%files -n oracle-nofcontext-selinux
%doc %{modulename}-nofcontext.fc %{modulename}-nofcontext.if %{modulename}-nofcontext.te
%{_datadir}/selinux/*/%{modulename}-nofcontext.pp
%{_datadir}/selinux/*/%{modulename}-port.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}-nofcontext.if
%attr(0755,root,root) %{_sbindir}/oracle-nofcontext-selinux-enable

%changelog
* Thu Jan 17 2013 Jan Pazdziora 0.1.23.34-1
- The rx_file_perms seems no longer available.

* Mon Jul 16 2012 Jan Pazdziora 0.1.23.33-1
- Start using the .tar.gz in the .src.rpm for oracle-selinux.
- %%defattr is not needed since rpm 4.4

* Wed Nov 23 2011 Jan Pazdziora 0.1.23.32-1
- Require the roles.

* Fri Jul 22 2011 Jan Pazdziora 0.1.23.31-1
- We only support version 14 and newer of Fedora, removing conditions for old
  versions.

* Thu Jul 21 2011 Jan Pazdziora 0.1.23.30-1
- Revert "Fedora 15 uses oracledb_port_t instead of oracle_port_t."

* Wed Jul 20 2011 Jan Pazdziora 0.1.23.29-1
- Allow sqlplus to read /sys/.../meminfo.

* Mon Jul 18 2011 Jan Pazdziora 0.1.23.28-1
- Fedora 15 uses oracledb_port_t instead of oracle_port_t.

* Fri Jul 15 2011 Jan Pazdziora 0.1.23.27-1
- Fixing typo -- they actually *are* there now.

* Wed Apr 06 2011 Jan Pazdziora 0.1.23.26-1
- 489548, 565417 - upon ORA-3136, database writes to network/log/sqlnet.log.

* Wed Mar 30 2011 Michael Mraka <michael.mraka@redhat.com> 0.1.23.25-1
- allow unconfined_r to run oracle_lsnrctl_t, oracle_tnslsnr_t and oracle_db_t

* Fri Jan 28 2011 Jan Pazdziora 0.1.23.24-1
- Move the oracle_port_t to separate SELinux policy module.

* Mon Jan 10 2011 Jan Pazdziora 0.1.23.23-1
- Allow sqlplus 11g to read /sys/devices/system/node and /sys/devices/system/cpu.

* Mon Jan 10 2011 Jan Pazdziora 0.1.23.22-1
- Make the user_devpts_t dontaudit part optional.

* Mon Jan 10 2011 Jan Pazdziora 0.1.23.21-1
- The netlink_route_socket is now needed with InstantClient 11g sqlplus.
- More devpts AVC denials on Fedora 13 dontaudited.

* Mon Jan 10 2011 Jan Pazdziora 0.1.23.20-1
- Stop AVCs about /dev/pts.
- Require reasonably new selinux-policy-targeted on Fedora 13.

* Thu Sep 23 2010 Michael Mraka <michael.mraka@redhat.com> 0.1.23.19-1
- switched to default VersionTagger

* Thu Aug 26 2010 Jan Pazdziora 0.1-23.18
- Require newer selinux-policy-base to get configfile.

