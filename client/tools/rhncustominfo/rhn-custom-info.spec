Name: rhn-custom-info
Summary: Set and list custom values for RHN-enabled machines
Group: Applications/System
License: GPLv2
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
URL:     https://fedorahosted.org/spacewalk
Version: 5.4.22
Release: 1%{?dist}
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch
BuildRequires: python-devel
Requires: rhnlib

%if 0%{?rhel} >= 5 || 0%{?fedora} >= 1
Requires: yum-rhn-plugin
%else
# rpm do not support elif
%if 0%{?suse_version}
Requires: zypp-plugin-spacewalk
# provide rhn directories for filelist check
BuildRequires: rhn-client-tools
%else
Requires: up2date
%endif
%endif

%description 
Allows for the setting and listing of custom key/value pairs for 
an RHN-enabled system.

%prep
%setup -q

%build
make -f Makefile.rhn-custom-info all

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT
make -f Makefile.rhn-custom-info install PREFIX=$RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{_mandir}/man8/
install -m 644 rhn-custom-info.8 $RPM_BUILD_ROOT%{_mandir}/man8/

%clean
rm -rf $RPM_BUILD_ROOT

%files
%{_bindir}/rhn-custom-info
%dir %{_datadir}/rhn/custominfo
%{_datadir}/rhn/custominfo/rhn-custom-info.py*
%doc LICENSE
%{_mandir}/man8/rhn-custom-info.*

%changelog
* Fri Feb 14 2014 Tomas Lestach <tlestach@redhat.com> 5.4.22-1
- 1063808 - Custom info with empty value added

* Fri Nov 29 2013 Michael Mraka <michael.mraka@redhat.com> 5.4.21-1
- add the option -d to delete custom values

* Thu Oct 10 2013 Michael Mraka <michael.mraka@redhat.com> 5.4.20-1
- cleaning up old svn Ids

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 5.4.19-1
- removed trailing whitespaces

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 5.4.18-1
- updating copyright years

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 5.4.17-1
- more branding cleanup

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 5.4.16-1
- rebranding RHN Satellite to Red Hat Satellite in client stuff

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 5.4.15-1
- branding clean-up of client tools
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.
- %%defattr is not needed since rpm 4.4

* Thu Feb 23 2012 Michael Mraka <michael.mraka@redhat.com> 5.4.14-1
- we are now just GPL

* Fri Jul 22 2011 Jan Pazdziora 5.4.13-1
- We only support version 5 and newer of RHEL, removing conditions for old
  versions.
- We only support version 14 and newer of Fedora, removing conditions for old
  versions.

* Fri Apr 15 2011 Jan Pazdziora 5.4.12-1
- build rhn-custom-info on SUSE (mc@suse.de)

* Fri Apr 08 2011 Miroslav Suchý 5.4.11-1
- update copyright years (msuchy@redhat.com)

* Fri Apr 08 2011 Miroslav Suchý 5.4.10-1
- both string and unicode are instance of basestring
- fix rhn-custom-info (mc@suse.de)

* Tue Apr 05 2011 Miroslav Suchý 5.4.9-1
- simplify read_username()
- 683200 - utilize up2date_client.config

* Wed Mar 30 2011 Miroslav Suchý 5.4.8-1
- no need to support rhel2
- Updating the copyright years to include 2010.

* Wed Dec 08 2010 Michael Mraka <michael.mraka@redhat.com> 5.4.7-1
- import Fault, ResponseError and ProtocolError directly from xmlrpclib

* Thu Nov 25 2010 Miroslav Suchý <msuchy@redhat.com> 5.4.6-1
- fix failing build in F13 (msuchy@redhat.com)

* Fri Nov 19 2010 Miroslav Suchý <msuchy@redhat.com> 5.4.5-1
- 553649 - we need to require X.Y version due to search path

* Thu Nov 18 2010 Miroslav Suchý <msuchy@redhat.com> 5.4.4-1
- 553649 - Requires correct, justified where necessary
- 553649 - fix changelog format

* Mon Oct 04 2010 Michael Mraka <michael.mraka@redhat.com> 5.4.3-1
- replaced local copy of compile.py with standard compileall module

