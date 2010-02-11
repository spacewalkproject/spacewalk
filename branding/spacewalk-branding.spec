Name:       spacewalk-branding
Version:    0.9.0
Release:    1%{?dist}
Summary:    Spacewalk branding data

Group:      Applications/Internet
License:    GPLv2
URL:        https://fedorahosted.org/spacewalk/
Source0:    %{name}-%{version}.tar.gz
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:  noarch

BuildRequires: java-devel >= 1.5.0

%description
Spacewalk specific branding, CSS, and images.

%prep
%setup -q

%build

javac java/code/src/com/redhat/rhn/branding/strings/StringPackage.java
rm -f java/code/src/com/redhat/rhn/branding/strings/StringPackage.java
jar -cf java-branding.jar -C java/code/src com

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}/%{_var}/www/html
install -d -m 755 %{buildroot}/%{_var}/www/html/nav
install -d -m 755 %{buildroot}%{_datadir}/spacewalk
install -d -m 755 %{buildroot}%{_datadir}/rhn/lib/
%if  0%{?rhel} && 0%{?rhel} < 6
install -d -m 755 %{buildroot}%{_var}/lib/tomcat5/webapps/rhn/WEB-INF/lib/
%else
install -d -m 755 %{buildroot}%{_var}/lib/tomcat6/webapps/rhn/WEB-INF/lib/
%endif
install -d -m 755 %{buildroot}/%{_sysconfdir}/rhn
install -d -m 755 %{buildroot}/%{_sysconfdir}/rhn/default
cp -R css %{buildroot}/%{_var}/www/html/
cp -R img %{buildroot}/%{_var}/www/html/
# Appplication expects two favicon's for some reason, copy it so there's just
# one in source:
cp img/favicon.ico %{buildroot}/%{_var}/www/html/
cp -R templates %{buildroot}/%{_var}/www/html/
cp -R styles %{buildroot}/%{_var}/www/html/nav/
cp -R setup  %{buildroot}%{_datadir}/spacewalk/
cp -R java-branding.jar %{buildroot}%{_datadir}/rhn/lib/
%if  0%{?rhel} && 0%{?rhel} < 6
ln -s %{_datadir}/rhn/lib/java-branding.jar %{buildroot}%{_var}/lib/tomcat5/webapps/rhn/WEB-INF/lib/java-branding.jar
%else
ln -s %{_datadir}/rhn/lib/java-branding.jar %{buildroot}%{_var}/lib/tomcat6/webapps/rhn/WEB-INF/lib/java-branding.jar
%endif
cp conf/rhn_docs.conf %{buildroot}/%{_sysconfdir}/rhn/default/rhn_docs.conf

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%dir /%{_var}/www/html/css
/%{_var}/www/html/css/*
%dir /%{_var}/www/html/img
/%{_var}/www/html/img/*
/%{_var}/www/html/favicon.ico
%dir /%{_var}/www/html/templates
/%{_var}/www/html/templates/*
/%{_var}/www/html/templates/.htaccess
%dir /%{_var}/www/html/nav/styles
/%{_var}/www/html/nav/styles/*
%{_datadir}/spacewalk/
%{_datadir}/rhn/lib/java-branding.jar
%{_var}/lib/tomcat5/webapps/rhn/WEB-INF/lib/java-branding.jar
%{_sysconfdir}/rhn/default/rhn_docs.conf


%changelog
* Fri Jan 29 2010 Miroslav Suchý <msuchy@redhat.com> 0.8.2-1
- upadating spacewalk cert (jsherril@redhat.com)

* Fri Jan 08 2010 Jan Pazdziora 0.8.1-1
- Update copyright years to end with 2010.
- Dead code removal.
- bumping Version to 0.8.0 (msuchy@redhat.com)

* Wed Sep 02 2009 Michael Mraka <michael.mraka@redhat.com> 0.7.1-1
- Add symlink capability to config management (joshua.roys@gtri.gatech.edu)
- add the Chat graphic as an advertisement to the layouts
- allow users to chat with spacewalk members on IRC via the web

* Tue Jul 21 2009 John Matthews <jmatthew@redhat.com> 0.6.8-1
- 510146 - Update copyright years from 2002-08 to 2002-09.
  (dgoodwin@redhat.com)

* Tue Jun 30 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.7-1
- 508710 - make bar on top of page wider, so we do not get empty space on wider displays

* Thu Jun 25 2009 John Matthews <jmatthew@redhat.com> 0.6.6-1
- 506489 - remove the link associated with the org name present in the UI
  header (bbuckingham@redhat.com)
- 505101 - update css so that links are underlined when hovering
  (bbuckingham@redhat.com)
- fix to shwo the correct error message css (paji@redhat.com)

* Wed May 27 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.5-1
- 500806 - limit a:hover to links only, changed to a:link:hover (jesusr@redhat.com)

* Thu May 21 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.4-1
- 501038 - Update css to mitigate wrapping of long org names. (jortel@redhat.com)

* Wed May 06 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.3-1
- 444221 - More fixes related to snippet pages in general (paji@redhat.com)
- 484962 - Cleanup System Overview alerts. (dgoodwin@redhat.com)
- 480011 - Added organization to the top header near the username (jason.dobies@redhat.com)

* Mon Apr 20 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.2-1
- 496321 - add Documentation as a search option on perl pages (jesusr@redhat.com)

* Wed Apr 15 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.1-1
- 494475,460136 - remove faq & feedback code which used customer service emails.
  (jesusr@redhat.com)
- 443132 - Converted action lists to new list tag. (jsherril@redhat.com)

* Thu Mar 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.8-1
- removing satellite-debug link

* Wed Feb 18 2009 Brad Buckingham <bbuckingham@redhat.com> 0.5.7-1
- adding rhn_docs.conf to enable configurable docs location

* Wed Feb 04 2009 Devan Goodwin <dgoodwin@redhat.com> 0.5.5-1
- Add /var/www/html/favicon.ico.

* Fri Jan 30 2009 Mike McCune <mmccune@gmail.com> 0.5.4-1
- going back to just spacewalk-branding but removing requires: spacewalk-html

* Wed Jan 28 2009 Mike McCune <mmccune@gmail.com> 0.5.3-1
- split out branding jar into its own subpackage.

* Wed Jan 21 2009 Michael Mraka <michael.mraka@redhat.com> 0.5.1-1
- modified branding according to jsp layout changes

* Mon Dec 22 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.1-1
- added spacewalk-public.cert and spacewalk-cert.conf

* Thu Oct 23 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.1.6-1
- fix square corner on left tab.

* Fri Aug 29 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.1.5-1
- bz: 460313  css fix for search bar in top right header.

* Tue Aug 12 2008 Devan Goodwin 0.1.4-0
- Adding nav styles.

* Thu Aug 07 2008 Devan Goodwin 0.1.3-0
- Adding templates.

* Wed Aug  6 2008 Jan Pazdziora 0.1.2-0
- decrease version to 0.1.*
- tag for rebuild

* Mon Aug 04 2008  Miroslav Suchy <msuchy@redhat.com>
- fix dependecies, requires spacewalk-html
- bump version

* Wed Jul 30 2008  Devan Goodwin <dgoodwin@redhat.com> 0.2-2
- Adding images.

* Tue Jul 29 2008  Devan Goodwin <dgoodwin@redhat.com> 0.2-1
- Initial packaging.

