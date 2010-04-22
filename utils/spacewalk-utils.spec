%define rhnroot %{_prefix}/share/rhn

Name:		spacewalk-utils
Version:	1.0.5
Release:	1%{?dist}
Summary:	Utilities that may be run against a Spacewalk server.

Group:		Applications/Internet
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk
Source0:	https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch

BuildRequires:  /usr/bin/docbook2man
BuildRequires:  docbook-utils
BuildRequires:  python

Requires:       bash
Requires:       cobbler
Requires:       coreutils
Requires:       initscripts
Requires:       iproute
Requires:       net-tools
Requires:       oracle-lib-compat
Requires:       perl-Satcon
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:       python, rpm-python
Requires:       rhnlib >= 2.5.20
Requires:       rpm
Requires:       setup
Requires:       spacewalk-admin
Requires:       spacewalk-certs-tools
Requires:       spacewalk-config
Requires:       spacewalk-setup

%description
Generic utilities that may be run against a Spacewalk server.  This package
contains utilities that may be installed on a client and run against the
server.


%prep
%setup -q


%build
make all


%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{rhnroot}
make install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    MANDIR=%{_mandir}


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root)
%config %{_sysconfdir}/rhn/spacewalk-common-channels.ini
%attr(755,root,root) %{_bindir}/*
%dir %{rhnroot}/utils
%{rhnroot}/utils/__init__.py*
%{rhnroot}/utils/systemSnapshot.py*
%{rhnroot}/utils/migrateSystemProfile.py*
%{_mandir}/man8/*


%changelog
* Thu Apr 22 2010 Tomas Lestach <tlestach@redhat.com> 1.0.5-1
- adding requires to utils/spacewalk-utils.spec (tlestach@redhat.com)

* Wed Apr 21 2010 Tomas Lestach <tlestach@redhat.com> 1.0.4-1
- introducing spacewalk-hostname-rename.sh script (tlestach@redhat.com)

* Mon Apr 19 2010 Justin Sherrill <jsherril@redhat.com> 1.0.2-1
- version changes for spacewalk 1.0 release (shughes@redhat.com)

* Thu Apr 01 2010 Miroslav Suchý <msuchy@redhat.com> 0.9.6-1
- add script delete-old-systems-interactive

* Tue Mar 16 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.5-1
- added repo urls and gpg keys to spacewalk-common-channel.ini

* Mon Feb 22 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.4-1
- emulate epilog in optparse on RHEL5 (python 2.4)

* Wed Feb 17 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.3-1
- fixed of spacewalk-common-channels

* Mon Feb 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.2-1
- added spacewalk-common-channels utility

* Thu Feb 04 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.3-1
- updated copyrights

* Mon Feb 01 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.2-1
- use rhnLockfile from rhnlib

* Tue Jan 05 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- added scr.cgi and apply_errata scripts

* Wed Nov 25 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.1-1
- migration of system profile should be able to run as non root now that it can run on any client and not just satellite. (pkilambi@redhat.com)
- bumping Version to 0.7.0 (jmatthew@redhat.com)

* Wed Aug 05 2009 Jan Pazdziora 0.6.7-1
- utils: add python to BuildRequires

* Fri Jul 31 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.6.6-1
- removing common module dep and adding locking to utils package.

* Wed Jul 15 2009 Miroslav Suchý <msuchy@redhat.com> 0.6.5-1
- add spacewalk-api script, which can interact with API from command line

* Mon May 11 2009 Brad Buckingham <bbuckingham@redhat.com> 0.6.4-1
- 500173 - update migrate-system-profile to import scripts from utils vs
  spacewalk_tools (bbuckingham@redhat.com)

* Sun May 03 2009 Brad Buckingham <bbuckingham@redhat.com> 0.6.3-1
- updates to include system migration scripts


* Mon Apr 27 2009 Brad Buckingham <bbuckingham@redhat.com> 0.6.2-1
- Adding migrate system profile tool to utils package

* Tue Apr 07 2009 Brad Buckingham <bbuckingham@redhat.com> 0.6.1-1
- Initial spec created to include sw-system-snapshot package
