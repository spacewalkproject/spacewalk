
%define selinux_variants mls strict targeted
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define POLICYCOREUTILSVER 1.33.12-1
%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

%define moduletype apps
%define modulename spacewalk

Name:           spacewalk-selinux
Version:        2.5.0
Release:        1%{?dist}
Summary:        SELinux policy module supporting Spacewalk Server

Group:          System Environment/Base
License:        GPLv2+
# This src.rpm is cannonical upstream. You can obtain it using
#      git clone git://git.fedorahosted.org/git/spacewalk.git/
URL:            http://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  checkpolicy, selinux-policy-devel, hardlink
BuildRequires:  policycoreutils >= %{POLICYCOREUTILSVER}
BuildArch:      noarch

%if "%{selinux_policyver}" != ""
Requires:       selinux-policy >= %{selinux_policyver}
%endif
%if 0%{?rhel} == 5
Requires:        selinux-policy >= 2.4.6-80
%endif
Requires(post):   /usr/sbin/semodule, %{sbinpath}/restorecon, /usr/sbin/setsebool, /usr/sbin/semanage, /usr/sbin/selinuxenabled
Requires(postun): /usr/sbin/semodule, %{sbinpath}/restorecon, /usr/sbin/semanage
Requires:       spacewalk-config
Requires:       spacewalk-admin
Requires:       spacewalk-backend
Requires:       spacewalk-setup
Requires:       spacewalk-backend-server
Requires:       spacewalk-certs-tools

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

# Install spacewalk-selinux-enable which will be called in %posttrans
install -d %{buildroot}%{_sbindir}
install -p -m 755 %{name}-enable %{buildroot}%{_sbindir}/%{name}-enable

%clean
rm -rf %{buildroot}

%post
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/%{name}-enable --run-pure
fi

%posttrans
#this may be safely remove when BZ 505066 is fixed
if /usr/sbin/selinuxenabled ; then
  %{sbinpath}/restorecon -rvvi /usr/share/rhn/satidmap.pl /usr/sbin/rhn-sat-restart-silent /var/log/rhn /var/cache/rhn \
        /usr/bin/rhn-sudo-ssl-tool /usr/sbin/tanukiwrapper
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

%{sbinpath}/restorecon -rvvi /usr/share/rhn/satidmap.pl %{_sbindir}/rhn-sat-restart-silent /var/log/rhn /var/cache/rhn \
    %{_bindir}/rhn-sudo-ssl-tool /usr/sbin/tanukiwrapper

%files
%doc %{modulename}.fc %{modulename}.if %{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
%attr(0755,root,root) %{_sbindir}/%{name}-enable

%changelog
* Tue Feb 17 2015 Tomas Lestach <tlestach@redhat.com> 2.3.2-1
- spacewalk-monitoring-selinux seems to be redundant now, removing

* Fri Jan 30 2015 Stephen Herr <sherr@redhat.com> 2.3.1-1
- Fix download/generation of kickstart profile for cobbler
- Bumping package versions for 2.3.

* Mon Jun 09 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.1-1
- make sure oracle deploy.sql is etc_t

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Fri Mar 22 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.1-1
- 919468 - fixed path in file based Requires
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Tue Feb 12 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.1-1
- allow httpd to access postgresql via socket in /var/run/postgresql/

* Fri Jun 29 2012 Jan Pazdziora 1.8.2-1
- Make java_t bits optional, as Fedora 17 does not have this type.
- %%defattr is not needed since rpm 4.4

* Tue Apr 17 2012 Jan Pazdziora 1.8.1-1
- No need to require httpd_cobbler_content_t that we don't use.

* Thu Mar 01 2012 Jan Pazdziora 1.7.2-1
- Allow PostgreSQL to use dblink.

* Tue Feb 14 2012 Tomas Lestach <tlestach@redhat.com> 1.7.1-1
- rename rhn-installation.log to rhn_installation.log (tlestach@redhat.com)
- Bumping package versions for 1.7. (mzazrivec@redhat.com)

* Thu Dec 08 2011 Miroslav Suchý 1.6.2-1
- code cleanup - rhn-load-ssl-cert and rhn-sudo-load-ssl-cert are not needed
  anymore

* Thu Jul 21 2011 Jan Pazdziora 1.6.1-1
- Revert "Fedora 15 uses oracledb_port_t instead of oracle_port_t."

* Mon Jul 18 2011 Jan Pazdziora 1.5.4-1
- Fedora 15 uses oracledb_port_t instead of oracle_port_t.

* Tue May 10 2011 Jan Pazdziora 1.5.3-1
- 702274 - fixing unconfined_u error.

* Tue May 10 2011 Jan Pazdziora 1.5.2-1
- 634989 - allow Apache to send emails, useful when mod_python/mod_perl is
  about to send traceback.

* Tue May 10 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.1-1
- 702274 - restore kickstart files context
- 702274 - fixed context of kickstart configs
- 702274 - allow cobblerd_t to read spacewalk_data_t

* Thu Mar 03 2011 Jan Pazdziora 1.4.1-1
- Apache should not be able to read the rpm database.

* Mon Jan 24 2011 Jan Pazdziora 1.3.2-1
- Adding explicit append allow for sqlplus.

* Wed Dec 29 2010 Jan Pazdziora 1.3.1-1
- Create sqlplus spool files with different type than the directories, to allow
  write.

* Fri Nov 05 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.5-1
- set correct context on satidmap.pl (msuchy@redhat.com)

* Fri Nov 05 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.4-1
- 491331 move /etc/rhn/satellite-httpd/conf/satidmap.pl to
  /usr/share/rhn/satidmap.pl (msuchy@redhat.com)

* Wed Oct 13 2010 Jan Pazdziora 1.2.3-1
- Need to allow wider sqlplus access to spacewalk_db_install_log_t for schema
  upgrades to work.

* Tue Oct 12 2010 Jan Pazdziora 1.2.2-1
- We cannot use oracle_sqlplus_log_t in .fc, in case we do not have the Oracle
  modules loaded.
- Move the oracle-instantclient*-selinux dependency to spacewalk-oracle, to
  make it posible to install Spacewalk without Oracle SELinux modules.
- Make the rule for access to oracle_port_t optional, for PostgreSQL
  installations.

* Wed Sep 01 2010 Jan Pazdziora 1.2.1-1
- 628640 - turn the wrapper into java_t upon runtime, it calls java anyway.

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages
- Move systemlogs directory out of /var/satellite (joshua.roys@gtri.gatech.edu)

