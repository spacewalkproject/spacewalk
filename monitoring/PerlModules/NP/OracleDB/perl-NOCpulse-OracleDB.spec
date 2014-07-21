Name:         perl-NOCpulse-OracleDB
Version: 	  2.3.0
Release:      1%{?dist}
Summary:      Perl modules for NOCpulse Oracle database access
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires: perl(NOCpulse::Debug) perl(NOCpulse::Config) perl(NOCpulse::Utils::XML) perl(NOCpulse::Object)
BuildRequires: perl(RHN::DBI)
BuildRequires: perl(DBI) perl(ExtUtils::MakeMaker)
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package provides an API for accessing NOCpulse Oracle databases.

%prep
%setup -q

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor OPTIMIZE="$RPM_OPT_FLAGS"
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -type f -name '*.bs' -size 0 -exec rm -f {} \;
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

%check
make test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%{perl_vendorlib}/NOCpulse/*

%changelog
* Tue Mar 26 2013 Jan Pazdziora 1.28.27-1
- Use to_timestamp instead of to_date which should bring the second precision
  to PostgreSQL.
- %%defattr is not needed since rpm 4.4

* Mon Feb 20 2012 Jan Pazdziora 1.28.26-1
- Use rhn_command_q_inst_recid_seq instead of the synonym, also drop
  command_queue_instances which is not used at all.
- Use rhn_command_q_comm_recid_seq instead of the synonym, also drop
  command_queue_commands which is not used at all.

* Tue Jan 31 2012 Jan Pazdziora 1.28.25-1
- In monitoring, use RHN::DBI instead of RHN::DB because we do not want to
  reuse the connection.

* Fri Dec 09 2011 Jan Pazdziora 1.28.24-1
- replace synonyms with real table names (mc@suse.de)
- replace sysdate with current_timestamp (mc@suse.de)

* Mon Oct 03 2011 Michael Mraka <michael.mraka@redhat.com> 1.28.23-1
- fixed misspelled table name

* Fri Sep 30 2011 Michael Mraka <michael.mraka@redhat.com> 1.28.22-1
- 741782 - replaced aliases with table names

* Thu Aug 11 2011 Jan Pazdziora 1.28.21-1
- The column names are always uppercase, due to the FetchHashKeyName setting.

* Tue Mar 22 2011 Michael Mraka <michael.mraka@redhat.com> 1.28.20-1
- fixed segmentation fault in use NOCpulse::DBRecord

* Tue Mar 22 2011 Miroslav Suchý <msuchy@redhat.com> 1.28.19-1
- add missing buildrequires

* Fri Mar 18 2011 Michael Mraka <michael.mraka@redhat.com> 1.28.18-1
- fixed input values (PG)
- fixed sysdate error (PG)
- replaced aliases with table names (PG)
- reuse RHN:DB for db connection in DBRecord.pm (PG)
- reuse RHN:DB for db connection in OracleDB.pm (PG)

