# Macros

%define cvs_package PerlModules/CPAN/Class-MethodMaker-1.05

# Package specific stuff
Name:		perl-Class-MethodMaker
Version:	1.7.1
Release:	1
Packager:	Nick Hansen <nhansen@redhat.com>
Summary:	Accessor method generation
Source:		%name-%PACKAGE_VERSION.tar.gz
BuildArch:	noarch
Requires:	perl
Group:		Development/Libraries
URL:            http://search.cpan.org/dist/Class-MethodMaker/
License:        GPL or Artistic
Vendor:		Red Hat, Inc.
Prefix:		%{_our_prefix}
BuildRoot:	%{_tmppath}/%name

%description

Provides a module for creating generic get/set methods.

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
