%if 0%{?fedora} || 0%{?suse_version} > 1320 || 0%{?rhel} >= 8 || 0%{?mageia}
%global build_py3   1
%endif

%{!?__python2:%global __python2 /usr/bin/python2}
%{!?__python3:%global __python3 /usr/bin/python3}

%if %{undefined python2_sitelib}
%global python2_sitelib %(%{__python2} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
%endif

%if %{undefined python3_sitelib}
%global python3_sitelib %(%{__python3} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
%endif

%if %{_vendor} == "debbuild"
# For making sure we can set the right args for deb distros
%global is_deb 1
%endif


Summary: Python libraries for the Spacewalk project
Name: rhnlib
Version: 2.9.3
Release: 1%{?dist}
%if %{_vendor} == "debbuild"
Group:      python
Packager:   Spacewalk Project <spacewalk-devel@redhat.com>
%else
Group:      Development/Libraries
%endif
URL:     https://github.com/spacewalkproject/spacewalk
Source0: %{name}-%{version}.tar.gz

License: GPLv2

%if %{?suse_version: %{suse_version} > 1110} %{!?suse_version:1}
BuildArch: noarch
%endif

%description
rhnlib is a collection of python modules used by the Spacewalk (http://spacewalk.redhat.com) software.

%package -n python2-rhnlib
Summary: Python libraries for the Spacewalk project

%if %{_vendor} != "debbuild"
%if 0%{?fedora} >= 28 || 0%{?rhel} >= 8
BuildRequires: python2-devel
Requires: python2-pyOpenSSL
%else
BuildRequires: python-devel
Requires: pyOpenSSL
%endif
%endif

%if %{_vendor} == "debbuild"
BuildRequires: python-dev
BuildRequires: rpm
Requires(preun): python-minimal
Requires(post): python-minimal
Requires: python-openssl
Obsoletes: python-rhn
Conflicts: python-rhn
%endif

Provides: python2-rhnlib = %{version}-%{release}
%{?python_provide:%python_provide python2-rhnlib}

Conflicts: rhncfg < 5.10.45
Conflicts: spacewalk-proxy-installer < 1.3.2
Conflicts: rhn-client-tools < 1.3.3
Conflicts: rhn-custom-info < 5.4.7
Conflicts: rhnpush < 5.5.10
Conflicts: rhnclient < 0.10
Conflicts: spacewalk-proxy < 1.3.6

Provides: rhnlib = %{version}-%{release}
Obsoletes: rhnlib < %{version}-%{release}

%description -n python2-rhnlib
rhnlib is a collection of python modules used by the Spacewalk (http://spacewalk.redhat.com) software.


%if 0%{?build_py3}
%package -n python3-rhnlib
Summary: Python libraries for the Spacewalk project

%if %{_vendor} != "debbuild"
BuildRequires: python3-devel
%if 0%{?mageia}
Requires: python3-OpenSSL
%else
Requires: python3-pyOpenSSL
%endif
%endif

%if %{_vendor} == "debbuild"
BuildRequires: python3-dev
BuildRequires: rpm
Requires(preun): python3-minimal
Requires(post): python3-minimal
Requires: python3-openssl
%endif

%{?python_provide:%python_provide python3-rhnlib}
Conflicts: rhncfg < 5.10.45
Conflicts: spacewalk-proxy-installer < 1.3.2
Conflicts: rhn-client-tools < 1.3.3
Conflicts: rhn-custom-info < 5.4.7
Conflicts: rhnpush < 5.5.10
Conflicts: rhnclient < 0.10
Conflicts: spacewalk-proxy < 1.3.6

%description -n python3-rhnlib
rhnlib is a collection of python modules used by the Spacewalk (http://spacewalk.redhat.com) software.
%endif

%prep
%setup -q

if [ ! -e setup.py ]; then
    sed -e 's/@VERSION@/%{version}/' -e 's/@NAME@/%{name}/' setup.py.in > setup.py
fi
if [ ! -e setup.cfg ]; then
    sed 's/@RELEASE@/%{release}/' setup.cfg.in > setup.cfg
fi


%build
#%{__python} setup.py build
make -f Makefile.rhnlib PYTHON=%{__python2}
%if 0%{?build_py3}
make -f Makefile.rhnlib PYTHON=%{__python3}
%endif


%install
%{__python2} setup.py install %{!?is_deb:-O1}%{?is_deb:--no-compile -O0} --skip-build --root $RPM_BUILD_ROOT %{?is_deb:--install-layout=deb} --prefix=%{_prefix}
%if 0%{?build_py3}
%{__python3} setup.py install %{!?is_deb:-O1}%{?is_deb:--no-compile -O0} --skip-build --root $RPM_BUILD_ROOT %{?is_deb:--install-layout=deb} --prefix=%{_prefix}
%endif

%files -n python2-rhnlib
%doc ChangeLog COPYING README TODO
%{python2_sitelib}/*

%if 0%{?build_py3}
%files -n python3-rhnlib
%doc ChangeLog COPYING README TODO
%{python3_sitelib}/*
%endif

%if %{_vendor} == "debbuild"

%post -n python2-rhnlib
# Do late-stage bytecompilation, per debian policy
pycompile -p python2-rhnlib -V -3.0

%preun -n python2-rhnlib
# Ensure all *.py[co] files are deleted, per debian policy
pyclean -p python2-rhnlib

%if 0%{?build_py3}
%post -n python3-rhnlib
# Do late-stage bytecompilation, per debian policy
py3compile -p python3-rhnlib -V -4.0

%preun -n python3-rhnlib
# Ensure all *.py[co] files are deleted, per debian policy
py3clean -p python3-rhnlib
%endif
%endif

%changelog
* Wed Jul 25 2018 Tomas Kasparek <tkasparek@redhat.com> 2.9.3-1
- forbid old SSL versions during negotiation

* Wed May 30 2018 Tomas Kasparek <tkasparek@redhat.com> 2.9.2-1
- client/rhel: Enable DNF plugin for Mageia 6+ and openSUSE Leap 15.0+

* Wed Apr 25 2018 Tomas Kasparek <tkasparek@redhat.com> 2.9.1-1
- move python2 version of rhnlib into python2-rhnlib package
- Bumping package versions for 2.9.

* Wed Mar 21 2018 Jiri Dostal <jdostal@redhat.com> 2.8.10-1
- Updating copyright years for 2018

* Mon Mar 19 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.9-1
- be compliant with new packaging guidelines when requiring python2 packages

* Fri Mar 09 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.8-1
- don't use undefined variable

* Tue Feb 20 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.7-1
- rhel8 utilizes python3

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.6-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Mon Oct 23 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.5-1
- rhnlib: enable py3 build for Tumbleweed

* Thu Oct 05 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.4-1
- 1494389 - Revert "[1260527] RHEL7 reboot loop"
- 1494389 - Revert "fix except in rhnlib to make it compatible with Python 2.4"

* Thu Sep 28 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.3-1
- Python's OpenSSL.SSL.Connection method for getting state was renamed. Now
  before run it we should determinate its name via getattr built-in function.

* Fri Sep 22 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- added proper python*-rhnlib provides

* Wed Sep 20 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.1-1
- 1471045 - check a state of handshake before shutdown SSL connection
- Bumping package versions for 2.8.

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.5-1
- update copyright year

* Mon Jul 31 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.4-1
- move version and release before sources

* Mon Jul 31 2017 Jan Dobes 2.7.3-1
- 1464157 - python 3 http calls flush

* Fri Apr 07 2017 Jan Dobes 2.7.2-1
- Let the memory usage for ssl-memleak-test stabilize a bit. During the test
  run, the first memory check is often done too quickly, and all necessary
  memory is not allocated yet, ending is false negative test result.
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Tue Nov 15 2016 Gennadii Altukhov <galt@redhat.com> 2.7.1-1
- fix except in rhnlib to make it compatible with Python 2.4
- Bumping package versions for 2.7.

* Fri Nov 11 2016 Jiri Dostal <jdostal@redhat.com> 2.6.2-1
- [1260527] RHEL7 reboot loop

* Thu Oct 20 2016 Gennadii Altukhov <galt@redhat.com> 2.6.1-1
- 1381343 - make rhncfg action configfile compatible with Python 2/3
- Bumping package versions for 2.6.

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.87-1
- updating copyright years

* Fri Apr 22 2016 Gennadii Altukhov <galt@redhat.com> 2.5.86-1
- Fix indentation error

* Fri Apr 22 2016 Gennadii Altukhov <galt@redhat.com> 2.5.85-1
- Add binary mode for file copying for Python 3

* Fri Feb 19 2016 Jan Dobes 2.5.84-1
- just set one required attribute to be compatible with all xmlrpclib versions
- fixed SyntaxError: invalid syntax ' .. = b ' to work in python 2.4

* Sat Jan 23 2016 Grant Gainey 2.5.83-1
- revert contruction errors='ignore' for python3
- python <2.7 fix 'TypeError: encode() takes no keyword arguments'

* Tue Jan 19 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.82-1
- yet another python3 fixes

* Tue Jan 12 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.81-1
- 1259884, 1286555 - more python3 fixes

* Mon Jan 11 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.80-1
- 1259884, 1286555 - fixed python3 BuildRequires

* Mon Jan 11 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.79-1
- 1259884 - build python3-rhnlib only on fedora

* Fri Jan 08 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.78-1
- 1259884, 1286555 - updated to work in python3

* Thu Sep 24 2015 Jan Dobes 2.5.77-1
- Bumping copyright year.

* Tue May 12 2015 Tomas Kasparek <tkasparek@redhat.com> 2.5.76-1
- use single variable instead of a tuple
- exception rising has changed in python 3
- print is function in python3
- make exceptions compatible with python 2.4 to 3.3

* Thu Mar 19 2015 Grant Gainey 2.5.75-1
- Updating copyright info for 2015

* Tue Feb 03 2015 Matej Kollar <mkollar@redhat.com> 2.5.74-1
- Updating function names
- Documentation changes - fix name and refer to RFC.

* Tue Jan 13 2015 Matej Kollar <mkollar@redhat.com> 2.5.73-1
- Getting rid of Tabs and trailing spaces in Python
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.5.72-1
- fix copyright years

* Wed Jun 04 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.5.71-1
- SmartIO: don't use tmpDir configuration from /etc/sysconfig/rhn/up2date

* Fri May 30 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.5.70-1
- convert trusted certificates filenames to utf-8

* Thu Oct 10 2013 Michael Mraka <michael.mraka@redhat.com> 2.5.69-1
- cleaning up old svn Ids

* Fri Oct 04 2013 Michael Mraka <michael.mraka@redhat.com> 2.5.68-1
- Python: fixed UserDictCase behaviour when key is not found

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.5.67-1
- removed trailing whitespaces

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.5.66-1
- Grammar error occurred

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.5.65-1
- updating copyright years

* Wed Jun 19 2013 Stephen Herr <sherr@redhat.com> 2.5.64-1
- 947639 - rhnlib timeout fixes

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.5.63-1
- removed old CVS/SVN version ids
- more branding cleanup

* Mon Jun 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.5.62-1
- rebranding few more strings in client stuff

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 2.5.61-1
- Revert "947639 - new rhnlib conflicts with old spacewalk-backend"

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 2.5.60-1
- branding clean-up of rhel client stuff

* Thu May 02 2013 Stephen Herr <sherr@redhat.com> 2.5.59-1
- 947639 - new rhnlib conflicts with old spacewalk-backend

* Tue Apr 09 2013 Stephen Herr <sherr@redhat.com> 2.5.58-1
- 947639 - rhnlib update made necessary by error in rhncfg

* Wed Apr 03 2013 Stephen Herr <sherr@redhat.com> 2.5.57-1
- 947639 - Make timeout of yum-rhn-plugin calls through rhn-client-tools
  configurable

* Tue Apr 02 2013 Stephen Herr <sherr@redhat.com> 2.5.56-1
- 947639 - make Proxy timeouts configurable
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Tue Oct 30 2012 Jan Pazdziora 2.5.55-1
- Update the copyright year.

* Mon Oct 22 2012 Jan Pazdziora 2.5.54-1
- Revert "Revert "Revert "get_server_capability() is defined twice in osad and
  rhncfg, merge and move to rhnlib and make it member of rpclib.Server"""

* Thu Jun 21 2012 Jan Pazdziora 2.5.53-1
- allow linking against openssl
- %%defattr is not needed since rpm 4.4

* Thu Mar 29 2012 Jan Pazdziora 2.5.52-1
- 807679 - replace $Revision$ with rhnlib version-release.

* Fri Jan 27 2012 Jan Pazdziora 2.5.51-1
- Revert "make split_host IPv6 compliant" (msuchy@redhat.com)

* Wed Jan 11 2012 Miroslav Suchý 2.5.50-1
- make split_host IPv6 compliant

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 2.5.49-1
- update copyright info

* Wed Nov 02 2011 Martin Minar <mminar@redhat.com> 2.5.48-1
- Change PASS percentage after few attempts and print percentage in case of
  failure (jhutar@redhat.com)

* Fri Oct 28 2011 Jan Pazdziora 2.5.47-1
- Do not rely on exact amount of memomory when determinig PASS/FAIL
  (jhutar@redhat.com)

* Mon Oct 24 2011 Martin Minar <mminar@redhat.com> 2.5.46-1
- simplify code (msuchy@redhat.com)
- move imports to beginning of file (msuchy@redhat.com)

* Wed Aug 17 2011 Martin Minar <mminar@redhat.com> 2.5.45-1
- 730744 - support IPv6 connections (mzazrivec@redhat.com)

* Thu Aug 11 2011 Miroslav Suchý 2.5.44-1
- do not mask original error by raise in execption

* Tue Aug 09 2011 Martin Minar <mminar@redhat.com> 2.5.43-1
- 688095 - set timeout for HTTP connections (mzazrivec@redhat.com)

* Wed Jul 27 2011 Michael Mraka <michael.mraka@redhat.com> 2.5.42-1
- import xmlrpclib directly
- removed unnecessary implicit imports

* Fri May 20 2011 Michael Mraka <michael.mraka@redhat.com> 2.5.41-1
- merged backend/common/UserDictCase.py into rhnlib/rhn/UserDictCase.py

* Wed Apr 13 2011 Jan Pazdziora 2.5.40-1
- 683200 - simplify idn_pune_to_unicode and idn_ascii_to_pune
  (msuchy@redhat.com)

* Fri Apr 08 2011 Miroslav Suchý 2.5.39-1
- idn_ascii_to_pune() have to return string (msuchy@redhat.com)
- Revert "idn_unicode_to_pune() have to return string" (msuchy@redhat.com)
- update copyright years (msuchy@redhat.com)

* Tue Apr 05 2011 Michael Mraka <michael.mraka@redhat.com> 2.5.38-1
- idn_unicode_to_pune() has to return string

* Wed Mar 30 2011 Jan Pazdziora 2.5.37-1
- string does not exist, str is the correct thing to use here...
  (jsherril@redhat.com)

* Wed Mar 16 2011 Miroslav Suchý <msuchy@redhat.com> 2.5.36-1
- code cleanup - remove HTTPResponse.read() override

* Fri Mar 11 2011 Miroslav Suchý <msuchy@redhat.com> 2.5.35-1
- 683200 - create idn_ascii_to_pune() and idn_pune_to_unicode(), which will
  take care about corner cases of encodings.idna

* Wed Feb 16 2011 Miroslav Suchý <msuchy@redhat.com> 2.5.34-1
- Revert "Revert "get_server_capability() is defined twice in osad and rhncfg,
  merge and move to rhnlib and make it member of rpclib.Server""
  (msuchy@redhat.com)

* Tue Feb 01 2011 Tomas Lestach <tlestach@redhat.com> 2.5.33-1
- Revert "get_server_capability() is defined twice in osad and rhncfg, merge
  and move to rhnlib and make it member of rpclib.Server" (tlestach@redhat.com)

* Fri Jan 28 2011 Miroslav Suchý <msuchy@redhat.com> 2.5.32-1
- get_server_capability() is defined twice in osad and rhncfg, merge and move
  to rhnlib and make it member of rpclib.Server
- Updating the copyright years to include 2010.

* Mon Dec 20 2010 Michael Mraka <michael.mraka@redhat.com> 2.5.31-1
- put crypto back

* Mon Dec 20 2010 Miroslav Suchý <msuchy@redhat.com> 2.5.30-1
- conflitcs with older versions

* Wed Nov 24 2010 Michael Mraka <michael.mraka@redhat.com> 2.5.29-1
- removed unused imports

* Tue Nov 02 2010 Jan Pazdziora 2.5.28-1
- Update copyright years in the rest of the repo.

* Mon Sep 20 2010 Miroslav Suchý <msuchy@redhat.com> 2.5.27-1
- add copyright file - this is required by Debian policy
- update GPLv2 license file
- 618267 - simplify regexp

* Thu Aug 05 2010 Milan Zazrivec <mzazrivec@redhat.com> 2.5.26-1
- 618267 - do not allow control characters in xmlrpc communication

* Thu Jul 01 2010 Miroslav Suchý <msuchy@redhat.com> 2.5.25-1
- 595837 - write nice error in case of "connection reset by peer" and xmlrpc
  protocol error (msuchy@redhat.com)
- 583980 - replace fcntl.O_NDELAY with os.O_NDELAY, for newer Pythons.
  (jpazdziora@redhat.com)
- 583020 - need to initialize self.send_handler for the class Server as well.
  (jpazdziora@redhat.com)
- Removing server from cmd-line (slukasik@redhat.com)
- Adding port number to command line args (slukasik@redhat.com)
- Adding shebang (slukasik@redhat.com)
- Fixing return value (slukasik@redhat.com)
- Fixing typo. (slukasik@redhat.com)

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 2.5.24-1
- Cleaning up, preparing for automatization
- 575259 - properly set protocol type

