%define ap_home        %{_var}/www
%define cgi_bin        %ap_home/cgi-bin
%define cgi_mod_perl   %ap_home/cgi-mod-perl
%define templatedir    %ap_home/templates
%define bin            %{_bindir}
%define vardir         /var/lib/nocpulse
%define registry       %{_sysconfdir}/rc.d/np.d/apachereg
Name:         SputLite
Source0:      %{name}-%{version}.tar.gz
Version:      0.48.1
Release:      1%{?dist}
Summary:      Command queue processor (Sputnik Lite)
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/SputLite
# make srpm
URL:          https://fedorahosted.org/spacewalk
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Group:        Applications/System
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
Provides command-queue capability.

%package server
Summary:  Command queue processor (Sputnik Lite)
Group:    Applications/System
Requires: nocpulse-common

%description server
Provides command-queue server capability.

%package client
Summary:  Command queue processor (Sputnik Lite)
Requires: perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires: MessageQueue ProgAGoGo
Group:    Applications/System
Requires: nocpulse-common

%description  client
Provides command-queue client capability for Spacewalk.

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse
install -m 644 lib/CommandQueue.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/CommandQueue.pm

# Install server
# CGI bin and mod-perl bin
mkdir -p $RPM_BUILD_ROOT%cgi_bin
mkdir -p $RPM_BUILD_ROOT%cgi_mod_perl
mkdir -p $RPM_BUILD_ROOT%registry
install -m 755 html/cgi-mod-perl/*.cgi $RPM_BUILD_ROOT%cgi_mod_perl
install -m 755 html/cgi-bin/*.cgi $RPM_BUILD_ROOT%cgi_bin
install -m 644 html/cgi-bin/registry.fetch_commands $RPM_BUILD_ROOT%registry/Apache.SputLite-server.fetch_commands

# Server HTML templates
mkdir -p $RPM_BUILD_ROOT%templatedir
install -m 644 html/templates/*.html $RPM_BUILD_ROOT%templatedir

# Install client
# Client perl libraries
mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/CommandQueue
install -m 644 lib/CommandQueue/Command.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/CommandQueue/Command.pm
install -m 644 lib/CommandQueue/Parser.pm  $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/CommandQueue/Parser.pm

# Client NOCpulse bin
mkdir -p $RPM_BUILD_ROOT%bin
install -m 755 bin/execute_commands $RPM_BUILD_ROOT%bin/execute_commands

# Client var files and directories
mkdir -p $RPM_BUILD_ROOT%vardir/commands
mkdir -p $RPM_BUILD_ROOT%vardir/queue/commands

%files server
%defattr(-,root,root,-)
%attr(755, nocpulse, nocpulse) %dir %templatedir
%{perl_vendorlib}/NOCpulse/*
%cgi_bin/*
%cgi_mod_perl/*
%templatedir/*
%registry/*

%files client
%defattr(-,root,root,-)
%attr(755,nocpulse,nocpulse) %dir %{vardir}/commands
%attr(755,nocpulse,nocpulse) %dir %{vardir}/queue/commands
%{_bindir}/*
%dir %{perl_vendorlib}/NOCpulse/CommandQueue
%{perl_vendorlib}/NOCpulse/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Thu Sep 25 2008 Miroslav Suchý <msuchy@redhat.com> 0.48.1-1
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Mon Jun 16 2008 Milan Zazrivec <mzazrivec@redhat.com> 0.48.0-4
- cvs.dist import
