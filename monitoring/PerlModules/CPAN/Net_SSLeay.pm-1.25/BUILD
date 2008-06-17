# Macros

%define external_package 1

%define cvs_package    PerlModules/CPAN/Net_SSLeay.pm-1.25


# Package specific stuff
Name:		perl-Net_SSLeay
Version:	1.25.0
Release:	3.2
Packager:	Dave Parker <dparker@nocpulse.com>
Summary:	Net::SSLeay ssl interface for perl
Source:		%name-%PACKAGE_VERSION.tar.gz
BuildArch:	i386
Requires:	perl
Group:		unsorted
License:      Distribution and use of this module is under the same terms as the OpenSSL package itself (i.e. free, but mandatory attribution; NO WARRANTY). Please consult LICENSE file in the root of the OpenSSL distribution.
Vendor:       Red Hat, Inc.
Prefix:		%{_our_prefix}
BuildRoot:	%{_tmppath}/%cvs_package

%description

Net::SSLeay ssl interface for perl


%prep
%entirely_abstract_build_step
 
%build
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION;
CFLAGS="$RPM_OPT_FLAGS"  %perl Makefile.PL /usr PREFIX=$RPM_BUILD_ROOT%{prefix}
make OPTIMIZE="$RPM_OPT_FLAGS"
 
%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
%makefile_install
%point_scripts_to_correct_perl
%make_file_list
 
%files -f %{name}-%{version}-%{release}-filelist
 
%clean
%abstract_clean_script
