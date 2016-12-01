%if ! (0%{?fedora} || 0%{?rhel} > 5)
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%{!?python_sitearch: %global python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(1))")}
%endif

Name:        spacewalk-remote-utils
Version:     2.7.1
Release:     1%{?dist}
Summary:     Utilities to interact with a Red Hat Satellite or Spacewalk server remotely.

Group:       Applications/System
License:     GPLv2
URL:         http://fedorahosted.org/spacewalk
Source:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:   %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:   noarch

BuildRequires: python-devel
%if 0%{?fedora} >= 23
Requires: python3-rhnlib
%else
Requires: rhnlib >= 2.5.74
%endif

BuildRequires: docbook-utils
%if 0%{?suse_version}
# provide directories for filelist check in OBS
BuildRequires: rhn-client-tools
%endif

%description
Utilities to interact with a Red Hat Satellite or Spacewalk server remotely over XMLRPC.

%prep
%setup -q

%build
docbook2man ./spacewalk-create-channel/doc/spacewalk-create-channel.sgml -o ./spacewalk-create-channel/doc/
%if 0%{?fedora} >= 23
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
#%{python_sitelib}/spacecmd/
%{_datadir}/rhn/channel-data/

%doc spacewalk-create-channel/doc/README spacewalk-create-channel/doc/COPYING
%doc %{_mandir}/man1/spacewalk-create-channel.1.gz

%changelog
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

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.2-1
- branding fixes in man pages

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.1-1
- rebranding RHN Satellite to Red Hat Satellite in client stuff
- Bumping package versions for 1.9

* Wed Feb 27 2013 Jan Pazdziora 1.9.3-1
- 916166 - the RHEL 6.4 spacewalk-create-channel definitions.

* Mon Jan 14 2013 Tomas Lestach <tlestach@redhat.com> 1.9.2-1
- 895029 - remove channel definitions that aren't available any more
- 895029 - sort 6.1 and 6.2 Supplementary content
- 895029 - adding missing 5-u9-server-x86_64

* Mon Jan 14 2013 Tomas Lestach <tlestach@redhat.com> 1.9.1-1
- 895029 - adding RHEL5.9 channel definitions
- 895029 - adding RHEL4.9-Extras channel definitions
- Bumping package versions for 1.9.

* Mon Oct 22 2012 Jan Pazdziora 1.8.5-1
- no need to require rhnlib >= 2.5.31
- rhnlib >= 2.5.38 is not necessary

* Tue Aug 28 2012 Jan Pazdziora 1.8.4-1
- Fixing the License rpm header to match the COPYING information.

* Fri Aug 10 2012 Tomas Lestach <tlestach@redhat.com> 1.8.3-1
- adding optional and supplementary RHEL6.3 channel definitions
- Revert "add missing optional and supplementary channel definitions"

* Thu Aug 09 2012 Tomas Lestach <tlestach@redhat.com> 1.8.2-1
- add missing optional and supplementary channel definitions
- fix dir to match RHEL6 supplementary channel
- fix dir to match RHEL6 optional channel

* Mon Jul 23 2012 Tomas Lestach <tlestach@redhat.com> 1.8.1-1
- 841027 - adding RHEL6.3 channel definitions
- add RHEL6.1 and RHEL6.2 Workstation channel definitions
- fix repodir to match RHEL-6 release directories
- add RHEL5.6 Client Supplementary channel definitions
- %%defattr is not needed since rpm 4.4
- Bumping package versions for 1.8.

* Wed Feb 22 2012 Miroslav Suchý 1.7.1-1
- 796077 - Include the RHEL 5.8 definitions in spacewalk-repo-sync
- Bumping package versions for 1.7. (mzazrivec@redhat.com)

* Mon Dec 19 2011 Miroslav Suchý 1.6.8-1
- 641936 - fix typo in man page
- 768854 - introduce mapping for rhel6 add-ons (slukasik@redhat.com)

* Thu Dec 15 2011 Miroslav Suchý 1.6.7-1
- 767718 - add data for rhel add-on's -
  Highavailability,Loadbalancer,Resilientstorage and Scalablefilesystem
- 767718 - gather data for rhel add-on's
- no need to handle Workstation for el6 specialy

