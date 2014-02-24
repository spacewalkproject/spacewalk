%define sysv_dir       %{_sysconfdir}/rc.d/np.d
Name:         SatConfig-cluster
Version:      2.2.0
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
%doc Cluster.ini.example
%sysv_dir/*
%{perl_vendorlib}/NOCpulse/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Thu Aug 11 2011 Jan Pazdziora 1.54.10-1
- Report the error to STDERR, not STDOUT.

* Fri Feb 18 2011 Jan Pazdziora 1.54.9-1
- Localize the filehandle globs; also use three-parameter opens.

