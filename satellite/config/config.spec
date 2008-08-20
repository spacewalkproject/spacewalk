%{!?__redhat_release:%define __redhat_release 2.1AS}

Name: spacewalk-config
Summary: Spacewalk Configuration
Version: 0.1
Release: 1%{?dist}
Source0: %{name}-%{version}.tar.gz
License: GPLv2
Group: RHN/Server
BuildRoot: %{_tmppath}/%{name}-root
Buildarch: noarch
Requires: perl(Satcon)
Requires: perl(Apache::DBI)

%define prepdir /etc/sysconfig/rhn-satellite-prep

%description
Spacewalk Configuration Templates

%prep
%setup -q
echo "%{name} %{version}" > version

%build
make -f Makefile.config

%install
rm -Rf $RPM_BUILD_ROOT
make -f Makefile.config install PREFIX=$RPM_BUILD_ROOT DEST=%{prepdir}

find $RPM_BUILD_ROOT -type f |
    egrep -v "/etc/init.d/satellite-httpd" |
    sed -e "s@^$RPM_BUILD_ROOT@@g" > config-filelist

find $RPM_BUILD_ROOT%{prepdir}/etc -type f |
    egrep -v "/etc/rhn/satellite-httpd/conf/httpd.conf" |
    egrep -v "jabberd" |
    egrep -v "/etc/tomcat5/tomcat5.conf" |
    egrep -v "/etc/init.d/satellite-httpd" |
    sed -e "s@^$RPM_BUILD_ROOT%{prepdir}/@%ghost %config(missingok,noreplace) %verify(not md5 size mtime) /@g" >> config-filelist

# debugging
cat config-filelist

mkdir -p $RPM_BUILD_ROOT/etc
cp -apv $RPM_BUILD_ROOT%{prepdir}/etc $RPM_BUILD_ROOT
rm $RPM_BUILD_ROOT/etc/rhn/satellite-httpd/conf/httpd.conf
rm -Rf $RPM_BUILD_ROOT/etc/jabberd
rm $RPM_BUILD_ROOT/etc/tomcat5/tomcat5.conf

# make rhn.conf zero-length so it doesn't conflict with the file from rhns
echo -n > $RPM_BUILD_ROOT/etc/rhn/rhn.conf

ln -s ../../httpd/logs $RPM_BUILD_ROOT/etc/rhn/satellite-httpd/logs
ln -s ../../httpd/run $RPM_BUILD_ROOT/etc/rhn/satellite-httpd/run
ln -s ../../httpd/modules $RPM_BUILD_ROOT/etc/rhn/satellite-httpd/modules
ln -s ../../../httpd/conf/magic $RPM_BUILD_ROOT/etc/rhn/satellite-httpd/conf/magic
ln -s ../../../httpd/conf/ssl.crt $RPM_BUILD_ROOT/etc/rhn/satellite-httpd/conf/ssl.crt
ln -s ../../../httpd/conf/ssl.key $RPM_BUILD_ROOT/etc/rhn/satellite-httpd/conf/ssl.key


%clean
rm -rf $RPM_BUILD_ROOT

%files -f config-filelist
%defattr(-,root,root)
%attr(0775,root,root) %{prepdir}/etc/tomcat5
%attr(0775,root,root) /etc/init.d/satellite-httpd
%dir %{prepdir}
%attr(0775,root,root) %{prepdir}/etc/init.d/satellite-httpd
/etc/rhn/satellite-httpd/modules
/etc/rhn/satellite-httpd/logs
/etc/rhn/satellite-httpd/run
/etc/rhn/satellite-httpd/conf/magic
/etc/rhn/satellite-httpd/conf/ssl.crt
/etc/rhn/satellite-httpd/conf/ssl.key

%postun
if [ "x$1" == "x0" ] ; then
	perl -i -ne 'print unless /satellite-httpd\.pid/' /etc/logrotate.d/httpd
fi

%post

perl -i -ne 'print unless /satellite-httpd\.pid/;
	if (/postrotate/) { print qq!\t/bin/kill -HUP `cat /var/run/satellite-httpd.pid 2>/dev/null` 2> /dev/null || true\n! }' \
		/etc/logrotate.d/httpd

%changelog
* Tue Aug 19 2008 Mike McCune 0.1-2
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
- exclude sudoers from %ghost list
- add rhn_monitoring.conf only for RHEL3

* Tue Jul  6 2004 Chip Turner <cturner@redhat.com>
- add %ghost to the files we'll override

* Tue Aug 20 2002 Cristian Gafton <gafton@redhat.com>
- port to the new build system
