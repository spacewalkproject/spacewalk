Name:         ProgAGoGo
Version:      1.11.6
Release:      1%{?dist}
Summary:      Program exec''er/respawner
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Group:        Applications/System
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
ProgAGoGo is a daemon monitor.  It spawns a daemon and makes sure it
stays alive, respawning it with notification if it dies.

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{_bindir}
install -m 755 gogo.pl $RPM_BUILD_ROOT/%{_bindir}

%files
%defattr(-,root,root,-)
%{_bindir}/gogo.pl

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Tue Aug 04 2009 Jan Pazdziora 1.11.6-1
- 513368 - call setpgrp to prevent kill 0 to propagate to jabberd and tomcat

* Tue Feb 10 2009 Jan Pazdziora 1.11.5-1
- gogo.pl: add a missing semicolon

* Tue Feb  3 2009 Miroslav Suchy <msuchy@redhat.com> 1.11.4-1
- 455934 - write timestamps to logs by default

* Tue Nov 11 2008 Miroslav Suchý <msuchy@redhat.com> 1.11.3-1
- call correct module

* Mon Oct 20 2008 Miroslav Suchý <msuchy@redhat.com> 1.11.2-1
- 467441 - fix namespace

* Thu Sep 25 2008 Miroslav Suchý <msuchy@redhat.com> 1.11.1-1
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Thu May 29 2008 Jan Pazdziora 1.11.0-5
- rebuild in dist.cvs

