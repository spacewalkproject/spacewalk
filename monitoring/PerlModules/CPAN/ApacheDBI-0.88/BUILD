# Macros

%define cvs_package    PerlModules/CPAN/ApacheDBI-0.88

# Package specific stuff
Name:         perl-ApacheDBI
Version:      0.89.1
Release:      1
Packager:     Nick Hansen <nhansen@redhat.com>
Summary:      Perl DBI for Apache
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl 
Provides:     %{name} Apache::DBI
Group:        Development/Libraries
URL:          http://search.cpan.org/dist/ApacheDBI/
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%name


%description

Provides DBI capability for mod_perl-enabled Apache webservers.

%prep
%entirely_abstract_build_step

%build
%makefile_build

%install
rm -rf $RPM_BUILD_ROOT
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%cpan_doc_install
%makefile_install
%point_scripts_to_correct_perl
%make_file_list


%files -f %{name}-%{version}-%{release}-filelist


%clean
%abstract_clean_script

