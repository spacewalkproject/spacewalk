Name: spacewalk-certs-tools
Summary: Spacewalk SSL Key/Cert Tool
Group: Applications/Internet
License: GPLv2 and Python
Version: 0.7.1
Release: 1%{?dist}
URL:      https://fedorahosted.org/spacewalk 
Source0:  https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
Requires: openssl rpm-build
BuildRequires: docbook-utils
BuildRequires: python
Obsoletes: rhns-certs < 5.3.0
Obsoletes: rhns-certs-tools < 5.3.0
# can not provides = %{version} since some old packages expect > 3.6.0
Provides:  rhns-certs = 5.3.0
Provides:  rhns-certs-tools = 5.3.0

%description
This package contains tools to generate the SSL certificates required by 
Spacewalk.

%global rhnroot %{_datadir}/rhn

%prep
%setup -q

%build
#nothing to do here

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/%{rhnroot}/certs
make -f Makefile.certs install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    MANDIR=%{_mandir}
chmod 755 $RPM_BUILD_ROOT/%{rhnroot}/certs/{rhn_ssl_tool.py,client_config_update.py,rhn_rpm.py,rhn_bootstrap.py}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{rhnroot}/certs/*.py*
%attr(755,root,root) %{rhnroot}/certs/sign.sh
%attr(755,root,root) %{rhnroot}/certs/gen-rpm.sh
%attr(755,root,root) %{_bindir}/rhn-sudo-ssl-tool
%attr(755,root,root) %{_bindir}/rhn-ssl-tool
%attr(755,root,root) %{_bindir}/rhn-bootstrap
%doc %{_mandir}/man1/rhn-*.1*
%doc LICENSE PYTHON-LICENSES.txt
%{_var}/www/html/pub/bootstrap/client_config_update.py*

%changelog
* Tue Nov 17 2009 Miroslav Suchy <msuchy@redhat.com> 0.7.1-1
- fix rpmlint warnings

* Wed May 06 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.3-1
- adding optional way to specify profile name. (satoru.satoh@gmail.com)
- 497110 - Don't assume jabberd is installed in rhn-ssl-tool (dgoodwin@redhat.com)

* Thu Apr 23 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.2-1
- 465622 - setup config file deployment when it's due (mzazrivec@redhat.com)

* Wed Apr 22 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.1-1
- bump Versions to 0.6.0 (jesusr@redhat.com)
- update copyright and licenses (jesusr@redhat.com)

* Fri Mar 27 2009 Devan Goodwin <dgoodwin@redhat.com> 0.5.5-1
- Update for new jabberd cert location, and possiblity of jabber user instead of jabberd.

* Wed Mar 25 2009 Jan Pazdziora 0.5.4-1
- 491687 - wrapper around sudo /usr/bin/rhn-ssl-tool, to change SELinux domain

* Fri Mar 13 2009 Miroslav Suchy <msuchy@redhat.com> 0.5.3-1
- put Provides to satisfy older Proxies

* Thu Feb 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.2-1
- replace "!#/usr/bin/env python" with "!#/usr/bin/python"

* Mon Jan 19 2009 Jan Pazdziora 0.5.1-1
- rebuilt for 0.5, after repository reorg

* Tue Dec  9 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.2-1
- fixed Obsoletes: rhns-* < 5.3.0

* Tue Sep 23 2008 Milan Zazrivec 0.3.1-1
- fixed package obsoletes

* Tue Sep  2 2008 Milan Zazrivec 0.2.2-1
- Bumped version for tag-release

* Tue Aug 18 2008 Mike McCune <mmccune@redhat.com> 0.2-1
- get rid of python-optik

* Tue Aug  5 2008 Miroslav Suchy <msuchy@redhat.com> 0.2-0
- Rename to spacewalk-certs-tools
- clean up spec

* Mon Aug  4 2008 Jan Pazdziora 0.1-1
- removed version and sources files

* Wed May 28 2008 Jan Pazdziora 5.2.0-2
- fix for padding L on RHEL 5

* Wed May 21 2008 Jan Pazdziora - 5.2.0-1
- rebuild in dist-cvs.

* Wed Mar 07 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.0.0-1
- adding dist tag

* Fri Dec 01 2006 Ryan Newberry <rnewberr@redhat.com> 
- adding docbook2man to build requires

* Mon Dec 20 2004 Todd Warner <taw@redhat.com> 3.6.0
- requirement added: python-optik (bug: 143413)

* Tue Jul 06 2004 Todd Warner <taw@redhat.com>
- rhn-bootstrap and associated files added.

* Tue Apr 20 2004 Todd Warner <taw@redhat.com>
- added rhn-ssl-tool and associated modules
- using a Makefile which builds a tarball now.
- added man page
- added __init__.py*
- GPLed this code. No reason to do otherwise.

* Tue Aug 20 2002 Cristian Gafton <gafton@redhat.com>
- update for the new build system

* Tue May 21 2002 Cristian Gafton <gafton@redhat.com>
- no more RHNS

* Tue May 14 2002 Todd Warner <taw@redhat.com>
- Initial.
