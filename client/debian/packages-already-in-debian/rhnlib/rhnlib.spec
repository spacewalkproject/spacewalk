%{!?python_sitelib: %define python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}

Summary: Python libraries for the Spacewalk project
Name: rhnlib
URL:     https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 2.7.0
Release: 1%{?dist}

Group: Development/Libraries
License: GPLv2
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%if %{?suse_version: %{suse_version} > 1110} %{!?suse_version:1}
BuildArch: noarch
%endif
BuildRequires: python-devel

Requires: pyOpenSSL 
Conflicts: rhncfg < 5.9.37
Conflicts: spacewalk-proxy-installer < 1.3.2
Conflicts: rhn-client-tools < 1.3.3
Conflicts: rhn-custom-info < 5.4.7
Conflicts: rhnpush < 5.5.10
Conflicts: rhnclient < 0.10
Conflicts: spacewalk-proxy < 1.3.6

%description
rhnlib is a collection of python modules used by the 
Red Hat Network (http://rhn.redhat.com) software.


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
%defattr(-,root,root,-)
%doc ChangeLog COPYING README TODO

%{python_sitelib}/*

%changelog
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

* Fri Feb 12 2010 Miroslav Suchý <msuchy@redhat.com> 2.5.22-1
- 564299 - handle http 302 redirect request for satellite-sync
- rpclib.py cleanup

* Thu Feb 04 2010 Michael Mraka <michael.mraka@redhat.com> 2.5.21-1
- updated copyrights

* Mon Feb 01 2010 Michael Mraka <michael.mraka@redhat.com> 2.5.20-1
- added rhnLockfile

* Wed Jan 20 2010 Miroslav Suchý <msuchy@redhat.com> 2.5.19-1
- code cleanup

* Mon Dec 07 2009 Michael Mraka <michael.mraka@redhat.com> 2.5.18-1
- moved code from rhnlib to spacewalk-backend-libs

* Fri Dec  4 2009 Miroslav Suchý <msuchy@redhat.com> 2.5.17-1
- sha256 support

* Fri Dec 04 2009 Michael Mraka <michael.mraka@redhat.com> 2.5.16-1
- added rhn_rpm and rhn_mpm 

* Wed Nov 25 2009 Miroslav Suchý <msuchy@redhat.com> 2.5.15-1
- aamt is not Null in most cases, move it more to right
- replace len() with ==
- count length of buffer only once in loop

* Thu Nov  5 2009 Miroslav Suchy <msuchy@redhat.com> 2.5.14-1
- fix build under opensuse

* Thu Aug 06 2009 Pradeep Kilambi <pkilambi@redhat.com> 2.5.13-1
- 

* Thu May 21 2009 jesus m. rodriguez <jesusr@redhat.com> 2.5.12-1
- merging additional spec changes and minor edits from svn (pkilambi@redhat.com)
- 499860 Ability to define location for the temporary transport file
  descriptors, uses /tmp by default (pkilambi@redhat.com)
- use tempfile to create transport objects instead of an ugly loop (pkilambi@redhat.com)

* Fri May  8 2009 Pradeep Kilambi <pkilambi@redhat.com> 2.2.7-2
Resolves: #489920 #484245 #489921 #492638 #499858 #499860

* Wed May 06 2009 jesus m. rodriguez <jesusr@redhat.com> 2.5.11-1
- fixing the rpc version checks (pkilambi@redhat.com)
- 492638, 489921, 484245 - Adding redirect support to rhnlib for rhel-5 clients
  (pkilambi@redhat.com)

* Mon Feb 23 2009 Miroslav Suchy <msuchy@redhat.com> 2.5.10-1
- point Source0 to Fedorahosted.org

* Thu Feb 12 2009 jesus m. rodriguez <jesusr@redhat.com> 2.5.9-1
- replace "!#/usr/bin/env python" with "!#/usr/bin/python"

* Tue Jan 27 2009 Dennis Gilmore <dennis@ausil.us> 2.5.8-1
- clean up files section 

* Tue Jan 27 2009 Miroslav Suchý <msuchy@redhat.com> 2.5.7-1
- remove .egg-info file from spec - we do not provide it

* Wed Jan 21 2009 Pradeep Kilambi <pkilambi@redhat.com> 2.5.6-1
- Remove usage of version and sources files.

* Tue Sep 16 2008 Pradeep Kilambi <pkilambi@redhat.com> - 2.2.6-2
Resolves: #211394 #250303 

* Fri Jun 20 2008 Devan Goodwin <dgoodwin@redhat.com> - 2.2.5-5
- Updating for Fedora 9.

* Thu Oct 05 2006 James Bowes <jbowes@redhat.com> - 2.2.5-1
- Increase to version 2.2.5
- Fix for #177062, #211219

* Thu Oct 05 2006 James Bowes <jbowes@redhat.com> - 2.2.4-1
- Increase to version 2.2.4
- Fix for #211862

* Thu Oct 05 2006 James Bowes <jbowes@redhat.com> - 2.2.3-1
- Increase to version 2.2.3

* Wed Sep 19 2006 James Bowes <jbowes@redhat.com> - 2.2.2-1
- New version.

* Wed Sep 13 2006 James Bowes <jbowes@redhat.com> - 2.2.1-1
- Fix error in UserDictCase.

* Wed Sep 13 2006 James Bowes <jbowes@redhat.com> - 2.2.0-1
- Remove _httplib and _internal_xmlrpclib.
- Stop ghosting pyo files.

* Wed Jul 19 2006 James Bowes <jbowes@redhat.com> - 2.1-2
- Explicitly list the installed files.

* Tue May 02 2006 Bret McMillan <bretm@redhat.com> 2.1-1
- Improved HTTP redirect support

* Wed Nov 30 2005 Mihai Ibanescu <misa@redhat.com> 2.0-1
- Fixed #165481 (setting socket timeouts causes uncaught SSL exceptions)
- Fixed #143833 (memory leak in SSL, caused by the cert verification callback)
- Finally incorporated patch from bug #135660 (basic HTTP authentication)

* Fri Jul  1 2005 Joel Martin <jmartin@redhat.com> 1.8-7
- Allow spec file to be used without Makefile (for Solaris builds)

* Mon Jul 19 2004 Mihai Ibanescu <misa@redhat.com> 1.8-6
- Fixed #128008 (internal _httplib, used with python 1.5.2, missed a
  HTTPResponse._read_chunked)
- Fixed a typo

* Sat Jul 10 2004 Mihai Ibanescu <misa@redhat.com> 1.8-4
- The previous fix in SSL.read uncovered a nastier bug in httplib:
  http://python.org/sf/988120
  Fixed it in our HTTPResponse subclass

* Sat Jul  3 2004 Mihai Ibanescu <misa@redhat.com> 1.8-3
- Fixed bug in SSL.SSLSocket.read() (blocking when less data is in a pipe that
  has not closed yet).

* Mon Jun 28 2004 Mihai Ibanescu <misa@redhat.com> 1.8-2
- Breaking transports.Transport.request() into smaller pieces
- Fixed a small bug in File.__del__

* Thu May 20 2004 Mihai Ibanescu <misa@redhat.com> 1.7-3
- Fixed lookupEncoding

* Fri Mar  5 2004 Mihai Ibanescu <misa@redhat.com> 1.6-1
- Rolled new version with a bunch of bug fixes

* Tue Feb 10 2004 Mihai Ibanescu <misa@redhat.com> 1.5-1
- Fixed #115318

* Wed Nov  5 2003 Mihai Ibanescu <misa@redhat.com> 1.4-10
- Compiling against python 2.3.2

* Tue Oct  7 2003 Mihai Ibanescu <misa@redhat.com> 1.3-11
- Rebuilding as an older version (for RHEL 2.1)

* Thu Sep  4 2003 Mihai Ibanescu <misa@redhat.com> 1.4-1
- Rolling out 1.4

* Thu Sep  4 2003 Mihai Ibanescu <misa@redhat.com> 1.3-12
- Fixed an error related to the decoding of XMLRPC responses

* Tue Sep  2 2003 Mihai Ibanescu <misa@redhat.com> 1.3-8
- Fixed a leaking file descriptor (bug #103488)

* Fri Aug 22 2003 Mihai Ibanescu <misa@redhat.com> 1.3-7
- Added missing BuildRequires (bug #102808)

* Mon Aug 11 2003 Mihai Ibanescu <misa@redat.com> 1.3-5
- Redirect support added

* Wed Jul 16 2003 Mihai Ibanescu <misa@redhat.com> 1.2-6
- Rebuilt

* Mon Jul 14 2003 Mihai Ibanescu <misa@redhat.com> 1.2-1
- Added download resumption, fixed header logic.

* Tue Mar 18 2003 Mihai Ibanescu <misa@redhat.com> 1.0-4
- Rebuilt for python 1.5.2

* Fri Feb 21 2003 Mihai Ibanescu <misa@redhat.com>
- Fixed bug #84803 (use OP_DONT_INSERT_EMPTY_FRAGMENTS to avoid breaking
  non-standard SSL implementations)

* Wed Feb  5 2003 Mihai Ibanescu <misa@redhat.com>
- Fixed bug #83535 (typo)

* Tue Feb  4 2003 Mihai Ibanescu <misa@redhat.com>
- Version 1.0-2
- Rebuild

* Thu Sep  5 2002 Mihai Ibanescu <misa@redhat.com>
- Use load_verify_locations instead of the SSL store functions, bug with
  multiple certs in the same file

* Thu Aug 29 2002 Mihai Ibanescu <misa@redhat.com>
- Memory explosion should be fixed now.
- File descriptor leak fixed.

* Fri Aug  2 2002 Mihai Ibanscu <misa@redhat.com>
- Removed debugging output (printing the SSL cert)

* Tue Jul 30 2002 Mihai Ibanescu <misa@redhat.com>
- User-Agent, X-Info and X-Client-Version were not present in the HTTP headers 

* Tue Jul 23 2002 Mihai Ibanescu <misa@redhat.com>
- Fixed #69518 (up2date seems to never properly reauthenticate after a auth
   timeout)
- Fixed the typo introduced when fixing the above bug :-)
- Completely deprecating rhnHTTPlib: swallowed reportError

* Mon Jul 22 2002 Mihai Ibanescu <misa@redhat.com>
- Fixed #69311 (leaking file descriptors over SSL connections).

* Fri Jul 19 2002 Mihai Ibanescu <misa@redhat.com>
- Fixed some proxy-related bugs.
- Fixed #68911 (and some other bugs that were related to this one).

* Fri Jun 28 2002 Mihai Ibanescu <misa@redhat.com>
- Added documentation files (but not too much :-)

* Thu Jun 27 2002 Adrian Likins <alikins@redhat.com>
- hack up distutils to build a sane spec file
- make sure the SSL support always gets built 
