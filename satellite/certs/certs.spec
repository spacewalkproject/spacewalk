Name: rhns-certs-tools
Summary: Red Hat Network SSL Key/Cert Tool
Group: RHN/Utilities
License: LGPL
Source2: sources
%define main_source %(awk '{ print $2 ; exit}' %{SOURCE2})
Source0: %{main_source}
Source1: version
Version: %(awk '{ print $1 }' %{SOURCE1})
Release: %(awk '{ print $2 }' %{SOURCE1})%{?dist}
BuildRoot: /var/tmp/%{name}-%{version}-root
BuildArch: noarch
Requires: openssl rpm-build python-optik
BuildRequires: docbook-utils
Obsoletes: rhns-certs

%description
This package contains tools to generate the SSL certificates required by 
Red Hat Network.

%define rhnroot /usr/share/rhn

%prep
%define build_sub_dir %(echo %{main_source} | sed 's/\.tar\.gz$//')
%setup -n %build_sub_dir

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/%{rhnroot}/certs
make -f Makefile.certs install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    MANDIR=%{_mandir}
#install -m 755 %{SOURCE2} %{SOURCE3} $RPM_BUILD_ROOT/%{rhnroot}/certs

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%attr(755,root,root) %{rhnroot}/certs/*.py*
%attr(755,root,root) %{rhnroot}/certs/sign.sh
%attr(755,root,root) %{rhnroot}/certs/gen-rpm.sh
%attr(755,root,root) /usr/bin/rhn-ssl-tool
%attr(755,root,root) /usr/bin/rhn-bootstrap
%doc %{_mandir}/man1/rhn-*.1*
/var/www/html/pub/bootstrap/client_config_update.py*

# $Id: certs.spec,v 1.25 2008-02-21 15:22:20 bperkins Exp $
%changelog
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
