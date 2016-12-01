%if 0%{?suse_version}
%define apacheconfdir %{_sysconfdir}/apache2
%define apachepkg apache2
%define apache_group www
%else
%define apacheconfdir %{_sysconfdir}/httpd
%define apachepkg httpd
%define apache_group apache
%endif

Name: spacewalk-config
Summary: Spacewalk Configuration
Version: 2.7.0
Release: 1%{?dist}
URL: http://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
License: GPLv2
Group: Applications/System
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Buildarch: noarch
Requires: perl(Satcon)
Obsoletes: rhn-satellite-config < 5.3.0
Provides: rhn-satellite-config = 5.3.0
%if 0%{?rhel} || 0%{?fedora}
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts
%endif
# We need package httpd to be able to assign group apache in files section
Requires(pre): %{apachepkg}
Requires: openssl

%global prepdir %{_var}/lib/rhn/rhn-satellite-prep

%description
Common Spacewalk configuration files and templates.

%prep
%setup -q
echo "%{name} %{version}" > version

%build

%install
rm -Rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT
mv etc $RPM_BUILD_ROOT/
mv var $RPM_BUILD_ROOT/
mv usr $RPM_BUILD_ROOT/

%if 0%{?suse_version}
export NO_BRP_STALE_LINK_ERROR=yes
mv $RPM_BUILD_ROOT/etc/httpd $RPM_BUILD_ROOT%{apacheconfdir}
sed -i 's|var/www/html|srv/www/htdocs|g' $RPM_BUILD_ROOT%{apacheconfdir}/conf.d/zz-spacewalk-www.conf
%endif

tar -C $RPM_BUILD_ROOT%{prepdir} -cf - etc \
     | tar -C $RPM_BUILD_ROOT -xvf -

echo "" > $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/rhn.conf

mkdir -p $RPM_BUILD_ROOT/etc/pki/tls/certs/
mkdir -p $RPM_BUILD_ROOT/etc/pki/tls/private/
%if 0%{?suse_version}
ln -sf  %{apacheconfdir}/ssl.key/server.key $RPM_BUILD_ROOT/etc/pki/tls/private/spacewalk.key
ln -sf  %{apacheconfdir}/ssl.crt/server.crt $RPM_BUILD_ROOT/etc/pki/tls/certs/spacewalk.crt
%else
ln -sf  %{apacheconfdir}/conf/ssl.key/server.key $RPM_BUILD_ROOT/etc/pki/tls/private/spacewalk.key
ln -sf  %{apacheconfdir}/conf/ssl.crt/server.crt $RPM_BUILD_ROOT/etc/pki/tls/certs/spacewalk.crt
%endif

%clean
rm -rf $RPM_BUILD_ROOT

