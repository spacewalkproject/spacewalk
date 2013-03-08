%define oracle_base /opt/apps/oracle
%define oracle_base_version %(echo %{version} | awk -F. '{print $1"."$2"."$3}')
%define oracle_home %{oracle_base}/web/product/%{oracle_base_version}/db_1
%define oracle_admin %{oracle_base}/admin/%{oracle_base_version}
%define oracle_config %{oracle_base}/config/%{oracle_base_version}
%define oracle_scripts %{oracle_base}/scripts/%{oracle_base_version}


Summary: Oracle 10g Database Server Enterprise Edition scripts
Name: oracle-server-scripts
Version: 10.2.0.59
Release: 1%{?dist}
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
License: Proprietary
Group:   Oracle Server
BuildArch: noarch
Buildroot: /var/tmp/%{name}-root
Requires: oracle-server >= %{oracle_base_version}
Requires: m4
Requires: oracle-config
%if 0%{?fedora} > 17
Requires(post): %{_sbindir}/runuser
Requires: %{_sbindir}/restorecon
%else
Requires(post): /sbin/runuser
Requires: /sbin/restorecon
%endif

%description
Management scripts for Oracle

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

install -m755 -d $RPM_BUILD_ROOT%{oracle_admin}
for f in oracle-home.sh init-params.ora create-db.sh start-db.sh \
	stop-db.sh create-user.sh \
	default-createdb.tmpl embedded-createdb.tmpl rhnora.m4 \
	embedded-upgradedb.tmpl embedded-upgradedb-10g.tmpl oracle-compute-sga.sh ; do
    install -m 755 $f $RPM_BUILD_ROOT%{oracle_admin}
done

install -m755 -d $RPM_BUILD_ROOT%{oracle_scripts}
for f in explain.sql users.sql sessions.sql ; do
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
if grep -q "^embedded:.*$" /etc/oratab; then
	sed -i "s;^embedded:.*$;embedded:%{oracle_home}:N;" /etc/oratab
else
	echo "embedded:%{oracle_home}:N" >> /etc/oratab || \
	echo "Unable to add 'embedded:%{oracle_home}:N' entry to /etc/oratab" >&2
fi

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
* Fri Mar 08 2013 Milan Zazrivec <mzazrivec@redhat.com> 10.2.0.59-1
- Fedora 19 does not provide /sbin/runuser
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Thu Sep 06 2012 Michael Mraka <michael.mraka@redhat.com> 10.2.0.58-1
- 852757 - create 2GB TEMP by default
- create 8GB data_tbs by default

* Mon Jul 16 2012 Jan Pazdziora 10.2.0.57-1
- Start using the .tar.gz in the .src.rpm for oracle-server-scripts.

* Mon Mar 26 2012 Miroslav Suchý 10.2.0.56-1
- add requires /sbin/restorecon (msuchy@redhat.com)
- All the NoTgzBuilders are now spacewalkx.builderx.NoTgzBuilder.
  (jpazdziora@redhat.com)

* Thu Apr 07 2011 Tomas Lestach <tlestach@redhat.com> 10.2.0.55-1
- fail the pipeline, if one of the pipeline commands fail (tlestach@redhat.com)

* Wed Mar 30 2011 Michael Mraka <michael.mraka@redhat.com> 10.2.0.54-1
- oracle_sqlplus_t is not able to write to logs

* Tue Mar 22 2011 Michael Mraka <michael.mraka@redhat.com> 10.2.0.53-1
- new m4 (1.4.13-5) insists on having defines before template

* Fri Nov 26 2010 Michael Mraka <michael.mraka@redhat.com> 10.2.0.52-1
- 643368 - compute sga size dynamicaly

* Thu Sep 23 2010 Michael Mraka <michael.mraka@redhat.com> 10.2.0.51-1
- switched to default VersionTagger

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 10.2.0-32
- 563902 - let's make default TEMP and UNDO 1GB

