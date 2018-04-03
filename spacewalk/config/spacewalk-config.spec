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
Version: 2.9.0
Release: 1%{?dist}
URL: https://github.com/spacewalkproject/spacewalk
Source0: https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
License: GPLv2
Buildarch: noarch
Requires: perl(Satcon)
Obsoletes: rhn-satellite-config < 5.3.0
Provides: rhn-satellite-config = 5.3.0
%if 0%{?fedora} > 24
BuildRequires: perl-generators
%endif
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

%files
%attr(400,root,root) %config(noreplace) %{_sysconfdir}/rhn/spacewalk-repo-sync/uln.conf
%config(noreplace) %{apacheconfdir}/conf.d/zz-spacewalk-www.conf
%config(noreplace) %{_sysconfdir}/webapp-keyring.gpg
%attr(440,root,root) %config(noreplace) %{_sysconfdir}/sudoers.d/spacewalk
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
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.5-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Fri Jan 05 2018 Jiri Dostal <jdostal@redhat.com> 2.8.4-1
- Remove whitespace from rhn.conf

* Thu Jan 04 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.3-1
- Updated man page for rhn.conf file to include information on setting
  Satellite's SMTP server

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- purged changelog entries for Spacewalk 2.0 and older

* Tue Aug 22 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.1-1
- Corrected variables for Taskomatic memory in rhn.conf and added documentation
  for taskomatic.java.initmemory
- Bumping package versions for 2.8.

* Mon Jul 17 2017 Jan Dobes 2.7.3-1
- 1447296 - add package_import_skip_changelog option to speed reposync up

* Fri May 05 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.2-1
- move sudoers configuration to /etc/sudoers.d/spacewalk
- Use HTTPS in all Github links
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Mon Jan 23 2017 Jan Dobes 2.7.1-1
- Mandatory Perl build-requires added
  <https://fedoraproject.org/wiki/Changes/Build_Root_Without_Perl>
- Bumping package versions for 2.7.

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

