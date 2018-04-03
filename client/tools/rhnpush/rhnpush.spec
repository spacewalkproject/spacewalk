%if 0%{?fedora} || 0%{?rhel} >= 7
%{!?pylint_check: %global pylint_check 1}
%endif

%if 0%{?fedora} || 0%{?rhel} >= 8
%global build_py3   1
%global default_py3 1
%endif

%global build_py2   1

%define pythonX %{?default_py3: python3}%{!?default_py3: python2}

Name:          rhnpush
Summary:       Package uploader for the Spacewalk or Red Hat Satellite Server
License:       GPLv2
URL:           https://github.com/spacewalkproject/spacewalk
Version:       5.5.113
Release:       1%{?dist}
Source0:       https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch:     noarch
Requires:      %{pythonX}-%{name} = %{version}-%{release}
BuildRequires: docbook-utils, gettext
%if 0%{?pylint_check}
%if 0%{?build_py2}
BuildRequires:  spacewalk-python2-pylint
%endif
%if 0%{?build_py3}
BuildRequires:  spacewalk-python3-pylint
%endif
%endif

%description
rhnpush uploads package headers to the Spacewalk or Red Hat Satellite
servers into specified channels and allows for several other channel
management operations relevant to controlling what packages are available
per channel.

%if 0%{?build_py2}
%package -n python2-%{name}
Summary: Package uploader for the Spacewalk or Red Hat Satellite Server
%{?python_provide:%python_provide python2-%{name}}
Requires: %{name} = %{version}-%{release}
%if 0%{?fedora} >= 28
Requires: python2-rpm
BuildRequires: python2-devel
%else
Requires: rpm-python
BuildRequires: python-devel
%endif
Requires: rhnlib >= 2.8.3
Requires: python2-rhn-client-tools
Requires: spacewalk-backend-libs >= 1.7.17
Requires: spacewalk-usix
BuildRequires: spacewalk-backend-libs > 1.8.33
BuildRequires: python2-rhn-client-tools
%description -n python2-%{name}
Python 2 specific files for rhnpush.
%endif

%if 0%{?build_py3}
%package -n python3-%{name}
Summary: Package uploader for the Spacewalk or Red Hat Satellite Server
%{?python_provide:%python_provide python3-%{name}}
Requires: %{name} = %{version}-%{release}
Requires: rpm-python3
Requires: python3-rhnlib >= 2.8.3
Requires: python3-rhn-client-tools
Requires: python3-spacewalk-backend-libs
Requires: python3-spacewalk-usix
BuildRequires: spacewalk-backend-libs > 1.8.33
BuildRequires: python3-devel
BuildRequires: python3-rhn-client-tools
BuildRequires: python3-rpm-macros
%description -n python3-%{name}
Python 3 specific files for rhnpush.
%endif


%prep
%setup -q

%build
make -f Makefile.rhnpush all

%install
install -d $RPM_BUILD_ROOT/%{python_sitelib}
%if 0%{?build_py2}
make -f Makefile.rhnpush install PREFIX=$RPM_BUILD_ROOT ROOT=%{python_sitelib} \
    MANDIR=%{_mandir} PYTHON_VERSION=%{python_version}
%endif

%if 0%{?build_py3}
sed -i 's|#!/usr/bin/python|#!/usr/bin/python3|' rhnpush
install -d $RPM_BUILD_ROOT/%{python3_sitelib}
make -f Makefile.rhnpush install PREFIX=$RPM_BUILD_ROOT ROOT=%{python3_sitelib} \
    MANDIR=%{_mandir} PYTHON_VERSION=%{python3_version}
%endif

%define default_suffix %{?default_py3:-%{python3_version}}%{!?default_py3:-%{python_version}}
ln -s rhnpush%{default_suffix} $RPM_BUILD_ROOT%{_bindir}/rhnpush

%clean

