# Macros

%define cvs_package scdb
%define apache_home /opt/apache
%define bdbdir      /nocpulse/scdb/bdb
%define registry    /etc/rc.d/np.d/apachereg

Name:         scdb
Version:      1.15.3
Release:      1
Packager:     Heather Adkins <hadkins@nocpulse.com>
Summary:      State Change Database
Requires:     bdb_perl
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        unsorted
Copyright:    Red Hat, Inc.  (c) 2001-2003
Vendor:       Red Hat, Inc.
BuildRoot:    %{_tmppath}/%cvs_package
Prereq:       NPusers

%description

State Change Database

%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%find_perl_installsitelib
pkgdir="$RPM_BUILD_ROOT$installsitelib/NOCpulse"


# Make sure the 'bdb' directory exists
install -o apache -g apache -d $RPM_BUILD_ROOT%bdbdir

# Copy the module
mkdir -p $pkgdir
install -o apache -g apache -m 444 SCDB.pm $pkgdir

# Add registry entries
mkdir -p $RPM_BUILD_ROOT%registry
cp Apache.scdb $RPM_BUILD_ROOT%registry

%point_scripts_to_correct_perl
%make_file_list
echo "%dir %bdbdir" >> %{name}-%{version}-%{release}-filelist


%files -f %{name}-%{version}-%{release}-filelist


%clean
%abstract_clean_script
