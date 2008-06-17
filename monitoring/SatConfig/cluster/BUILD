# Macros

%define cvs_package    SatConfig/cluster

%define etc            /etc
%define sysv_dir       %etc/rc.d/np.d

# Package specific stuff
Name:         SatConfig-cluster
Version:      1.54.2
Release:      1
Packager:     Karen Jacqmin-Adams <karen@nocpulse.com>
Summary:      Satellite Configuration System - cluster information
Source:	      SatConfig-cluster-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        unsorted
Copyright:    Red Hat, Inc. (c) 2000-2003
Vendor:       Red Hat, Inc.
Prefix:	      %install_prefix
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       perl(NOCpulse::Object) perl(Config::IniFiles) perl
Provides:     perl(NOCpulse::SatCluster)

%description

SatConfig-cluster includes a library file that provides i/o access to
the cluster definition file.

%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%find_perl_installsitelib

mkdir -p $RPM_BUILD_ROOT%sysv_dir
mkdir -p $RPM_BUILD_ROOT%etc
mkdir -p $RPM_BUILD_ROOT$installsitelib/NOCpulse


install -o root -g root -m 644 ApacheServer.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 ConfigObject.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 HostsAccess.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 IpAddr.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 LocalConfig.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 RemoteConfig.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 ModJK2.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 NetworkFilesystem.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 OffnetRoute.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 PhysNode.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 PrivateIpAddr.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 SatCluster.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 TomcatBinding.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 TomcatServer.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 VIP.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 PhysCluster.pm $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 Cluster.ini.example $RPM_BUILD_ROOT%etc
install -o root -g root -m 555 cconfig $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 555 describeClusterIni $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 644 SatCluster.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse/.
 
%point_scripts_to_correct_perl
%make_file_list

%files -f %{name}-%{version}-%{release}-filelist
%defattr(-,root,root,-)


%clean
%abstract_clean_script
