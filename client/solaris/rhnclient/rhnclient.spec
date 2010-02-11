%define shareroot /usr/share
%define rhnconf /etc/sysconfig/rhn


Summary: Red Hat Network Client Utilities and Libraries
Name: rhnclient
Source0: %{name}-%{version}.tar.gz
Version: 0.8
Release: 1
License: GPLv2
Group: Development/Libraries
BuildRoot: %{_tmppath}/%{name}-buildroot
Prefix: %{_prefix}
#BuildArch: noarch
Requires: pyOpenSSL python
BuildRequires: python-devel
Url: http://rhn.redhat.com

%description
Red Hat Network Client Utilities
Includes: rhn_check, action handler, and modules to allow
client packages to communicate with RHN.

%prep
%setup

%build
%{__python} setup.py build
make

%install
%{__python} setup.py install --root=$RPM_BUILD_ROOT --record=INSTALLED_FILES
sed -e 's|/[^/]*$||' INSTALLED_FILES | grep "site-packages/" | \
    sort | uniq | awk '{ print "%attr(755,root,root) %dir " $1}' > INSTALLED_DIRS
cat INSTALLED_FILES INSTALLED_DIRS > INSTALLED_OBJECTS
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

%files -f INSTALLED_OBJECTS
%defattr(-,root,root)
%{shareroot}/rhn/*
/usr/sbin/*
%{rhnconf}/*
/var/log/up2date
/var/run/.keep
%defattr(0744,root,sys)
/etc/init.d/rhnsd
#%doc ChangeLog COPYING README TODO

%changelog
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

