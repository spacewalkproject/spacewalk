Summary: DBD-Oracle module for perl
Name: perl-DBD-Oracle
Version: 1.62
Release: 7%{?dist}
License:  GPL+ or Artistic
Source0: DBD-Oracle-%{version}.tar.gz
Source1: demo.mk
Url: http://www.cpan.org
BuildRequires: perl >= 0:5.6.1, perl(DBI)
BuildRequires: perl(ExtUtils::MakeMaker)
BuildRequires: oracle-instantclient18.5-devel
BuildRequires:  coreutils
BuildRequires:  findutils
BuildRequires:  make
%if 0%{?fedora} || 0%{?rhel} >= 8
BuildRequires:  perl-interpreter
%else
BuildRequires:  perl
%endif
%if 0%{?rhel} == 8
BuildRequires:  perl-generators < 1.10-7.module
%else
BuildRequires:  perl-generators
%endif
BuildRequires:  perl(strict)

Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
# the version requires is not automatically picked up
Requires: perl(DBI) >= 1.51

%description
DBD-Oracle module for perl

%prep
%define modname %(echo %{name}| sed 's/perl-//')
%define perl_vendorlib %(eval "`%{__perl} -V:installvendorlib`"; echo $installvendorlib)
%define perl_vendorarch %(eval "`%{__perl} -V:installvendorarch`"; echo $installvendorarch)

%setup -q -n %{modname}-%{version}

cp %{SOURCE1} .

%build

MKFILE=$(find /usr/share/oracle/ -name demo.mk)
%ifarch ppc ppc64
# the included version in oracle-instantclient-devel is bad on ppc arches
# using the version from i386 rpm
MKFILE=demo.mk
%endif
%ifarch x86_64 s390x
ORACLE_HOME=$(find /usr/lib/oracle/ -name client64 | tail -1)
%else
ORACLE_HOME=$(find /usr/lib/oracle/ -name client | tail -1)
%endif
export ORACLE_HOME
perl Makefile.PL -m $MKFILE INSTALLDIRS="vendor" PREFIX=%{_prefix} -V 18.5.0.0.0
make  %{?_smp_mflags} OPTIMIZE="%{optflags}"

%clean

%install
make PREFIX=$RPM_BUILD_ROOT%{_prefix} pure_install

rm -f `find $RPM_BUILD_ROOT -type f -name perllocal.pod -o -name .packlist`

