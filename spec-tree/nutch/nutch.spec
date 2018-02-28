Name: nutch
Version: 1.0
Release: 0.19.20081201040121nightly%{?dist}
Summary: Open source web-search software

License: ASL 2.0
URL: http://lucene.apache.org/nutch/index.html
Source0: http://hudson.zones.apache.org/hudson/job/Nutch-trunk/647/artifact/trunk/build/nutch-2008-12-01_04-01-21.tar.gz
BuildArch: noarch
Requires: java-headless >= 1:1.8.0

%description
Nutch is open source web-search software. It builds on Lucene Java,
adding web-specifics, such as a crawler, a link-graph database, parsers for
HTML and other document formats, etc.

%prep
%setup -q -n nutch-2008-12-01_04-01-21

%build
#removing the hadoop JNI code
rm -fr ./lib/native/Linux-amd64-64
rm -fr ./lib/native/Linux-i386-32
sed -i 's|^hadoop.log.dir=.*$|hadoop.log.dir=/var/log/rhn/search|' conf/log4j.properties

%install
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/nutch
install -m 644 nutch-2008-12-01_04-01-21.jar $RPM_BUILD_ROOT%{_prefix}/share/nutch
install -m 644 default.properties $RPM_BUILD_ROOT%{_prefix}/share/nutch
cp -pR bin $RPM_BUILD_ROOT%{_prefix}/share/nutch
chmod -R 777 $RPM_BUILD_ROOT%{_prefix}/share/nutch/bin
cp -pR conf $RPM_BUILD_ROOT%{_prefix}/share/nutch
cp -pR lib $RPM_BUILD_ROOT%{_prefix}/share/nutch
cp -pR plugins $RPM_BUILD_ROOT%{_prefix}/share/nutch
ln -s %{_prefix}/share/nutch/nutch-2008-12-01_04-01-21.jar $RPM_BUILD_ROOT%{_prefix}/share/nutch/lib
install -d -m 755 $RPM_BUILD_ROOT%{_var}/log/rhn/search

%clean


%files
%{_prefix}/share/nutch/*
%attr(755,root,root) %{_prefix}/share/nutch/bin/*
%{_var}/log/rhn/search


%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 1.0-0.19.20081201040121nightly
- removed %%%%defattr from specfile
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Mon Oct 09 2017 Michael Mraka <michael.mraka@redhat.com> 1.0-0.18.20081201040121nightly
- 1483503 - move hadoop logs to /var/log

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 1.0-0.17.20081201040121nightly
- recompile all packages with the same (latest) version of java
- fixed tito build warning
- replace legacy name of Tagger with new one

* Mon Jan 21 2013 Michael Mraka <michael.mraka@redhat.com> 1.0-0.16.20081201040121nightly
- rebuild nutch from git

* Wed Oct 10 2012 Stephen Herr <sherr@redhat.com> 1.0-0.15.20081201040121nightly
- Fixing nutch buildroot symlink issue

* Wed Oct 10 2012 Stephen Herr <sherr@redhat.com> 1.0-0.14.20081201040121nightly
- We also need the nutch lib directory to contian the nutch jar

* Wed Oct 10 2012 Stephen Herr <sherr@redhat.com> 1.0-0.13.20081201040121nightly
- updating bin directory permissions

* Tue Oct 09 2012 Stephen Herr <sherr@redhat.com> 1.0-0.12.20081201040121nightly
- fixing nutch executable permissions

* Mon Oct 08 2012 Michael Mraka <michael.mraka@redhat.com> 1.0-0.11.20081201040121nightly
- we need scripts in bin for spacewalk-doc-indexes

* Thu Apr 21 2011 Michael Mraka <michael.mraka@redhat.com> 1.0-0.10.20081201040121nightly
- shrinking nutch rpm from 70M to 22M

* Wed Nov 24 2010 Lukas Zapletal 1.0-0.9.20081201040121nightly
- Correcting URL of the tarball in Nutch pkg (lzap+git@redhat.com)

* Fri Nov 19 2010 Lukas Zapletal 1.0-0.8.20081201040121nightly
- Removing unnecessary files
- Erasing empty lines

* Thu Nov 18 2010 Lukas Zapletal <lzap+rpm@redhat.com> 1.0-0.7.20081201040121nightly
- dropping unnecessary files

* Thu Jun 25 2009 John Matthews <jmatthew@redhat.com> 1.0-0.6.20081201040121nightly
- rebuild

* Wed Feb 25 2009 Devan Goodwin <dgoodwin@redhat.com> 1.0-0.5.20081201040121nightly
- Rebuild for new build tools.

* Fri Dec 19 2008 John Matthews <jmatthews@redhat.com> 1.0-0.4.20081201040121nightly
- initial
