Name:           spacewalk-abrt
Version:        2.5.1
Release:        1%{?dist}
Summary:        ABRT plug-in for rhn-check

Group:	        Applications/System
License:        GPLv2
URL:            https://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  gettext
BuildRequires:  python
Requires:       abrt
Requires:       abrt-cli
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

%find_lang %{name}

%clean
rm -rf $RPM_BUILD_ROOT

%post
service abrtd restart

%files -f %{name}.lang
%config  /etc/sysconfig/rhn/clientCaps.d/abrt
%config  /etc/libreport/events.d/spacewalk.conf
%{_bindir}/spacewalk-abrt
%{_datadir}/rhn/spacewalk_abrt/*
%{_mandir}/man8/*

%changelog
* Fri Nov 13 2015 Tomas Kasparek <tkasparek@redhat.com> 2.5.1-1
- python is not part of basic Fedora installation anymore
- Bumping package versions for 2.5.

* Fri Sep 25 2015 Jan Dobes 2.4.2-1
- support translations in spacewalk-abrt

* Wed Sep 23 2015 Jan Dobes 2.4.1-1
- Pulling updated *.po translations from Zanata.
- Bumping package versions for 2.4.
- Bumping package versions for 2.3.
- Bumping package versions for 2.2.

* Thu Oct 31 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.4-1
- explicitely require abrt-cli

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.3-1
- Reading only one line
- 1002041 - File content is loaded only when needed

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.2-1
- Grammar error occurred

* Tue Sep 03 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.1-1
- 1002041 - don't upload crash file if over the size limit or the upload is
  disabled
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Wed Jul 10 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.6-1
- 982642 - spacewalk-abrt: correctly report kdump crashes

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.5-1
- rebranding RHN Satellite to Red Hat Satellite in client stuff

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.4-1
- branding clean-up of client tools

* Tue Mar 26 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.3-1
- abrt: report only valid problem directories

* Thu Mar 14 2013 Jan Pazdziora 1.10.2-1
- abrt: support parsing package nevra from older abrt versions

* Fri Mar 08 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.1-1
- spacewalk-abrt: don't return 1 for success

* Fri Mar 01 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.6-1
- typo fix

* Fri Mar 01 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.5-1
- spacewalk-abrt: remodel dump dir location logic
- spacewalk-abrt: use absolute paths

* Wed Feb 27 2013 Jan Pazdziora 1.9.4-1
- abrt: use notify rather than post-create
- abrt: use new abrt dump location

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

