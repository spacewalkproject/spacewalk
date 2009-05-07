%define startup_root   %{_sysconfdir}/rc.d
%define queue_dir      %{_var}/lib/nocpulse/queue
%define notif_qdir     %queue_dir/notif
%define states_qdir    %queue_dir/sc_db
%define trends_qdir    %queue_dir/ts_db
%define commands_qdir  %queue_dir/commands
%define snmp_qdir      %queue_dir/snmp

Name:         MessageQueue
Version:      3.26.3
Release:      1%{?dist}
Summary:      Message buffer/relay system
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:     ProgAGoGo nocpulse-common
Group:        Applications/Communications
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
MessageQueue is a mechanism by which Spacewalk plugins and event handlers
can safely and quickly buffer outbound messages. The system provides
a dequeue daemon that reliably dequeues messages to internal systems.

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse
mkdir -p $RPM_BUILD_ROOT%{_bindir}
mkdir -p $RPM_BUILD_ROOT%notif_qdir
mkdir -p $RPM_BUILD_ROOT%states_qdir
mkdir -p $RPM_BUILD_ROOT%trends_qdir
mkdir -p $RPM_BUILD_ROOT%commands_qdir
mkdir -p $RPM_BUILD_ROOT%snmp_qdir

# Install libraries
install	-m 644 *.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/

# Install binaries
install -m 755 dequeue $RPM_BUILD_ROOT%{_bindir}

# stuff needing special ownership doesn't go in filelist
install -m 755 queuetool $RPM_BUILD_ROOT%{_bindir}

%post
if [ $1 -eq 2 ]; then
  ls /home/nocpulse/var/queue/commands/* 2>/dev/null | xargs -I file mv file %commands_qdir
  ls /home/nocpulse/var/queue/notif/* 2>/dev/null | xargs -I file mv file %notif_qdir
  ls /home/nocpulse/var/queue/sc_db/* 2>/dev/null | xargs -I file mv file %states_qdir
  ls /home/nocpulse/var/queue/snmp/* 2>/dev/null | xargs -I file mv file %snmp_qdir
  ls /home/nocpulse/var/queue/ts_db/* 2>/dev/null | xargs -I file mv file %trends_qdir
fi

%files
%defattr(-,root,root,-)
%attr(755,nocpulse,nocpulse) %dir %queue_dir
%attr(755,nocpulse,nocpulse) %dir %states_qdir
%attr(755,nocpulse,nocpulse) %dir %notif_qdir
%attr(755,nocpulse,nocpulse) %dir %trends_qdir
%attr(755,nocpulse,nocpulse) %dir %commands_qdir
%attr(755,nocpulse,nocpulse) %dir %snmp_qdir
%{_bindir}/queuetool
%{_bindir}/dequeue
%{perl_vendorlib}/NOCpulse/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Mon Apr 20 2009 jesus m. rodriguez <jesusr@redhat.com> 3.26.3-1
- change Source0 to point to fedorahosted.org (msuchy@redhat.com)

* Mon Oct 20 2008 Miroslav Suchý <msuchy@redhat.com> 3.26.2-1
- 467441 - fix namespace

* Mon Sep 29 2008 Miroslav Suchý <msuchy@redhat.com> 3.26.1-1
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Wed Jun  4 2008 Milan Zazrivec <mzazrivec@redhat.com> 3.26.0-6
- fixed file permissions

* Thu May 29 2008 Jan Pazdziora 3.26.0-5
- rebuild in dist.cvs

