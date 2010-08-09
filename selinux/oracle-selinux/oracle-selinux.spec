
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
Version:         0.1
Release:         23.16%{?obtag}%{?dist}%{?repo}
Summary:         SELinux policy module supporting Oracle
Group:           System Environment/Base
License:         GPLv2+
URL:             http://www.stl.gtri.gatech.edu/rmyers/oracle-selinux/
Source1:         %{modulename}.if
Source2:         %{modulename}.te
Source3:         %{modulename}.fc
Source4:         oracle-nofcontext-selinux-enable
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
Requires:        selinux-policy-targeted >= 2.4.6-80
%endif
Requires(post):   /usr/sbin/semanage, /usr/sbin/semodule, /sbin/restorecon, /usr/sbin/selinuxenabled
Requires(postun): /usr/sbin/semanage, /usr/sbin/semodule, /sbin/restorecon
Conflicts:       oracle-selinux

%description -n oracle-nofcontext-selinux
SELinux policy module defining types and interfaces for
Oracle RDBMS, without specifying any file contexts.

%prep
rm -rf SELinux
mkdir -p SELinux
cp -p %{SOURCE1} %{SOURCE2} %{SOURCE3} %{SOURCE4} SELinux

# Make file contexts relative to oracle_base
perl -pi -e 's#%{default_oracle_base}#%{oracle_base}#g' SELinux/%{modulename}.fc

# Create oracle-nofcontext source files
cp SELinux/%{modulename}.if SELinux/%{modulename}-nofcontext.if
cp SELinux/%{modulename}.te SELinux/%{modulename}-nofcontext.te
sed -i 's!^policy_module(oracle,!policy_module(oracle-nofcontext,!' SELinux/%{modulename}-nofcontext.te

%build
# Build SELinux policy modules
cd SELinux
for selinuxvariant in %{selinux_variants}
do
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile
    mv %{modulename}.pp %{modulename}.pp.${selinuxvariant}
    mv %{modulename}-nofcontext.pp %{modulename}-nofcontext.pp.${selinuxvariant}
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile clean
done
cd -

%install
rm -rf %{buildroot}

# Install SELinux policy modules
cd SELinux
for selinuxvariant in %{selinux_variants}
  do
    install -d %{buildroot}%{_datadir}/selinux/${selinuxvariant}
    install -p -m 644 %{modulename}.pp.${selinuxvariant} \
           %{buildroot}%{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp
    install -p -m 644 %{modulename}-nofcontext.pp.${selinuxvariant} \
           %{buildroot}%{_datadir}/selinux/${selinuxvariant}/%{modulename}-nofcontext.pp
  done
cd -

# Install SELinux interfaces
install -d %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}
install -p -m 644 SELinux/%{modulename}.if \
  %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
install -p -m 644 SELinux/%{modulename}-nofcontext.if \
  %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}-nofcontext.if

# Hardlink identical policy module packages together
/usr/sbin/hardlink -cv %{buildroot}%{_datadir}/selinux

# Install oracle-nofcontext-selinux-enable which will be called in %posttrans
install -d %{buildroot}%{_sbindir}
install -p -m 755 SELinux/oracle-nofcontext-selinux-enable %{buildroot}%{_sbindir}/oracle-nofcontext-selinux-enable

%clean
rm -rf %{buildroot}

%post
# Install SELinux policy modules
for selinuxvariant in %{selinux_variants}
  do
    /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 \
      && /usr/sbin/semodule -s ${selinuxvariant} -i \
        %{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp || :
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
      /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 \
        && /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} || :
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
      /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 \
        && /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename}-nofcontext || :
    done
fi