%check
%if 0%{?pylint_check}
# check coding style
%if 0%{?build_py2}
export PYTHONPATH=$RPM_BUILD_ROOT%{python_sitelib}
spacewalk-python2-pylint $RPM_BUILD_ROOT%{_bindir} $RPM_BUILD_ROOT%{python_sitelib}
%endif
%if 0%{?build_py3}
export PYTHONPATH=$RPM_BUILD_ROOT%{python3_sitelib}
spacewalk-python3-pylint $RPM_BUILD_ROOT%{_bindir} $RPM_BUILD_ROOT%{python3_sitelib}
%endif
%endif

%files
%{_bindir}/rhnpush
%{_bindir}/rpm2mpm
%config(noreplace) %attr(644,root,root) %{_sysconfdir}/sysconfig/rhn/rhnpushrc
%{_mandir}/man8/rhnpush.8*
%doc COPYING

%if 0%{?build_py2}
%files -n python2-%{name}
%attr(755,root,root) %{_bindir}/rhnpush-%{python_version}
%{python_sitelib}/rhnpush/
%endif

%if 0%{?build_py3}
%files -n python3-%{name}
%attr(755,root,root) %{_bindir}/rhnpush-%{python3_version}
%{python3_sitelib}/rhnpush/
%endif

%changelog
* Mon Mar 19 2018 Tomas Kasparek <tkasparek@redhat.com> 5.5.113-1
- disable pylint warnings discovered by run on python3
- run pylint 2/3 depending on environment
- don't build python2 subpackages on systems with default python3

* Mon Mar 19 2018 Tomas Kasparek <tkasparek@redhat.com> 5.5.112-1
- be compliant with new packaging guidelines when requiring python2 packages
- require python3-devel for building on python3

* Tue Feb 20 2018 Tomas Kasparek <tkasparek@redhat.com> 5.5.111-1
- use python3 on rhel8 in rhnpush

* Tue Feb 13 2018 Eric Herget <eherget@redhat.com> 5.5.110-1
- Update to use newly separated spacewalk-python[2|3]-pylint packages

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 5.5.109-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Mon Oct 09 2017 Michael Mraka <michael.mraka@redhat.com> 5.5.108-1
- run pylint on all Fedoras
- simplified Makefile
- modules are now in standard sitelib path
- install files into python_sitelib/python3_sitelib
- move rhnpush files into proper python2/python3 subpackages
- split rhnpush into python2/python3 specific packages

* Wed Aug 09 2017 Michael Mraka <michael.mraka@redhat.com> 5.5.107-1
- precompile py3 bytecode on Fedora 23+
- use standard brp-python-bytecompile

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 5.5.106-1
- update copyright year

* Thu May 25 2017 Michael Mraka <michael.mraka@redhat.com> 5.5.105-1
- fixed pylint warnings disabled python3 pylint on Fedora 26+ for now
- removed outdated solaris2mpm script

* Fri Mar 24 2017 Ondrej Gajdusek <ogajduse@redhat.com> 5.5.104-1
- Disabling Pylint in Fedora<25 to prevent weird err

* Wed Mar 15 2017 Ondrej Gajdusek <ogajduse@redhat.com> 5.5.103-1
- Pylint fixes in rhnpush
- pylint fix consider-iterating-dictionary for rhnpush.rhnpush_config
- Use HTTPS in all Github links
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Wed Feb 15 2017 Tomas Kasparek <tkasparek@redhat.com> 5.5.102-1
- require spacewalk-usix indead of spacewalk-backend-usix

* Thu Nov 03 2016 Gennadii Altukhov <galt@redhat.com> 5.5.101-1
- 1390170 - rhnpush is used on a client side as well, so make it compatible
  with RHEL 5 and Python 2.4

* Wed Sep 14 2016 Jan Dobes 5.5.100-1
- fixing pylint in rhnpush

* Tue Sep 06 2016 Jan Dobes 5.5.99-1
- Fix typo

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 5.5.98-1
- updating copyright years

