
%define selinux_variants mls strict targeted 
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define moduletype apps
%define modulename oracle-rhnsat

Name:            oracle-rhnsat-selinux
Version:         10.2.0.23
Release:         1%{?dist}
Summary:         SELinux policy module supporting Oracle
Group:           System Environment/Base
License:         GPLv2+
Source0:         https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
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

# Install oracle-rhnsat-selinux-enable which will be called in %post
install -d %{buildroot}%{_sbindir}
install -p -m 755 %{name}-enable %{buildroot}%{_sbindir}/%{name}-enable

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
%doc %{modulename}.fc %{modulename}.if %{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
%attr(0755,root,root) %{_sbindir}/%{name}-enable

%changelog
* Wed Sep 12 2012 Jan Pazdziora 10.2.0.23-1
- 768097 - ignore Postfix smtpd parsing /proc/mounts.

* Wed Aug 22 2012 Michael Mraka <michael.mraka@redhat.com> 10.2.0.22-1
- 799131 - allow oracle db to read logs/*.aud files

* Mon Jul 16 2012 Jan Pazdziora 10.2.0.21-1
- Start using the .tar.gz in the .src.rpm for oracle-rhnsat-selinux.
- %%defattr is not needed since rpm 4.4
- All the NoTgzBuilders are now spacewalkx.builderx.NoTgzBuilder.

* Wed May 04 2011 Michael Mraka <michael.mraka@redhat.com> 10.2.0.20-1
- fixed typo

* Mon May 02 2011 Michael Mraka <michael.mraka@redhat.com> 10.2.0.19-1
- 699979 - allow oracle to write to configuration manager files

* Wed Apr 06 2011 Jan Pazdziora 10.2.0.18-1
- 489548, 565417 - upon ORA-3136, database writes to network/log/sqlnet.log.

* Tue Apr 05 2011 Jan Pazdziora 10.2.0.17-1
- Making oracle_common_log_t into a logging type.

* Thu Sep 23 2010 Michael Mraka <michael.mraka@redhat.com> 10.2.0.16-1
- switched to default VersionTagger

