Name: spacewalk-ssl-cert-check
Summary: Check ssl certs for impending expiration
Group:   Applications/System
License: GPLv2
URL:     https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Epoch:	 1
Version: 2.0
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
Requires:  /etc/cron.daily/certwatch
Obsoletes: rhn-ssl-cert-check < %{epoch}:%{version}
Provides:  rhn-ssl-cert-check = %{epoch}:%{version}

%description 
Runs a check once a day to see if the ssl certificates installed on this
server are expected to expire in the next 30 days, and if so, email the 
administrator.

%prep
%setup -q

%build
# Nothing to do

%install
rm -rf $RPM_BUILD_ROOT

install -d $RPM_BUILD_ROOT/etc/cron.daily

install -m755 rhn-ssl-cert-check $RPM_BUILD_ROOT/%{_sysconfdir}/cron.daily/rhn-ssl-cert-check

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-) 
%attr(0755,root,root) %{_sysconfdir}/cron.daily/rhn-ssl-cert-check
%doc LICENSE

%changelog
* Tue May 04 2010 Jan Pazdziora 2.0-1
- 461270 - replace our own ssl-cert-check with stock certwatch.

* Thu Sep 24 2009 Miroslav Suchý <msuchy@redhat.com> 1.9-1
- 524053 - Force to "upgrade" to older version of rhn-ssl-cert-check

* Fri Aug 28 2009 Michael Mraka <michael.mraka@redhat.com> 1.8-1
- grep | awk is rarely needed
- use spacewalk-cfg-get instead of awk

* Wed Mar 18 2009 Miroslav Suchy <msuchy@redhat.com> 1.7-1
- 490695 - versioned provides

* Thu Feb 05 2009 jesus m. rodriguez <jesusr@redhat.com> 1.5-1
- 483867 - names of packages that help us distinguish Proxy from Spacewalk (Satellite) have changed.
- 483867 - Spacewalk and Satellite no longer use /etc/rhn/satellite-httpd/conf/ssl.conf.

* Wed Jan 21 2009 Milan Zazrivec <mzazrivec@redhat.com> 1.4-10.12
- 480967 - obsolete rhn-ssl-cert-check

* Tue Sep  2 2008 Milan Zazrivec 1.4-10.10
- Renamed rhn-ssl-cert-check to spacewalk-ssl-cert-check

* Mon Aug 11 2008 Mike McCune 1.4-10.9
- building to clean up src vs binary rpm mismatch in public repo

* Mon Aug  4 2008 Jan Pazdziora 1.4-10.8
- remove the version file

* Thu Jun 2 2005 Adrian Likins <alikins@redhat.com>
- fix some bugs in rhn-ssl-cert-check

* Mon May 9 2005 Adrian Likins <alikins@redhat.com> 
- initial build
