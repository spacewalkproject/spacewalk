# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/Heap-0.50
%define fileslist      /tmp/files.%name

# Package specific stuff
Name:         Heap
Version:      0.50.0
Release:      2
Packager:     Adam Pingel <apingel@nocpulse.com>
Summary:      Heap data structure
Source:	      Heap-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl 
Provides:     Heap
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:       /usr
Buildroot:    %{_tmppath}/%name

%description

Perl implementation of Heap data structure.

%prep
# Prep for build. This is entirely abstract - you should not need to change it.
rm -rf $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
cvs checkout $RPM_TAG_PARAM %cvs_package
mv %cvs_package $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
find $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION -type d -name CVS | xargs rm -rf
tar -cvzf $RPM_SOURCE_DIR/$RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION.tar.gz $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%build
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
perl Makefile.PL
make PREFIX=$RPM_BUILD_ROOT%{_prefix}

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p $RPM_BUILD_ROOT%{_prefix}
make install  PREFIX=$RPM_BUILD_ROOT%{_prefix}
cd $RPM_BUILD_ROOT
find -type f -not -name 'perllocal.pod' -and -not -path "*/man/*" -printf '/%%P\n' > %fileslist
find -type f -path "*/man/*" -printf '/%%P.gz\n' >> %fileslist

%files -f %fileslist

%clean
rm -rf $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
cd $RPM_BUILD_DIR
rm -rf PerlModules
rm %fileslist
