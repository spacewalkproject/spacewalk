%{!?__redhat_release:%define __redhat_release 2.1AS}

Name: spacewalk-config
Summary: Spacewalk Configuration
Version: 0.8.2
Release: 1%{?dist}
URL: http://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
License: GPLv2
Group: Applications/System
BuildRoot: %{_tmppath}/%{name}-root
Buildarch: noarch
Requires: perl(Satcon)
Requires: perl(Apache::DBI)
Obsoletes: rhn-satellite-config < 5.3.0
Provides: rhn-satellite-config = 5.3.0
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts
# We need package httpd to be able to assign group apache in files section
Requires: httpd

%define prepdir %{_sysconfdir}/sysconfig/rhn-satellite-prep

%description
Spacewalk Configuration Templates

%prep
%setup -q
echo "%{name} %{version}" > version

%build

%install
rm -Rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT
mv etc $RPM_BUILD_ROOT/
mv var $RPM_BUILD_ROOT/

tar -C $RPM_BUILD_ROOT%{prepdir} -cf - etc \
     --exclude=etc/tomcat5 \
     | tar -C $RPM_BUILD_ROOT -xvf -

echo "" > $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/rhn.conf

find $RPM_BUILD_ROOT -name '*.symlink' | \
	while read filename ; do linkname=${filename%.symlink} ; \
		target=`sed -s 's/^Link to //' $filename` ; \
		ln -sf $target $linkname ; \
		rm -f $filename ; \
	done

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{prepdir}%{_sysconfdir}/tomcat5
%attr(0755,root,root) %{_sysconfdir}/rhn/satellite-httpd/conf/satidmap.pl
%attr(0755,root,root) %{_sysconfdir}/rhn/satellite-httpd/conf/startup.pl
%config(noreplace) %{_sysconfdir}/rhn/satellite-httpd/conf/rhn/rhn_monitoring.conf
%config(noreplace) %{_sysconfdir}/httpd/conf.d/zz-spacewalk-www.conf
%config(noreplace) %{_sysconfdir}/httpd/conf.d/00-spacewalk-mod_jk.conf
%config(noreplace) %{_sysconfdir}/rhn/satellite-httpd/conf/workers.properties
%config(noreplace) %{_sysconfdir}/webapp-keyring.gpg
%config(noreplace) %{_var}/lib/cobbler/kickstarts/spacewalk-sample.ks
%config(noreplace) %{_var}/lib/cobbler/snippets/spacewalk_file_preservation
%attr(0750,root,apache) %dir %{_sysconfdir}/rhn
%dir %{_sysconfdir}/rhn/satellite-httpd
%dir %{_sysconfdir}/rhn/satellite-httpd/conf
%dir %{_sysconfdir}/rhn/satellite-httpd/conf/rhn
%ghost %config(missingok,noreplace) %verify(not md5 size mtime) %{_sysconfdir}/rhn/cluster.ini
%attr(0640,root,apache) %config(missingok,noreplace) %verify(not md5 size mtime) %{_sysconfdir}/rhn/rhn.conf
# NOTE: If if you change these, you need to make a corresponding change in
# spacewalk/install/Spacewalk-Setup/bin/spacewalk-setup
%config(noreplace) %{_sysconfdir}/pki/tls/private/spacewalk.key
%config(noreplace) %{_sysconfdir}/pki/tls/certs/spacewalk.crt
%config(noreplace) %{_sysconfdir}/satname
%{prepdir}
%doc LICENSE

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


%post

cat >> %{_sysconfdir}/sysconfig/httpd <<EOF
export ORACLE_HOME=/opt/oracle
export NLS_LANG=english.AL32UTF8
EOF


%changelog
* Thu Feb 04 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.2-1
- Removal of RHN::TokenGen::Local
- 479911 - removing duplicate rewrites and consolidating to a single location

* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- rebuild for spacewalk 0.8

* Wed Nov 25 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.2-1
- Create the symlinks in .spec, based on .symlink "templates". (jpazdziora@redhat.com)

* Fri Aug 28 2009 Milan Zazrivec <mzazrivec@redhat.com> 0.7.1-1
- No need to pre-require jabberd (mzazrivec@redhat.com)
- removed all jabberd prep config files (mzazrivec@redhat.com)
- bumping versions to 0.7.0 (jmatthew@redhat.com)

* Wed Jul 29 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.13-1
- Add router.xml and router-users.xml to jabberd configs we deploy.
  (dgoodwin@redhat.com)

* Tue Jul 28 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.12-1
- Better jabberd password replacement for upgrades. (dgoodwin@redhat.com)

* Mon Jul 27 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.11-1
- Populate Hibernate settings in rhn.conf for both Oracle and PostgreSQL.
  (dgoodwin@redhat.com)
- Add note on rhn.conf default_db being only used for Oracle.
  (dgoodwin@redhat.com)

* Mon Jul 27 2009 John Matthews <jmatthew@redhat.com> 0.6.10-1
- 508187 - Fix jabberd configs on x86_64. (dgoodwin@redhat.com)
- 493060 - do not send email "RHN Monitoring Scout started" by default
  (msuchy@redhat.com)

* Tue Jul 21 2009 John Matthews <jmatthew@redhat.com> 0.6.9-1
- adding disable_iss flag to rhn.conf (pkilambi@redhat.com)
- 511100 - Fixed upgrade scripts to include cobbler.host (paji@redhat.com)

* Thu Jun 25 2009 John Matthews <jmatthew@redhat.com> 0.6.8-1
- Fix mod_jk failure to load. (dgoodwin@redhat.com)

