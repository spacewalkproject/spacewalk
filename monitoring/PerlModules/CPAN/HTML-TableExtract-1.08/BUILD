# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/HTML-TableExtract-1.08

# Package specific stuff
Name:		perl-HTML-TableExtract
Version:	1.8.0
Release:	4.2
Packager:	Nick Hansen <nhansen@redhat.com>
Summary:	HTML table extractor
Source:		%name-%PACKAGE_VERSION.tar.gz
BuildArch:	noarch
Prereq: 	perl
Group:		unsorted
URL:            http://www.mojotoad.com/sisk/projects/HTML-TableExtract/
License:        GPL or Artistic
Vendor:         Red Hat, Inc.
Prefix:		%{_our_prefix}
BuildRoot:	%{_tmppath}/%cvs_package

%description

HTML::TableExtract is a subclass of HTML::Parser that serves to extract
the textual information from tables of interest contained within an HTML document.
The text from each extracted table is stored in tabe state objects which
hold the information as an array of arrays that represent the rows and cells of that table.

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
