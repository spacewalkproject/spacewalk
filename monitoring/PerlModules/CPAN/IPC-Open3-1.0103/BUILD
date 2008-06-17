# Macros

#control upversion
%define external_package 1

%define cvs_package     PerlModules/CPAN/IPC-Open3-1.0103

# Package specific stuff
Name:         perl-IPC-Open3
Version:      1.104.0
Release:      1.1
Packager:     Dave Faraldo <dfaraldo@nocpulse.com>
Summary:      Perl IPC::Open3 library
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Requires:     perl
Provides:     IPC::Open3
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

Provides an OO interface for two-way IPC communication.

%prep
%entirely_abstract_build_step

%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%find_perl_installsitelib
mkdir -p $RPM_BUILD_ROOT$installsitelib/IPC
mkdir -p $RPM_BUILD_ROOT$installsitelib/man/man3

install -o root -g root -m 755 Open3.pm $RPM_BUILD_ROOT$installsitelib/IPC
install -o root -g root -m 755 IPC::Open3.3.gz $RPM_BUILD_ROOT$installsitelib/man/man3
%point_scripts_to_correct_perl
%make_file_list

%files -f %{name}-%{version}-%{release}-filelist

 
%clean
%abstract_clean_script
