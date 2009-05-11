Name:         ssl_bridge
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      1.9.3
Release:      1%{?dist}
Summary:      SSL bridge
URL:          https://fedorahosted.org/spacewalk
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:     nocpulse-common

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package provides an authenticating relay between an SSL client and an 
unencrypted server.

%prep
%setup -q


%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{_bindir}
install -m 755 ssl_bridge.pl $RPM_BUILD_ROOT%{_bindir}

%files
%defattr(-,root,root,-)
%{_bindir}/ssl_bridge.pl

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Thu Apr 23 2009 jesus m. rodriguez <jesusr@redhat.com> 1.9.3-1
- change Source0 to point to fedorahosted.org (msuchy@redhat.com)

* Thu Sep 11 2008 Miroslav Suchý <msuchy@redhat.com> 1.9.2-1
- removing logrotate, it is hadled by nocpulse-common 
- clean up spec to comply with Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Mon Jun 16 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.9.0-5
- cvs.dist import
