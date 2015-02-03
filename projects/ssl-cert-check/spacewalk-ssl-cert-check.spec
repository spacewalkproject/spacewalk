Name: spacewalk-ssl-cert-check
Summary: Check ssl certs for impending expiration
Group:   Applications/System
License: GPLv2
URL:     https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Epoch:	 1
Version: 2.4
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
%attr(0755,root,root) %{_sysconfdir}/cron.daily/rhn-ssl-cert-check
%doc LICENSE

%changelog
* Mon Jan 12 2015 Matej Kollar <mkollar@redhat.com> 2.4-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Tue Oct 30 2012 Jan Pazdziora 2.3-1
- Update the copyright year.

* Thu Jun 07 2012 Jan Pazdziora 2.2-1
- 788972 - for multiple recipient email addresses, join them with comma.
- %%defattr is not needed since rpm 4.4

* Tue Nov 02 2010 Jan Pazdziora 2.1-1
- Update copyright years in the rest of the repo.

* Tue May 04 2010 Jan Pazdziora 2.0-1
- 461270 - replace our own ssl-cert-check with stock certwatch.