* Wed May 18 2016 Tomas Kasparek <tkasparek@redhat.com> 5.5.97-1
- convert binary data to string to work correctly in Python 3

* Tue May 17 2016 Tomas Kasparek <tkasparek@redhat.com> 5.5.96-1
- fixed RuntimeError: dictionary changed size during iteration
- convert binary data to string to possible compare data in Python 3

* Thu May 12 2016 Gennadii Altukhov <galt@redhat.com> 5.5.95-1
- change build dependency on python-devel, because we don't use Python3 during
  package building

* Fri Apr 22 2016 Gennadii Altukhov <galt@redhat.com> 5.5.94-1
- Add some fixes to rhnpush for Python 3 compatibility - change mode for open()
  function - HTTPResponse getheaders() was renamed to get() - fix binary string
  decoding
- Fix types in rhnpush utility
- Fix relative imports in rhnpush utility

* Thu Apr 21 2016 Gennadii Altukhov <galt@redhat.com> 5.5.93-1
- rhnpush is adapted for Python3

* Wed Mar 30 2016 Tomas Kasparek <tkasparek@redhat.com> 5.5.92-1
- simplify expression
- don't count on having newest rhn-client-tools

* Thu Dec 17 2015 Jan Dobes 5.5.91-1
- 1262780 - alow to use existing rpcServer when creating RhnServer

* Tue Nov 24 2015 Jan Dobes 5.5.90-1
- rhn-satellite-activate: manual references removed

* Wed May 27 2015 Tomas Kasparek <tkasparek@redhat.com> 5.5.89-1
- fix pylint warning on Fedora 22

* Mon Mar 23 2015 Grant Gainey 5.5.88-1
- Standardize pylint-check to only happen on Fedora

* Thu Mar 19 2015 Grant Gainey 5.5.87-1
- Updating copyright info for 2015

* Fri Feb 13 2015 Matej Kollar <mkollar@redhat.com> 5.5.86-1
- One more bump for pune change

* Fri Feb 13 2015 Tomas Lestach <tlestach@redhat.com> 5.5.85-1
- 663039 - Setting timeout requires newer rhnlib
- 663039 - Update man
- 663039 - Kitten has been sacrificed
- 663039 - Wire in timeout for rhnpush
- Cleanup space around comments
- Misplaced comment after 73a918d909d1804a43f7773b6d0b4d7cb0464ac3
- Updating function names
- Remove trailing space

* Fri Jan 30 2015 Matej Kollar <mkollar@redhat.com> 5.5.84-1
- Remove unnecessary pylint disabling...

* Wed Jan 21 2015 Matej Kollar <mkollar@redhat.com> 5.5.83-1
- Fix Pylint on Fedora 21: manual fixes
- Fix Pylint on Fedora 21: autopep8

* Wed Jan 14 2015 Matej Kollar <mkollar@redhat.com> 5.5.82-1
- Getting rid of Tabs and trailing spaces in Python

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.5.81-1
- fix copyright years

* Tue Jun 17 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.5.80-1
- urlparse_object on RHEL-5 is a regular tuple

* Tue Jun 10 2014 Stephen Herr <sherr@redhat.com> 5.5.79-1
- make rhnpush backwards-compatible with old spacewalk-proxy

* Mon Jun 09 2014 Stephen Herr <sherr@redhat.com> 5.5.78-1
- This should work for all versions of pylint

* Mon Jun 09 2014 Stephen Herr <sherr@redhat.com> 5.5.77-1
- One more pylint fix for rhnpush

* Mon Jun 09 2014 Stephen Herr <sherr@redhat.com> 5.5.76-1
- Whitespace changes to rhnpush to make pylint happy

* Sat Jun 07 2014 Stephen Herr <sherr@redhat.com> 5.5.75-1
- 1104375 - typo fix

