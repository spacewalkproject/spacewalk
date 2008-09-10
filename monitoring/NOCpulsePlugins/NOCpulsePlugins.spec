Name:         NOCpulsePlugins
Version: 	  2.208.0
Release:      30%{?dist}
Summary:      NOCpulse authored Plugins
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/NOCpulsePlugins
# make srpm
URL:          https://fedorahosted.org/spacewalk
Source0:      %{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:     nocpulse-common
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package contain NOCpulse authored plugins for probes.

%prep
%setup -q

%build
# Nothing to build

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/nocpulse
mkdir -p $RPM_BUILD_ROOT%{_bindir}
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/nocpulse/libexec
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/nocpulse/ProbeState

install *.ini   $RPM_BUILD_ROOT%{_sysconfdir}/nocpulse
install *.pm    $RPM_BUILD_ROOT%{_var}/lib/nocpulse/libexec
install status  $RPM_BUILD_ROOT%{_var}/lib/nocpulse/libexec
install catalog $RPM_BUILD_ROOT%{_var}/lib/nocpulse/libexec
install setTrending $RPM_BUILD_ROOT%{_bindir}
ln -s %{_var}/lib/nocpulse/libexec/catalog $RPM_BUILD_ROOT%{_bindir}/rhn-catalog

for pkg in Apache Apache/test General LogAgent MySQL NetworkService Oracle Oracle/test Satellite Unix Unix/test Weblogic 
do
  fulldir=$RPM_BUILD_ROOT%{_var}/lib/nocpulse/libexec/$pkg
  mkdir -p  $fulldir
  install $pkg/*.pm $fulldir
done

%files
%defattr(-,root,root,-)
%dir %{_sysconfdir}/nocpulse
%dir %{_var}/lib/nocpulse
%attr(777,nocpulse,nocpulse) %dir %{_var}/lib/nocpulse/ProbeState
%dir %{_var}/lib/nocpulse/libexec
%{_var}/lib/nocpulse/*
%{_sysconfdir}/nocpulse/*
%{_bindir}/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Wed Sep 10 2008 Miroslav Suchý <msuchy@redhat.com>
- spec cleanup for Fedora
- remove /opt directory

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Fri Jun  6 2008 Milan Zazrivec <mzazrivec@redhat.com> 2.208.0-30
- cvs.dist import
