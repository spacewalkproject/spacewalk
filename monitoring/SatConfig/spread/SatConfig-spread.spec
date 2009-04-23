Name:         SatConfig-spread
Version:      1.1.3
Release:      1%{?dist}
Summary:      Spread configuration for Spacewalk
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Group:        Applications/System
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
Defines how Spacewalk spread configurations should look.

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{_bindir}
install -m 755 getSpreadConfig $RPM_BUILD_ROOT%{_bindir}

%files
%defattr(-,root,root,-)
%{_bindir}/getSpreadConfig
%doc README

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Thu Apr 23 2009 jesus m. rodriguez <jesusr@redhat.com> 1.1.3-1
- change Source0 to point to fedorahosted.org (msuchy@redhat.com)

* Mon Oct 20 2008 Miroslav Suchý <msuchy@redhat.com> 1.1.2-1
- 467441 - fix namespace

* Wed Sep 24 2008 Miroslav Suchý <msuchy@redhat.com> 1.1.1-1
- spec cleanup for Fedora
