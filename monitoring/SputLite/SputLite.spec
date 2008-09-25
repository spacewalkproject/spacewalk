
# CVS hacks
%define cvs_package_prefix	old-nocpulse/

# What Perl to use?
%define perl_prefix     /usr
%define perl            %perl_prefix/bin/perl
%define perlpkg         perl-rhnmon

# Macro for cpan documentation
%define doc_prefix     %perl_prefix/share/doc/%name
%define man_prefix     %perl_prefix/man 


# Macro(s) slavishly copied from autoconf's config.status.
%define _our_prefix                /usr
%define _our_exec_prefix           %{_our_prefix}
%define _our_bindir                %{_our_exec_prefix}/bin
%define _our_sbindir               %{_our_exec_prefix}/sbin
%define _our_libexecdir            %{_our_exec_prefix}/libexec
%define _our_datadir               %{_our_prefix}/share
%define _our_sysconfdir            %{_our_prefix}/etc
%define _our_sharedstatedir        %{_our_prefix}/com
%define _our_localstatedir         %{_our_prefix}/var
%define _our_lib                   lib
%define _our_libdir                %{_our_exec_prefix}/%{_lib}
%define _our_includedir            %{_our_prefix}/include
%define _our_oldincludedir         /usr/include
%define _our_infodir               %{_our_prefix}/info
%define _our_mandir                %{_our_prefix}/man


# Prep for build. This is entirely abstract - you should not need to change it.
%define entirely_abstract_build_step rm -rf $RPM_BUILD_ROOT; rm -rf $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION; cvs checkout $RPM_TAG_PARAM %cvs_package_prefix%cvs_package; [ -n %cvs_package_prefix ] && mkdir -p %cvs_package && rmdir %cvs_package && ln -s %cvs_package_prefix%cvs_package %cvs_package ; [ %cvs_package = $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION ] || mv %cvs_package $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION; find $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION -type d -name CVS | xargs rm -rf; tar -cvzf $RPM_SOURCE_DIR/$RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION.tar.gz $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION



%define perl_makefile CFLAGS="$RPM_OPT_FLAGS" %perl Makefile.PL verbose PREFIX=$RPM_BUILD_ROOT%{prefix}; make OPTIMIZE="$RPM_OPT_FLAGS"



%define makefile_build cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION; %perl_makefile


# For CPAN modules with a copyright or license that is not GPL or Artistic
%define cpan_doc_install mkdir -p $RPM_BUILD_ROOT%doc_prefix; [ -e README ]    && cp README    $RPM_BUILD_ROOT%doc_prefix; [ -e COPYING ]   && cp COPYING   $RPM_BUILD_ROOT%doc_prefix; [ -e COPYRIGHT ] && cp COPYRIGHT $RPM_BUILD_ROOT%doc_prefix


%define our_makeinstall  make prefix=%{?buildroot:%{buildroot}}%{_our_prefix} exec_prefix=%{?buildroot:%{buildroot}}%{_our_exec_prefix} bindir=%{?buildroot:%{buildroot}}%{_our_bindir} sbindir=%{?buildroot:%{buildroot}}%{_our_sbindir} sysconfdir=%{?buildroot:%{buildroot}}%{_our_sysconfdir} datadir=%{?buildroot:%{buildroot}}%{_our_datadir} includedir=%{?buildroot:%{buildroot}}%{_our_includedir} libdir=%{?buildroot:%{buildroot}}%{_our_libdir} libexecdir=%{?buildroot:%{buildroot}}%{_our_libexecdir} localstatedir=%{?buildroot:%{buildroot}}%{_our_localstatedir} sharedstatedir=%{?buildroot:%{buildroot}}%{_our_sharedstatedir} mandir=%{?buildroot:%{buildroot}}%{_our_mandir} infodir=%{?buildroot:%{buildroot}}%{_our_infodir} install



%define makefile_install eval `%perl '-V:installarchlib'`; mkdir -p $RPM_BUILD_ROOT$installarchlib; %our_makeinstall; rm -f `find $RPM_BUILD_ROOT -type f -name perllocal.pod -o -name .packlist`; [ -x /usr/lib/rpm/brp-compress ] && /usr/lib/rpm/brp-compress


# For the really ugly cases, e.g. PerlModules/CPAN/libwww-perl-5.48
%define alt_makefile_install mkdir -p $RPM_BUILD_ROOT/%{_our_prefix}/lib; make install PREFIX=$RPM_BUILD_ROOT; mv $RPM_BUILD_ROOT/lib $RPM_BUILD_ROOT%{_our_prefix}/lib/perl5



