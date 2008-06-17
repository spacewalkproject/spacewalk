# Macros

%define cvs_package NOCpulsePlugins

%define install_prefix   /home/nocpulse
%define cfg_dir          %install_prefix/etc
%define bin_dir          %install_prefix/bin
%define data_dir         %install_prefix/var
%define probe_state_dir  %data_dir/ProbeState
%define exe_dir          %install_prefix/libexec
%define buildroot        /tmp/%cvs_package

# Package specific stuff
Name:         NOCpulsePlugins
Version:      2.207.0
Release:      1
Packager:     Nick Hansen <nhansen@redhat.com>
Summary:      NOCpulse authored Plugins
Source:	      NOCpulsePlugins-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl NPusers perl-NOCpulse-Probe
Group:        unsorted
Copyright:    Red Hat, Inc (c) 2000-2004
Vendor:       Red Hat, Inc.
Prefix:	      %install_prefix
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers


%description

NOCpulse-authored plugins

%prep
%entirely_abstract_build_step

%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p $RPM_BUILD_ROOT%install_prefix
mkdir -p $RPM_BUILD_ROOT%cfg_dir
mkdir -p $RPM_BUILD_ROOT%exe_dir
mkdir -p $RPM_BUILD_ROOT%bin_dir
mkdir -p $RPM_BUILD_ROOT%probe_state_dir

install -o nocpulse -g nocpulse -m 644 *.ini        $RPM_BUILD_ROOT%cfg_dir
install -o nocpulse -g nocpulse -m 644 *.pm         $RPM_BUILD_ROOT%exe_dir
install -o nocpulse -g nocpulse -m 755 status       $RPM_BUILD_ROOT%exe_dir
install -o nocpulse -g nocpulse -m 755 catalog      $RPM_BUILD_ROOT%exe_dir
install -o nocpulse -g nocpulse -m 755 setTrending  $RPM_BUILD_ROOT%bin_dir

for pkg in Apache Apache/test General LogAgent MySQL NetworkService Oracle Oracle/test Satellite Unix Unix/test Weblogic 
do
  fulldir=$RPM_BUILD_ROOT%exe_dir/$pkg
  install -o nocpulse -g nocpulse -m 755 -d $fulldir
  install -o nocpulse -g nocpulse -m 644 $pkg/*.pm $fulldir
done

%point_scripts_to_correct_perl

%files
%attr(777,nocpulse,nocpulse) %dir %probe_state_dir
%cfg_dir/*
%exe_dir/*
%bin_dir/*



%clean
%abstract_clean_script