* Wed Jun 24 2009 John Matthews <jmatthew@redhat.com> 0.6.7-1
- 507679 - Added custom server.xml to force UTF8 encoding of GET parameters in tomcat

* Mon May 18 2009 Mike McCune <mmccune@gmail.com> 0.6.5-1
- 496104 - need to make the regexes for the rewrites a bit more flexible
  (mmccune@gmail.com)

* Wed Apr 29 2009 Jan Pazdziora 0.6.4-1
- Require httpd, we need the apache group for %files

* Thu Apr 16 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.3-1
- 485355 - change perms of /etc/rhn/rhn.conf & /etc/rhn dir

* Wed Apr 15 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.2-1
- 495722 - fixing issue where /ty/TOKEn wasnt being rendered properly
  (jsherril@redhat.com)

* Tue Apr 14 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.1-1
- config: Remove duplicate symlinks to httpd crt and key. (dgoodwin@redhat.com)
- 491668 - update Spacewalk Apache conf to support .htaccess
  (bbuckingham@redhat.com)
- 487563 - adding enable_snapshots config value to default rhn.conf as per docs
  (jsherril@redhat.com)

* Mon Mar 30 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.9-1
- 487618 - fixing jabberd to use mysql db by default instead of sqlite

* Tue Mar 24 2009 Dennis Gilmore <dennis@ausil.us> 0.5.8-1
- Requires(pre) jabberd so we can set the password in %%post

* Fri Mar 20 2009 Miroslav Suchy <msuchy@redhat.com> 0.5.7-1
- edit the spec for Fedora

* Thu Mar 19 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.6-1
- 485532 - removing Apache2::SizeLimit instances and manage processes by requestlimit.

* Tue Mar 03 2009 Dave Parker <dparker@redhat.com> 0.5.5-1
- 483802 Directory /etc/rhn owned by two packages, group does not match

* Wed Feb 25 2009 Jan Pazdziora 0.5.4-1
- load modules/mod_version.so, for Fedora 10

* Thu Feb 19 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.3-1
- resolving conflicts
- adding a config variable to define the repomd cache mount point

* Mon Feb  2 2009 Jan Pazdziora 0.5.2-1
- 482838 - remove satellite-httpd removal from uninstall scripts

* Mon Jan 19 2009 Jan Pazdziora 0.5.1-1
- rebuilt for 0.5, after repository reorg

* Wed Jan 14 2009 Mike McCune <mmccune@gmail.com> 0.4.24-1
- 480095 - old package name for taskomatic

* Sat Jan 10 2009 Milan Zazrivec 0.4.23-1
- update rhn_monitoring.conf to use /var/www for web content

* Tue Jan 06 2009 Dave Parker <dparker@redhat.com> 0.4.22-1
- remove satellite-httpd, instead use stock httpd configuration

* Mon Dec 22 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.21-1
- product_name moved to spacewalk-branding

* Fri Dec 19 2008 Dave Parker <dparker@redhat.com> 0.4.11-1
- added file preservation snippet to cobbler
- added sample spacewalk kickstart template to cobbler

* Fri Dec 19 2008 Dave Parker <dparker@redhat.com> 0.4.10-1
- reconfigured spacewalk to use stock apache installation rather than satellite-httpd

* Fri Dec 19 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.10-1
- fixed list of files which conflict with jabberd

* Tue Dec 16 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.9-1
- fixed %%file attributes and permissions

* Fri Dec 12 2008 Jan Pazdziora 0.4.7-1
- addressed rpmlint's error and warnings
- fixed 474306 - added directories to %%files
- fixed 461162 - configs for cobbler

* Tue Dec  9 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.6-1
- fixed Obsoletes: rhns-* < 5.3.0

* Fri Dec  5 2008 Miroslav Suchý <msuchy@redhat.com> 0.4.5-1
- 474591 - move web data to /usr/share/nocpulse

* Tue Nov 25 2008 Miroslav Suchý <msuchy@redhat.com> 0.4.2-1
- Replace use of perl-crypt-OpenPGP and perl-crypt-RIPEMD160 with gpg system call.
- 461162 - making kickstart handler a bit shorter

* Tue Oct 21 2008 Michael Mraka <michael.mraka@redhat.com> 0.3.3-1
- resolves #467717 - fixed sysvinit scripts

* Mon Oct 20 2008 Jan Pazdziora 0.3.2-1
- bugzilla 467704 - move mod_rewrite's lock file from /tmp to run/

* Tue Sep 23 2008 Milan Zazrivec 0.3.1-1
- fixed package obsoletes

* Tue Sep  2 2008 Milan Zazrivec 0.2.1-1
- bumping version for tag-release

* Tue Aug 19 2008 Mike McCune
- renamed to spacewalk-config

* Mon Aug  4 2008 Jan Pazdziora 0.1-1
- removed version and sources files

* Wed Jun  4 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-3
- fixed file permissions

* Fri May 30 2008 Jan Pazdziora 5.2.0-2
- changes to support RHEL 5
- rebuild in dist-cvs

* Tue Sep  4 2007 Jan Pazdziora <jpazdziora@redhat.com>
- no longer need special case for apache.no_ld_preload

* Mon Oct 18 2004 Robin Norwood <rnorwood@redhat.com>
- remove sudoers file entirely - install.sh handles it now

* Thu Jul 15 2004 Robin Norwood <rnorwood@redhat.com>
- exclude sudoers from %%ghost list
- add rhn_monitoring.conf only for RHEL3

* Tue Jul  6 2004 Chip Turner <cturner@redhat.com>
- add %%ghost to the files we'll override

* Tue Aug 20 2002 Cristian Gafton <gafton@redhat.com>
- port to the new build system