* Fri Jun 06 2014 Stephen Herr <sherr@redhat.com> 5.5.74-1
- 1104375 - add default path structure to proxy lookaside that avoids
  collisions

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.5.73-1
- spec file polish

* Thu Mar 20 2014 Jan Dobes 5.5.72-1
- 1078157 - correcting exception type

* Thu Oct 10 2013 Michael Mraka <michael.mraka@redhat.com> 5.5.71-1
- cleaning up old svn Ids

* Tue Oct 01 2013 Michael Mraka <michael.mraka@redhat.com> 5.5.70-1
- fixed pylint deprecated-lambda warning

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 5.5.69-1
- removed trailing whitespaces

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 5.5.68-1
- Grammar error occurred

* Tue Aug 06 2013 Tomas Kasparek <tkasparek@redhat.com> 5.5.67-1
- Branding clean-up of proxy stuff in client dir

* Thu Aug 01 2013 Jan Dobes 5.5.66-1
- 990366 - rhnpush can have specified SSL cert by parameter

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 5.5.65-1
- branding fixes in man pages

* Mon Jun 17 2013 Tomas Kasparek <tkasparek@redhat.com> 5.5.64-1
- rebranding few more strings in client stuff

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 5.5.63-1
- rebranding RHN Proxy to Red Hat Proxy in client stuff
- rebranding RHN Satellite to Red Hat Satellite in client stuff

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 5.5.62-1
- branding clean-up of client tools

* Tue May 14 2013 Michael Mraka <michael.mraka@redhat.com> 5.5.61-1
- 871745 - let rhnpush care about SSL cert

* Thu Feb 28 2013 Michael Mraka <michael.mraka@redhat.com> 5.5.60-1
- fixed pylint warnings

* Fri Jan 18 2013 Michael Mraka <michael.mraka@redhat.com> 5.5.59-1
- silence pylint warning

* Mon Dec 17 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.58-1
- restored old passwd based API functions
- fixed Bad indentation. Found 11 spaces, expected 12

* Fri Dec 14 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.57-1
- 873541 - switch back to /XP handler if /APP is not available

* Sun Nov 11 2012 Michael Calmer <mc@suse.de> 5.5.56-1
- package solaris converter for SUSE too

* Tue Oct 30 2012 Jan Pazdziora 5.5.55-1
- Update the copyright year.

