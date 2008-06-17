# Macros

#control upversion
%define external_package 1

%define cvs_package    PerlModules/CPAN/Test-Unit-0.24


# Package specific stuff
Name:		Test-Unit
Version:	0.24.0
Release:	1
Packager:	Karen Jacqmin-Adams <kja@redhat.com>
Summary:	a unit testing framework for Perl
Source:		%name-%PACKAGE_VERSION.tar.gz
BuildArch:	noarch
Requires:	perl
Group:		unsorted
License:        GPL or Artistic
Vendor:         Red Hat, Inc.
Prefix:		%{_our_prefix}
BuildRoot:	%{_tmppath}/%cvs_package

%description

Test::Unit::* is a sophisticated unit testing framework for Perl
that is derived from the JUnit testing framework for Java by Kent
Beck and Erich Gamma.


%prep
%entirely_abstract_build_step
 
%build
%makefile_build 
 
%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
%makefile_install
%point_scripts_to_correct_perl
%make_file_list
 
%files -f %{name}-%{version}-%{release}-filelist
 
%clean
%abstract_clean_script
