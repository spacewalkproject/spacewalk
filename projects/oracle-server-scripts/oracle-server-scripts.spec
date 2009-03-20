%define oracle_base /opt/apps/oracle
%define oracle_home %{oracle_base}/web/product/%{oracle_base_version}/db_1
%define oracle_admin %{oracle_base}/admin/%{oracle_base_version}
%define oracle_config %{oracle_base}/config/%{oracle_base_version}
%define oracle_scripts %{oracle_base}/scripts/%{oracle_base_version}


Summary: Oracle 10g Database Server Enterprise Edition scripts
Name: oracle-server-scripts
Version: 10.2.0
Release: 24%{?dist}
Source0: oracle-home.sh
Source1: init-params.ora
Source2: create-db.sh
Source3: start-db.sh
Source4: stop-db.sh
Source5: create-user.sh
Source6: explain.sql
Source7: users.sql
Source8: sessions.sql
Source9: default-createdb.tmpl
Source10: embedded-createdb.tmpl
Source11: rhnora.m4
Source12: embedded-upgradedb.tmpl
License: Proprietary
Group:   Oracle Server
BuildArch: noarch
Buildroot: /var/tmp/%{name}-root
Requires: oracle-server >= %{oracle_base_version}
Requires: m4
Requires: oracle-config
Requires(post): /sbin/runuser

%description
Management scripts for Oracle

%prep
%setup -c -T

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

install -m755 -d $RPM_BUILD_ROOT%{oracle_admin}
for f in %{SOURCE0} %{SOURCE1} %{SOURCE2} %{SOURCE3} \
	 %{SOURCE4} %{SOURCE5} %{SOURCE9} %{SOURCE10} %{SOURCE11} \
	 %{SOURCE12}; do
    install -m 755 $f $RPM_BUILD_ROOT%{oracle_admin}
done

install -m755 -d $RPM_BUILD_ROOT%{oracle_scripts}
for f in %{SOURCE6} %{SOURCE7} %{SOURCE8} ; do
    install -m 644 $f $RPM_BUILD_ROOT%{oracle_scripts}
done

%clean
rm -rf $RPM_BUILD_ROOT


%preun
# clean up various logs left behind
if [ $1 = 0 ] ; then
    rm -f %{oracle_home}/network/log/* 2>/dev/null
    rm -f %{oracle_home}/rdbms/audit/* 2>/dev/null
fi
exit 0

%post
# set ORACLE_HOME
echo "embedded:%{oracle_home}:N" >>/etc/oratab \
  || echo "Unable add 'embedded:%{oracle_home}:N' entry to /etc/oratab" >&2

# setup environment for oracle user
[ -f %{oracle_base}/.bash_profile ] \
    && chown oracle.dba %{oracle_base}/.bash_profile
/sbin/runuser - oracle -c 'cat - >>.bash_profile' <<EOP

# entries added by the %{name} install script
# setup environment for embedded db
ORAENV_ASK=NO
ORACLE_SID=embedded
. oraenv
unset ORAENV_ASK ORACLE_SID
# /entries added by the %{name} install script

EOP

exit 0

%files
%defattr(-,oracle,dba)
%{oracle_admin}
%{oracle_scripts}

%changelog
* Wed Feb  4 2009 Jan Pazdziora 10.2.0-24
- 477812 - only run restorecon in create-db.sh if install-db.sh tells us so
- 477812 - use -R (Jesus R.)

* Thu Jan 29 2009 Jan Pazdziora 10.2.0-23
- run restorecon on /rhnsat/(admin|data)/rhnsat
- put audit logs to adump, resolves selinux error (Michael M.)
- move listener check down

* Wed Nov 26 2008 Michael Mraka <michael.mraka@redhat.com> 10.2.0-22
- resolved #472807 - 32bit to 64bit upgrade fix

* Mon Nov 24 2008 Michael Mraka <michael.mraka@redhat.com> 10.2.0-21
- resolved #472378 - oracle autostart flag set on

* Mon Sep 29 2008 Michael Mraka <michael.mraka@redhat.com> 10.2.0-20
- 464200 - fixed number of processes
- 464197 - fixed .bash_profile ownership

* Mon Jun  9 2008 Michael Mraka <michael.mraka@redhat.com> 10.2.0-18
- added 9i to 10g upgrade template and environment
- fixed file ownership in %post

* Fri May 23 2008 Michael Mraka <michael.mraka@redhat.com> 10.2.0-13
- config files moved to independent package

* Wed May 21 2008 Michael Mraka <michael.mraka@redhat.com> 10.2.0-12
- fixed error code handling in create-db.sh, updated create-user.sh

* Tue May 20 2008 Michael Mraka <michael.mraka@redhat.com> 10.2.0-11
- added embedded line to oratab

* Mon May 19 2008 Michael Mraka <michael.mraka@redhat.com> 10.2.0-10
- fixed initial size of system tablespace in templates

* Thu May 15 2008 Michael Mraka <michael.mraka@redhat.com> 10.2.0-8
- fixed user and group creation in %pre script

* Wed Apr 30 2008 Michael Mraka <michael.mraka@redhat.com> 10.2.0-6
- modified *.tmpl for 10gR2

* Fri Mar  7 2008 Michael Mraka <michael.mraka@redhat.com> 10.2.0-1
- 10gR2 changes

* Tue Mar  2 2004 Mihai Ibanescu <misa@redhat.com> 10.1.0.2-1
- First stab at 10g

* Fri Jul 25 2003 Mihai Ibanescu <misa@redhat.com> 9.2.0.2.0-1
- Initial build
