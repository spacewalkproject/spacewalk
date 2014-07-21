%define shareroot /usr/share
%define rhnconf /etc/sysconfig/rhn


Summary: Spacewalk Client Utilities and Libraries
Name: rhnclient
Source0: %{name}-%{version}.tar.gz
Version: 5.5.9
Release: 1
License: GPLv2
Group: Development/Libraries
BuildRoot: %{_tmppath}/%{name}-buildroot
Prefix: %{_prefix}
#BuildArch: noarch
Requires: pyOpenSSL python
Requires: rhnlib >= 2.5.35
BuildRequires: python-devel binutils-devel
Url: http://rhn.redhat.com

%description
Spacewalk Client Utilities
Includes: rhn_check, action handler, and modules to allow
client packages to communicate with RHN.

%prep
%setup

%build
%{__python} setup.py build
make

%install
%{__python} setup.py install --root=$RPM_BUILD_ROOT
%{__install} -d -m 0755 $RPM_BUILD_ROOT/usr/sbin/
%{__cp} -p rhn_check.py $RPM_BUILD_ROOT/usr/sbin/rhn_check
%{__cp} -p rhnsd $RPM_BUILD_ROOT/usr/sbin/rhnsd
%{__cp} -p rhnreg_ks.py $RPM_BUILD_ROOT/usr/sbin/rhnreg_ks
%{__install} -d -m 0755 $RPM_BUILD_ROOT/%{shareroot}/rhn/
%{__cp} -p RHNS-CA-CERT $RPM_BUILD_ROOT/%{shareroot}/rhn/RHNS-CA-CERT
%{__install} -d -m 0755 $RPM_BUILD_ROOT/%{rhnconf}/
%{__cp} -p up2date.config $RPM_BUILD_ROOT/%{rhnconf}/up2date
%{__cp} -p rhnsd.sysconfig $RPM_BUILD_ROOT/%{rhnconf}/rhnsd
%{__install} -d -m 0755 $RPM_BUILD_ROOT/etc/init.d/
%{__cp} -p rhnsd.init $RPM_BUILD_ROOT/etc/init.d/rhnsd
mkdir -p $RPM_BUILD_ROOT/var/log/
touch $RPM_BUILD_ROOT/var/log/up2date
mkdir -p $RPM_BUILD_ROOT/var/run/
touch $RPM_BUILD_ROOT/var/run/.keep


%clean
rm -rf $RPM_BUILD_ROOT

%files
%{shareroot}/rhn/*
/usr/sbin/*
%{python_sitelib}/rhn/*
%{python_sitelib}/rhnclient*
%{rhnconf}/*
/var/log/up2date
/var/run/.keep
%defattr(0744,root,sys)
/etc/init.d/rhnsd
#%doc ChangeLog COPYING README TODO

%changelog
* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.5.9-1
- fix copyright years

* Mon Oct 14 2013 Michael Mraka <michael.mraka@redhat.com> 5.5.8-1
- cleaning up old svn Ids

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 5.5.7-1
- removed trailing whitespaces

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 5.5.6-1
- Grammar error occurred

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 5.5.5-1
- updating copyright years
- Get the CPU frequency for solaris clients correctly (even for 7013-53H)

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 5.5.4-1
- removed old CVS/SVN version ids
- more branding cleanup

* Mon Jun 17 2013 Tomas Kasparek <tkasparek@redhat.com> 5.5.3-1
- rebranding few more strings in client stuff

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 5.5.2-1
- branding clean-up of solaris client stuff

* Mon Nov 26 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.1-1
- let's reset version above satellite version

* Tue Oct 30 2012 Jan Pazdziora 0.19-1
- Update the copyright year.

* Tue Jul 31 2012 Michael Mraka <michael.mraka@redhat.com> 0.18-1
- removed unused argument oemInfo

* Tue Jul 10 2012 Michael Mraka <michael.mraka@redhat.com> 0.17-1
- Add missing space to log message

* Mon Jul 09 2012 Michael Mraka <michael.mraka@redhat.com> 0.16-1
- Fix typo in 'Fatal error in Python code occurred'

* Thu Jun 21 2012 Jan Pazdziora 0.15-1
- allow linking against openssl
- %%defattr is not needed since rpm 4.4

* Tue Nov 01 2011 Michael Mraka <michael.mraka@redhat.com> 0.14-1
- 744287 - fixed path so it isn't substituted in rpm2pkg

* Wed Mar 30 2011 Miroslav Suchý 0.13-1
- 683200 - instead of encodings.idna use wrapper from rhn.connections, which
  workaround corner cases
- 683200 - client/solaris - when making profile name from hostname, convert it
  from Pune encoding

* Tue Mar 08 2011 Miroslav Suchý <msuchy@redhat.com> 0.12-1
- add binutils-devel as buildrequires

* Tue Mar 08 2011 Miroslav Suchý <msuchy@redhat.com> 0.11-1
- removing files from rhn subdir - they are not used
- do not record installed files as it does not include .pyo files

* Wed Dec 08 2010 Michael Mraka <michael.mraka@redhat.com> 0.10-1
- import Fault, ResponseError and ProtocolError directly from xmlrpclib

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 0.9-1
- updated copyrights

* Fri Jan 29 2010 Miroslav Suchý <msuchy@redhat.com> 0.8-1
- replaced popen2 with subprocess in client (michael.mraka@redhat.com)

* Wed Nov 25 2009 Miroslav Suchý <msuchy@redhat.com> 0.7-1
- Reverting the client/solaris/rhnclient/rhnclient.spec part of the patch. (jpazdziora@redhat.com)
- Log files should be ghosted rather than belonging to a package (m.d.chappell@bath.ac.uk)

* Thu Apr 23 2009 jesus m. rodriguez <jesusr@redhat.com> 0.4-1
- update copyright and licenses (jesusr@redhat.com)

* Mon Mar 23 2009 Devan Goodwin <dgoodwin@redhat.com> 0.3-1
- Rebuild from spacewalk.git.

* Fri Jul 01 2005 Joel Martin <jmartin@redhat.com> 4.0.0-8
- Allow building on Solaris systems without getopt.h. Use local
  getopt.h on Solaris. 

* Thu Jun 30 2005 Joel Martin <jmartin@redhat.com> 4.0.0-7
- Handle i86pc arch

* Thu Jun 23 2005 Joel Martin <jmartin@redhat.com> 4.0.0-6
- Send capabilities to server on all rpc calls

* Thu Jun 02 2005 Joel Martin <jmartin@redhat.com>
- Add rhnsd daemon, init script and configs
- Changed spec to be able to build on Solaris
- /var/run directory

* Fri May 27 2005 Joel Martin <jmartin@redhat.com>
- Initial build version 4.0.0-1

