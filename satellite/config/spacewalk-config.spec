%{!?__redhat_release:%define __redhat_release 2.1AS}

Name: spacewalk-config
Summary: Spacewalk Configuration
Version: 0.4.9
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

ln -s ../../httpd/logs $RPM_BUILD_ROOT/etc/rhn/satellite-httpd/logs
ln -s ../../httpd/run $RPM_BUILD_ROOT/etc/rhn/satellite-httpd/run
ln -s ../../httpd/modules $RPM_BUILD_ROOT/etc/rhn/satellite-httpd/modules
ln -s ../../../httpd/conf/magic $RPM_BUILD_ROOT/etc/rhn/satellite-httpd/conf/magic
ln -s ../../../httpd/conf/ssl.crt $RPM_BUILD_ROOT/etc/rhn/satellite-httpd/conf/ssl.crt
ln -s ../../../httpd/conf/ssl.key $RPM_BUILD_ROOT/etc/rhn/satellite-httpd/conf/ssl.key

tar -C $RPM_BUILD_ROOT%{prepdir} -cf - etc \
     --exclude=etc/tomcat5 \
     --exclude=etc/jabberd \
     | tar -C $RPM_BUILD_ROOT -xvf -

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0644,root,root,0755)
%attr(0755,root,root) %{prepdir}/etc/tomcat5
%attr(0755,root,root) /etc/init.d/satellite-httpd
%attr(0755,root,root) /etc/rhn/satellite-httpd/conf/satidmap.pl
%attr(0755,root,root) /etc/rhn/satellite-httpd/conf/startup.pl
%config(noreplace) /etc/httpd/conf.d/satellite-installed.conf
%config(noreplace) /etc/rhn/satellite-httpd/conf/httpd.conf
%config(noreplace) /etc/rhn/satellite-httpd/conf/rhn/rhn_monitoring.conf
%config(noreplace) /etc/rhn/satellite-httpd/conf/rhnweb.conf
%config(noreplace) /etc/rhn/satellite-httpd/conf/ssl.conf
%config(noreplace) /etc/rhn/satellite-httpd/conf/workers.properties
%config(noreplace) /etc/webapp-keyring.gpg
%dir /etc/rhn
%dir /etc/rhn/satellite-httpd
%dir /etc/rhn/satellite-httpd/conf
%dir /etc/rhn/satellite-httpd/conf/rhn
%ghost %config(missingok,noreplace) %verify(not md5 size mtime) /etc/rhn/cluster.ini
%ghost %config(missingok,noreplace) %verify(not md5 size mtime) /etc/rhn/rhn.conf
%ghost %config(missingok,noreplace) %verify(not md5 size mtime) /etc/sysconfig/satellite-httpd
/etc/rhn/satellite-httpd/conf/magic
/etc/rhn/satellite-httpd/conf/ssl.crt
/etc/rhn/satellite-httpd/conf/ssl.key
/etc/rhn/satellite-httpd/logs
/etc/rhn/satellite-httpd/modules
/etc/rhn/satellite-httpd/run
/etc/satname
%{prepdir}


%preun
if [ $1 = 0 ] ; then
    /sbin/service satellite-httpd stop >/dev/null 2>&1
    /sbin/chkconfig --del satellite-httpd
fi

%postun
if [ "x$1" == "x0" ] ; then
    perl -i -ne 'print unless /satellite-httpd\.pid/' /etc/logrotate.d/httpd
fi

%post
# This adds the proper /etc/rc*.d links for the script
/sbin/chkconfig --add satellite-httpd

perl -i -ne 'print unless /satellite-httpd\.pid/;
    if (/postrotate/) { print qq!\t/bin/kill -HUP `cat /var/run/satellite-httpd.pid 2>/dev/null` 2> /dev/null || true\n! }' \
        /etc/logrotate.d/httpd

%changelog
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
