%define release_name Smile

Name:           spacewalk
Version:        2.5.0
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
Requires:       rhnpush


# Misc
Requires:       spacewalk-schema
Requires:       spacewalk-config
Requires:       yum-utils

# Requires:       osa-dispatcher
# Requires:       jabberpy
Obsoletes:      spacewalk-monitoring < 2.3

# SELinux
Requires:       osa-dispatcher-selinux
Requires:       spacewalk-selinux
Obsoletes:      spacewalk-monitoring-selinux < 2.3

%if 0%{?rhel} == 5
Requires:       jabberd-selinux
%endif
%if 0%{?rhel} == 6
Requires:       selinux-policy-base >= 3.7.19-93
%endif


Requires:       ace-editor >= 1.1.1

Requires:       cobbler20

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

Requires: oracle-instantclient11.2-basic
Requires: oracle-instantclient11.2-sqlplus
Conflicts: oracle-instantclient-basic <= 10.2.0.4
Conflicts: oracle-instantclient-sqlplus <= 10.2.0.4
Requires: spacewalk-java-oracle
Requires: perl(DBD::Oracle)
Requires: cx_Oracle
Requires: spacewalk-backend-sql-oracle
Requires: quartz-oracle
Requires: oracle-instantclient-selinux
Requires: oracle-instantclient-sqlplus-selinux

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
Requires: spacewalk-backend-sql-postgresql
Requires: /usr/bin/psql
%if 0%{?rhel} == 5
Requires: postgresql84-contrib
%else
Requires: postgresql-contrib >= 8.4
%endif
Requires: postgresql >= 8.4

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
%{_sysconfdir}/spacewalk-release

%files oracle
%{_datadir}/spacewalk/setup/defaults.d/oracle-backend.conf

%files postgresql
%{_datadir}/spacewalk/setup/defaults.d/postgresql-backend.conf

%changelog
* Fri Jul 24 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.2-1
- require cobbler20 - Spacewalk is not working with upstream cobbler anyway

* Wed Jun 24 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.1-1
- Recommend cobbler20 with all packages requiring cobbler on Fedora 22
- Bumping package versions for 2.4.

* Wed Mar 25 2015 Tomas Lestach <tlestach@redhat.com> 2.3.4-1
- 1205113 - obsoleting spacewalk-monitoring and spacewalk-monitoring-selinux
  packages

* Tue Mar 17 2015 Tomas Lestach <tlestach@redhat.com> 2.3.3-1
- removing spacewalk-pxt completelly

* Mon Mar 09 2015 Tomas Lestach <tlestach@redhat.com> 2.3.2-1
- removing spacewalk-grail as they are not needed any more
- removing spacewalk-sniglets as they are not needed any more

* Fri Jan 16 2015 Tomas Lestach <tlestach@redhat.com> 2.3.1-1
- remove Monitoring and Solaris dependencies
- Bumping package versions for 2.3.

* Fri Apr 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.2-1
- editarea has been replaced with ace-editor

* Thu Mar 20 2014 Matej Kollar <mkollar@redhat.com> 2.2.1-1
- Remove unnecessary dependency
- Bumping package versions for 2.2.
- fixed tito build warning
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Sun Jul 14 2013 Tomas Lestach <tlestach@redhat.com> 1.10.2-1
- fix postgresql84-pltc dependency to postgresql84-pltcl

* Fri Jul 12 2013 Tomas Lestach <tlestach@redhat.com> 1.10.1-1
- let spacewalk-postgresql require postgresql-pltcl
- Bumping package versions for 1.9

* Mon Mar 04 2013 Jan Pazdziora 1.9.1-1
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Thu Oct 25 2012 Jan Pazdziora 1.8.6-1
- Revert "Require spacewalk-setup-embedded-postgresql for spacewalk-setup to
  work."

* Thu Oct 25 2012 Jan Pazdziora 1.8.5-1
- Require spacewalk-setup-embedded-postgresql for spacewalk-setup to work.

* Fri Oct 19 2012 Jan Pazdziora 1.8.4-1
- We need one extra package in the dependency chain to prefer cobbler20 upon
  fresh installation.

* Tue Oct 16 2012 Jan Pazdziora 1.8.3-1
- Require the cobbler20 for full installation.

* Tue Oct 09 2012 Jan Pazdziora 1.8.2-1
- The spacewalk-backend-xp subpackage is not longer built.
- %%defattr is not needed since rpm 4.4

* Mon Apr 16 2012 Jan Pazdziora 1.8.1-1
- Require postgresql >= 8.4 (mzazrivec@redhat.com)

* Fri Mar 02 2012 Jan Pazdziora 1.7.3-1
- On RHEL 5, we need to explicitly name postgresql84-contrib.

* Thu Mar 01 2012 Jan Pazdziora 1.7.2-1
- The path is different on PostgreSQL 9.1/Fedora 16, luckily the postgresql-
  contrib package name is the same.

* Wed Feb 29 2012 Jan Pazdziora 1.7.1-1
- Creating the dblink function(s) upon schema population, in schema public.

* Fri Jun 17 2011 Jan Pazdziora 1.5.1-1
- No longer require jabberd-selinux-workaround now that RHEL 6.1 has been
  released.

* Mon Jan 31 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.3.3-1
- Require jabberd-selinux-workaround on RHEL-6.0

* Fri Jan 07 2011 Jan Pazdziora 1.3.2-1
- Conflict with the InstantClient 10 to remind that they need to be removed
  upon upgrade.
- Switch to Oracle InstantClient 11 in spacewalk-oracle.
- add build.py.props to allow building using tito (msuchy@redhat.com)

* Wed Dec 08 2010 Tomas Lestach <tlestach@redhat.com> 1.3.1-1
- remove jabberd-selinux dependency for rhel6+ (tlestach@redhat.com)
- Bumping package versions for 1.3. (jpazdziora@redhat.com)

* Tue Oct 12 2010 Jan Pazdziora 1.2.3-1
- Move the oracle-instantclient*-selinux dependency to spacewalk-oracle, to
  make it posible to install Spacewalk without Oracle SELinux modules.

* Fri Oct 08 2010 Jan Pazdziora 1.2.2-1
- Moving the quartz-oracle Requires from spacewalk-taskomatic to spacewalk-
  oracle.

* Wed Aug 11 2010 Jan Pazdziora 1.2.1-1
- The dependency of python-psycopg2 (which replaced python-pgsql) is in
  spacewalk-backend-sql-postgresql, no need to have it in spacewalk-postgresql
  directly.
- bumping package versions for 1.2 (mzazrivec@redhat.com)

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

