
%define selinux_variants mls strict targeted 
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define moduletype apps
%define modulename oracle-rhnsat

Name:            oracle-rhnsat-selinux
Version:         10.2
Release:         15%{?dist}
Summary:         SELinux policy module supporting Oracle
Group:           System Environment/Base
License:         GPLv2+
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
%if 0%{?rhel} == 5
Requires:        selinux-policy >= 2.4.6-80
%endif
Requires(post):   /usr/sbin/semodule, /sbin/restorecon, /usr/sbin/selinuxenabled
Requires(postun): /usr/sbin/semodule, /sbin/restorecon
Requires:         oracle-server >= 10.2.0.3
Requires:         oracle-nofcontext-selinux

%description
SELinux policy module supporting Satellite embedded Oracle server.

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
cd -

# Install SELinux interfaces
install -d %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}
install -p -m 644 %{name}-%{version}/%{modulename}.if \
  %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

# Hardlink identical policy module packages together
/usr/sbin/hardlink -cv %{buildroot}%{_datadir}/selinux

# Install oracle-rhnsat-selinux-enable which will be called in %post
install -d %{buildroot}%{_sbindir}
install -p -m 755 %{name}-%{version}/%{name}-enable %{buildroot}%{_sbindir}/%{name}-enable

%clean
rm -rf %{buildroot}

%post
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/%{name}-enable
fi

%posttrans
#this may be safely removed when BZ 505066 is fixed
if /usr/sbin/selinuxenabled ; then
  # Fix up oracle-server-arch files
  rpm -q --whatprovides oracle-server | xargs rpm -ql | xargs -n 100 /sbin/restorecon -Riv
  # Fix up database files
  /sbin/restorecon -rvi /rhnsat /var/tmp/.oracle || :
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

  # Clean up oracle-server-arch files
  rpm -q --whatprovides oracle-server | xargs rpm -ql | xargs -n 100 /sbin/restorecon -Riv

  # Clean up any remaining file contexts (shouldn't be any really)
  /sbin/restorecon -rvi /rhnsat /var/tmp/.oracle || :
fi

%files
%defattr(-,root,root,0755)
%doc %{name}-%{version}/%{modulename}.fc %{name}-%{version}/%{modulename}.if %{name}-%{version}/%{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
%attr(0755,root,root) %{_sbindir}/%{name}-enable

%changelog
* Fri Jan 29 2010 Jan Pazdziora 10.2-15
- Do semodule -l before any semodule operation.

* Thu Jun 18 2009 Jan Pazdziora 10.2-14
- 505606 - Require at least selinux-policy 2.4.6-80
- do semodule -l first to see if we have the store

* Mon Jun 15 2009 Miroslav Suchy <msuchy@redhat.com> 10.2-13
- 498611 - run "semodule -i" in %%post and restorecon in %%posttrans

* Thu Jun 11 2009 Miroslav Suchy <msuchy@redhat.com> 10.2-12
- return version down to 10.2

* Wed Jun 10 2009 Miroslav Suchy <msuchy@redhat.com> 10.3-1
- 498611 - run restorecon in %%posttrans

* Wed Apr 29 2009 Jan Pazdziora 10.2-11
- move the %%post SELinux activation to /usr/sbin/oracle-rhnsat-enable

* Mon Mar 16 2009 Jan Pazdziora 10.2-10
- 489377 - allow sqlplus and lsnrctl to use NIS

* Wed Feb 25 2009 Jan Pazdziora 10.2-9
- 486737 - allow lsnrctl to also append to oracle_common_log_t

* Thu Feb 19 2009 Jan Pazdziora 10.2-8
- add texrel_shlib_t to libocci.so.10.1

* Mon Feb  9 2009 Jan Pazdziora 10.2-7
- added texrel_shlib_t to libnnz10.so
- allow listener to append to common logs
- logs of dbstart and dbshut are not in $ORACLE_HOME/log

* Thu Jan 29 2009 Jan Pazdziora 10.2-6
- Require oracle-server 10.2.0.3 only, for s390x

* Thu Jan 29 2009 Jan Pazdziora 10.2-5
- modify policy module to silence numerous AVC denials
- make restorecon in scriptlets less verbose

* Mon Jan 19 2009 Devan Goodwin <dgoodwin@redhat.com> 10.2-4
- Remove missed dependency on oracle-selinux.

* Sat Jan 17 2009 Jan Pazdziora 10.2-3
- require oracle-nofcontext-selinux, not oracle-selinux

* Wed Nov 19 2008 Jan Pazdziora 10.2-2
- change build subdir
- use rpm version for SELinux policy module version as well

* Thu Oct  9 2008 Jan Pazdziora 10.2-1
- the initial release, based on oracle-selinux 0.1-23.1
