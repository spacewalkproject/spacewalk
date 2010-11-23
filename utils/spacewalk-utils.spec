%define rhnroot %{_prefix}/share/rhn

Name:		spacewalk-utils
Version:	1.3.2
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
Requires:       /usr/bin/sqlplus
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
Generic utilities that may be run against a Spacewalk server.


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
* Tue Nov 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.2-1
- fixed pylint errors
- added spacewalk 1.2 channels and repos

* Fri Nov 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.1-1
- re-added automatic external yum repo creation based on new API
- Bumping package versions for 1.3

* Fri Nov 05 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.9-1
- 491331 - move /etc/sysconfig/rhn-satellite-prep to /var/lib/rhn/rhn-
  satellite-prep (msuchy@redhat.com)

* Mon Nov 01 2010 Jan Pazdziora 1.2.8-1
- As the table rhnPaidErrataTempCache is no more, we do not need to have check
  for temporary tables.

* Fri Oct 29 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.7-1
- fixed spacewalk-common-channels
- updated spacewalk-common-channels to Spacewalk 1.1 and Fedora 13 and 14

* Tue Oct 26 2010 Jan Pazdziora 1.2.6-1
- Blobs (byteas) want double backslashes and octal values.

* Thu Oct 21 2010 Jan Pazdziora 1.2.5-1
- Adding spacewalk-dump-schema to the Makefile to be added to the rpm.
- Documentation (man page).
- For blobs, quote everything; for varchars, do not quote the UTF-8 characters.
- Export in UTF-8.
- To process the evr type, we need to handle the ARRAY ref.
- Skip the quartz tables, they get regenerated anyway.
- Escape characters that we need to escape.
- Use the ISO format for date.
- Dump records.
- No commit command, we run psql in autocommit.
- Fail if we try to dump lob longer than 10 MB.
- Do not dump copy commands for tables that are empty.
- For each table, print the copy command.
- Do not attempt to copy over temporary tables or we get error about
  rhnpaiderratatempcache.
- Initial table processing -- just purge for now.
- Stop on errors.
- Dump sequences.
- Process arguments and connect.
- Original stub of the schema dumper.

* Tue Oct 19 2010 Jan Pazdziora 1.2.4-1
- As Oracle XE is no longer managed by rhn-satellite, we need to change the
  logic in spacewalk-hostname-rename a bit as well.

* Tue Oct 05 2010 Tomas Lestach <tlestach@redhat.com> 1.2.3-1
- 639818 - fixing sys path (tlestach@redhat.com)

* Mon Oct 04 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.2-1
- replaced local copy of compile.py with standard compileall module

* Thu Sep 09 2010 Tomas Lestach <tlestach@redhat.com> 1.2.1-1
- 599030 - check whether SSL certificate generation was successful
  (tlestach@redhat.com)
- use hostname as default value for organization unit (tlestach@redhat.com)
- enable also VPN IP (tlestach@redhat.com)
- bumping package versions for 1.2 (mzazrivec@redhat.com)

* Mon May 17 2010 Tomas Lestach <tlestach@redhat.com> 1.1.5-1
- changing package description (tlestach@redhat.com)
- do not check /etc/hosts file for actual hostname (tlestach@redhat.com)
- check for presence of bootstrap files before modifying them
  (tlestach@redhat.com)
- fixed typo (tlestach@redhat.com)
- set localhost instead of hostname to tnsnames.ora and listener.ora
  (tlestach@redhat.com)
- fixed a typo in the man page (tlestach@redhat.com)

* Tue Apr 27 2010 Tomas Lestach <tlestach@redhat.com> 1.1.4-1
- fixed Requires (tlestach@redhat.com)
- spacewalk-hostname-rename code cleanup (tlestach@redhat.com)

* Thu Apr 22 2010 Tomas Lestach <tlestach@redhat.com> 1.1.3-1
- adding requires to utils/spacewalk-utils.spec (tlestach@redhat.com)

* Wed Apr 21 2010 Tomas Lestach <tlestach@redhat.com> 1.1.2-1
- changes to spacewalk-hostname-rename script (tlestach@redhat.com)
- introducing spacewalk-hostname-rename.sh script (tlestach@redhat.com)

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

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
