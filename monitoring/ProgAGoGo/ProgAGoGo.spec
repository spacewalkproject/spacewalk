Name:         ProgAGoGo
Version:      1.11.1
Release:      1%{?dist}
Summary:      Program exec''er/respawner
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/ProgAGoGo
# make srpm
URL:          https://fedorahosted.org/spacewalk
Source0:      %{name}-%{version}.tar.gz
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
* Mon Oct 20 2008 Miroslav Suchý <msuchy@redhat.com>
- 467441 - fix namespace

* Thu Sep 25 2008 Miroslav Suchý <msuchy@redhat.com> 1.11.1-1
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Thu May 29 2008 Jan Pazdziora 1.11.0-5
- rebuild in dist.cvs