%files
%attr(400,root,root) %config(noreplace) %{_sysconfdir}/rhn/spacewalk-repo-sync/uln.conf
%config(noreplace) %{apacheconfdir}/conf.d/zz-spacewalk-www.conf
%config(noreplace) %{_sysconfdir}/webapp-keyring.gpg
%dir %{_var}/lib/cobbler/
%dir %{_var}/lib/cobbler/kickstarts/
%dir %{_var}/lib/cobbler/snippets/
%config(noreplace) %{_var}/lib/cobbler/kickstarts/spacewalk-sample.ks
%config(noreplace) %{_var}/lib/cobbler/snippets/spacewalk_file_preservation
%attr(0750,root,%{apache_group}) %dir %{_sysconfdir}/rhn
%attr(0640,root,%{apache_group}) %config(missingok,noreplace) %verify(not md5 size mtime) %{_sysconfdir}/rhn/rhn.conf
%attr(0750,root,%{apache_group}) %dir %{_sysconfdir}/rhn/candlepin-certs
%config %attr(644, root, root) %{_sysconfdir}/rhn/candlepin-certs/candlepin-redhat-ca.crt
# NOTE: If if you change these, you need to make a corresponding change in
# spacewalk/install/Spacewalk-Setup/bin/spacewalk-setup
%config(noreplace) %{_sysconfdir}/pki/tls/private/spacewalk.key
%config(noreplace) %{_sysconfdir}/pki/tls/certs/spacewalk.crt
%config(noreplace) %{_sysconfdir}/satname
%dir %{_var}/lib/rhn
%dir %{_var}/lib/rhn/rhn-satellite-prep
%attr(0750,root,root) %dir %{_var}/lib/rhn/rhn-satellite-prep/etc
%attr(0750,root,%{apache_group}) %dir %{_var}/lib/rhn/rhn-satellite-prep/etc/rhn
%attr(0640,root,%{apache_group}) %{_var}/lib/rhn/rhn-satellite-prep/etc/rhn/rhn.conf
%dir %{_prefix}/share/rhn
%attr(0755,root,root) %{_prefix}/share/rhn/startup.pl
%doc LICENSE
%doc %{_mandir}/man5/rhn.conf.5*
%if 0%{?suse_version}
%dir %{_sysconfdir}/pki
%dir %{_sysconfdir}/pki/tls
%dir %{_sysconfdir}/pki/tls/certs
%dir %{_sysconfdir}/pki/tls/private
%dir %{_sysconfdir}/rhn/spacewalk-repo-sync
%endif

%pre
# This section is needed here because previous versions of spacewalk-config
# (and rhn-satellite-config) "owned" the satellite-httpd service. We need
# to keep this section here indefinitely, because Satellite 5.2 could
# be upgraded directly to our version of Spacewalk.
if [ -f /etc/init.d/satellite-httpd ] ; then
    /sbin/service satellite-httpd stop >/dev/null 2>&1
    /sbin/chkconfig --del satellite-httpd
    %{__perl} -i -ne 'print unless /satellite-httpd\.pid/' /etc/logrotate.d/httpd
fi

