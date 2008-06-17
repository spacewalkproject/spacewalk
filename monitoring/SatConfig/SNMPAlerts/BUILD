# Macros

%define cvs_package SatConfig/SNMPAlerts

%define ap_home        /var/www
%define cgi_bin        %ap_home/cgi-bin
%define cgi_mod_perl   %ap_home/cgi-mod-perl
%define registry       /etc/rc.d/np.d/apachereg

# Package specific stuff
Name:         SNMPAlerts
Version:      0.5.1
Release:      1
Packager:     Dave Faraldo <dfaraldo@nocpulse.com>
Summary:      Download and clear SNMP alerts from the database
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Group:        unsorted
Copyright:    Red Hat, Inc.  (c) 2000-2003
Vendor:       Red Hat, Inc.
Buildroot:    %{_tmppath}/%cvs_package


%description

Provides ability to download and clear SNMP alerts from the database.

%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"


%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

# CGI bin and mod-perl bin
mkdir -p $RPM_BUILD_ROOT%cgi_mod_perl
mkdir -p $RPM_BUILD_ROOT%registry
install -o root -g root -m 555 fetch_snmp_alerts.cgi $RPM_BUILD_ROOT%cgi_mod_perl
install -o root -g root -m 444 Apache.SatConfig-SNMPAlerts $RPM_BUILD_ROOT%registry

%point_scripts_to_correct_perl 
%make_file_list


%files -f %{name}-%{version}-%{release}-filelist


%clean
%abstract_clean_script
