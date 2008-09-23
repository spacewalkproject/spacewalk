Name:         SatConfig-bootstrap
Version:      1.11.1
Release:      1%{?dist}
Summary:      Satellite Configuration System - satellite id installer
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/SatConfig/bootstrap
# make srpm
URL:          https://fedorahosted.org/spacewalk
Source:	      %{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:	  nocpulse-common
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

SatConfig-bootstrap queries NOCpulse for the contents of the netsaintId file.

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{_bindir}
install -m 755 npBootstrap.pl $RPM_BUILD_ROOT%{_bindir}

%files
%defattr(-,root,root,-)
%{_bindir}/npBootstrap.pl

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Tue Sep 23 2008 Miroslav Suchý <msuchy@redhat.com> 1.11.1-1
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

