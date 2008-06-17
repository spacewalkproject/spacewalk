# Macros
%define cvs_package NPalert
%define install_prefix     /opt/notification
%define cron_prefix        /etc/cron.d
%define httpd_prefix       /var/www
%define notif_user         nocpulse
%define registry           /etc/rc.d/np.d/apachereg
%define log_rotate_prefix  /etc/logrotate.d/

# Package specific stuff
Name:         %cvs_package
Version:      1.126.0
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      NOCpulse notification system
Source:	      %cvs_package-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl perl(Config::IniFiles) perl(DBI) perl(DBD::Oracle) perl(Class::MethodMaker) perl(Error) perl(Date::Manip) perl-TimeDate perl-MailTools perl-NOCpulse-Probe perl-libwww-perl perl(URI) perl(HTML::Parser) perl(FreezeThaw)
Provides:     NPalert
Group:        unsorted
Copyright:    (c) 2002-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:	      %install_prefix
Prereq:       NPusers sendmail
Buildroot:    %{_tmppath}/%cvs_package


%description

The NOCpulse notification system.

%prep
%entirely_abstract_build_step

%build

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

# Create directories
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/config/archive
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/config/generated
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/config/static
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/config/stage/config
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/etc
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/ack_queue
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/ack_queue/.new
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/alert_queue
mkdir -p --mode=775 $RPM_BUILD_ROOT%install_prefix/queue/alert_queue/.new
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/scripts
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/tmp
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/var
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/var/archive
mkdir -p --mode=755 $RPM_BUILD_ROOT%install_prefix/var/ticketlog


# Create symlinks
ln -s ../../scripts                 $RPM_BUILD_ROOT%install_prefix/config/stage/scripts
ln -s ../../static                  $RPM_BUILD_ROOT%install_prefix/config/stage/config/static
ln -s ..                            $RPM_BUILD_ROOT%install_prefix/scripts/NOCpulse
ln -s ..                            $RPM_BUILD_ROOT%install_prefix/etc/NOCpulse

# Install the perl modules
%find_perl_installsitelib
pm_prefix=$installsitelib/NOCpulse/Notif
mkdir -p --mode 755 $RPM_BUILD_ROOT$pm_prefix/test
install -o root -g root -m 444 *.pm $RPM_BUILD_ROOT$pm_prefix/
install -o root -g root -m 444 test/*.pm $RPM_BUILD_ROOT$pm_prefix/test

# Install the scripts
install -o %notif_user -g %notif_user -m 755 scripts/*        $RPM_BUILD_ROOT%install_prefix/scripts/

# Install the config stuff
install -o %notif_user -g %notif_user -m 644 config/*.ini             $RPM_BUILD_ROOT%install_prefix/config/static


# Make sure everything is owned by the right user/group and critical dirs
# have the right permissions
chmod 755 $RPM_BUILD_ROOT%install_prefix
chown -R %notif_user:%notif_user $RPM_BUILD_ROOT%install_prefix
chmod -R 755 $RPM_BUILD_ROOT%install_prefix/scripts

# Install the html and cgi scripts
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/htdocs
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/cgi-bin
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/cgi-mod-perl
mkdir -p --mode=755 $RPM_BUILD_ROOT%httpd_prefix/templates

ln -s %install_prefix/var           $RPM_BUILD_ROOT%httpd_prefix/htdocs/alert_logs

install -o root -g root -m 755 httpd/cgi-bin/*.cgi      $RPM_BUILD_ROOT%httpd_prefix/cgi-bin/
install -o root -g root -m 755 httpd/cgi-mod-perl/*.cgi $RPM_BUILD_ROOT%httpd_prefix/cgi-mod-perl/
install -o root -g root -m 755 httpd/html/*.html        $RPM_BUILD_ROOT%httpd_prefix/htdocs/
install -o root -g root -m 755 httpd/html/*.css         $RPM_BUILD_ROOT%httpd_prefix/htdocs/
install -o root -g root -m 755 httpd/templates/*.html   $RPM_BUILD_ROOT%httpd_prefix/templates/

# Install the cron stuff
mkdir -p $RPM_BUILD_ROOT%cron_prefix
install -o root -g root -m 644 cron/notification        $RPM_BUILD_ROOT%cron_prefix


# Install apache registration entries
mkdir -p $RPM_BUILD_ROOT%registry
install -o root -g root -m 644 Apache.NPalert $RPM_BUILD_ROOT%registry

# Install logrotate stuff
mkdir -p %buildroot%log_rotate_prefix
install -o root -g root -m 444 logrotate.d/notification  $RPM_BUILD_ROOT%log_rotate_prefix

# Fix up the perl scripts and build the filelist
%point_scripts_to_correct_perl
%make_file_list


%files -f %{name}-%{version}-%{release}-filelist
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/archive
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/generated
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/static
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/stage
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/stage/config
%attr (755,%notif_user,%notif_user) %dir %install_prefix/etc
%attr (755,%notif_user,%notif_user) %dir %install_prefix/queue
%attr (775,mail,       %notif_user) %dir %install_prefix/queue/ack_queue
%attr (775,mail,       %notif_user) %dir %install_prefix/queue/ack_queue/.new
%attr (775,apache,     %notif_user) %dir %install_prefix/queue/alert_queue
%attr (775,apache,     %notif_user) %dir %install_prefix/queue/alert_queue/.new
%attr (755,%notif_user,%notif_user) %dir %install_prefix/scripts
%attr (755,%notif_user,%notif_user) %dir %install_prefix/tmp
%attr (755,%notif_user,%notif_user) %dir %install_prefix/var
%attr (755,%notif_user,%notif_user) %dir %install_prefix/var/archive
%attr (755,%notif_user,%notif_user) %dir %install_prefix/var/ticketlog
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/stage/scripts
%attr (755,%notif_user,%notif_user) %dir %install_prefix/config/stage/config/static
%attr (755,%notif_user,%notif_user) %dir %install_prefix/scripts/NOCpulse
%attr (755,%notif_user,%notif_user) %dir %install_prefix/etc/NOCpulse
%dir %httpd_prefix/htdocs/alert_logs


%clean
%abstract_clean_script
