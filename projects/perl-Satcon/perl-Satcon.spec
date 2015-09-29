%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

Name:           perl-Satcon
Summary:        Framework for configuration files
Version:        2.5.0
Release:        1%{?dist}
License:        GPLv2
Group:          Applications/System
URL:            https://fedorahosted.org/spacewalk
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRequires:  perl(ExtUtils::MakeMaker)
Requires:       %{sbinpath}/restorecon

%description
Framework for generating config files during installation.
This package include Satcon perl module and supporting applications.

%prep
%setup -q

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT

make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

%check
make test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%doc README LICENSE 
%{perl_vendorlib}/*
%{_bindir}/*

%changelog
* Thu Mar 19 2015 Grant Gainey 2.3.2-1
- Updating copyright info for 2015

* Fri Jan 16 2015 Matej Kollar <mkollar@redhat.com> 2.3.1-1
- Getting rid of trailing spaces in Perl
- Getting rid of Tabs in Perl
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files
- Bumping package versions for 2.3.
- Bumping package versions for 2.2.

* Fri Mar 22 2013 Michael Mraka <michael.mraka@redhat.com> 1.20-1
- 919468 - fixed path in file based Requires
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.
- %%defattr is not needed since rpm 4.4

* Tue Jul 19 2011 Jan Pazdziora 1.19-1
- Updating the copyright years.

* Tue May 03 2011 Jan Pazdziora 1.18-1
- Do chgrp apache for files being deployed.

* Thu Apr 28 2011 Jan Pazdziora 1.17-1
- Do not confuse me by saying Unsubstituted Tags when there are none.
- Do not deploy .orig files.
- When creating config files in /etc/rhn, clear access for other (make it
  -rw-r-----, in typical case).

* Mon Apr 25 2011 Jan Pazdziora 1.16-1
- The File::Copy and File::Temp do not seem to be used in Satcon, removing the
  use.

* Thu Apr 21 2011 Jan Pazdziora 1.15-1
- When creating the backup directory, do not leave them open for other, just
  owner and group should be enough.
- Use cp -p instead of File::Copy::copy to preserve the access rights.

* Fri Feb 18 2011 Jan Pazdziora 1.14-1
- Localize the filehandle globs; also use three-parameter opens.

* Tue Jan 11 2011 Jan Pazdziora 1.13-1
- Removing satcon-make-rpm.pl from repository as we haven't been packaging it
  since 2008.

* Tue Dec 14 2010 Jan Pazdziora 1.12-1
- We need to check the return value of GetOptions and die if the parameters
  were not correct.

