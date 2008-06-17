# Macros

%define cvs_package PerlModules/CPAN/TimeDate-1.14

# Package specific stuff
Name:		TimeDate
Version:	1.14
Release:	2
Packager:	Karen Jacqmin-Adams
Summary:	Perl date manipulation
Source:		%{name}-%PACKAGE_VERSION.tar.gz
BuildArch:	noarch
Prereq: 	perl
Group:		unsorted
License:	GPL or Artistic
Vendor:		Red Hat, Inc.
Prefix:		%{_our_prefix}
BuildRoot:	%{_tmppath}/%cvs_package

%description
Perl date manipulation modules

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
