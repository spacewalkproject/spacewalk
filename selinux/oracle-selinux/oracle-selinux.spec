#
# $Id: oracle-selinux.spec 1233 2007-09-26 13:44:14Z rm153 $
#

#
# change oracle_base in case of non-standard installation path
#
%define oracle_base /opt/oracle

%define selinux_variants mls strict targeted 
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp)
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
Release:         11%{?obtag}%{?dist}%{?repo}
Summary:         SELinux policy module supporting Oracle
Group:           System Environment/Base
License:         GPLv2+
URL:             http://www.stl.gtri.gatech.edu/rmyers/oracle-selinux/
Source1:         %{modulename}.if
Source2:         %{modulename}.te
Source3:         %{modulename}.fc
BuildRoot:       %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires:   checkpolicy, selinux-policy-devel, hardlink
BuildArch:       noarch

%if "%{selinux_policyver}" != ""
Requires:         selinux-policy >= %{selinux_policyver}
%endif
Requires(post):   /usr/sbin/semodule, /sbin/restorecon
Requires(postun): /usr/sbin/semodule, /sbin/restorecon
Obsoletes:        oracle-10gR2-selinux

%description
SELinux policy module supporting Oracle.

%prep
mkdir -p SELinux
cp -p %{SOURCE1} %{SOURCE2} %{SOURCE3} SELinux

# Make file contexts relative to oracle_base
perl -pi -e 's#%{default_oracle_base}#%{oracle_base}#g' SELinux/%{modulename}.fc

%build
# Build SELinux policy modules
cd SELinux
for selinuxvariant in %{selinux_variants}
do
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile
    mv %{modulename}.pp %{modulename}.pp.${selinuxvariant}
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
  done
cd -

# Install SELinux interfaces
install -d %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}
install -p -m 644 SELinux/%{modulename}.if \
  %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

# Hardlink identical policy module packages together
/usr/sbin/hardlink -cv %{buildroot}%{_datadir}/selinux

%clean
rm -rf %{buildroot}

%post
# Install SELinux policy modules
for selinuxvariant in %{selinux_variants}
  do
    /usr/sbin/semodule -s ${selinuxvariant} -i \
      %{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp &> /dev/null || :
  done

# add an oracle port if it does not already exist
SEPORT_STATUS=`semanage port -l | grep -c ^oracle`
test ${SEPORT_STATUS} -lt 1 && semanage port -a -t oracle_port_t -p tcp 1521 || :

# Fix up non-standard file contexts
/sbin/restorecon -R -v %{oracle_base} || :
/sbin/restorecon -R -v /u0? || :
/sbin/restorecon -R -v /etc || :
/sbin/restorecon -R -v /var/tmp || :

%postun
# Clean up after package removal
if [ $1 -eq 0 ]; then
 # remove an existing oracle port
 SEPORT_STATUS=`semanage port -l | grep -c ^oracle`
 test ${SEPORT_STATUS} -gt 0 && semanage port -d -t oracle_port_t -p tcp 1521 || :

  # Remove SELinux policy modules
  for selinuxvariant in %{selinux_variants}
    do
      /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} &> /dev/null || :
    done
  # Clean up any remaining file contexts (shouldn't be any really)
  [ -d %{oracle_base} ] && \
    /sbin/restorecon -R %{_localstatedir}/cache/oracle-selinux &> /dev/null || :
  /sbin/restorecon -R -v /u0? || :
  /sbin/restorecon -R -v /etc || :
  /sbin/restorecon -R -v /var/tmp || :
fi

%files
%defattr(-,root,root,0755)
%doc SELinux/%{modulename}.fc SELinux/%{modulename}.if SELinux/%{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

%changelog
* Wed Sep 26 2007 Rob Myers <rob.myers@gtri.gatech.edu> - 0.1-11
- install interface

* Tue Sep 25 2007 Rob Myers <rob.myers@gtri.gatech.edu> - 0.1-9
- initial oracle 11gR1 support.  added oracle_11g_support which defaults to
  false.

* Wed Sep  9 2007 Rob Myers <rob.myers@gtri.gatech.edu> - 0.1-8
- split off from oracle-10gR2 package to support oracle-11gR1
