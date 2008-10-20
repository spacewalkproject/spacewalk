%define config_dir     %{_var}/lib/nocpulse/trapReceiver
Name:         SatConfig-installer
Summary:      Satellite Configuration System - command line installer
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/SatConfig/installer
# make srpm
URL:          https://fedorahosted.org/spacewalk
Source0:      %{name}-%{version}.tar.gz
Version:      3.24.1
Release:      1%{?dist}
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Group:        Applications/System
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:     NPusers

%description
SatConfig-installer is the command line mechanism by which Netsaint
configuration files are installed and used by Netsaint on satellite boxes.
The program must be run on the Spacewalk.  

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{_bindir}
mkdir -p $RPM_BUILD_ROOT%config_dir

install -m 755 scheduleEvents $RPM_BUILD_ROOT%{_bindir}
install -m 755 validateCurrentStateFiles.pl $RPM_BUILD_ROOT%{_bindir}

%files
%defattr(-,root,root,-)
%attr(755,nocpulse,nocpulse) %dir %config_dir
%{_bindir}/scheduleEvents
%{_bindir}/validateCurrentStateFiles.pl

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Mon Oct 20 2008 Miroslav Suchý <msuchy@redhat.com>
- 467441 - fix namespace

* Wed Sep 24 2008 Miroslav Suchý <msuchy@redhat.com> 3.24.1-1
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)
