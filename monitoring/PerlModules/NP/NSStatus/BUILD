# Macros

%define name           NOCpulse-NSStatus
%define cvs_package    PerlModules/NP/NSStatus
%define install_prefix /usr/lib/perl5/site_perl/5.005/NOCpulse/NSStatus
%define buildroot      /tmp/%cvs_package

# Package specific stuff
Name:         %name
Version:      1.1.0
Release:      1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      NOCpulse netsaint status file reader classes
Source:	      %name-%PACKAGE_VERSION.tar.gz
Requires:     NOCpulse-Object np-config
BuildArch:    noarch
Group:        unsorted
Copyright:    NOCpulse (c) 2000
Vendor:       NOCpulse
Prefix:       %install_prefix
Buildroot:    %buildroot

%description

NOCpulse-NSStatus provides a framework for reading Netsaint status.log
files in perl

%prep
# Prep for build. This is entirely abstract - you should not need to change it.
rm -rf %buildroot
rm -rf $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
cvs checkout $RPM_TAG_PARAM %cvs_package
mv %cvs_package $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
tar -cvzf $RPM_SOURCE_DIR/$RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION.tar.gz $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p %buildroot%install_prefix

install -o root -g root -m 444 NSHostStatus.pm    %buildroot%install_prefix/NSHostStatus.pm 
install -o root -g root -m 444 NSProgramStatus.pm %buildroot%install_prefix/NSProgramStatus.pm 
install -o root -g root -m 444 NSServiceStatus.pm %buildroot%install_prefix/NSServiceStatus.pm 
install -o root -g root -m 444 NSStatusFile.pm    %buildroot%install_prefix/NSStatusFile.pm 
install -o root -g root -m 444 NSStatusRecord.pm  %buildroot%install_prefix/NSStatusRecord.pm 

%files
%attr(755,-,-) %dir %install_prefix
%attr(444,-,-) %install_prefix/NSHostStatus.pm
%attr(444,-,-) %install_prefix/NSProgramStatus.pm
%attr(444,-,-) %install_prefix/NSServiceStatus.pm
%attr(444,-,-) %install_prefix/NSStatusFile.pm
%attr(444,-,-) %install_prefix/NSStatusRecord.pm


%clean
rm -rf %buildroot
rm -rf $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
cd $RPM_BUILD_DIR
rm -rf %cvs_package
