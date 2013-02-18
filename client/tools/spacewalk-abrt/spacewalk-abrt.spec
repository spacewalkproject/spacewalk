Name:           spacewalk-abrt
Version:        1.9.3
Release:        1%{?dist}
Summary:        ABRT plug-in for rhn-check

Group:	        Applications/System
License:        GPLv2
URL:            https://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  gettext
Requires:       abrt
Requires:       rhnlib
Requires:       rhn-check
%description
spacewalk-abrt - rhn-check plug-in for collecting information about crashes handled by ABRT.

%prep
%setup -q

%build
make -f Makefile.spacewalk-abrt

%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.spacewalk-abrt install PREFIX=$RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files
%config  /etc/sysconfig/rhn/clientCaps.d/abrt
%config  /etc/libreport/events.d/spacewalk.conf
%{_bindir}/spacewalk-abrt
%{_datadir}/rhn/spacewalk_abrt/*
%{_mandir}/man8/*

%changelog
* Mon Feb 18 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.3-1
- update build requires

* Fri Feb 15 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.2-1
- spacewalk-abrt: implement --sync command
- abrt: add info about spacewalk libreport events
- abrt: ability to update crash count

* Thu Jan 17 2013 Jan Pazdziora 1.9.1-1
- abrt: use DumpLocation from /etc/abrt/abrt.conf if set

* Wed Jul 18 2012 Jan Pazdziora 0.0.1-1
- new package built with tito

* Mon Jul 09 2012 Richard Marko <rmarko@redhat.com> 0.0.1-1
- initial packaging

