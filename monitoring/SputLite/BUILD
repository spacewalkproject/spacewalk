# Macros

%define cvs_package    sputnik/SputLite
%define ap_home        /var/www
%define cgi_bin        %ap_home/cgi-bin
%define cgi_mod_perl   %ap_home/cgi-mod-perl
%define templatedir    %ap_home/templates
%define bin            /home/nocpulse/bin
%define var            /home/nocpulse/var
%define registry       /etc/rc.d/np.d/apachereg

# Package specific stuff
Name:         SputLite
Version:      0.45.7
Release:      1
Packager:     Karen Jacqmin-Adams <karen@nocpulse.com>
Summary:      Command queue processor (Sputnik Lite)
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl NPusers
Group:        unsorted
Copyright:    (c) 2002-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Buildroot:    %{_tmppath}/%cvs_package


%description
Provides command-queue capability.


%package server
Summary:  Command queue processor (Sputnik Lite)
Provides: SputLite-server
Group:    unsorted
Prereq:   NPusers


%description server
Provides command-queue server capability.


%package client
Summary:  Command queue processor (Sputnik Lite)
Requires: perl MessageQueue ProgAGoGo NOCpulse::Debug NPusers
Provides: SputLite-client
Group:    unsorted
Prereq:   NPusers


%description  client
Provides command-queue client capability for satellites.


%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"


%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

# Perl libraries -- both client and server
%find_perl_installsitelib
perllib=$installsitelib/NOCpulse

mkdir -p $RPM_BUILD_ROOT$perllib
install -o root -g root -m 444 lib/CommandQueue.pm $RPM_BUILD_ROOT$perllib/CommandQueue.pm

# Install server
find $RPM_BUILD_ROOT -type f -print | \
        sed "s@^$RPM_BUILD_ROOT@@g" > %{_tmppath}/%{name}-server-%{version}-%{release}-filelist
if [ "$(cat %{_tmppath}/%{name}-server-%{version}-%{release}-filelist)X" = "X" ] ; then
    echo "ERROR: EMPTY FILE LIST"
    exit 1
fi

# CGI bin and mod-perl bin
mkdir -p $RPM_BUILD_ROOT%cgi_bin
mkdir -p $RPM_BUILD_ROOT%cgi_mod_perl
mkdir -p $RPM_BUILD_ROOT%registry
install -o root -g root -m 555 html/cgi-mod-perl/*.cgi $RPM_BUILD_ROOT%cgi_mod_perl
install -o root -g root -m 555 html/cgi-bin/*.cgi $RPM_BUILD_ROOT%cgi_bin
install -o root -g root -m 444 html/cgi-bin/registry.fetch_commands $RPM_BUILD_ROOT%registry/Apache.SputLite-server.fetch_commands

# Server HTML templates
mkdir -p $RPM_BUILD_ROOT%templatedir
cp html/templates/*.html $RPM_BUILD_ROOT%templatedir
chmod -R 444 $RPM_BUILD_ROOT%templatedir

# Install client

# Client perl libraries
mkdir -p $RPM_BUILD_ROOT$perllib/CommandQueue
install -o root -g root -m 444 lib/CommandQueue/Command.pm $RPM_BUILD_ROOT$perllib/CommandQueue/Command.pm
install -o root -g root -m 444 lib/CommandQueue/Parser.pm  $RPM_BUILD_ROOT$perllib/CommandQueue/Parser.pm

find $RPM_BUILD_ROOT -type f -name "*.pm" -print | \
     sed "s@^$RPM_BUILD_ROOT@@g" > %{_tmppath}/%{name}-client-%{version}-%{release}-filelist
if [ "$(cat %{_tmppath}/%{name}-client-%{version}-%{release}-filelist)X" = "X" ] ; then
    echo "ERROR: EMPTY FILE LIST"
    exit 1
fi

# Client NOCpulse bin
mkdir -p $RPM_BUILD_ROOT%bin
install -o root -g root -m 555 bin/execute_commands $RPM_BUILD_ROOT%bin/execute_commands


# Client var files and directories
mkdir -p $RPM_BUILD_ROOT%var/commands
mkdir -p $RPM_BUILD_ROOT%var/queue/commands

%point_scripts_to_correct_perl


%files server -f %{_tmppath}/%{name}-server-%{version}-%{release}-filelist
%attr(755, nocpulse, nocpulse) %dir %templatedir
%cgi_bin/*
%cgi_mod_perl/*
%templatedir/*
%registry/*


%files client -f %{_tmppath}/%{name}-client-%{version}-%{release}-filelist
%attr(755,nocpulse,nocpulse) %dir %var/commands
%bin/*


%clean
%abstract_clean_script
rm %{_tmppath}/%{name}-server-%{version}-%{release}-filelist
rm %{_tmppath}/%{name}-client-%{version}-%{release}-filelist