* Mon Oct 22 2012 Jan Pazdziora 5.5.54-1
- Revert "Revert "Revert "get_server_capability() is defined twice in osad and
  rhncfg, merge and move to rhnlib and make it member of rpclib.Server"""

* Fri Aug 24 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.53-1
- latest spacewalk-pylint is required

* Fri Aug 24 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.52-1
- turned on pylint checks
- fixed pylint errors/warnings
* Tue Aug 21 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.51-1
- removed dead code
- fixed pylint errors

* Wed Jul 25 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.50-1
- fixed pylint warnings and errors

* Fri Jul 13 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.49-1
- fixed man page
- removed dead --no-cache option
- fixed --no-session-caching option

* Fri Jul 13 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.48-1
- 838044 - solaris2mpm on RHEL5 is not supported
- remove trailing '/' from from archive dir

* Tue Jun 26 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.47-1
- reuse UploadError from uploadLib
- removed functions not used in rhnpush/rhn-package-manager
- simplified authentication code

* Fri Jun 22 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.46-1
- removed commented out code and obsoleted comments

* Sat Jun 16 2012 Miroslav Suchý <msuchy@redhat.com> 5.5.45-1
- 827022 - add COPYING file

* Mon May 21 2012 Jan Pazdziora 5.5.44-1
- 823491 - Use the correct a_pkg variable.
- %%defattr is not needed since rpm 4.4

* Mon Mar 05 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.43-1
- removed unused get_header_struct_size()
- removed unused function get_header_byte_range()

* Fri Mar 02 2012 Jan Pazdziora 5.5.42-1
- Update the copyright year info.

* Mon Feb 20 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.41-1
- merged list() with parent class
- merged uploadHeaders() with parent class
- the very same newest() is defined in parent class

* Wed Feb 08 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.40-1
- pylint fixes

* Tue Feb 07 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.39-1
- updated uploadLib to use A_Package interface
- removed legacy code for satellite < 4.0.6 support
- converted rhnpush to use A_Package interface
- InvalidPackageError is now in rhn_pkg
- removed support for satellite < 4.1.0

* Mon Feb 06 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.38-1
- require new spacewalk-backend-libs

* Sat Feb 04 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.37-1
- fixed pylint errors / warnings

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 5.5.36-1
- update copyright info

* Tue Nov 29 2011 Michael Mraka <michael.mraka@redhat.com> 5.5.35-1
- removed dead functions

* Thu Nov 24 2011 Michael Mraka <michael.mraka@redhat.com> 5.5.34-1
- replaced external zip with zipfile module
- replaced external tar with tarfile module
- don't call os.path.join() over and over
- don't read 2GB file into memory at once
- don't hide original error message
- replaced external unzip with zipfile module

* Wed Oct 19 2011 Michael Mraka <michael.mraka@redhat.com> 5.5.33-1
- removed test for already removed object_has_attr()
- removed dead function object_has_attr()

* Thu Aug 11 2011 Miroslav Suchý 5.5.32-1
- True and False constants are defined since python 2.4
- do not mask original error by raise in execption

* Thu Jul 28 2011 Jan Pazdziora 5.5.31-1
- removing unnecessarry summary line from rhnpush.spec (lzap+git@redhat.com)

* Fri Jul 22 2011 Jan Pazdziora 5.5.30-1
- We always have rhnserver (no longer building for RHEL 4-).
- We only support version 5 and newer of RHEL, removing conditions for old
  versions.

* Fri Jul 15 2011 Miroslav Suchý 5.5.29-1
- optparse is here since python 2.3 - remove optik (msuchy@redhat.com)

* Tue Jun 21 2011 Jan Pazdziora 5.5.28-1
- 559092 - recognize both new and old patch clusters (michael.mraka@redhat.com)
- 485880 - put -N option to SYNOPSIS as well (msuchy@redhat.com)

* Thu May 05 2011 Miroslav Suchý 5.5.27-1
- do not test if rhnParent can handle session caching

* Fri Apr 15 2011 Jan Pazdziora 5.5.26-1
- build rhnpush on SUSE (mc@suse.de)

* Tue Apr 12 2011 Miroslav Suchý 5.5.25-1
- build rhnpush on SUSE (mc@suse.de)

* Fri Apr 08 2011 Miroslav Suchý 5.5.24-1
- Revert "idn_unicode_to_pune() have to return string" (msuchy@redhat.com)

* Fri Apr 08 2011 Miroslav Suchý 5.5.23-1
- update copyright years (msuchy@redhat.com)

* Tue Apr 05 2011 Michael Mraka <michael.mraka@redhat.com> 5.5.22-1
- idn_unicode_to_pune() has to return string
- no need to define built-in constants
- delete dead code

* Fri Apr 01 2011 Miroslav Suchý 5.5.21-1
- pass only one argument to idn_ascii_to_pune (msuchy@redhat.com)

* Wed Mar 30 2011 Miroslav Suchý 5.5.20-1
- 683200 - instead of encodings.idna use wrapper from rhn.connections, which
  workaround corner cases
- 683200 - rhnpush.py - convert servername from input to Pune encodings

* Wed Mar 02 2011 Michael Mraka <michael.mraka@redhat.com> 5.5.19-1
- Revertes "use size instead of archivesize"

* Thu Feb 24 2011 Michael Mraka <michael.mraka@redhat.com> 5.5.18-1
- use size instead of archivesize

* Fri Feb 18 2011 Jan Pazdziora 5.5.17-1
- Revert "Revert "get_server_capability() is defined twice in osad and rhncfg,
  merge and move to rhnlib and make it member of rpclib.Server""
  (msuchy@redhat.com)
- Revert "Revert "648403 - do not create TB even on Red Hat Enterprise Linux
  4"" (msuchy@redhat.com)

* Tue Feb 01 2011 Tomas Lestach <tlestach@redhat.com> 5.5.16-1
- Revert "648403 - do not create TB even on Red Hat Enterprise Linux 4"
  (tlestach@redhat.com)

* Tue Feb 01 2011 Tomas Lestach <tlestach@redhat.com> 5.5.15-1
- Revert "get_server_capability() is defined twice in osad and rhncfg, merge
  and move to rhnlib and make it member of rpclib.Server" (tlestach@redhat.com)

* Tue Feb 01 2011 Miroslav Suchý <msuchy@redhat.com> 5.5.14-1
- 648403 - do not require up2date on rhel5

* Fri Jan 28 2011 Miroslav Suchý <msuchy@redhat.com> 5.5.13-1
- get_server_capability() is defined twice in osad and rhncfg, merge and move
  to rhnlib and make it member of rpclib.Server
- 648403 - do not create TB even on Red Hat Enterprise Linux 4
- 648403 - workaround missing hasCapability() on RHEL4
- Updating the copyright years to include 2010.

* Thu Dec 23 2010 Miroslav Suchý <msuchy@redhat.com> 5.5.12-1
- 648403 - use server given on command line rather than rhnParent

* Mon Dec 20 2010 Miroslav Suchý <msuchy@redhat.com> 5.5.11-1
- 648403 - do not call getPackageChecksumBySession directly

* Wed Dec 08 2010 Michael Mraka <michael.mraka@redhat.com> 5.5.10-1
- import Fault, ResponseError and ProtocolError directly from xmlrpclib

* Mon Dec 06 2010 Miroslav Suchý <msuchy@redhat.com> 5.5.9-1
- 656746 - make _processFile and _processBatch method of UploadClass class
  (msuchy@redhat.com)

* Wed Nov 24 2010 Michael Mraka <michael.mraka@redhat.com> 5.5.8-1
- removed unused imports

* Wed Nov 03 2010 Jan Pazdziora 5.5.7-1
- 649259 - do not fail with invalid user, if we are only testing if call exist
  (msuchy@redhat.com)

* Tue Nov 02 2010 Jan Pazdziora 5.5.6-1
- Update copyright years in the rest of the repo.

* Thu Sep 16 2010 Michael Mraka <michael.mraka@redhat.com> 5.5.5-1
- 600347 - added sat<540 compatibility functions

* Fri Jul 16 2010 Michael Mraka <michael.mraka@redhat.com> 5.5.4-1
- removed dead code

* Thu Jul 08 2010 Justin Sherrill <jsherril@redhat.com> 5.5.3-1
- set default server for rhnpush to localhost instead of
  rhn.redhat.com (jsherril@redhat.com)

* Thu Jul 01 2010 Miroslav Suchý <msuchy@redhat.com> 5.5.2-1
- Also fixed 'Info' -> 'info' as suggested by Milan Zazrivec.
  (jhutar@redhat.com)
- And one more space in 'sometime' as suggested by Jan Pazdziora
  (jhutar@redhat.com)
- Just put space to the correct side (jhutar@redhat.com)

* Tue May 18 2010 Miroslav Suchý <msuchy@redhat.com> 5.5.1-1
- 470154 - arch can be optional, do not freak out if it is not present
- 514805 - recognize X86 arch as i386
- 516898 - workaround for patches which do not have packed most top directory
- no need to copy file, we can operate directly on original
- do not read one file twice
- 559092 - recognize new sun patch cluster format
- 569946 - normalize solaris "x86" value to rhn known value

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 5.4.14-1
- 563630 - Enable proxy support for rhnpush

