%{!?python_sitelib: %define python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}

Summary: Python libraries for the Spacewalk project
Name: rhnlib
URL:     https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 2.5.77
Release: 1%{?dist}

Group: Development/Libraries
License: GPLv2
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%if %{?suse_version: %{suse_version} > 1110} %{!?suse_version:1}
BuildArch: noarch
%endif
BuildRequires: python-devel

Requires: pyOpenSSL 
Conflicts: rhncfg < 5.10.45
Conflicts: spacewalk-proxy-installer < 1.3.2
Conflicts: rhn-client-tools < 1.3.3
Conflicts: rhn-custom-info < 5.4.7
Conflicts: rhnpush < 5.5.10
Conflicts: rhnclient < 0.10
Conflicts: spacewalk-proxy < 1.3.6

%description
rhnlib is a collection of python modules used by the Spacewalk (http://spacewalk.redhat.com) software.


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
make -f Makefile.rhnlib


%install
rm -rf $RPM_BUILD_ROOT
%{__python} setup.py install -O1 --skip-build --root $RPM_BUILD_ROOT --prefix=%{_prefix}


%clean
rm -rf $RPM_BUILD_ROOT


%files
%doc ChangeLog COPYING README TODO

%{python_sitelib}/*

%changelog
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

