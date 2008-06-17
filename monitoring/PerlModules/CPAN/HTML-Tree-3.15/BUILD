# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/HTML-Tree-3.15

# Package specific stuff
Name:		HTML-Tree
Version:	3.15.0
Release:	2
Packager:	Karen Jacqmin-Adams <kja@redhat.com>
Summary:	HTML tree-based parser
Source:		%name-%PACKAGE_VERSION.tar.gz
BuildArch:	noarch
Prereq: 	perl
License:        GPL or Artistic
Vendor:         Red Hat, Inc.
Group:		unsorted
Prefix:         %{_our_prefix}
Buildroot:      %{_tmppath}/%cvs_package


%description

This distribution contains a suite of modules for representing,
creating, and extracting information from HTML syntax trees; there is
also relevent documentation.  These modules used to be part of the
libwww-perl distribution, but are now unbundled in order to facilitate
a separate development track.  Bug reports and discussions about these
modules can still be sent to the <libwww@perl.org> mailing list, or to
<sburke@cpan.org>.


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
