%define cgi_bin        %{_datadir}/nocpulse/cgi-bin
%define cgi_mod_perl   %{_datadir}/nocpulse/cgi-mod-perl
%define templatedir    %{_datadir}/nocpulse/templates
%define bin            %{_bindir}
%define vardir         /var/lib/nocpulse
Name:         SputLite
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      2.3.0
Release:      1%{?dist}
Summary:      Command queue processor (Sputnik Lite)
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
install -m 755 html/cgi-mod-perl/*.cgi $RPM_BUILD_ROOT%cgi_mod_perl
install -m 755 html/cgi-bin/*.cgi $RPM_BUILD_ROOT%cgi_bin

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

%post client
if [ $1 -eq 2 ]; then
  ls /home/nocpulse/var/commands/heartbeat 2>/dev/null | xargs -I file mv file %{vardir}/commands
  ls /home/nocpulse/var/commands/last_completed 2>/dev/null | xargs -I file mv file %{vardir}/commands
  ls /home/nocpulse/var/commands/last_started 2>/dev/null | xargs -I file mv file %{vardir}/commands
fi

%files server
%attr(755, nocpulse, nocpulse) %dir %templatedir
%cgi_bin/*
%cgi_mod_perl/*
%templatedir/*

%files client
%attr(755,nocpulse,nocpulse) %dir %{vardir}/commands
%attr(755,nocpulse,nocpulse) %dir %{vardir}/queue/commands
%{_bindir}/*
%{perl_vendorlib}/NOCpulse/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Tue Mar 26 2013 Jan Pazdziora 1.10.1-1
- Use to_timestamp instead of to_date which should bring the second precision
  to PostgreSQL.

* Fri Feb 08 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.1-1
- removed lost files we are not packing for ages
- %%defattr is not needed since rpm 4.4

* Thu Feb 02 2012 Jan Pazdziora 1.7.2-1
- import used module (msuchy@redhat.com)

* Wed Feb 01 2012 Jan Pazdziora 1.7.1-1
- Make the Completed value not truncated to day which makes the scout config
  push actually green.

* Fri Dec 09 2011 Jan Pazdziora 1.6.5-1
- replace synonyms with real table names (mc@suse.de)

* Tue Nov 29 2011 Jan Pazdziora 1.6.4-1
- Fixing typo (under / undef).

* Tue Nov 29 2011 Jan Pazdziora 1.6.3-1
- Correct fix for the vn_rhn_command_queue_execs_stderr constraint issue.
- Revert "postgres seems to reject empty text for stdout and stderr column"

* Mon Nov 28 2011 Miroslav Suchý 1.6.2-1
- replace sysdate with current_timestamp (mc@suse.de)
- postgres seems to reject empty text for stdout and stderr column (mc@suse.de)

* Tue Aug 30 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.1-1
- remove perl module files from the -server package

* Fri Mar 18 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.2-1
- fixed db connection in fetch_nocpulseini*.cgi (PG)

* Fri Feb 18 2011 Jan Pazdziora 1.4.1-1
- Localize the filehandle globs; also use three-parameter opens.

* Sat Nov 20 2010 Miroslav Suchý <msuchy@redhat.com> 0.48.14-1
- bumping version as tag SputLite-0.48.13-1 already exists (msuchy@redhat.com)
- 474591 - move web data to /usr/share/nocpulse (msuchy@redhat.com)

