Name:           spacewalk-setup-postgresql
Version:        2.8.3
Release:        1%{?dist}
Summary:        Tools to setup embedded PostgreSQL database for Spacewalk
License:        GPLv2
URL:            https://github.com/spacewalkproject/spacewalk
Source0:        https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
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
Requires:	perl(DBD::Pg)
Requires: spacewalk-dobby
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
install -m 0644 setup/*.conf %{buildroot}/%{_datadir}/spacewalk/setup/

# Comment this parameter on PSQL 9.5
%if 0%{?fedora} >= 24
sed -i '/^checkpoint_segments/d' %{buildroot}/%{_datadir}/spacewalk/setup/postgresql.conf
%endif

%check


%clean
rm -rf %{buildroot}


%files
%doc LICENSE
%attr(755,root,root) %{_bindir}/spacewalk-setup-postgresql
#%{_mandir}/man1/*
%{_datadir}/spacewalk/setup/defaults.d/*
%{_datadir}/spacewalk/setup/*.conf
%if 0%{?suse_version}
%dir %{_datadir}/spacewalk
%dir %{_datadir}/spacewalk/setup
%dir %{_datadir}/spacewalk/setup/defaults.d
%endif


%changelog
* Wed Mar 14 2018 Jiri Dostal <jdostal@redhat.com> 2.8.3-1
- Make spacewalk-setup-postgres run on postgres10+

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- removed %%%%defattr from specfile
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Tue May 09 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.3-1
- 1447591 - pull in spacewalk-dobby just on postgresql

* Fri Apr 07 2017 Ondrej Gajdusek <ogajduse@redhat.com> 2.7.2-1
- fix isSUSE: command not found
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Thu Feb 02 2017 Gennadii Altukhov <galt@redhat.com> 2.7.1-1
- 1415118 - add Perl DBI backend for PostgreSQL as requirement
- Bumping package versions for 2.7.

* Tue Sep 20 2016 Jan Dobes 2.6.2-1
- postgresql 9.5 does not support checkpoint_segments parameter

* Mon Jun 13 2016 Grant Gainey 2.6.1-1
- spacewalk-setup-postgresql: build and setup on openSUSE
- Bumping package versions for 2.6.
- Bumping package versions for 2.5.
- Bumping package versions for 2.4.

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

