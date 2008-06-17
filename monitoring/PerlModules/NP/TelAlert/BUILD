# Macros

%define cvs_package PerlModules/NP/TelAlert


# Package specific stuff
Name:         NOCpulse-TelAlert
Version:      1.37.0
Release:      1
Packager:     Dave Faraldo <dfaraldo@nocpulse.com>
Summary:      Perl debug output package
Source:	      NOCpulse-TelAlert-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl >= 5.00500
Provides:     NOCpulse::TelAlert
Group:        unsorted
Copyright:    NOCpulse (c) 2000
Vendor:       NOCpulse
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

Provides an API for generating varying levels of debugging output
on various output streams.

%prep
%entirely_abstract_build_step

%build

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p %buildroot%{_our_prefix}
install -o root -g root -m 444 TelAlert.pm %buildroot%{_our_prefix}/TelAlert.pm
%make_file_list

%files -f %{name}-%{version}-%{release}-filelist

%clean
%abstract_clean_script


%post
/usr/bin/perl -e '$\="\n\n";' -e 'print "=head2 ", scalar(localtime), ": C<", shift, ">", " L<", shift, ">";' -e 'print "=over 4";' -e 'while (defined($key = shift) and defined($val = shift)){print "=item *";print "C<$key: $val>";}' -e 'print "=back";' \
	"Module" "NOCpulse::TelAlert" \
        "installed into" "/usr/lib/perl5/site_perl/5.005" \
        LINKTYPE "dynamic" \
        VERSION "1.0" \
        EXE_FILES "" \
        >> /usr/lib/perl5/5.00503/i386-linux/perllocal.pod

