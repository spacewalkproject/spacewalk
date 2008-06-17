# Macros


%define cvs_package PerlModules/CPAN/Crypt-GeneratePassword-0.02

# Package specific stuff
Name:		perl-Crypt-GeneratePassword
Version:	0.3.1
Release:	1
Packager:	Nick Hansen <nhansen@redhat.com>
Summary:	Generate secure random pronounceable passwords 
Source:		%name-%PACKAGE_VERSION.tar.gz
BuildArch:	noarch
Prereq: 	perl
Group:		unsorted
License:        GPL or Artistic
Vendor:		Red Hat, Inc.
Prefix:         %{_our_prefix}
BuildRoot:      %{_tmppath}/%name

%description

Crypt::GeneratePassword generates random passwords that are (more or less) pronounceable. Unlike Crypt::RandPasswd, it doesn't use the FIPS-181 NIST standard, which is proven to be insecure. It does use a similar interface, so it should be a drop-in replacement in most cases.  This perl module is free software; it may be redistributed and/or modified under the same terms as Perl itself. 

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

