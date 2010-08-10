%define release_name Smile

Name:           spacewalk
Version:        1.2.0
Release:        1%{?dist}
Summary:        Spacewalk Systems Management Application
URL:            https://fedorahosted.org/spacewalk
Group:          Applications/Internet
License:        GPLv2
BuildRoot:      %{_tmppath}/%{name}-root-%(%{__id_u} -n)
BuildArch:      noarch

%description
Spacewalk is a systems management application that will
inventory, provision, update and control your Linux and
Solaris machines.

%package common
Summary: Spacewalk Systems Management Application with Oracle database backend
Group:   Applications/Internet
License: GPLv2
Obsoletes: spacewalk < 0.7.0

BuildRequires:  python
Requires:       python >= 2.3
Requires:       spacewalk-setup

# Java
Requires:       spacewalk-java
Requires:       spacewalk-taskomatic
Requires:       spacewalk-search

# Perl
Requires:       spacewalk-html
Requires:       spacewalk-base
Requires:       spacewalk-grail
Requires:       spacewalk-pxt
Requires:       spacewalk-sniglets

# Python
Requires:       spacewalk-certs-tools
Requires:       spacewalk-backend
Requires:       spacewalk-backend-app
Requires:       spacewalk-backend-applet
Requires:       spacewalk-backend-config-files
Requires:       spacewalk-backend-config-files-common
Requires:       spacewalk-backend-config-files-tool
Requires:       spacewalk-backend-iss
Requires:       spacewalk-backend-iss-export
Requires:       spacewalk-backend-package-push-server
Requires:       spacewalk-backend-tools
Requires:       spacewalk-backend-server
Requires:       spacewalk-backend-sql
Requires:       spacewalk-backend-xml-export-libs
Requires:       spacewalk-backend-xmlrpc
Requires:       spacewalk-backend-xp
Requires:       rhnpush


# Misc
Requires:       spacewalk-schema
Requires:       spacewalk-config
Requires:       yum-utils

# Requires:       osa-dispatcher
# Requires:       jabberpy

# Monitoring packages
Requires:       spacewalk-monitoring

# Solaris
# Requires:       rhn-solaris-bootstrap
# Requires:       rhn_solaris_bootstrap_5_1_0_3

# SELinux
Requires:       osa-dispatcher-selinux
Requires:       spacewalk-monitoring-selinux
Requires:       spacewalk-selinux

%if 0%{?fedora} >= 11
%else
# Fedoras 11+ have their own selinux policy for jabberd:
Requires:       jabberd-selinux
%endif

Requires:       editarea >= 0.8.2-2


%description common
Spacewalk is a systems management application that will
inventory, provision, update and control your Linux and
Solaris machines.

%package oracle
Summary: Spacewalk Systems Management Application with Oracle database backend
Group:   Applications/Internet
License: GPLv2
Obsoletes: spacewalk < 0.7.0
Requires:  spacewalk-common = %{version}-%{release}
Conflicts: spacewalk-postgresql

Requires: oracle-instantclient-basic >= 10.2.0
Requires: oracle-instantclient-sqlplus >= 10.2.0
Requires: spacewalk-java-oracle
Requires: perl(DBD::Oracle)
Requires: cx_Oracle
Requires: spacewalk-backend-sql-oracle
Requires: NOCpulsePlugins-Oracle
Requires: perl-NOCpulse-Probe-Oracle

%description oracle
Spacewalk is a systems management application that will
inventory, provision, update and control your Linux and
Solaris machines.

%package postgresql
Summary: Spacewalk Systems Management Application with PostgreSQL database backend
Group:   Applications/Internet
License: GPLv2
Obsoletes: spacewalk < 0.7.0
Requires:  spacewalk-common = %{version}-%{release}
Conflicts: spacewalk-oracle

Requires: spacewalk-java-postgresql
Requires: perl(DBD::Pg)
Requires: python-pgsql
Requires: spacewalk-backend-sql-postgresql
Requires: /usr/bin/psql

%description postgresql
Spacewalk is a systems management application that will 
inventory, provision, update and control your Linux and 
Solaris machines.

%prep
#nothing to do here

%build
#nothing to do here

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{_sysconfdir}
SW_REL=$(echo %{version} | awk -F. '{print $1"."$2}')
echo "Spacewalk release $SW_REL (%{release_name})" > $RPM_BUILD_ROOT/%{_sysconfdir}/spacewalk-release
install -d $RPM_BUILD_ROOT/%{_datadir}/spacewalk/setup/defaults.d
for i in oracle postgresql ; do
        cat <<EOF >$RPM_BUILD_ROOT/%{_datadir}/spacewalk/setup/defaults.d/$i-backend.conf
# database backend to be used by spacewalk
db-backend = $i
EOF
done

%clean
rm -rf %{buildroot}

%files common
%defattr(-,root,root)
%{_sysconfdir}/spacewalk-release

