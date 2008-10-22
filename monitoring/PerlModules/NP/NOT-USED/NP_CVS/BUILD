# Macros

%define cvs_package PerlModules/NP/NP_CVS

# Package specific stuff
Name:         NOCpulse-CVS
Version:      1.2.0
Release:      1
Packager:     Karen Jacqmin-Adams <karen@nocpulse.com>
Summary:      Perl CVS wrapper
Source:	      NOCpulse-CVS-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     cvs
Provides:     perl(NOCpulse::CVS)
Group:        unsorted
Copyright:    NOCpulse (c) 2001
Vendor:       NOCpulse
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package


%description

Provides an API to the cvs command.

%prep
%entirely_abstract_build_step


%build
%makefile_build

%install
rm -rf $RPM_BUILD_ROOT
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%makefile_install
%point_scripts_to_correct_perl
%make_file_list

%files -f %{name}-%{version}-%{release}-filelist
%defattr(-,root,root,-)

%clean
%abstract_clean_script


