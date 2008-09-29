Name:         SatConfig-dbsynch
Version:      1.3.1
Release:      1%{?dist}
Summary:      Satellite Configuration System - database synchronizer
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/SatConfig/dbsynch
# make srpm
URL:          https://fedorahosted.org/spacewalk
Source:	      %{name}-%{version}.tar.gz
BuildArch:    noarch
Group:        Applications/Databases
License:      GPLv2
Requires:	  oracle-instantclient-basic
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
SatConfig-dbsynch defines a mechanism by which config pusher logic can 
explicitly tell the current state database to synchronize itself with the
config db.

%prep
%setup -q

%build
#nothing to do here

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{_bindir}
mkdir -p $RPM_BUILD_ROOT%{_usr}/share/SatConfig
install -m 755 synch.sh $RPM_BUILD_ROOT%{_bindir}
install -m 644 synch.sqplus $RPM_BUILD_ROOT%{_usr}/share/SatConfig

%files 
%defattr(-,root,root,-)
%{_bindir}/synch.sh
%dir %{_usr}/share/SatConfig
%{_usr}/share/SatConfig/synch.sqplus

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Wed Sep 24 2008 Miroslav Suchý <msuchy@redhat.com> 1.3.1-1
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

