Name:         SatConfig-dbsynch
Version:      1.3.2
Release:      1%{?dist}
Summary:      Satellite Configuration System - database synchronizer
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
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
* Thu Apr 23 2009 jesus m. rodriguez <jesusr@redhat.com> 1.3.2-1
- change Source0 to point to fedorahosted.org (msuchy@redhat.com)

* Wed Sep 24 2008 Miroslav Suchý <msuchy@redhat.com> 1.3.1-1
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