# Set the group to allow Apache to access the conf files ...
chgrp %{apache_group} /etc/rhn /etc/rhn/rhn.conf 2> /dev/null || :
# ... once we restrict access to some files that were too open in
# the past.
chmod o-rwx /etc/rhn/rhn.conf* /etc/sysconfig/rhn/backup-* /var/lib/rhn/rhn-satellite-prep/* 2> /dev/null || :

%if 0%{?suse_version}
%post
sysconf_addword /etc/sysconfig/apache2 APACHE_MODULES version
sysconf_addword /etc/sysconfig/apache2 APACHE_MODULES access_compat
sysconf_addword /etc/sysconfig/apache2 APACHE_MODULES proxy
sysconf_addword /etc/sysconfig/apache2 APACHE_MODULES proxy_ajp
sysconf_addword /etc/sysconfig/apache2 APACHE_MODULES rewrite
sysconf_addword /etc/sysconfig/apache2 APACHE_MODULES headers
sysconf_addword /etc/sysconfig/apache2 APACHE_MODULES wsgi
sysconf_addword /etc/sysconfig/apache2 APACHE_MODULES perl
sysconf_addword /etc/sysconfig/apache2 APACHE_SERVER_FLAGS SSL
sysconf_addword /etc/sysconfig/apache2 APACHE_SERVER_FLAGS ISSUSE
%endif

%changelog
* Thu Nov 10 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.6.5-1
- 1373067 - Modified option for fonts directory

* Mon Nov 07 2016 Jan Dobes 2.6.4-1
- adding development key to keyring

* Tue Oct 25 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.6.3-1
- 1373067 - Prevent Apache directory listing

* Wed Oct 05 2016 Jan Dobes 2.6.2-1
- adding candlepin CA certificate to check manifest signature

* Tue Jun 14 2016 Jan Dobes 2.6.1-1
- create the symlink directly and point to correct destination on SUSE
- Bumping package versions for 2.6.

* Tue May 10 2016 Grant Gainey 2.5.3-1
- spacewalk-config: build on openSUSE

* Thu Dec 17 2015 Jan Dobes 2.5.2-1
- removing unused enable_solaris_support configuration parameter
- removing unused force_unentitlement configuration parameter

* Tue Nov 24 2015 Jan Dobes 2.5.1-1
- rhn-satellite-activate: manual references removed
- Bumping package versions for 2.5.

* Wed Aug 12 2015 Tomas Lestach <tlestach@redhat.com> 2.4.1-1
- Fixed typo on the rhn.conf man page
- Bumping package versions for 2.4.

* Thu Mar 19 2015 Grant Gainey 2.3.17-1
- remove unused dependency

* Fri Mar 13 2015 Tomas Lestach <tlestach@redhat.com> 2.3.16-1
- preparations for mod_perl removal

* Fri Mar 13 2015 Tomas Lestach <tlestach@redhat.com> 2.3.15-1
- do not reference Apache2::SizeLimit

* Thu Mar 12 2015 Tomas Lestach <tlestach@redhat.com> 2.3.14-1
- satellite-rules do not seem to be used, removing

* Thu Mar 12 2015 Tomas Lestach <tlestach@redhat.com> 2.3.13-1
- removing RHN::Cleansers
- removing RHN::Access and PXT::ACL
- remove apache PXT configuration
- no more pxt pages

* Mon Mar 09 2015 Tomas Lestach <tlestach@redhat.com> 2.3.12-1
- stop using permission.pxt error document

* Thu Mar 05 2015 Tomas Lestach <tlestach@redhat.com> 2.3.11-1
- we do not have /var/www/html/network anymore

* Wed Mar 04 2015 Tomas Lestach <tlestach@redhat.com> 2.3.10-1
- removing unused pxt error pages
- removing packages/package_map_raw as it isn't referenced
- removing packages/view_readme as it isn't referenced

* Tue Mar 03 2015 Tomas Lestach <tlestach@redhat.com> 2.3.9-1
- start using the jsp error pages

* Fri Feb 27 2015 Tomas Lestach <tlestach@redhat.com> 2.3.8-1
- removing system_list/proxy.pxt as it isn't referenced anymore
- remove unused raw_script_output.txt

* Wed Feb 25 2015 Tomas Lestach <tlestach@redhat.com> 2.3.7-1
- removing subscribers.pxt as it was ported to java

* Tue Feb 24 2015 Tomas Lestach <tlestach@redhat.com> 2.3.6-1
- removing activation.pxt as it was ported to java

* Mon Feb 16 2015 Stephen Herr <sherr@redhat.com> 2.3.5-1
- spacewalk-config etc/rhn-satellite-httpd dir no longer exists after
  monitoring removal

* Mon Feb 16 2015 Stephen Herr <sherr@redhat.com> 2.3.4-1
- remove monitoring artefacts from spacewalk-config

* Tue Jan 13 2015 Matej Kollar <mkollar@redhat.com> 2.3.3-1
- Getting rid of trailing spaces in Perl
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Wed Dec 17 2014 Stephen Herr <sherr@redhat.com> 2.3.2-1
- drop monitoring code and monitoring schema
- 1170064 - equality is too strict

* Thu Dec 11 2014 Matej Kollar <mkollar@redhat.com> 2.3.1-1
- 1020952 - Include SSL configuration in setup
- Bumping package versions for 2.3.

* Tue Jul 08 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.2-1
- make JSESSIONID cookie httpOnly

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.1-1
- spec file polish

* Mon Jan 06 2014 Tomas Lestach <tlestach@redhat.com> 2.1.5-1
- rewrite Login2.do to Login.do page

* Thu Dec 19 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.4-1
- updated links to system group delete page

* Mon Dec 16 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.3-1
- Remove groups/errata_list.pxt
- system group edit properties - linking + cleanup
- system group details - linking + cleanup

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.2-1
- Updating rhn.conf man page for taskomatic.maxmemory option
- Changes to rhn.conf man page for ISS settings

* Thu Aug 22 2013 Tomas Lestach <tlestach@redhat.com> 2.1.1-1
- update webapp-keyring.gpg with pgp public key valid until 2023-02-05
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Tue Jul 09 2013 Tomas Lestach <tlestach@redhat.com> 1.10.6-1
- clean up managers.pxt

* Tue Jul 02 2013 Stephen Herr <sherr@redhat.com> 1.10.5-1
- 977878 - move iss parent / ca_cert configs into database

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.4-1
- rebrading RHN Satellite to Red Hat Satellite

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.3-1
- misc branding clean up

* Wed Apr 17 2013 Jan Pazdziora 1.10.2-1
- moving taskomatic.channel_repodata_workers config default from backend to
  java
- Added taskomatic.channel_repodata_workers to rhn.conf man page

* Wed Mar 27 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.1-1
- downloading packages for kickstart via java
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Thu Feb 28 2013 Jan Pazdziora 1.9.8-1
- Removing the dsn parameter from initDB, removing support for --db option.

* Fri Feb 15 2013 Tomas Lestach <tlestach@redhat.com> 1.9.7-1
- fix typo

* Tue Feb 12 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.6-1
- removed unused pxt page

* Fri Feb 08 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.5-1
- don't overload standard valid-user keyword
- make pxt ACL work in apache 2.4
- put requires for single file/directory to one line
- merged .htaccess to main httpd configuration

* Fri Feb 01 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.4-1
- made apache 2.4 happy with our acl auth definitions

* Thu Jan 31 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.3-1
- RewriteLock is no longer valid in apache 2.4
- removed no longer necessary directory definitions

* Tue Jan 22 2013 Jan Pazdziora 1.9.2-1
- We no longer ship /var/www/html/applications.

* Fri Nov 09 2012 Jan Pazdziora 1.9.1-1
- Address Permission Error on proxy details page.

* Wed Oct 31 2012 Jan Pazdziora 1.8.6-1
- Advertise the www.spacewalkproject.org.

* Mon Oct 29 2012 Jan Pazdziora 1.8.5-1
- We just assume Apache 2.2 these days, no need to check.
- All the Java requests end up at /rhn, no need to have separate .do and .jsp
  rewrites.
- 663248 - enable connection polling to tomcat.
- 663250 - set the Expires header for static content.

* Fri Oct 12 2012 Jan Pazdziora 1.8.4-1
- The /network/systems/details/kickstart/* is not used for a long time.

* Mon Aug 06 2012 Jan Pazdziora 1.8.3-1
- 844474 - add a comment about the server.satellite.http_proxy format.

* Wed Jun 27 2012 Jan Pazdziora 1.8.2-1
- The delete_confirm.pxt was replaced by DeleteConfirm.do.
- %%defattr is not needed since rpm 4.4

* Wed Mar 21 2012 Jan Pazdziora 1.8.1-1
- Reverting removal of traceback_mail.

* Tue Jan 31 2012 Jan Pazdziora 1.7.2-1
- Removing the web.debug_disable_database option -- it is not supported beyond
  RHN::DB anyway.

* Mon Jan 23 2012 Tomas Lestach <tlestach@redhat.com> 1.7.1-1
- increase ProxyTimeout because of long lasting API calls (tlestach@redhat.com)
- Bumping package versions for 1.7. (mzazrivec@redhat.com)

* Fri Nov 04 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.4-1
- 679335 - remove osa-dispatcher login credentials from rhn.conf

* Mon Oct 03 2011 Jan Pazdziora 1.6.3-1
- 621531 - fixing rhn.conf(5) man page.

* Fri Sep 16 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.2-1
- 713477 - made session cookies httponly

* Fri Aug 05 2011 Jan Pazdziora 1.6.1-1
- Make monitoring .cgi live again in the /cgi-bin/ namespace, fixing scout
  config push.

* Tue Jun 21 2011 Jan Pazdziora 1.5.5-1
- Silence chgrp/chmod, during first installation.

* Tue May 17 2011 Miroslav Suchý 1.5.4-1
- migrate .htaccess files to apache core configuration

* Tue May 03 2011 Jan Pazdziora 1.5.3-1
- We restrict access to some files that were too open in the past (some of them
  are not tracked by rpm).

* Thu Apr 21 2011 Jan Pazdziora 1.5.2-1
- Explicitly setting attributes of .../rhn-satellite-prep/etc/rhn.

* Tue Apr 12 2011 Jan Pazdziora 1.5.1-1
- CVE-2009-0788 / 491365 - no proxying is needed, just rewrite before ajp kicks in.

* Mon Apr 04 2011 Miroslav Suchý 1.4.3-1
- Added web.maximum_config_file_size option in man page for rhn.conf
  (mmello@redhat.com)

* Tue Mar 01 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.2-1
- Fixed some typos in man page for rhn.conf (mmello@redhat.com)
- Added on rhn.conf man page a bunch of new options and fixed some typos.
  (mmello@redhat.com)
- use better macro (msuchy@redhat.com)

* Mon Feb 28 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.1-1
- Modifing SPEC file including new man page
- Adding usr/share/man/man5/rhn.conf.5 manpage file (mmello@redhat.com)

* Sat Nov 20 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.1-1
- 474591 - move web data to /usr/share/nocpulse (msuchy@redhat.com)
- Bumping package versions for 1.3. (jpazdziora@redhat.com)

* Mon Nov 15 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.7-1
- 491331 - move /etc/rhn/satellite-httpd/conf/startup.pl
  to /usr/share/rhn/startup.pl

* Thu Nov 04 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.6-1
- 491331 move /etc/rhn/satellite-httpd/conf/satidmap.pl to
  /usr/share/rhn/satidmap.pl
- 491331 - do not list duplicates in %%files
- 491331 - require openssl
- 491331 - we should own /var/lib/cobbler
- 491331 - _sharedstatedir expands on el5 to /usr/com instead of expected
  /var/lib/ as on fedora or EL6
- 491331 - %%description should end with a dot (and could be a little more
  elaborate)
- 491331 - use %%global instead of %%define
- 491331 - use correct buildroot

* Wed Nov 03 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.5-1
- code cleanup - no one use Red Hat Enterprise Linux 2AS
- 491331 - move /etc/sysconfig/rhn-satellite-prep to /var/lib/rhn/rhn-
  satellite-prep

* Fri Oct 29 2010 Jan Pazdziora 1.2.4-1
- removed unused Spacewalk (Certificate Signing Key) <jmrodri@nc.rr.com> key
  from keyring (michael.mraka@redhat.com)

* Mon Oct 25 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.3-1
- fixing changelog entry

* Mon Sep 06 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.2-1
- removed unneeded oracle settings from httpd environment

* Wed Sep 01 2010 Jan Pazdziora 1.2.1-1
- As 00-spacewalk-mod_jk.conf which referenced workers.properties is gone,
  remove it now as well.
- The 00-spacewalk-mod_jk.conf is no more needed as all Spacewalks are now on
  Apache 2.2+.
- 573788 - ks handler is no longer needed
- schedule SatelliteCertificateCheck (tlestach@redhat.com)
- bumping package versions for 1.2 (mzazrivec@redhat.com)

* Fri Jul 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.7-1
- renamed db_sid to SID db_name to be consistent with PostgreSQL

* Fri Jul 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.6-1
- renamed db_sid to SID db_name to be consistent with PostgreSQL

* Fri Jul 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.5-1
- default_db has been obsoleted
- hibernate.connection.url is now created dynamicaly from db_* variables
- let's use unified db_{user,password} instead of hibernate.connection.*
- 596112 - restrict /server-status to 127.0.0.1

* Wed Jul 14 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.4-1
- tomcat files have been removed

* Mon Jun 21 2010 Jan Pazdziora 1.1.3-1
- The satellite-httpd service is no more.

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.2-1
- bumping spec files to 1.1 packages

