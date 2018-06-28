%if 0%{?fedora} || 0%{?rhel} >= 8
%global build_py3   1
%endif

Name:        spacewalk-remote-utils
Version:     2.9.3
Release:     1%{?dist}
Summary:     Utilities to interact with a Red Hat Satellite or Spacewalk server remotely.

License:     GPLv2
URL:         https://github.com/spacewalkproject/spacewalk
Source:      https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch:   noarch

%if 0%{?build_py3}
BuildRequires: python3-devel
Requires: python3-rhnlib
Requires: python3-pygpgme
%else
BuildRequires: python-devel
Requires: rhnlib >= 2.8.4
Requires: pygpgme
%if 0%{?suse_version}
# provide directories for filelist check in OBS
BuildRequires: rhn-client-tools
%endif
%endif
BuildRequires: docbook-utils

%description
Utilities to interact with a Red Hat Satellite or Spacewalk server remotely over XMLRPC.

%prep
%setup -q

%build
docbook2man ./spacewalk-create-channel/doc/spacewalk-create-channel.sgml -o ./spacewalk-create-channel/doc/
%if 0%{?build_py3}
    sed -i 's|#!/usr/bin/python|#!/usr/bin/python3|' ./spacewalk-create-channel/spacewalk-create-channel
    sed -i 's|#!/usr/bin/python|#!/usr/bin/python3|' ./spacewalk-add-providers/spacewalk-add-providers
%endif

%install
%{__rm} -rf %{buildroot}

%{__mkdir_p} %{buildroot}/%{_bindir}
%{__install} -p -m0755 spacewalk-add-providers/spacewalk-add-providers %{buildroot}/%{_bindir}/
%{__install} -p -m0755 spacewalk-create-channel/spacewalk-create-channel %{buildroot}/%{_bindir}/

