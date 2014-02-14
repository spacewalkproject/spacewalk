%if  0%{?rhel} && 0%{?rhel} < 6
%global tomcat tomcat5
%else
%if 0%{?fedora}
%global tomcat tomcat
%else
%global tomcat tomcat6
%endif
%endif

Name:       spacewalk-branding
Version:    2.1.28
Release:    1%{?dist}
Summary:    Spacewalk branding data

Group:      Applications/Internet
License:    GPLv2
URL:        https://fedorahosted.org/spacewalk/
Source0:    https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:  noarch

BuildRequires: java-devel >= 1.5.0
BuildRequires: nodejs-less
BuildRequires: bootstrap-less <= 3.0.0
Requires:   httpd
Requires:   bootstrap <= 3.0.0
Requires:   font-awesome >= 4.0.0
Requires:   roboto >= 1.2
Requires: pwstrength-bootstrap

%description
Spacewalk specific branding, CSS, and images.

%prep
%setup -q

%build

javac java/code/src/com/redhat/rhn/branding/strings/StringPackage.java
rm -f java/code/src/com/redhat/rhn/branding/strings/StringPackage.java
jar -cf java-branding.jar -C java/code/src com

# Compile less into css
lessc --include-path=/usr/share css/spacewalk.less > css/spacewalk.css

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{_var}/www/html
install -d -m 755 %{buildroot}%{_var}/www/html/css
install -d -m 755 %{buildroot}%{_datadir}/spacewalk
install -d -m 755 %{buildroot}%{_datadir}/spacewalk/web
install -d -m 755 %{buildroot}%{_datadir}/spacewalk/web/nav
install -d -m 755 %{buildroot}%{_datadir}/rhn/lib/
install -d -m 755 %{buildroot}%{_var}/lib/%{tomcat}/webapps/rhn/WEB-INF/lib/
install -d -m 755 %{buildroot}/%{_sysconfdir}/rhn
install -d -m 755 %{buildroot}/%{_prefix}/share/rhn/config-defaults
cp -p css/spacewalk.css %{buildroot}/%{_var}/www/html/css
cp -pR fonts %{buildroot}/%{_var}/www/html/
cp -pR img %{buildroot}/%{_var}/www/html/
# Appplication expects two favicon's for some reason, copy it so there's just
# one in source:
cp -p img/favicon.ico %{buildroot}/%{_var}/www/html/
cp -pR templates %{buildroot}%{_datadir}/spacewalk/web/
cp -pR styles %{buildroot}%{_datadir}/spacewalk/web/nav/
cp -pR setup  %{buildroot}%{_datadir}/spacewalk/
cp -pR java-branding.jar %{buildroot}%{_datadir}/rhn/lib/
ln -s %{_datadir}/rhn/lib/java-branding.jar %{buildroot}%{_var}/lib/%{tomcat}/webapps/rhn/WEB-INF/lib/java-branding.jar
cp -p conf/rhn_docs.conf %{buildroot}/%{_prefix}/share/rhn/config-defaults/rhn_docs.conf

%clean
rm -rf %{buildroot}


