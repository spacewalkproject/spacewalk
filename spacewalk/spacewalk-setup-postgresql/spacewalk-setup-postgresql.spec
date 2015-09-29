Name:           spacewalk-setup-postgresql
Version:        2.5.0
Release:        1%{?dist}
Summary:        Tools to setup embedded PostgreSQL database for Spacewalk
Group:          Applications/System
License:        GPLv2
URL:            https://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       postgresql-server > 8.4
%if 0%{?rhel} == 5
Requires:	postgresql84-contrib
Requires:	postgresql84-pltcl
%else
Requires:	postgresql-contrib >= 8.4
Requires:	postgresql-pltcl
%endif
Requires:	lsof
Obsoletes:	spacewalk-setup-embedded-postgresql

%description
Script, which will setup PostgreSQL database for Spacewalk.

%prep
%setup -q


%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}/%{_bindir}
install -m 0755 bin/* %{buildroot}/%{_bindir}
install -d -m 755 %{buildroot}/%{_datadir}/spacewalk/setup/defaults.d
install -m 0644 setup/defaults.d/* %{buildroot}/%{_datadir}/spacewalk/setup/defaults.d/


%check


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%doc LICENSE
%attr(755,root,root) %{_bindir}/spacewalk-setup-postgresql
#%{_mandir}/man1/*
%{_datadir}/spacewalk/setup/defaults.d/*

%changelog
* Mon Jan 12 2015 Matej Kollar <mkollar@redhat.com> 2.3.1-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files
- Bumping package versions for 2.3.

* Fri May 02 2014 Stephen Herr <sherr@redhat.com> 2.2.2-1
- 1093845 - automatically select utf8 for db character encoding

* Thu Feb 27 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.1-1
- 1070544 - spacewalk-setup-postgresql requires lsof
- Bumping package versions for 2.2.

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.4-1
- 982560 - Small regex fixes

* Mon Sep 02 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.3-1
- 980355 - check SELinux contexts before PostgreSQL db initialization

* Tue Aug 20 2013 Jan Dobes 2.1.2-1
- 998862 - allow root connect to db same way as user postgres can

* Thu Aug 01 2013 Matej Kollar <mkollar@redhat.com> 2.1.1-1
- 982560 - Checking validity of user-provided addresses
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Sun Jul 14 2013 Tomas Lestach <tlestach@redhat.com> 1.10.8-1
- fix postgresql84-pltc dependency to postgresql84-pltcl

* Fri Jul 12 2013 Tomas Lestach <tlestach@redhat.com> 1.10.7-1
- create pltclu for PostgreSQL
- let spacewalk-setup-postgresql require postgresql-pltcl

* Tue Jul 09 2013 Tomas Lestach <tlestach@redhat.com> 1.10.6-1
- spacewalk-setup-postgresql: state the requirement for address/netmask format
  explicitly
- spacewalk-setup-postgresql: --help option

* Mon Jun 24 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.5-1
- spacewalk-setup-postgresql: don't try to configure PG port
- re-configure postgresql when re-running the setup utility
- discard error output from createuser

* Fri Jun 07 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.4-1
- Fixes for managed-db configuration

* Fri Jun 07 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.3-1
- Fix requires for RHEL-5

* Wed Jun 05 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.2-1
- initial build

* Mon May 06 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.1-1
- make spacewalk-setup-embedded-postgresql systemctl-aware
- manage embedded PostgreSQL by spacewalk-service

* Mon Feb 04 2013 Jan Pazdziora 1.9.1-1
- 903487 - on newer PostgreSQL versions, plpgsql gets created automatically in
  new database, we need to skip createlang there.
- Bump up the shmmax in case it is too small for our PostgreSQL configuration
  purposes.

* Mon Oct 22 2012 Michael Mraka
- wait for postmaster to be ready
- made postgresql log more readable

* Mon Oct 22 2012 Michael Mraka
- tuned default postgresql settings
- use current time not start of session time
- 821446 - turning on timestamp logging for pgsql by default
- let's start embedded database before checking its state

* Mon Oct 22 2012 Michael Mraka
- spacewalk-setup-embedded-postgresql 1.8
