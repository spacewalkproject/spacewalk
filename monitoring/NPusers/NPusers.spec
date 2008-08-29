
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

%define cvs_package NPusers

%define install_prefix /opt/home/nocpulse
%define exe_dir     %install_prefix/bin
%define cfg_dir     %install_prefix/etc
%define libexec_dir %install_prefix/libexec
%define var_dir     %install_prefix/var
%define archive_dir %var_dir/archives

%define root_homedir   /root
%define buildroot      /tmp/%cvs_package

# Package specific stuff
Name:         NPusers
Version: 1.17.11
Release: 6%{?dist}
Summary:      Adds NOCpulse production users
License: GPLv2
BuildArch:    noarch
Group:        unsorted
Buildroot:    %buildroot
Prereq:       /bin/echo /usr/sbin/groupadd /usr/sbin/useradd /bin/chmod /bin/false /usr/bin/passwd /bin/chown /bin/awk
Prereq:       httpd

%description

Installs NOCpulse users

%setup

%install

rm -rf %{buildroot}

# Install the user creation script
install -m 755 -d %buildroot/var/log/nocpulse

%pre
PASSWD='$1$QHACLtf8$kJB3WeLHn33ZaI1qLbqaa0'

/bin/echo "* Adding users"

if [ $OSTYPE = solaris ] ; then
  SOLARIS=true
  sysacct=
  wheel_group=apache
  oracle_group=dba
  tcsh=/usr/local/bin/tcsh
  orac
else
  SOLARIS=
  sysacct=-r
  wheel_group="-G apache"
  oracle_group=oinstall
  tcsh=/bin/tcsh
fi

/bin/echo " -- Prod account nocpulse"
/usr/sbin/useradd -c 'NOCpulse user' $wheel_group nocpulse
/usr/bin/passwd -l nocpulse

/bin/echo " -- Login account nocops"
/usr/sbin/useradd -c "NOCpulse Ops" $wheel_group nocops


/bin/echo "* Finished adding users"


/bin/echo "* Setting passwds"
/bin/echo " -- root"
passwd=`/bin/grep '^root:' /etc/shadow | /bin/awk -F: '{print $2}'`
if [ "$passwd" = "!!" -o "$passwd" = "" ]
then
  /usr/sbin/usermod -p "$PASSWD" root
else
  /bin/echo "   Root already has password ($passwd)"
fi

/bin/echo "* Finished setting root passwd"


/bin/echo "* Setting up nocpulse homedir and ssh key pair"

for dir in /opt/home/nocpulse/{,.ssh,bin,etc,libexec,var{,/archives}}
do
  if [ ! -d $dir ]
  then
    mkdir $dir
  fi
done
/usr/bin/ssh-keygen -q -t dsa -N '' -f /opt/home/nocpulse/.ssh/nocpulse-identity
chown -R nocpulse.nocpulse /opt/home/nocpulse
/bin/echo "* Finished setting up nocpulse homedir and ssh key pair"


%files
%defattr(-,nocpulse,nocpulse)
%dir /var/log/nocpulse

%clean
%abstract_clean_script

%changelog
* Fri Aug 29 2008 Jan Pazdziora
- move version to the .spec file

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Wed May 21 2008 Miroslav Suchy <msuchy@redhat.com> 1.17.11-6
- migrate to brew / dist-cvs
