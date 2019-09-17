
%define selinux_variants mls strict targeted 
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define moduletype apps
%define modulename oracle-xe
%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

Name:            oracle-xe-selinux
Version:         10.2.0.48
Release:         1%{?dist}
Summary:         SELinux policy module supporting Oracle XE
License:         GPLv2+
# This src.rpm is canonical upstream.
# You can obtain it using this set of commands
# git clone https://github.com/spacewalkproject/spacewalk.git
# cd spacewalk
# make srpm TAG=%{name}-%{version}-%{release}
URL:             https://github.com/spacewalkproject/spacewalk
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
Requires(post):   /usr/sbin/semodule, %{sbinpath}/restorecon, /sbin/ldconfig, /usr/sbin/selinuxenabled, /usr/sbin/semanage
Requires(postun): /usr/sbin/semodule, %{sbinpath}/restorecon, /usr/sbin/semanage
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
%define hardlink /usr/sbin/hardlink
%if 0%{?fedora} >= 31
%define hardlink /usr/bin/hardlink
%endif
%{hardlink} -cv %{buildroot}%{_datadir}/selinux

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
      /usr/sbin/semanage module -s ${selinuxvariant} -l > /dev/null 2>&1 \
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
* Tue Sep 17 2019 Michael Mraka <michael.mraka@redhat.com> 10.2.0.48-1
- hardlink has moved to /usr/bin in Fedora 31

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 10.2.0.47-1
- removed Group from specfile

* Thu Sep 07 2017 Michael Mraka <michael.mraka@redhat.com> 10.2.0.46-1
- removed unnecessary BuildRoot tag

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 10.2.0.45-1
- purged changelog entries for Spacewalk 2.0 and older
- fixed selinux error messages during package install, see related BZ#1446487

* Thu Aug 10 2017 Tomas Kasparek <tkasparek@redhat.com> 10.2.0.44-1
- 1479849 - BuildRequires: perl has been renamed to perl-interpreter on Fedora
  27

* Mon Jul 17 2017 Jan Dobes 10.2.0.43-1
- Remove more fedorahosted links
- Use HTTPS in all Github links
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Tue Nov 29 2016 Jan Dobes 10.2.0.42-1
- perl isn't in Fedora 25 buildroot

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

