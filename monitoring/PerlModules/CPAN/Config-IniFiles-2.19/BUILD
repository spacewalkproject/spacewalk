# Macros

%define cvs_package PerlModules/CPAN/Config-IniFiles-2.19

# Package specific stuff
Name:		perl-Config-IniFiles
Version:	2.24.1
Release:	1
Packager:	Nick Hansen <nhansen@redhat.com>
Summary:	Perl INI File reader/writer
Source:		%name-%PACKAGE_VERSION.tar.gz
BuildArch:	noarch
Prereq: 	perl
Group:		Development/Libraries
URL:            http://search.cpan.org/dist/Config-IniFiles/
License:	GPL or Artistic
Vendor:		Red Hat, Inc.
Prefix:		%{_our_prefix}
BuildRoot:	%{_tmppath}/%name

%description

Provides INI-style file reading/writing capabilities to perl scripts

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
