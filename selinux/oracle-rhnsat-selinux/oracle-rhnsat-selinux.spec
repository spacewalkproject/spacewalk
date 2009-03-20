
%define selinux_variants mls strict targeted 
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define moduletype apps
%define modulename oracle-rhnsat

Name:            oracle-rhnsat-selinux
Version:         10.2
Release:         10%{?dist}
Summary:         SELinux policy module supporting Oracle
Group:           System Environment/Base
License:         GPLv2+
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
Requires:         oracle-server >= 10.2.0.3
Requires:         oracle-nofcontext-selinux

%description
SELinux policy module supporting Satellite embedded Oracle server.

%prep
rm -rf %{name}-%{version}
mkdir -p %{name}-%{version}
cp -p %{SOURCE1} %{SOURCE2} %{SOURCE3} %{name}-%{version}

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

%clean
rm -rf %{buildroot}

%post
# Install SELinux policy modules
for selinuxvariant in %{selinux_variants}
  do
    /usr/sbin/semodule -s ${selinuxvariant} -i \
      %{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp &> /dev/null || :
  done

# Fix up oracle-server-arch files
rpm -q --whatprovides oracle-server | xargs rpm -ql | xargs -n 100 /sbin/restorecon -Riv

# Fix up database files
/sbin/restorecon -rvi /rhnsat /var/tmp/.oracle || :

%postun
# Clean up after package removal
if [ $1 -eq 0 ]; then
  # Remove SELinux policy modules
  for selinuxvariant in %{selinux_variants}
    do
      /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} &> /dev/null || :
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

%changelog
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
