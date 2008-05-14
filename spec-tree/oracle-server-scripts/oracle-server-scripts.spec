Source9999: version
%define oracle_base_version     %(echo `awk '{ print $1 }' %{SOURCE9999}`)
%define release                 %(echo `awk '{ print $2 }' %{SOURCE9999}`)

%define oracle_base /opt/apps/oracle
%define oracle_home %{oracle_base}/web/product/%{oracle_base_version}/db_1
%define oracle_admin %{oracle_base}/admin/%{oracle_base_version}
%define oracle_config %{oracle_base}/config/%{oracle_base_version}
%define oracle_scripts %{oracle_base}/scripts/%{oracle_base_version}


Summary: Oracle 10g Database Server Enterprise Edition scripts
Name: oracle-server-scripts
Version: %{oracle_base_version}
Release: %{release}%{?dist}
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
License: Proprietary
Group:   Oracle Server
BuildArch: noarch
Buildroot: /var/tmp/%{name}-root
Requires: oracle-server >= %{oracle_base_version}
Requires: m4

%description
Management scripts for Oracle

%prep
%setup -c -T

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

install -m755 -d $RPM_BUILD_ROOT%{oracle_admin}
for f in %{SOURCE0} %{SOURCE1} %{SOURCE2} %{SOURCE3} \
	 %{SOURCE4} %{SOURCE5} %{SOURCE9} %{SOURCE10} %{SOURCE11}; do
    install -m 755 $f $RPM_BUILD_ROOT%{oracle_admin}
done

install -m755 -d $RPM_BUILD_ROOT%{oracle_scripts}
for f in %{SOURCE6} %{SOURCE7} %{SOURCE8} ; do
    install -m 644 $f $RPM_BUILD_ROOT%{oracle_scripts}
done

%clean
rm -rf $RPM_BUILD_ROOT

%pre
# Add the oracle.dba setup
getent group dba >/dev/null    || groupadd -fr dba
getent group oracle >/dev/null || groupadd -fr oracle
getent passwd  oracle >/dev/null || \
        useradd -g oracle -G dba -c "Oracle Server" \
	        -r -d %{oracle_base} oracle

%preun
# clean up various logs left behind
if [ $1 = 0 ] ; then
    rm -f %{oracle_home}/network/log/* 2>/dev/null
    rm -f %{oracle_home}/rdbms/audit/* 2>/dev/null
fi
exit 0

%files
%defattr(-,oracle,dba)
%{oracle_admin}
%{oracle_scripts}

%changelog
* Thu May 15 2008 Michael Mraka <michael.mraka@redhat.com>
- fixed user and group creation in %pre script

* Wed Apr 30 2008 Michael Mraka <michael.mraka@redhat.com> 10.2.0-6
- modified *.tmpl for 10gR2

* Fri Mar  7 2008 Michael Mraka <michael.mraka@redhat.com> 10.2.0-1
- 10gR2 changes

* Tue Mar  2 2004 Mihai Ibanescu <misa@redhat.com> 10.1.0.2-1
- First stab at 10g

* Fri Jul 25 2003 Mihai Ibanescu <misa@redhat.com> 9.2.0.2.0-1
- Initial build