%files oracle
%defattr(-,root,root)
%{_datadir}/spacewalk/setup/defaults.d/oracle-backend.conf

%files postgresql
%defattr(-,root,root)
%{_datadir}/spacewalk/setup/defaults.d/postgresql-backend.conf

%changelog
* Fri Jul 23 2010 Jan Pazdziora 1.1.6-1
- To populate the database, we need psql.

* Fri Jul 16 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.5-1
- only spacewalk-oracle should requires newly splitted packages with Oracle
  probes

* Fri Jul 09 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.4-1
- create virtual package spacewalk-backend-sql-virtual (msuchy@redhat.com)

* Mon Jun 21 2010 Jan Pazdziora 1.1.3-1
- Make bash the default for syntax highlighting (colin.coe@gmail.com)

* Thu Apr 22 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.2-1
- put new ascii art to instaler 

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

* Fri Mar 19 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.1-1
- modified Spacewalk 0.9 release name

* Thu Jan 14 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- droped spacewalk-cypress from Requires
- removed spacewalk-moon (sub)package as it is not used anywhere

* Fri Nov 27 2009 Jan Pazdziora 0.7.4-1
- Disable jabberd-selinux for Fedora 11+, enable spacewalk-selinux

* Wed Nov 25 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.3-1
- Make spacewalk require the editarea RPM (colin.coe@gmail.com)

* Wed Sep 02 2009 Michael Mraka <michael.mraka@redhat.com> 0.7.2-1
- added database backend to defaults

* Tue Sep 01 2009 Michael Mraka <michael.mraka@redhat.com> 0.7.1-1
- let's change codename to something new
- split spacewalk metapackage into spacewalk-oracle/postgresql
- bumping Version to 0.7.0

* Mon Jul 27 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.4-1
- Re-enable spacewalk-monitoring-selinux dependency for F11.
  (dgoodwin@redhat.com)
- osa-dispatcher-selinux is back, in osad-5.9.19-1.*. (jpazdziora@redhat.com)
- Disable jabberd-selinux for Fedora 11 permanently. (dgoodwin@redhat.com)

* Wed Jul 22 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.3-1
- Re-enable selinux for everything but Fedora 11. (dgoodwin@redhat.com)

* Mon Jul 20 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.2-1
- Disabling spacewalk selinux support temporarily. (dgoodwin@redhat.com)

* Fri Apr 17 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.1-1
- bump Versions to 0.6.0 (jesusr@redhat.com)

* Fri Feb 27 2009 Miroslav Suchy <msuchy@redhat.com> 0.5.4-1
- require ISS packages

* Tue Feb 10 2009 Jan Pazdziora 0.5.3-2
- Require jabberd-selinux, osa-dispatcher-selinux, and
  spacewalk-monitoring-selinux

* Wed Jan 21 2009 Devan Goodwin <dgoodwin@redhat.com> 0.5.3-1
- Restore dependency on taskomatic and search.

* Mon Jan 19 2009 Jan Pazdziora 0.5.1-1
- rebuilt for 0.5, after repository reorg

* Thu Jan  8 2009 Jan Pazdziora 0.4.2-3
- Require spacewalk-selinux, making it a mandatory rpm

* Mon Dec 22 2008 Mike McCune <mmccune@gmail.com> 0.4.2-2
- Removing cobbler requirement down to RPMs that actually need it 

* Tue Nov 18 2008 Miroslav Suchý <msuchy@redhat.com> 0.4.2-1
- require spacewalk-monitoring instead each individual monitoring package

* Fri Oct 24 2008 Jesus Rodriguez <jesusr@redhat.com> 0.3.2-1
- respin for 0.3

* Wed Oct 22 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.4-1
- Remove spacewalk-dobby dependency, only needed for Satellite embedded Oracle installs.

* Mon Sep 29 2008 Miroslav Suchý <msuchy@redhat.com> 0.2.3-1
- rename oracle_config to nocpulse-db-perl
- merge NPusers and NPconfig to nocpulse-common
- remove nslogs
- enable monitoring again
- fix rpmlint errors

* Tue Sep  2 2008 Jesus Rodriguez <jesusr@redhat.com> 0.2.2-1
- add spacewalk-search as a new Requires
- change version to work with the new make srpm rules

* Mon Sep  1 2008 Milan Zazrivec <mzazrivec@redhat.com> 0.2-4
- bumped minor release for new package build

* Wed Aug 13 2008 Mike 0.2-3
- Fixing requires for new package names

* Mon Aug 11 2008 Mike 0.2-2
- tag to rebuild

* Wed Aug  6 2008 Jan Pazdziora 0.1-7
- tag to rebuild

* Mon Aug  4 2008 Miroslav Suchy <msuchy@redhat.com>
- Migrate name of packages to spacewalk namespace.

* Tue Jun 3 2008 Jesus Rodriguez <mmccune at redhat dot com> 0.1
- initial rpm release
