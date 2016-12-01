
%define selinux_variants mls strict targeted
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define POLICYCOREUTILSVER 1.33.12-1
%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

%define moduletype apps
%define modulename spacewalk-proxy

Name:           spacewalk-proxy-selinux
Version:        2.7.1
Release:        1%{?dist}
Summary:        SELinux policy module supporting Spacewalk Proxy

Group:          System Environment/Base
License:        GPLv2+
# This src.rpm is cannonical upstream. You can obtain it using
#      git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd spacewalk
# make srpm TAG=%{name}-%{version}-%{release}
URL:            http://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  perl
BuildRequires:  checkpolicy, selinux-policy-devel, hardlink
BuildRequires:  policycoreutils >= %{POLICYCOREUTILSVER}
BuildArch:      noarch

%if "%{selinux_policyver}" != ""
Requires:       selinux-policy >= %{selinux_policyver}
%endif
%if 0%{?rhel} == 5
Requires:        selinux-policy >= 2.4.6-80
%endif
Requires(post):   /usr/sbin/semodule, %{sbinpath}/restorecon, /usr/sbin/setsebool, /usr/sbin/selinuxenabled
Requires(postun): /usr/sbin/semodule, %{sbinpath}/restorecon
Requires:       spacewalk-proxy-management
Requires:       spacewalk-proxy-common
Requires:       spacewalk-proxy-broker

%description
SELinux policy module supporting Spacewalk Proxy.

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

# Install spacewalk-proxy-selinux-enable which will be called in %posttrans
install -d %{buildroot}%{_sbindir}
install -p -m 755 %{name}-enable %{buildroot}%{_sbindir}/%{name}-enable

%clean
rm -rf %{buildroot}

%post
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/%{name}-enable
fi

%posttrans
if /usr/sbin/selinuxenabled ; then
  %{sbinpath}/restorecon -rvvi /var/log/rhn /var/cache/rhn/proxy-auth /var/spool/rhn-proxy
fi

%postun
# Clean up after package removal
if [ $1 -eq 0 ]; then
  for selinuxvariant in %{selinux_variants}
    do
      /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 \
        && /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} || :
    done
fi

%{sbinpath}/restorecon -rvvi /var/log/rhn /var/cache/rhn/proxy-auth /var/spool/rhn-proxy

%files
%doc %{modulename}.fc %{modulename}.if %{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
%attr(0755,root,root) %{_sbindir}/%{name}-enable

%changelog
* Tue Nov 29 2016 Jan Dobes 2.7.1-1
- perl isn't in Fedora 25 buildroot
- Bumping package versions for 2.7.
- Bumping package versions for 2.6.
- Bumping package versions for 2.5.
- Bumping package versions for 2.4.
- Bumping package versions for 2.3.
- Bumping package versions for 2.2.
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Fri Mar 22 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.1-1
- 919468 - fixed path in file based Requires
- %%defattr is not needed since rpm 4.4

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- rebuild for spacewalk 0.8

* Thu Jul  2 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.6-1
- 509369 - run restorecon for /var/www/html/pub since its content is not owned by any package

* Thu Jun 18 2009 Jan Pazdziora 0.6.5-1
- 505606 - Require at least selinux-policy 2.4.6-80

* Mon Jun 15 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.4-1
- 498611 - run "semodule -i" in %%post and restorecon in %%posttrans

* Wed Jun 10 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.3-1
- 498611 - run restorecon in %%posttrans

* Mon Apr 27 2009 Jan Pazdziora 0.6.2-1
- move the %post SELinux activation to /usr/sbin/spacewalk-proxy-selinux-enable
- use src.rpm packaging with single Source0

* Wed Apr 22 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.1-1
- Make spacewalk-proxy-selinux buildable with tito. (dgoodwin@redhat.com)
- bump Versions to 0.6.0 (jesusr@redhat.com)

* Tue Jan 20 2009 Jan Pazdziora 0.5.1-1
- the initial release, based on spacewalk-selinux
