Name: rhns-schema-tools
Summary: Check an RHN schema for correctness.
Group: RHN/Schema
License: GPLv2
Source0: schema-tools-%{version}.tar.gz
Source1: version
Version: %(echo `awk '{ print $1 }' %{SOURCE1}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE1}`)
BuildRoot: /var/tmp/%{name}-%{version}-root
BuildArch: noarch
Requires: python, rhns-server
Obsoletes: schemaTools
Obsoletes: schemaTools-devel

%define rhnroot /usr/share/rhn

%description
Verifies an installed database schema for the Red Hat Network Satellite

%prep
%setup -q -n schema-tools-%{version}

%build
make

%install
rm -rf $RPM_BUILD_ROOT
make install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%dir %{rhnroot}/schema
%{rhnroot}/schema/listobjs.py*
%{rhnroot}/schema/verify.py*
%{rhnroot}/schema/DBObjects.py*
%{rhnroot}/schema/__init__.py*
%{rhnroot}/schema/dump.py*

%changelog
* Tue Aug 20 2002 Cristian Gafton <gafton@redhat.com>
- migrated to the new build system
- renamed to rhns-schema-tools and obsolted the old schemaTools packages
- unified under the same package again

* Tue May 21 2002 Todd Warner <taw@redhat.com>
- RHNS --> RHN

* Fri May  3 2002 Peter Jones <pjones@redhat.com>
- initial spec