* Mon Dec 12 2011 Miroslav Suchý 1.6.6-1
- 641936 - fix grammar in man page
- 641936 - correct script name in --help output

* Fri Dec 09 2011 Miroslav Suchý 1.6.5-1
- 750743 - add channel definition for optional channels
- 750743 - gather data for optional channels
- 761548 - add rhel 6.2 channel definitions

* Thu Dec 08 2011 Miroslav Suchý 1.6.4-1
- 641936 - update example to RHEL6
- 641936 - fix typos in man page

* Tue Nov 01 2011 Aron Parsons <parsonsa@bit-sys.com> 1.6.3-1
- added spacewalk-add-providers script to spacewalk-remote-utils package
  (parsonsa@bit-sys.com)

* Tue Aug 02 2011 Tomas Lestach <tlestach@redhat.com> 1.6.2-1
- 727531 - adding RHEL5.7 channel definitions (tlestach@redhat.com)

* Fri Jul 22 2011 Jan Pazdziora 1.6.1-1
- We only support version 14 and newer of Fedora, removing conditions for old
  versions.

* Fri Jul 08 2011 Simon Lukasik <slukasik@redhat.com> 1.5.3-1
- 719555 - override channel name of ComputeNode (slukasik@redhat.com)

* Mon Jun 27 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.2-1
- added data files for RHEL6.1
- added data files for RHEL5.6 Supplementary
- adopted spacewalk-create-channel to RHEL6.1

* Fri Apr 15 2011 Jan Pazdziora 1.5.1-1
- build spacewalk-remote-utils on SUSE (mc@suse.de)

* Fri Apr 08 2011 Miroslav Suchý 1.4.7-1
- Revert "idn_unicode_to_pune() have to return string" (msuchy@redhat.com)

* Tue Apr 05 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.6-1
- idn_unicode_to_pune() has to return string

* Wed Mar 30 2011 Miroslav Suchý 1.4.5-1
- 683200 - support IDN

* Wed Mar 16 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.4-1
- allowing input of 0 insteado f 'gold' in spacewalk-create-channel
  (jsherril@redhat.com)
- replace dead code with default from optparse

* Tue Mar 08 2011 Justin Sherrill <jsherril@redhat.com> 1.4.3-1
- adding new data files for spacewalk-create-channel (jsherril@redhat.com)
- updating spacewalk-create-channel to properly support RHEL 6 and added
  supplementary repos for it (jsherril@redhat.com)

* Mon Mar 07 2011 Jan Pazdziora 1.4.2-1
- Fixing description of the -u/--update option in spacewalk-create-channel man
  page. (luc@delouw.ch)

* Thu Feb 03 2011 Justin Sherrill <jsherril@redhat.com> 1.4.1-1
- Adding RHEL 5.6 data files for spacewalk-create-channel (jsherril@redhat.com)

* Tue Oct 12 2010 Jan Pazdziora 1.0.5-1
- correct Summary and Description (msuchy@redhat.com)
- correct URL and Source0 (msuchy@redhat.com)
- man page formatting fix (jsherril@redhat.com)
- man page formatting fix (jsherril@redhat.com)
- fixing man page name (jsherril@redhat.com)

* Tue Oct 05 2010 Justin Sherrill <jsherril@redhat.com> 1.0.4-1
- adding RHEL 6 data files for spacewalk-create-channel (jsherril@redhat.com)
- adding initial support for RHEL 6 to spacewalk-create-channel
  (jsherril@redhat.com)
- updating readme for spacewalk-create-channel (jsherril@redhat.com)

* Thu Sep 30 2010 Justin Sherrill <jsherril@redhat.com> 1.0.3-1
- updating spacewalk-remote-utils man page to remove left over bits from copied
  spec (jsherril@redhat.com)

* Mon Sep 20 2010 Shannon Hughes <shughes@redhat.com> 1.0.2-1
- adding docbook-utils build require (shughes@redhat.com)

* Mon Sep 20 2010 Shannon Hughes <shughes@redhat.com> 1.0.1-1
- new package built with tito

* Fri Aug 20 2010 Justin Sherrill <jsherril@redhat.com> 1.0.0-0
- Initial build.  (jlsherrill@redhat.com)