%files
%defattr(-,root,root,0755)
%doc SELinux/%{modulename}.fc SELinux/%{modulename}.if SELinux/%{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

%files -n oracle-nofcontext-selinux
%defattr(-,root,root,0755)
%doc SELinux/%{modulename}-nofcontext.fc SELinux/%{modulename}-nofcontext.if SELinux/%{modulename}-nofcontext.te
%{_datadir}/selinux/*/%{modulename}-nofcontext.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}-nofcontext.if
%attr(0755,root,root) %{_sbindir}/oracle-nofcontext-selinux-enable

%changelog
* Mon Aug 09 2010 Jan Pazdziora 0.1-23.16
- 621912 - ensure selinux-policy-targeted is upgraded before we install the
  oracle-nofcontext-selinux.

* Fri Mar 05 2010 Jan Pazdziora 0.1-23.15
- bumpi up release to allow for rebuild on F12 where etcfile was removed

* Fri Jan 29 2010 Jan Pazdziora 0.1-23.14
- Do semodule -l before any semodule operation.

* Tue Dec 01 2009 Jan Pazdziora 0.1-23.13
- Allow sqlplus to read pipes from unconfined_t

* Fri Nov 27 2009 Jan Pazdziora 0.1-23.12
- Use read_files_pattern to get open on Fedora 11

* Mon Aug 03 2009 Jan Pazdziora 0.1-23.11
- /usr/sbin/oracle-nofcontext-selinux-enable needs semanage, let's add it to
  Requires everywhere

* Mon Jul 27 2009 Jan Pazdziora 0.1-23.10
- 512718 - on Fedora 11, corenet_udp_bind_lo_node is no longer available
- 512718 - on Fedora 12, it will be just and corenet_udp_bind_generic_node and
  corenet_udp_bind_all_nodes

* Thu Jun 18 2009 Jan Pazdziora <jpazdziora@redhat.com> 0.1-23.9
- 505606 - Require at least selinux-policy 2.4.6-80
- do semodule -l first to see if we have the store

* Mon Jun 15 2009 Miroslav Suchy <msuchy@redhat.com> 0.3-1
- 498611 - run "semodule -i" in %%post and restorecon in %%posttrans

* Wed Jun 10 2009 Miroslav Suchy <msuchy@redhat.com> 0.2-1
- 498611 - run restorecon in %%posttrans

* Wed Apr 29 2009 Jan Pazdziora 0.1-23.8
- fix the name of the SELinux enabling script

* Tue Apr 28 2009 Jan Pazdziora 0.1-23.7
- move the %%post SELinux activation of -nofcontext package to
  /usr/sbin/oracle-nofcontext-selinux-enable

* Thu Mar 12 2009 jesus m. rodriguez <jesusr@redhat.com> 0.1-23.6
- oracle-selinux: allow unconfined_r to run oracle_sqlplus_t.

* Thu Feb 19 2009 Jan Pazdziora 0.1-23.5
- make the unconfined_devpts_t part optional

* Tue Feb 10 2009 Jan Pazdziora 0.1-23.4
- add dontaudit on unconfined_devpts_t
- replace create_file_perms with manage_fifo_file_perms
- replace create_file_perms with manage_file_perms
- replace create_dir_perms with manage_dir_perms
- these changes are needed to run on Fedora 10

* Wed Feb  4 2009 Jan Pazdziora 0.1-23.3
- address build problem on Fedoras (manage_sock_file_perms)
- address src.rpm create problem

* Thu Dec 18 2008 Jan Pazdziora 0.1-23.2
- added oracle-nofcontext-selinux subpackage

* Fri Oct  3 2008 Jan Pazdziora - 0.1-23.1
- remove audit-archive-selinux, rsync-ssh-selinux (Build)Requires

* Thu Apr 17 2008 Rob Myers <rob.myers@gtri.gatech.edu> - 0.1-23
- fix up file contexts for oracle_backup_exec_t

* Wed Apr 16 2008 Rob Myers <rob.myers@gtri.gatech.edu> - 0.1-22
- fix targeted policy
- allow sqlplus to read user home content on targeted policy

* Tue Apr 15 2008 Rob Myers <rob.myers@gtri.gatech.edu> - 0.1-21
- code cleanup
- update buildrequires and requires

* Tue Apr 8 2008 Patrick Neely <patrick.neely@gtri.gatech.edu> - 0.1-18
- added optional policy to work with targeted policy

* Tue Apr 8 2008 Patrick Neely <patrick.neely@gtri.gatech.edu> - 0.1-17
- allow backup scripts to create tars and rsync

* Fri Mar 14 2008 Rob Myers <rob.myers@gtri.gatech.edu> - 0.1-16
- allow sysadm_r to manage oracle files

* Tue Oct  9 2007 Rob Myers <rob.myers@gtri.gatech.edu> - 0.1-15
- allow sqlplus to name_connect to oracle_port_t

* Thu Oct  4 2007 Rob Myers <rob.myers@gtri.gatech.edu> - 0.1-14
- fixup requires in oracle.if

* Wed Sep 26 2007 Rob Myers <rob.myers@gtri.gatech.edu> - 0.1-11
- install interface

* Tue Sep 25 2007 Rob Myers <rob.myers@gtri.gatech.edu> - 0.1-9
- initial oracle 11gR1 support.  added oracle_11g_support which defaults to
  false.

* Wed Sep  9 2007 Rob Myers <rob.myers@gtri.gatech.edu> - 0.1-8
- split off from oracle-10gR2 package to support oracle-11gR1
