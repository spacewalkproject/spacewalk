Name:           spacewalk-schema
Group:          Applications/Internet
Summary:        Oracle SQL schema for Spacewalk server.

Version:        0.2.3
Release:        1%{?dist}
Source0:        %{name}-%{version}.tar.gz

License:        GPLv2
Url:            http://fedorahosted.org/spacewalk/
BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Obsoletes:	rhn-satellite-schema <= 5.1.0

%define rhnroot /etc/sysconfig/rhn/
%define universe universe.satellite.sql

%description
rhn-satellite-schema is the Oracle SQL schema for the Spacewalk server.
Oracle tablespace name conversions have NOT been applied.

%prep

%setup

%build
SCHEMA_VER=$(echo %{version} | sed 's/%{?dist}$//')
make -f Makefile.schema \
  UNIVERSE=%{universe} TOP=. SCHEMA=%{name} VERSION=$SCHEMA_VER RELEASE=%{release} \
  all

%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d $RPM_BUILD_ROOT%{rhnroot}
install -m 0644 %{universe} $RPM_BUILD_ROOT%{rhnroot}
install -m 0644 %{name}-upgrade $RPM_BUILD_ROOT%{rhnroot}
find upgrade -type d | \
    xargs -r -n1 -I{} install -m 0755 -d $RPM_BUILD_ROOT%{rhnroot}/schema-{}
find upgrade -type f | \
    xargs -r -n1 -I{} install -m 0644 {} $RPM_BUILD_ROOT%{rhnroot}/schema-{}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{rhnroot}/*

%changelog
* Wed Sep 10 2008 Milan Zazrivec 0.2.3-1
- fixed package obsoletes

* Tue Sep  2 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.2-1
- Adding new kickstart profile options.

* Mon Sep  1 2008 Milan Zazrivec <mzazrivec@redhat.com> 0.2.1-1
- bumping version for spacewalk 0.2

* Tue Aug  5 2008 Michael Mraka <michael.mraka@redhat.com> 0.1.0-2
- renamed from rhn-satellite-schema and changed version

* Mon Jun  9 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-2
- fixed build issue

* Tue Jun  3 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-1
- purged unused code
- rebuilt via brew / dist-cvs

