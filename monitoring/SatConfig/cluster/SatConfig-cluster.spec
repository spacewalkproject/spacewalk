
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


%define make_file_list find $RPM_BUILD_ROOT -type f -print | sed "s@^$RPM_BUILD_ROOT@@g" > %{name}-%{version}-%{release}-filelist; if [ "$(cat %{name}-%{version}-%{release}-filelist)X" = "X" ] ; then echo "ERROR: EMPTY FILE LIST"; exit 1; fi


%define abstract_clean_script rm -rf $RPM_BUILD_ROOT; cd $RPM_BUILD_DIR; rm -rf $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION; [ -n %cvs_package_prefix ] && [ -e %cvs_package_prefix ] && rm -rf %cvs_package_prefix; [ -e %cvs_package ] && rm -rf %cvs_package; [ -e %{name}-%{version}-%{release}-filelist ] && rm %{name}-%{version}-%{release}-filelist
# Macros

%define cvs_package    SatConfig/cluster

%define etc            /etc
%define sysv_dir       %etc/rc.d/np.d

# Package specific stuff
Name:         SatConfig-cluster
Version:      1.54.2
Release:      5%{?dist}
Summary:      Satellite Configuration System - cluster information
Source0:      %{name}-%{version}.tar.gz
BuildArch:    noarch
Group:        unsorted
License:      GPLv2
Vendor:       Red Hat, Inc.
Prefix:	      %install_prefix
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       perl(NOCpulse::Object) perl(Config::IniFiles) perl
Provides:     perl(NOCpulse::SatCluster)

%description

SatConfig-cluster includes a library file that provides i/o access to
the cluster definition file.

%prep
%setup -q


%build
echo "Nothing to build"

%install

%find_perl_installsitelib

mkdir -p $RPM_BUILD_ROOT%sysv_dir
mkdir -p $RPM_BUILD_ROOT%etc
mkdir -p $RPM_BUILD_ROOT$installsitelib/NOCpulse


install -m 644 ApacheServer.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 ConfigObject.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 HostsAccess.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 IpAddr.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 LocalConfig.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 RemoteConfig.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 ModJK2.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 NetworkFilesystem.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 OffnetRoute.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 PhysNode.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 PrivateIpAddr.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 SatCluster.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 TomcatBinding.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 TomcatServer.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 VIP.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 PhysCluster.pm $RPM_BUILD_ROOT%sysv_dir
install -m 644 Cluster.ini.example $RPM_BUILD_ROOT%etc
install -m 555 cconfig $RPM_BUILD_ROOT%sysv_dir
install -m 555 describeClusterIni $RPM_BUILD_ROOT%sysv_dir
install -m 644 SatCluster.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse/.
 
%point_scripts_to_correct_perl
%make_file_list

%files -f %{name}-%{version}-%{release}-filelist
%defattr(-,root,root,-)


%clean
%abstract_clean_script

%changelog
* Thu May 29 2008 Jan Pazdziora 1.54.2-5
- rebuild in dist.cvs