%files
%{perl_vendorarch}/auto/DBD/
%{perl_vendorarch}/DBD/
%{_mandir}/man3/*

%changelog
* Thu 28 May 2020 Laurence Rochfort <laurence.rochfort@oracle.com> 18.5.0.0-1
- Update instant client to 18.5 [Orabug: 31413086]

* Tue Oct 01 2019 Michael Mraka <michael.mraka@redhat.com> 1.62-7
- workaround RHEL8 buildrequires modules issue

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 1.62-6
- removed %%%%defattr from specfile
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Thu Aug 10 2017 Tomas Kasparek <tkasparek@redhat.com> 1.62-5
- 1479849 - BuildRequires: perl has been renamed to perl-interpreter on Fedora
  27

* Tue Mar 28 2017 Michael Mraka <michael.mraka@redhat.com> 1.62-4
- since Fedora 25 perl is not in default buildroot

* Thu Jan 29 2015 Tomas Lestach <tlestach@redhat.com> 1.62-3
- we need to use the exact oracle instantclient version

* Thu Jan 29 2015 Tomas Lestach <tlestach@redhat.com> 1.62-2
- do not require exact version of oracle instantclient
- fixed tito build warning

* Mon May 13 2013 Jan Pazdziora 1.62-1
- Rebase DBD::Oracle to 1.62.

* Mon Mar 18 2013 Michael Mraka <michael.mraka@redhat.com> 1.50-2
- fixed builder definition

* Mon Oct 08 2012 Jan Pazdziora 1.50-1
- Rebase perl-DBD-Oracle to 1.50.
- %%defattr is not needed since rpm 4.4

* Fri Jan 07 2011 Jan Pazdziora 1.27-2
- We shall hardcode the 11g version.
- Revert "Specify the InstantClient version with -V."

* Fri Jan 07 2011 Jan Pazdziora 1.27-1
- upgrading to 1.27

* Tue Jun 08 2010 Jan Pazdziora 1.24a-3
- rebuild to fix dist-cvs issue.

* Wed May 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.24a-2
- updated to upstream version 1.24a

* Thu Dec 17 2009 Justin Sherrill <jsherril@redhat.com> 1.23-5
- 548489 - adding patch to fix issue with updating/inserting a blob using a
  synonym (jsherril@redhat.com)

* Fri Jun 05 2009 Milan Zazrivec <mzazrivec@redhat.com> 1.23-4
- bug 504281: fix out of memory error

* Tue Jun 02 2009 Miroslav Suchý <msuchy@redhat.com> 1.23-3
- apply commit 12769 from Bug 46016 from upstream as patch

* Mon Jun 01 2009 Michael Mraka <michael.mraka@redhat.com> 1.23-2
- 470999 - fixed warnings on s390(x)

* Wed May 20 2009 Jan Pazdziora 1.23-1
- rebase to latest stable upstream 1.23
- fix typo in Summary of -explain subpackage

* Tue May 19 2009 Jan Pazdziora 1.22-15
- use plain find instead of rpm -ql for now

* Wed Apr 01 2009 Miroslav Suchý <msuchy@redhat.com> 1.22-13
- 493295 - requires perl-DBI >= 1.51

* Sat Feb 28 2009 Dennis Gilmore 1.22-12
- ppc oracle-instantclient-devel has a bade demo.mk file

* Fri Feb 27 2009 Dennis Gilmore <dgilmore@redhat.com> 1.22-11
- fix up sources and correct setup

* Fri Feb 27 2009 Dennis Gilmore <dgilmore@redhat.com> 1.22-10
- Rebuild for ppc ppc64 and ia64

* Wed Feb 25 2009 Devan Goodwin <dgoodwin@redhat.com> 1.22-9
- Rebuild for new rel-eng tools.

* Mon Jan 19 2009 Dennis Gilmore <dgilmore@redhat.com> 1.22-8
- bump and rebuild for git tag

* Thu Jan 15 2009 Dennis Gilmore <dgilmore@redhat.com> 1.22-6
- BR perl(ExtUtils::MakeMaker)

* Wed Dec 10 2008 Michael Mraka <michael.mraka@redhat.com> 1.22-5
- simplified %%build and %%instal stage
- resolved #470999

* Tue Nov 25 2008 Miroslav Suchy <msuchy@redhat.com> 1.22-2
- added buildrequires for oracle-lib-compat
- rebased to DBD::Oracle 1.22
- removed DBD-Oracle-1.14-blobsyn.patch

* Thu Oct 16 2008 Milan Zazrivec 1.21-4
- bumped release for minor release tagging
- added %%{?dist} to release

* Tue Aug 26 2008 Mike McCune 1.21-3
- Cleanup spec file to work in fedora and our new Makefile structure

* Wed Jul  2 2008 Michael Mraka <michael.mraka@redhat.com> 1.21-2
- rebased to DBD::Oracle 1.21, Oracle Instantclient 10.2.0.4
- ora_explain moved into subpackage

* Wed May 21 2008 Jan Pazdziora - 1.19-8
- rebuild on RHEL 4 as well.

* Fri Dec 05 2007 Michael Mraka <michael.mraka@redhat.com>
- update to DBD::Oracle 1.19 to support oracle-instantclient

* Fri Jun 20 2003 Mihai Ibanescu <misa@redhat.com>
- Linking against Oracle 9i Release 2 client libraries.

* Sun Nov 11 2001 Chip Turner <cturner@redhat.com>
- update to DBD::Oracle 1.12 to fix LOB bug

* Mon Jul 23 2001 Cristian Gafton <gafton@redhat.com>
- compile against oracle libraries using -rpath setting
- disable as many checks as we can from the default Makefile.PL

* Mon Apr 30 2001 Chip Turner <cturner@redhat.com>
- Spec file was autogenerated.