%define find_perl_installsitelib eval `%perl '-V:installsitelib'`; echo installsitelib is $installsitelib; if [ "$installsitelibX" = "X" ] ; then echo "ERROR: installsitelib is undefined"; exit 1; fi



%define point_scripts_to_correct_perl find $RPM_BUILD_ROOT -type f -print | xargs perl -pi -e 's,^#\\\!/usr/bin/perl,#\\\!%perl, if ($ARGV ne $lf); $lf = $ARGV;'


%define make_file_list cd $RPM_BUILD_DIR; find $RPM_BUILD_ROOT -type f -print | sed "s@^$RPM_BUILD_ROOT@@g" > $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION/%{name}-%{version}-%{release}-filelist; if [ "$(cat $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION/%{name}-%{version}-%{release}-filelist)X" = "X" ] ; then echo "ERROR: EMPTY FILE LIST"; exit 1; fi


%define abstract_clean_script rm -rf $RPM_BUILD_ROOT; cd $RPM_BUILD_DIR; rm -rf $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION; [ -n %cvs_package_prefix ] && [ -e %cvs_package_prefix ] && rm -rf %cvs_package_prefix; [ -e %cvs_package ] && rm -rf %cvs_package; [ -e %{name}-%{version}-%{release}-filelist ] && rm %{name}-%{version}-%{release}-filelist
# Macros

%define cvs_package    sputnik/SputLite
%define ap_home        /var/www
%define cgi_bin        %ap_home/cgi-bin
%define cgi_mod_perl   %ap_home/cgi-mod-perl
%define templatedir    %ap_home/templates
%define bin            /opt/home/nocpulse/bin
%define var            /opt/home/nocpulse/var
%define registry       /etc/rc.d/np.d/apachereg

# Package specific stuff
Name:         SputLite
Source0:      %{name}-%{version}.tar.gz
Source1:      version
Version:      %(echo `awk '{ print $1 }' %{SOURCE1}`)
Release:      %(echo `awk '{ print $2 }' %{SOURCE1}`)%{?dist}
Summary:      Command queue processor (Sputnik Lite)
BuildArch:    noarch
Requires:     perl NPusers
Group:        unsorted
License:      GPLv2
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
%setup -q


%build
echo "Nothing to build"


%install
rm -rf $RPM_BUILD_ROOT

# Perl libraries -- both client and server
%find_perl_installsitelib
perllib=$installsitelib/NOCpulse

mkdir -p $RPM_BUILD_ROOT$perllib
install -m 444 lib/CommandQueue.pm $RPM_BUILD_ROOT$perllib/CommandQueue.pm

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
install -m 555 html/cgi-mod-perl/*.cgi $RPM_BUILD_ROOT%cgi_mod_perl
install -m 555 html/cgi-bin/*.cgi $RPM_BUILD_ROOT%cgi_bin
install -m 444 html/cgi-bin/registry.fetch_commands $RPM_BUILD_ROOT%registry/Apache.SputLite-server.fetch_commands

# Server HTML templates
mkdir -p $RPM_BUILD_ROOT%templatedir
cp html/templates/*.html $RPM_BUILD_ROOT%templatedir
#chmod -R 444 $RPM_BUILD_ROOT%templatedir

# Install client

# Client perl libraries
mkdir -p $RPM_BUILD_ROOT$perllib/CommandQueue
install -m 444 lib/CommandQueue/Command.pm $RPM_BUILD_ROOT$perllib/CommandQueue/Command.pm
install -m 444 lib/CommandQueue/Parser.pm  $RPM_BUILD_ROOT$perllib/CommandQueue/Parser.pm

find $RPM_BUILD_ROOT -type f -name "*.pm" -print | \
     sed "s@^$RPM_BUILD_ROOT@@g" > %{_tmppath}/%{name}-client-%{version}-%{release}-filelist
if [ "$(cat %{_tmppath}/%{name}-client-%{version}-%{release}-filelist)X" = "X" ] ; then
    echo "ERROR: EMPTY FILE LIST"
    exit 1
fi

# Client NOCpulse bin
mkdir -p $RPM_BUILD_ROOT%bin
install -m 555 bin/execute_commands $RPM_BUILD_ROOT%bin/execute_commands


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

%changelog
* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Mon Jun 16 2008 Milan Zazrivec <mzazrivec@redhat.com> 0.48.0-4
- cvs.dist import
