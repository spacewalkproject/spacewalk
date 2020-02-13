
#
# change oracle_base in case of non-standard installation path
#
%define oracle_base /opt/oracle

%define selinux_variants mls strict targeted 
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define modulename oracle
%define moduletype apps
%define default_oracle_base /opt/oracle
%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

#
# tag to be used in release to differentiate rpms with the same policy but
# with different oracle_bases
#
%if "%{oracle_base}" != "%{default_oracle_base}"
%define obtag %(echo %{?oracle_base} | sed 's#/#.#g' 2>/dev/null)
%endif

Name:            oracle-selinux
Version:         0.1.23.43
Release:         1%{?obtag}%{?dist}%{?repo}
Summary:         SELinux policy module supporting Oracle
License:         GPLv2+
URL:             http://www.stl.gtri.gatech.edu/rmyers/oracle-selinux/
Source0:         https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
%if 0%{?fedora} && 0%{?fedora} > 26
BuildRequires:   perl-interpreter
%else
BuildRequires:   perl
%endif
BuildRequires:   checkpolicy, selinux-policy-devel, hardlink
BuildArch:       noarch

%if "%{selinux_policyver}" != ""
Requires:         selinux-policy >= %{selinux_policyver}
%endif
Requires(post):   /usr/sbin/semanage, /usr/sbin/semodule, %{sbinpath}/restorecon
Requires(postun): /usr/sbin/semanage, /usr/sbin/semodule, %{sbinpath}/restorecon
Obsoletes:        oracle-10gR2-selinux

%description
SELinux policy module supporting Oracle.

%package -n oracle-nofcontext-selinux
Summary:         SELinux policy module supporting Oracle, without file contexts
%if "%{selinux_policyver}" != ""
Requires:         selinux-policy >= %{selinux_policyver}
%endif
%if 0%{?rhel} == 5
Requires:        selinux-policy-base >= 2.4.6-267
%endif
Requires(post):   /usr/sbin/semanage, /usr/sbin/semodule, %{sbinpath}/restorecon, /usr/sbin/selinuxenabled
Requires(postun): /usr/sbin/semanage, /usr/sbin/semodule, %{sbinpath}/restorecon
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
%define hardlink /usr/sbin/hardlink
%if 0%{?fedora} >= 31
%define hardlink /usr/bin/hardlink
%endif
%{hardlink} -cv %{buildroot}%{_datadir}/selinux

# Install oracle-nofcontext-selinux-enable which will be called in %posttrans
install -d %{buildroot}%{_sbindir}
install -p -m 755 oracle-nofcontext-selinux-enable %{buildroot}%{_sbindir}/oracle-nofcontext-selinux-enable

%clean
rm -rf %{buildroot}

%post
# Install SELinux policy modules
for selinuxvariant in %{selinux_variants}
  do
    if /usr/sbin/semanage module -s ${selinuxvariant} -l > /dev/null 2>&1 ; then
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
%{sbinpath}/restorecon -R -v %{oracle_base} || :
%{sbinpath}/restorecon -R -v /u0? || :
%{sbinpath}/restorecon -R -v /etc || :
%{sbinpath}/restorecon -R -v /var/tmp || :

%posttrans
#this may be safely removed when BZ 505066 is fixed
if /usr/sbin/selinuxenabled ; then
  # Fix up non-standard file contexts
  %{sbinpath}/restorecon -R -v %{oracle_base} || :
  %{sbinpath}/restorecon -R -v /u0? || :
  %{sbinpath}/restorecon -R -v /etc || :
  %{sbinpath}/restorecon -R -v /var/tmp || :
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
      if /usr/sbin/semanage module -s ${selinuxvariant} -l > /dev/null 2>&1 ; then
        /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} || :
        /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename}-port || :
      fi
    done
  # Clean up any remaining file contexts (shouldn't be any really)
  [ -d %{oracle_base} ] && \
    %{sbinpath}/restorecon -R -v %{oracle_base} &> /dev/null || :
  %{sbinpath}/restorecon -R -v /u0? || :
  %{sbinpath}/restorecon -R -v /etc || :
  %{sbinpath}/restorecon -R -v /var/tmp || :
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
      if /usr/sbin/semanage module -s ${selinuxvariant} -l > /dev/null 2>&1 ; then
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
* Tue Sep 17 2019 Michael Mraka <michael.mraka@redhat.com> 0.1.23.43-1
- hardlink has moved to /usr/bin in Fedora 31

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 0.1.23.42-1
- removed Group from specfile

* Thu Sep 07 2017 Michael Mraka <michael.mraka@redhat.com> 0.1.23.41-1
- removed unnecessary BuildRoot tag

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 0.1.23.40-1
- purged changelog entries for Spacewalk 2.0 and older
- fixed selinux error messages during package install, see related BZ#1446487

* Thu Aug 10 2017 Tomas Kasparek <tkasparek@redhat.com> 0.1.23.39-1
- 1479849 - BuildRequires: perl has been renamed to perl-interpreter on Fedora
  27

* Mon Jul 17 2017 Jan Dobes 0.1.23.38-1
- Updated links to github in spec files

* Tue Nov 29 2016 Jan Dobes 0.1.23.37-1
- perl isn't in Fedora 25 buildroot

* Fri Nov 15 2013 Michael Mraka <michael.mraka@redhat.com> 0.1.23.36-1
- 1029894 - allow oracle read sysfs

