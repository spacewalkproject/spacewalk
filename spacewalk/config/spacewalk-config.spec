%{!?__redhat_release:%define __redhat_release 2.1AS}

Name: spacewalk-config
Summary: Spacewalk Configuration
Version: 0.5.4
Release: 1%{?dist}
# This src.rpm is canonical upstream.
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd spacewalk
# make srpm TAG=%{name}-%{version}-%{release}
URL: http://fedorahosted.org/spacewalk
Source0: %{name}-%{version}.tar.gz
License: GPLv2
Group: Applications/System
BuildRoot: %{_tmppath}/%{name}-root
Buildarch: noarch
Requires: perl(Satcon)
Requires: perl(Apache::DBI)
Obsoletes: rhn-satellite-config < 5.3.0
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts

%define prepdir /etc/sysconfig/rhn-satellite-prep

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

ln -s ../../../httpd/conf/ssl.key/server.key $RPM_BUILD_ROOT/etc/pki/tls/private/server.key
ln -s ../../../httpd/conf/ssl.crt/server.crt $RPM_BUILD_ROOT/etc/pki/tls/certs/server.crt

tar -C $RPM_BUILD_ROOT%{prepdir} -cf - etc \
     --exclude=etc/tomcat5 \
     --exclude=etc/jabberd \
     | tar -C $RPM_BUILD_ROOT -xvf -


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0644,root,root,0755)
%attr(0755,root,root) %{prepdir}/etc/tomcat5
%attr(0755,root,root) /etc/rhn/satellite-httpd/conf/satidmap.pl
%attr(0755,root,root) /etc/rhn/satellite-httpd/conf/startup.pl
%config(noreplace) /etc/rhn/satellite-httpd/conf/rhn/rhn_monitoring.conf
%config(noreplace) /etc/httpd/conf.d/zz-spacewalk-www.conf
%config(noreplace) /etc/rhn/satellite-httpd/conf/workers.properties
%config(noreplace) /etc/webapp-keyring.gpg
%config(noreplace) /var/lib/cobbler/kickstarts/spacewalk-sample.ks
%config(noreplace) /var/lib/cobbler/snippets/spacewalk_file_preservation
%dir /etc/rhn
%dir /etc/rhn/satellite-httpd
%dir /etc/rhn/satellite-httpd/conf
%dir /etc/rhn/satellite-httpd/conf/rhn
%ghost %config(missingok,noreplace) %verify(not md5 size mtime) /etc/rhn/cluster.ini
%ghost %config(missingok,noreplace) %verify(not md5 size mtime) /etc/rhn/rhn.conf
%ghost %config(missingok,noreplace) %verify(not md5 size mtime) /etc/pki/tls/private/server.key
%ghost %config(missingok,noreplace) %verify(not md5 size mtime) /etc/pki/tls/certs/server.crt
# NOTE: If if you change these, you need to make a corresponding change in
# spacewalk/install/Spacewalk-Setup/bin/spacewalk-setup
%config /etc/pki/tls/private/spacewalk.key
%config /etc/pki/tls/certs/spacewalk.crt
/etc/satname
%{prepdir}

%pre
# This section is needed here because previous versions of spacewalk-config
# (and rhn-satellite-config) "owned" the satellite-httpd service. We need
# to keep this section here indefinitely, because Satellite 5.2 could
# be upgraded directly to our version of Spacewalk.
if [ -f /etc/init.d/satellite-httpd ] ; then
    /sbin/service satellite-httpd stop >/dev/null 2>&1
    /sbin/chkconfig --del satellite-httpd
    perl -i -ne 'print unless /satellite-httpd\.pid/' /etc/logrotate.d/httpd
fi


%post

cat >> /etc/sysconfig/httpd <<EOF
export ORACLE_HOME=/opt/oracle
export NLS_LANG=english.AL32UTF8
EOF

%changelog
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
