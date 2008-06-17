# Macros

#control upversion
%define external_package 1

%define cvs_package    PerlModules/CPAN/Test-Unit-0.14


# Package specific stuff
Name:		Test-Unit
Version:	0.15.0
Release:	1
Packager:	Rod McChesney <rmcchesney@nocpulse.com>
Summary:	A unit testing interface for Perl
Source:		%name-%PACKAGE_VERSION.tar.gz
BuildArch:	noarch
Requires:	perl
Group:		unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:		%{_our_prefix}
BuildRoot:	%{_tmppath}/%cvs_package
Provides:	perl(Test::Unit::tests::TornDown) perl(Test::Unit::tests::WasRun)


%description

Provides a JUnit-style unit test environment.


%prep
%entirely_abstract_build_step
 
%build
%makefile_build 
 
%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
%makefile_install
%point_scripts_to_correct_perl
cd $RPM_BUILD_DIR; \
find $RPM_BUILD_ROOT -type f -and -not -name 'TkTestRunner.*' -print | \
sed "s@^$RPM_BUILD_ROOT@@g" > %{name}-%{version}-%{release}-filelist; \
if [ "$(cat %{name}-%{version}-%{release}-filelist)X" = "X" ] ; then \
echo "ERROR: EMPTY FILE LIST"; \
exit 1; \
fi
find $RPM_BUILD_ROOT -type f
rm $RPM_BUILD_ROOT/usr/lib/perl5/site_perl/5.8.0/Test/Unit/TkTestRunner.pm
rm $RPM_BUILD_ROOT/usr/lib/perl5/site_perl/5.8.0/Test/TkTestRunner.pl
 
%files -f %{name}-%{version}-%{release}-filelist
 
%clean
%abstract_clean_script
