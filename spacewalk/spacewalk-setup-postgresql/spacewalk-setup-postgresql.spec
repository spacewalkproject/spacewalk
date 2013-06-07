Name:           spacewalk-setup-postgresql
Version:        1.10.3
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
%else
Requires:	postgresql-contrib >= 8.4
%endif
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
