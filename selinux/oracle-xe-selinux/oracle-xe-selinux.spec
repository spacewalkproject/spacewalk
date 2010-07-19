
%define selinux_variants mls strict targeted 
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define moduletype apps
%define modulename oracle-xe

Name:            oracle-xe-selinux
Version:         10.2
Release:         17%{?dist}
Summary:         SELinux policy module supporting Oracle XE
Group:           System Environment/Base
License:         GPLv2+
# This src.rpm is canonical upstream.
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd spacewalk
# make srpm TAG=%{name}-%{version}-%{release}
URL:             http://fedorahosted.org/spacewalk
Source1:         %{modulename}.if
Source2:         %{modulename}.te
Source3:         %{modulename}.fc
Source4:         %{name}-enable
BuildRoot:       %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires:   checkpolicy, selinux-policy-devel, hardlink
BuildArch:       noarch

%if "%{selinux_policyver}" != ""
Requires:         selinux-policy >= %{selinux_policyver}
%endif
Requires(post):   /usr/sbin/semodule, /sbin/restorecon, /sbin/ldconfig, /usr/sbin/selinuxenabled
Requires(postun): /usr/sbin/semodule, /sbin/restorecon
Requires:         oracle-xe-univ
Requires:         oracle-nofcontext-selinux
Requires:         oracle-lib-compat

%description
SELinux policy module supporting Oracle XE server.

%prep
rm -rf %{name}-%{version}
mkdir -p %{name}-%{version}
cp -p %{SOURCE1} %{SOURCE2} %{SOURCE3} %{SOURCE4} %{name}-%{version}

%build
# Build SELinux policy modules
cd %{name}-%{version}
perl -i -pe 'BEGIN { $VER = join ".", grep /^\d+$/, split /\./, "%{version}.%{release}"; } s!\@\@VERSION\@\@!$VER!g;' %{modulename}.te
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
cd %{name}-%{version}
for selinuxvariant in %{selinux_variants}
  do
    install -d %{buildroot}%{_datadir}/selinux/${selinuxvariant}
    install -p -m 644 %{modulename}.pp.${selinuxvariant} \
           %{buildroot}%{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp
  done

%define extra_restorecon /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/log /usr/lib/oracle/xe/oradata /usr/lib/oracle/xe/app /var/tmp/.oracle
%define extra_subdirs /usr/lib/oracle/xe/app/oracle/flash_recovery_area /usr/lib/oracle/xe/app/oracle/admin /usr/lib/oracle/xe/oradata
sed -i -e 's!%%extra_restorecon!%extra_restorecon!g' -e 's!%%extra_subdirs!%extra_subdirs!g' %{name}-enable
cd -

# Install SELinux interfaces
install -d %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}
install -p -m 644 %{name}-%{version}/%{modulename}.if \
  %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

# Hardlink identical policy module packages together
/usr/sbin/hardlink -cv %{buildroot}%{_datadir}/selinux

# Install oracle-xe-selinux-enable which will be called in %posttrans
install -d %{buildroot}%{_sbindir}
install -p -m 755 %{name}-%{version}/%{name}-enable %{buildroot}%{_sbindir}/%{name}-enable

%clean
rm -rf %{buildroot}

%pre

ORACLE_UID=`id -u oracle`
if [ -z "$ORACLE_UID" ] ; then
    echo "The oracle user has to exist with uid < 500 before installing this package."
    exit 1
elif [ $ORACLE_UID -ge 500 ] ; then
    echo "The oracle user has to exist with uid < 500 before installing this package."
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
  # Relabel oracle-xe-univ's files
  rpm -ql oracle-xe-univ | xargs -n 100 /sbin/restorecon -Rivv
  # Fix up additional directories, not owned by oracle-xe-univ
  /sbin/restorecon -Rivv %extra_restorecon
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

  # Clean up oracle-xe-univ's files
  rpm -ql oracle-xe-univ | xargs -n 100 /sbin/restorecon -Rivv

  # Clean up additional directories, not owned by oracle-xe-univ
  /sbin/restorecon -Rivv %extra_restorecon
fi

%files
%defattr(-,root,root,0755)
%doc %{name}-%{version}/%{modulename}.fc %{name}-%{version}/%{modulename}.if %{name}-%{version}/%{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
%attr(0755,root,root) %{_sbindir}/%{name}-enable

%changelog
* Mon Jul 19 2010 Jan Pazdziora 10.2-17
- 615901 - dontaudit Oracle XE's access to /dev/console.

* Fri Jan 29 2010 Jan Pazdziora 10.2-16
- Do semodule -l before any semodule operation.

* Fri Nov 27 2009 Jan Pazdziora 10.2-15
- Change the port from 9000 to 9055.

* Thu Nov 26 2009 Jan Pazdziora 10.2-14
- In RHEL5 one process reading information on another in the /proc directory
  caused a ptrace access check, allow

* Mon Aug 03 2009 Jan Pazdziora 10.2-13
- Use rw_files_pattern instead of direct allows, to get open on new Fedoras

* Mon Jun 15 2009 Miroslav Suchy <msuchy@redhat.com> 10.2-12
- 498611 - run "semodule -i" in %%post and restorecon in %%posttrans

* Thu Jun 11 2009 Miroslav Suchy <msuchy@redhat.com> 10.2-11
- return version down to 10.2

* Wed Jun 10 2009 Miroslav Suchy <msuchy@redhat.com> 10.3-1
- 498611 - run restorecon in %%posttrans

* Wed Apr 29 2009 Jan Pazdziora 10.2-10
- move the %%post SELinux activation to /usr/sbin/oracle-xe-enable

* Tue Feb 10 2009 Jan Pazdziora 10.2-9
- added textrel_shlib_t to libdbcfg10.so

* Mon Feb  9 2009 Jan Pazdziora 10.2-8
- the /etc/ld.so.conf.d configuration is done in oracle-lib-compat now
- address src.rpm create problem

* Thu Dec 18 2008 Jan Pazdziora 10.2-7
- switch to using oracle-nofcontext-selinux

* Mon Dec 15 2008 Jan Pazdziora 10.2-6
- added textrel_shlib_t for libocci.so.10.1
- minor .spec cleanup

* Tue Nov 18 2008 Jan Pazdziora 10.2-5
- added multiple textrel_shlib_t's
- added /etc/ld.so.conf.d/oracle-xe.conf
- abort rpm install if oracle's uid is not below 500
- use rpm version for SELinux policy module version as well

* Wed Oct 29 2008 Jan Pazdziora 10.2-4
- /etc/init.d/oracle-xe configure with port 9000 passes without AVC denial
- creating new user via http://...:9000/apex passes without AVC denial

* Fri Oct 24 2008 Jan Pazdziora 10.2-3
- addressing first part of /etc/init.d/oracle-xe configure issues

* Thu Oct 23 2008 Jan Pazdziora 10.2-2
- require oracle-selinux

* Tue Oct  7 2008 Jan Pazdziora 10.2-1
- the initial release, based on oracle-selinux 0.1-23.1