%{__mkdir_p} %{buildroot}/%{_datadir}/rhn/channel-data
%{__install} -p -m0644 spacewalk-create-channel/data/* %{buildroot}/%{_datadir}/rhn/channel-data/

%{__mkdir_p} %{buildroot}/%{_mandir}/man1
%{__gzip} -c ./spacewalk-create-channel/doc/spacewalk-create-channel.1 > %{buildroot}/%{_mandir}/man1/spacewalk-create-channel.1.gz

%clean
%{__rm} -rf %{buildroot}

%files
%{_bindir}/spacewalk-add-providers
%{_bindir}/spacewalk-create-channel
%{_datadir}/rhn/channel-data/
%doc spacewalk-create-channel/doc/README spacewalk-create-channel/doc/COPYING
%doc %{_mandir}/man1/spacewalk-create-channel.1.gz

%changelog
* Thu Jun 28 2018 Tomas Kasparek <tkasparek@redhat.com> 2.9.3-1
- add RHEL 6.10 channel definitions
- fix ordering of RPMs
- ensure numbers are compared

* Mon May 14 2018 Tomas Kasparek <tkasparek@redhat.com> 2.9.2-1
- 1577219 - explicitly require pygpgme
- 1577219 - fix build macro for python3

* Thu May 03 2018 Jiri Dostal <jdostal@redhat.com> 2.9.1-1
- 1574492 - Update spacewalk-remote-utils with RHEL 7.5 channel definitions
- Bumping package versions for 2.9.

* Tue Feb 20 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.5-1
- use python3 on rhel8 in spacewalk-remote-utils

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.4-1
- removed Group from specfile

* Tue Oct 10 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.3-1
- make python2/3 defs consistent with other specs

* Thu Sep 07 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- removed unnecessary BuildRoot tag

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Wed Aug 09 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.8-1
- 1161715 - add newline before list of arguments

* Fri Aug 04 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.7-1
- 1474345 - fixed script output

* Fri Aug 04 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.6-1
- 1161715 - spacewalk-create-channel man page options

* Thu Aug 03 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.5-1
- 1474345 - update spacewalk-remote-utils with RHEL 7.4 channel definitions

* Wed Apr 05 2017 Jiri Dostal <jdostal@redhat.com> 2.7.4-1
- 1439097 - Update spacewalk-remote-utils with RHEL 6.9 channel definitions
- Use HTTPS in all Github links
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Wed Dec 07 2016 Jiri Dostal <jdostal@redhat.com> 2.7.3-1
- python 3 requires print with parentheses   File /usr/bin/spacewalk-create-
  channel, line 443     print fullDir                 ^ SyntaxError: Missing
  parentheses in call to 'print'

* Thu Dec 01 2016 Jiri Dostal <jdostal@redhat.com> 2.7.2-1
- Updating spacewalk-create-channel to gather Supplementary channels
- Supplementary channels for RHEL 7.3 channel definitions

* Mon Nov 28 2016 Jiri Dostal <jdostal@redhat.com> 2.7.1-1
- update of spacewalk-remote-utils with RHEL 7.3 channel definitions
- Bumping package versions for 2.7.

* Mon May 30 2016 Tomas Kasparek <tkasparek@redhat.com> 2.6.1-1
- add supplementary channanels to spacewalk-create-channel
- Bumping package versions for 2.6.

* Wed May 18 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.5-1
- convert string and print in spacewalk-create-channel to work in python 3

* Wed May 18 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.4-1
- update spacewalk-remote-utils with RHEL 6.8 content

* Thu May 12 2016 Gennadii Altukhov <galt@redhat.com> 2.5.3-1
- change build dependency on python-devel, because we don't use Python3 during
  package building

* Mon Apr 25 2016 Gennadii Altukhov <galt@redhat.com> 2.5.2-1
- Make spacewalk-remote-utils compatible with Python 2 and 3
- Fix indentation to default 4 spaces

* Fri Nov 20 2015 Tomas Kasparek <tkasparek@redhat.com> 2.5.1-1
- add RHEL 7.2 channel definitions
- Bumping package versions for 2.5.

* Wed Sep 09 2015 Jiri Dostal <jdostal@redhat.com> 2.4.5-1
- RFE 1257652 - spacewalk-create-channel added -o option to clone channel to
  current state

* Fri Aug 07 2015 Jan Dobes 2.4.4-1
- use hostname instead of localhost for https connections

* Mon Aug 03 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.3-1
- channel definitions for rhel 6.7

* Mon Apr 13 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.2-1
- channel definitions for rhel 7.1
- update channel definitions

* Thu Apr 02 2015 Jan Dobes 2.4.1-1
- require more recent rhnlib
- Bumping package versions for 2.4.

* Wed Feb 18 2015 Matej Kollar <mkollar@redhat.com> 2.3.7-1
- Updating function names
- Setting ts=4 is wrong

* Wed Jan 14 2015 Matej Kollar <mkollar@redhat.com> 2.3.6-1
- Getting rid of Tabs and trailing spaces in Python
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Fri Nov 28 2014 Tomas Lestach <tlestach@redhat.com> 2.3.5-1
- 1161787 - Option "--name" of sw-create-channel is not documented correctly in
  the man page.

* Fri Nov 07 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.4-1
- 1158840 - missing RHEL6.6 subrepos
- 1158840 - compose subrepos don't contain listing in RHEL6.6

* Mon Nov 03 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.3-1
- 1158840 - channel definitions for RHEL 6.6
- compose format has slightly changed for RHEL6.6

* Tue Sep 16 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.2-1
- 1142172 - channel definitions for RHEL 5.11

* Fri Aug 01 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.1-1
- 1121352 - sw-create-channel 6-gold-server-x86_64 data file out-of-date

* Thu Jun 26 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.2-1
- Channel content definitions for RHEL-7.0
- 1112391 - recognize RHEL-7 compose structure

* Mon Mar 31 2014 Stephen Herr <sherr@redhat.com> 2.2.1-1
- Fix channel arch on the spacewalk-create-channel man page
- Bumping package versions for 2.2.

* Fri Jan 03 2014 Tomas Lestach <tlestach@redhat.com> 2.1.3-1
- don't print traceback when entered incorrect credentials

* Wed Nov 27 2013 Tomas Lestach <tlestach@redhat.com> 2.1.2-1
- 1035288 - channel definitions for RHEL6.5

* Mon Nov 11 2013 Tomas Lestach <tlestach@redhat.com> 2.1.1-1
- 1020665 - channel definitions for RHEL-5-U10
- Bumping package versions for 2.1.