%files
%dir %{_var}/www/html/css
%{_var}/www/html/css/*
%dir %{_var}/www/html/fonts
%{_var}/www/html/fonts/*
%dir /%{_var}/www/html/img
%{_var}/www/html/img/*
%{_var}/www/html/favicon.ico
%{_datadir}/spacewalk/
%{_datadir}/rhn/lib/java-branding.jar
%{_var}/lib/%{tomcat}/webapps/rhn/WEB-INF/lib/java-branding.jar
%{_prefix}/share/rhn/config-defaults/rhn_docs.conf
%doc LICENSE

%changelog
* Fri Feb 14 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.28-1
- simplify datepicker layout and unify look of date/time part
- Introduce a date-time picker.
- style CreateUser page so it resembles old look

* Tue Feb 11 2014 Grant Gainey 2.1.27-1
- 1063915, CVE-2013-4415 - Missed changing Search.do to post, perl-side

* Thu Feb 06 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.26-1
- fixed create probe page aligning
- required field marker used to be red
- password meter needs pwstrength-bootstrap

* Tue Feb 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.25-1
- help links are already hidden via spacewalk-help-link class
- move toolbar items right for all header levels

* Fri Jan 31 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.24-1
- add special class to help links
- Revert "bootstrap tuning - style submit buttons"
- style table for system comparsion
- update copyright year in perl footer
- highlight column by which is list sorted and hovered row

* Wed Jan 29 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.23-1
- add sort order icons and alphaResult icon
- adding custom styles
- removing old spacewalk css

* Mon Jan 27 2014 Matej Kollar <mkollar@redhat.com> 2.1.22-1
- New less file added to style Inputs. New less file added for the minor fixes
  of TB3 for spacewalk layout

* Mon Jan 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.21-1
- Add a rhn-date tag

* Fri Jan 17 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.20-1
- Roboto font has been moved to separate package
- font-awesome has been moved to separate package

* Thu Jan 16 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.19-1
- Fix to use .less files in development mode (2)

* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.18-1
- Fix to use .less files in development mode

* Mon Jan 13 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.17-1
- allow to use .less files in development mode
- perl List port to new css/markup

* Thu Jan 09 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.16-1
- use packaged upstream bootstrap .less files

* Mon Dec 16 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.15-1
- making help links disappear
- colour added to the counter in SSM
- Links inside a alert-info have a darker blue than the text shown and have
  underline. It is necessary to distinguish the link over the general text

* Fri Dec 13 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.14-1
- replaced icons with icon tag
- updated pxt pages to use <rhn-icon> tag

* Wed Dec 04 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.13-1
- bootstrap tuning

* Tue Dec 03 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.12-1
- bootstrap tuning

* Tue Dec 03 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.11-1
- bootstrap tuning

* Fri Nov 29 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.10-1
- bootstrap tuning: make non-link text in header more visible
- bootstrap tuning - style submit buttons

* Wed Nov 27 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.9-1
- bootstrap tuning - make disappear only qustion mark and not all links in h1
- bootstrap tuning - hide the documentation question marks on java and perl
  pages
* Mon Nov 18 2013 Tomas Lestach <tlestach@redhat.com> 2.1.8-1
- point Spacewalk documentation to Red Hat Satellite 5.6 documentation
- replace 'Channel Managemet Guide' docs with 'User Guide' and 'Getting Started
  Guide'

* Fri Nov 15 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.7-1
- polishing changelog

* Thu Nov 14 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.6-1
- Bootstrap 3.0 changes, brand new WebUI look

* Thu Oct 17 2013 Stephen Herr <sherr@redhat.com> 2.1.5-1
- 1020497 - provide a way to order kickstart scripts

* Tue Oct 08 2013 Stephen Herr <sherr@redhat.com> 2.1.4-1
- 1006142 - non-roman character languages had bad wrapping for thin table
  columns

* Tue Sep 10 2013 Tomas Lestach <tlestach@redhat.com> 2.1.3-1
- 1006406 - fix encodig in branding

* Tue Sep 03 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.2-1
- fix redundant margin in perl sidenav

* Tue Aug 06 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.1-1
- Indent organization configuration dialog to clarify semantics of checkboxes.
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Mon Jul 08 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.21-1
- making display-none of class help-title spacewalk-spcecific only

* Tue Jun 25 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.20-1
- fix of some css errors

* Mon Jun 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.19-1
- rebranding few more strings

* Wed Jun 05 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.18-1
- moving #rhn_welcome to spacewalk specific styles

* Fri May 17 2013 Tomas Lestach <tlestach@redhat.com> 1.10.17-1
- 591988 - render error messages without dot in front of them

* Tue May 07 2013 Jan Pazdziora 1.10.16-1
- removing unnecessary css property
- removing duplicate left border in tables containing checkbox as 1st column

* Thu Apr 11 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.15-1
- overlap of currently active section on top-nav

* Wed Mar 27 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.14-1
- fix css in duplicate system comparsion

* Wed Mar 27 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.13-1
- adding back accidentaly deleted css style

* Wed Mar 27 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.12-1
- pixel perfecting first and last-child of th when sorting by them

* Tue Mar 26 2013 Jan Pazdziora 1.10.11-1
- indentation of ssm buttons from top of bar whoch contains them

* Fri Mar 22 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.10-1
- simplify tomcat version decisison

* Wed Mar 20 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.9-1
- changing structure of css files

* Sun Mar 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.8-1
- removing unreferenced images from spacewalk-branding

* Thu Mar 14 2013 Jan Pazdziora 1.10.7-1
- rhn-iecompat.css is never used - delete it

* Thu Mar 14 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.6-1
- removing unused styles from rhn-basic.css
- removing unused styles from blue-docs.css

* Wed Mar 13 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.5-1
- removing unused styles and refactoring blue-nav-top.css and adjacent files
- removing unused styles from rhn-header.css
- removing unused styles from rhn-listview.css
- removing unused styles from rhn-messaging.css
- removing unused styles from rhn-nav-sidenav.css
- rmoving some unused styles from rhn-status.css

* Tue Mar 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.4-1
- clean up of rhn-special-styles.css and adjacent files
- removing css hacks for vintage versions of IE

* Mon Mar 11 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.3-1
- removing duplicate css
- removing -moz- in front of border-radius
- css changes - table borders

* Fri Mar 08 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.2-1
- removing filter input from page when printing

* Wed Mar 06 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.1-1
- using css3 border-radius instead of images to render round edges
- Bumping package versions for 1.9

* Fri Mar 01 2013 Tomas Lestach <tlestach@redhat.com> 1.9.6-1
- introducing crash logo
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Thu Jan 31 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.5-1
- removed no longer necessary directory definitions
- pack branding template files outside of document root

* Tue Dec 04 2012 Jan Pazdziora 1.9.4-1
- On Fedoras, start to use tomcat >= 7.

* Wed Nov 28 2012 Tomas Lestach <tlestach@redhat.com> 1.9.3-1
- 470463 - fixing xmllint issue

* Mon Nov 12 2012 Tomas Lestach <tlestach@redhat.com> 1.9.2-1
- Fix typos

* Mon Nov 12 2012 Tomas Lestach <tlestach@redhat.com> 1.9.1-1
- 866326 - customize KickstartFileDownloadAdvanced.do page in case of kickstart
  file DownloadException
- reformated using xmllint -format
- Bumping package versions for 1.9.

* Wed Oct 24 2012 Jan Pazdziora 1.8.7-1
- WebUI - css for @media print

* Tue Oct 23 2012 Tomas Lestach <tlestach@redhat.com> 1.8.6-1
- make the white image background transparent
- Expose extra packages / systems with extra packages

* Fri Oct 19 2012 Jan Pazdziora 1.8.5-1
- Edit colors in highlightning of :hovered rows in list views
- Highlightning of :hover row in list views

* Wed Oct 10 2012 Jan Pazdziora 1.8.4-1
- The Sniglets::Utils is no longer needed in footer.pxt.
- The rhn-bugzilla-link generates emply paragraph.

* Mon Jun 04 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.3-1
- Add support for studio image deployments (web UI) (jrenner@suse.de)
- %%defattr is not needed since rpm 4.4 (msuchy@redhat.com)

* Fri Apr 27 2012 Jan Pazdziora 1.8.2-1
- Missing icon for the systems that need reboot list (dmacvicar@suse.de)

* Thu Apr 19 2012 Jan Pazdziora 1.8.1-1
- Update the copyright year info on .pxt pages.

* Mon Feb 27 2012 Jan Pazdziora 1.7.1-1
- automatically focus search form (msuchy@redhat.com)

* Fri Sep 30 2011 Jan Pazdziora 1.6.4-1
- 621531 - move /etc/rhn/default to /usr/share/rhn/config-defaults (branding).

* Fri Sep 02 2011 Jan Pazdziora 1.6.3-1
- 558972 - making the navigational bar nice on 2000+ px wide screens.

* Fri Aug 05 2011 Jan Pazdziora 1.6.2-1
- 458413 - hide the bubble help links since we do not ship the documentation
  with Spacewalk.

* Fri Jul 22 2011 Jan Pazdziora 1.6.1-1
- cleanup: revhistory style is not used (msuchy@redhat.com)
- fix typos in css (msuchy@redhat.com)

* Tue Jun 21 2011 Jan Pazdziora 1.5.2-1
- 708957 - remove RHN Satellite Proxy Release Notes link (tlestach@redhat.com)

* Tue May 10 2011 Jan Pazdziora 1.5.1-1
- 484895 - Point the release notes dispatcher to fedorahosted.org.

* Wed Mar 30 2011 Jan Pazdziora 1.4.3-1
- update copyright years (msuchy@redhat.com)
- implement common access keys (msuchy@redhat.com)

* Fri Feb 18 2011 Jan Pazdziora 1.4.2-1
- The LOGGED IN and SIGN OUT are not images since Satellite 5.0 (rhn-360.css),
  removing.

* Wed Feb 09 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.1-1
- made system legend of the same width as side navigation

* Fri Dec 17 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.2-1
- let import PXT modules on fly

* Thu Nov 25 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.1-1
- add GPLv2 license (msuchy@redhat.com)
- cleanup spec (msuchy@redhat.com)
- remove .htaccess file (msuchy@redhat.com)
- point to url where we store tar.gz (msuchy@redhat.com)
- Bumping package versions for 1.3. (jpazdziora@redhat.com)

* Mon Sep 27 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.2-1
- 627920 - Added a larger config file icon for symlinks. Thanks to Joshua Roys
  (paji@redhat.com)

* Wed Sep 01 2010 Jan Pazdziora 1.2.1-1
- 567885 - "Spacewalk release 0.9" leads to 404 (coec@war.coesta.com)

* Mon May 31 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.2-1
- Adding the correct checkstyle for inactive systems
- Added the dupe compare css and javascript magic
- 572714 - fixing css issues with docs

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

