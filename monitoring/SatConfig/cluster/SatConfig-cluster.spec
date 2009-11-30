%define sysv_dir       %{_sysconfdir}/rc.d/np.d
Name:         SatConfig-cluster
Version:      1.54.8
Release:      1%{?dist}
Summary:      Satellite Configuration System - cluster information
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
SatConfig-cluster includes a library file that provides i/o access to
the cluster definition file.

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%sysv_dir
mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse

install -m 644 ApacheServer.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 ConfigObject.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 HostsAccess.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 IpAddr.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 LocalConfig.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 RemoteConfig.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 ModJK2.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 NetworkFilesystem.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 OffnetRoute.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 PhysNode.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 PrivateIpAddr.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 SatCluster.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 TomcatBinding.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 TomcatServer.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 VIP.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 PhysCluster.pm $RPM_BUILD_ROOT%sysv_dir
install -m 555 cconfig $RPM_BUILD_ROOT%sysv_dir
install -m 555 describeClusterIni $RPM_BUILD_ROOT%sysv_dir
install -m 644 SatCluster.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/
 
%files
%defattr(-,root,root,-)
%doc Cluster.ini.example
%sysv_dir/*
%{perl_vendorlib}/NOCpulse/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Mon Nov 30 2009 Miroslav Suchý <msuchy@redhat.com> 1.54.8-1
- name space Validator conflicts with older version of perl-IO-Compress-Base

* Mon Jul 27 2009 John Matthews <jmatthew@redhat.com> 1.54.7-1
- remove warning when run as perl -w (msuchy@redhat.com)

* Thu Jun 25 2009 John Matthews <jmatthew@redhat.com> 1.54.6-1
- 490783 - preventing to read a config file, that must not exist
  (tlestach@redhat.com)

* Thu Apr 23 2009 jesus m. rodriguez <jesusr@redhat.com> 1.54.5-1
- change Source0 to point to fedorahosted.org (msuchy@redhat.com)

* Mon Oct 20 2008 Miroslav Suchý <msuchy@redhat.com> 1.54.4-1
- 467441 - fix namespace

* Wed Sep 24 2008 Miroslav Suchý <msuchy@redhat.com> 1.54.3-1
- spec cleanup for Fedora

* Thu May 29 2008 Jan Pazdziora 1.54.2-5
- rebuild in dist.cvs

