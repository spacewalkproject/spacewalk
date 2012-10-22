Name:           spacewalk-setup-embedded-postgresql
Version:        0.1
Release:        1%{?dist}
Summary:        Tools to setup embedded PostgreSQL database for Spacewalk
Group:          Applications/System
License:        GPLv2
URL:            https://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       postgresql-server > 8.4

%description
Script, which setup embedded PostgreSQL database for Spacewalk. Used during
installation of Spacewalk server.

%prep
%setup -q


%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}/%{_bindir}
install -m 0644 bin/* %{buildroot}/%{_bindir}
chmod -R u+w %{buildroot}/%{_bindir}/*
install -d -m 755 %{buildroot}/%{_datadir}/spacewalk/setup/defaults.d
install -m 0644 setup/defaults.d/* %{buildroot}/%{_datadir}/spacewalk/setup/defaults.d/


%check


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%doc LICENSE
%{_bindir}/spacewalk-setup-embedded-postgresql
%{_mandir}/man1/*
%{_datadir}/spacewalk/setup/defaults.d/*

%changelog
