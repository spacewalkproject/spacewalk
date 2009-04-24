
%define selinux_variants mls strict targeted
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define POLICYCOREUTILSVER 1.33.12-1

%define moduletype apps
%define modulename spacewalk

Name:           spacewalk-selinux
Version:        0.6.1
Release:        1%{?dist}
Summary:        SELinux policy module supporting Spacewalk Server

Group:          System Environment/Base
License:        GPLv2+
# This src.rpm is cannonical upstream. You can obtain it using
#      git clone git://git.fedorahosted.org/git/spacewalk.git/
URL:            http://fedorahosted.org/spacewalk
Source0:        Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  checkpolicy, selinux-policy-devel, hardlink
BuildRequires:  policycoreutils >= %{POLICYCOREUTILSVER}
BuildArch:      noarch

%if "%{selinux_policyver}" != ""
Requires:       selinux-policy >= %{selinux_policyver}
%endif
Requires(post):   /usr/sbin/semodule, /sbin/restorecon, /usr/sbin/setsebool, /usr/sbin/semanage, /usr/sbin/selinuxenabled
Requires(postun): /usr/sbin/semodule, /sbin/restorecon, /usr/sbin/semanage
Requires:       spacewalk-config
Requires:       spacewalk-admin
Requires:       spacewalk-backend
Requires:       spacewalk-backend-server
Requires:       spacewalk-certs-tools
Requires:       oracle-instantclient-selinux

%description
SELinux policy module supporting Spacewalk Server.

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

# Install spacewalk-selinux-enable which will be called in %post
install -d %{buildroot}%{_sbindir}
install -p -m 755 %{name}-enable %{buildroot}%{_sbindir}/%{name}-enable

%clean
rm -rf %{buildroot}

%post
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/%{name}-enable
fi

%postun
# Clean up after package removal
if [ $1 -eq 0 ]; then
  for selinuxvariant in %{selinux_variants}
    do
      /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 \
        && /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} || :
    done
  /usr/sbin/semanage port -d -t cobbler_port_t -p tcp 25152 || :
fi

/sbin/restorecon -rvvi /etc/rhn/satellite-httpd/conf/satidmap.pl %{_sbindir}/rhn-sat-restart-silent /var/log/rhn /var/cache/rhn \
    %{_bindir}/rhn-sudo-ssl-tool %{_bindir}/rhn-sudo-load-ssl-cert

%files
%defattr(-,root,root,0755)
%doc %{modulename}.fc %{modulename}.if %{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
%attr(0755,root,root) %{_sbindir}/%{name}-enable

%changelog
* Fri Apr 24 2009 Jan Pazdziora 0.6.1-1
- move the %post SELinux activation to /usr/sbin/spacewalk-selinux-enable
- use src.rpm packaging with single Source0

* Tue Apr 21 2009 Jan Pazdziora 0.6.0-2
- 495869 - mark /var/log/spacewalk as oracle_sqlplus_log_t
- bump Versions to 0.6.0 (jesusr@redhat.com)

* Wed Mar 25 2009 Jan Pazdziora 0.5.3-1
- 491687 - label the sudo wrappers with httpd_unconfined_script_exec_t

* Mon Feb  9 2009 Jan Pazdziora 0.5.2-1
- spacewalk-selinux: allow satidmap.pl to do network connections

* Fri Jan 30 2009 Jan Pazdziora 0.5.1-1
- bump version to 0.5.*

* Fri Jan 30 2009 Jan Pazdziora 0.4.1-9
- change type of populate_db.log
- add definition of cobbler port 25152, allow httpd to connect

* Thu Jan 29 2009 Jan Pazdziora 0.4.1-8
- make install_db.log of type spacewalk_install_log_t
- avoid .src.rpm-packing-time error when selinux-policy-devel is not installed

* Thu Jan  8 2009 Jan Pazdziora 0.4.1-7
- httpd does not need execstack nor execmem, with execstack flags
  cleared on libraries
- allow mountpoint (/var/satellite) to be a symlink
- allow mountpoint (/var/satellite) to be NFS mounted

* Thu Dec 11 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.1-6
- resolved #471225 - moved rhn-sat-restart-silent to /usr/sbin

* Wed Dec 10 2008 Jan Pazdziora 0.4.1-5
- added type for /var/cache/rhn
- registering clients, using yum, and kickstarting works now

* Wed Dec 10 2008 Jan Pazdziora 0.4.1-4
- replace allows with macros
- allow mod_perl (in httpd_t) to talk to the Oracle database
- defined types for /var/log/rhn and /var/satellite
- rhnpush works now

* Wed Nov 26 2008 Jan Pazdziora 0.4.1-3
- Spacewalk can now be restarted from WebUI, via /sbin/rhn-sat-restart-silent

* Thu Nov 20 2008 Jan Pazdziora 0.4.1-2
- SELinux policy module which allows clean install and spacewalk-setup
  of Spacewalk on RHEL 5

* Thu Oct 30 2008 Jan Pazdziora 0.4.1-1
- bumping up the version

* Thu Oct 30 2008 Jan Pazdziora 0.3.1-1
- the initial release
- inspired by Rob Myers' oracle-selinux
