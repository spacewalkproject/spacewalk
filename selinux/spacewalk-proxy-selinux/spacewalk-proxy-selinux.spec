
%define selinux_variants mls strict targeted
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define POLICYCOREUTILSVER 1.33.12-1
%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

%define moduletype apps
%define modulename spacewalk-proxy

Name:           spacewalk-proxy-selinux
Version:        2.9.0
Release:        1%{?dist}
Summary:        SELinux policy module supporting Spacewalk Proxy

License:        GPLv2+
# This src.rpm is cannonical upstream. You can obtain it using
#      git clone https://github.com/spacewalkproject/spacewalk.git
# cd spacewalk
# make srpm TAG=%{name}-%{version}-%{release}
URL:            https://github.com/spacewalkproject/spacewalk
Source0:        https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz

%if 0%{?fedora} && 0%{?fedora} > 26
BuildRequires:  perl-interpreter
%else
BuildRequires:  perl
%endif
BuildRequires:  checkpolicy, selinux-policy-devel, hardlink
BuildRequires:  policycoreutils >= %{POLICYCOREUTILSVER}
BuildArch:      noarch

%if "%{selinux_policyver}" != ""
Requires:       selinux-policy >= %{selinux_policyver}
%endif
%if 0%{?rhel} == 5
Requires:        selinux-policy >= 2.4.6-80
%endif
Requires(post):   /usr/sbin/semodule, %{sbinpath}/restorecon, /usr/sbin/setsebool, /usr/sbin/selinuxenabled, /usr/sbin/semanage
Requires(postun): /usr/sbin/semodule, %{sbinpath}/restorecon, /usr/sbin/semanage
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
      /usr/sbin/semanage module -s ${selinuxvariant} -l > /dev/null 2>&1 \
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
* Fri Mar 23 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.3-1
- 1365569 - Update SELinux to allow httpd to read systemid file

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- fixed selinux error messages during package install, see related BZ#1446487
- Bumping package versions for 2.8.

* Thu Aug 10 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.3-1
- 1479849 - BuildRequires: perl has been renamed to perl-interpreter on Fedora
  27

* Mon Jul 17 2017 Jan Dobes 2.7.2-1
- Remove more fedorahosted links
- Use HTTPS in all Github links
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Tue Nov 29 2016 Jan Dobes 2.7.1-1
- perl isn't in Fedora 25 buildroot
- Bumping package versions for 2.7.
- Bumping package versions for 2.6.
- Bumping package versions for 2.5.
- Bumping package versions for 2.4.
- Bumping package versions for 2.3.
- Bumping package versions for 2.2.
- Bumping package versions for 2.1.

