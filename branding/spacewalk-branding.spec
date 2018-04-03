%if  0%{?rhel} && 0%{?rhel} < 6
%global tomcat_path %{_var}/lib/tomcat5
%global wwwdocroot %{_var}/www/html
%else
%if 0%{?fedora} || 0%{?rhel} >= 7
%global tomcat_path %{_var}/lib/tomcat
%global wwwdocroot %{_var}/www/html
%else
%if 0%{?suse_version}
%global tomcat_path /srv/tomcat
%global wwwdocroot /srv/www/htdocs
%else
%global tomcat_path %{_var}/lib/tomcat6
%global wwwdocroot %{_var}/www/html
%endif
%endif
%endif

Name:       spacewalk-branding
Version:    2.9.0
Release:    1%{?dist}
Summary:    Spacewalk branding data

License:    GPLv2
URL:        https://github.com/spacewalkproject/spacewalk/
Source0:    https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch:  noarch

BuildRequires: java-1.8.0-openjdk-devel
BuildRequires: nodejs-less
BuildRequires: patternfly1
Requires:      httpd
Requires:      bootstrap <= 3.0.0
Requires:      bootstrap-datepicker
Requires:      font-awesome >= 4.0.0
Requires:      jquery-timepicker >= 1.3.2
Requires:      roboto >= 1.2
Requires:      pwstrength-bootstrap
Requires:      momentjs
Requires:      jquery-ui
Requires:      patternfly1
Requires:      select2
Requires:      select2-bootstrap-css
%if 0%{?suse_version}
Requires(pre): tomcat
%endif

%description
Spacewalk specific branding, CSS, and images.

%package devel
Requires:       %{name} = %{version}-%{release}
Summary:        Spacewalk LESS source files for development use

%description devel
This package contains LESS source files corresponding to Spacewalk's
CSS files.

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
install -d -m 755 %{buildroot}%{wwwdocroot}
install -d -m 755 %{buildroot}%{wwwdocroot}/css
install -d -m 755 %{buildroot}%{_datadir}/spacewalk
install -d -m 755 %{buildroot}%{_datadir}/spacewalk/web
install -d -m 755 %{buildroot}%{_datadir}/rhn/lib/
install -d -m 755 %{buildroot}%{tomcat_path}/webapps/rhn/WEB-INF/lib/
install -d -m 755 %{buildroot}/%{_sysconfdir}/rhn
install -d -m 755 %{buildroot}/%{_prefix}/share/rhn/config-defaults
cp -pR css/* %{buildroot}/%{wwwdocroot}/css
cp -pR fonts %{buildroot}/%{wwwdocroot}/
cp -pR img %{buildroot}/%{wwwdocroot}/
# Appplication expects two favicon's for some reason, copy it so there's just
# one in source:
cp -p img/favicon.ico %{buildroot}/%{wwwdocroot}/
cp -pR setup  %{buildroot}%{_datadir}/spacewalk/
cp -pR java-branding.jar %{buildroot}%{_datadir}/rhn/lib/
ln -s %{_datadir}/rhn/lib/java-branding.jar %{buildroot}%{tomcat_path}/webapps/rhn/WEB-INF/lib/java-branding.jar
cp -p conf/rhn_docs.conf %{buildroot}/%{_prefix}/share/rhn/config-defaults/rhn_docs.conf
ln -s %{_datadir}/patternfly1/resources/fonts/* %{buildroot}%{wwwdocroot}/fonts/

%clean
rm -rf %{buildroot}


%files
%dir %{wwwdocroot}/css
%{wwwdocroot}/css/*.css
%dir %{wwwdocroot}/fonts
%{wwwdocroot}/fonts/*
%dir /%{wwwdocroot}/img
%{wwwdocroot}/img/*
%{wwwdocroot}/favicon.ico
%{_datadir}/spacewalk/
%{_datadir}/rhn/lib/java-branding.jar
%{tomcat_path}/webapps/rhn/WEB-INF/lib/java-branding.jar
%{_prefix}/share/rhn/config-defaults/rhn_docs.conf
%doc LICENSE
%if 0%{?suse_version}
%attr(775,tomcat,tomcat) %dir %{tomcat_path}/webapps/rhn
%attr(775,tomcat,tomcat) %dir %{tomcat_path}/webapps/rhn/WEB-INF
%attr(775,tomcat,tomcat) %dir %{tomcat_path}/webapps/rhn/WEB-INF/lib/
%dir %{_prefix}/share/rhn
%dir %{_prefix}/share/rhn/lib
%attr(755,root,www) %dir %{_prefix}/share/rhn/config-defaults
%endif

%files devel
%{wwwdocroot}/css/*.less

%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.5-1
- removed %%%%defattr from specfile
- removed Group from specfile
- removed BuildRoot from specfiles

* Mon Jan 22 2018 Jiri Dostal <jdostal@redhat.com> 2.8.4-1
- Unify icons/style with other services

* Mon Jan 22 2018 Jiri Dostal <jdostal@redhat.com>
- Unify icons/style with other services

* Wed Jan 03 2018 Jiri Dostal <jdostal@redhat.com> 2.8.2-1
- Add another table style, some tables are hard to read

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Fri Jul 28 2017 Jan Dobes 2.7.5-1
- bumping version to fix RHEL 7 build

* Mon May 08 2017 Silvio Moioli <smoioli@suse.de>
- PR 476 - Use different symbols for collapsible sidebar items

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.3-1
- recompile all packages with the same (latest) version of java
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub
- Fix checkbox icon align

* Mon Jan 23 2017 Jan Dobes 2.7.2-1
- Differentiate writable/non-writable fields

* Thu Nov 17 2016 Eric Herget <eherget@redhat.com> 2.7.1-1
- 1394299 - fix css and UI display to better support tree list
- Bumping package versions for 2.7.
- Bumping package versions for 2.6.

* Tue May 10 2016 Grant Gainey 2.5.3-1
- spacewalk-branding: build on openSUSE

* Tue Dec 15 2015 Jan Dobes 2.5.2-1
- fix %%tomcat in spacewalk-branding.spec for EL7

* Tue Nov 24 2015 Jan Dobes 2.5.1-1
- Remove unused load_satellite_certificate function and satellite-cert-file
  parameter
- branding: remove unused css classes and their dead references
- Bumping package versions for 2.5.

* Thu Sep 24 2015 Jan Dobes 2.4.6-1
- deleting language images

* Wed Aug 26 2015 Jan Dobes 2.4.5-1
- fixing floating problem

* Fri Jul 03 2015 Matej Kollar <mkollar@redhat.com> 2.4.4-1
- Fix file input control alignment issue with form-control (bsc#873203)

* Fri Jun 05 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.3-1
- Add a spacewalk-branding-devel package to install LESS files for development
  use

* Wed May 20 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.2-1
- Rebuild package due to BZ#1223240

* Tue Apr 28 2015 Grant Gainey 2.4.1-1
- 1189354 - restore missing cfg-diff CSS
- Bumping package versions for 2.4.

* Mon Mar 23 2015 Grant Gainey 2.3.25-1
- inline input class
- spacewalk-theme.less: bottom-margin to section tag

* Thu Mar 19 2015 Grant Gainey 2.3.24-1
- Updating copyright info for 2015

* Wed Mar 18 2015 Tomas Kasparek <tkasparek@redhat.com> 2.3.23-1
- update documentation with Satellite 5.7

* Mon Mar 09 2015 Tomas Lestach <tlestach@redhat.com> 2.3.22-1
- removing unused navbar_top_sat.txt

* Thu Mar 05 2015 Tomas Lestach <tlestach@redhat.com> 2.3.21-1
- templates dir was removed completelly from branding

* Wed Mar 04 2015 Tomas Lestach <tlestach@redhat.com> 2.3.20-1
- removing templates/profile.pxt as it isn't used anymore
- removing templates/footer.pxt as it isn't used anymore
- removing templates/header.pxt as it isn't used anymore
- removing templates/c.pxt as it isn't used anymore

* Mon Jan 12 2015 Matej Kollar <mkollar@redhat.com> 2.3.19-1
- Getting rid of trailing spaces in Java
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Mon Dec 15 2014 Jan Dobes 2.3.18-1
- style java.custom_header, java.custom_footer, java.login_banner,
  java.legal_note parameters

* Thu Dec 11 2014 Jan Dobes 2.3.17-1
- add style for documentation navigation

* Mon Dec 08 2014 Jan Dobes 2.3.16-1
- remove unused code
- slightly improve hideable menu
- revert accidentaly pushed commits
- test toggling
- back
- float left menu on smaller screens
- test not making sidenav horizontal
- test not making aside horizontal

* Wed Nov 19 2014 Jan Dobes 2.3.15-1
- do not show expanded menu on small screens on default
- avoid white space under footer
- do not restrict collapsable menu height
- remove redundant navbar-collapse-1 class
- spread all buttons
- make navbar-utility line 100%% wide on small screens
- display navbar-utility items in single line even on tiny screen
- fix color
- shrink header images
- remove unused responsive rule
- hide items on smaller screens

* Tue Nov 11 2014 Jan Dobes 2.3.14-1
- remove unused styles
- long lines are not visible (API doc)

* Thu Nov 06 2014 Jan Dobes 2.3.13-1
- changing left navigation menu colors to be darker
- collapse class should work on all screen widths

* Tue Nov 04 2014 Jan Dobes 2.3.12-1
- we don't actually need equal height columns there

* Tue Nov 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.11-1
- do not use list bullets in messages on centered login page

* Thu Oct 23 2014 Jan Dobes 2.3.10-1
- decorate alert messages with patternfly icons
- change style of alerts
- actually link all patternfly fonts
- style .spacewalk-list-footer-addons-extra to float-right like all the other
  list-bottom-matter

* Mon Oct 20 2014 Jan Dobes 2.3.9-1
- slightly improve contrast of left menu

* Fri Oct 17 2014 Jan Dobes 2.3.8-1
- indent bottom list control as well

* Wed Oct 15 2014 Jan Dobes 2.3.7-1
- there is more to hide on unauthenticated pages

* Wed Oct 15 2014 Jan Dobes 2.3.6-1
- fixing path for font linking
- underline links in all alert boxes

* Thu Oct 09 2014 Tomas Kasparek <tkasparek@redhat.com> 2.3.5-1
- fixing colors in lists

* Mon Sep 29 2014 Tomas Kasparek <tkasparek@redhat.com> 2.3.4-1
- branding should require patternfly

* Fri Sep 26 2014 Tomas Kasparek <tkasparek@redhat.com> 2.3.3-1
- use PatternFly fonts
- update spacewalk-branding to use patternfly
- patternfly: removing hardcoded csrf token from pxt pages
- patternfly: css files order fixed because of spacewalk specific icons
- patternfly: fixing footer position
- Integrating patternfly for more awesomeness...

* Fri Sep 12 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.2-1
- fixing images file permissions and removing unused image backup
- updated links to proper sections in Satellite 5.6 documentation

* Fri Aug 01 2014 Jan Dobes 2.3.1-1
- sidenav should always have it's space
- Bumping package versions for 2.3.

* Fri May 30 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.5-1
- require jquery-ui, select2 and select2-bootstrap-css

* Fri May 23 2014 Stephen Herr <sherr@redhat.com> 2.2.4-1
- build an rpm for momentjs and require it

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.3-1
- make the warning alters readable

* Wed Apr 30 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.2-1
- Update default Spacewalk entitlement certificate

* Wed Mar 05 2014 Jan Dobes 2.2.1-1
- hide search form together with other UI changes
- fix gap under menu
- show roll menu button only on small screens
- control menu type switching completely with css instead of javascript
- Bumping package versions for 2.2.

* Tue Feb 18 2014 Matej Kollar <mkollar@redhat.com> 2.1.33-1
- The fix should have been the other way round...

* Tue Feb 18 2014 Matej Kollar <mkollar@redhat.com> 2.1.32-1
- do not use fixed size
- add space after alphabar result sign

* Mon Feb 17 2014 Tomas Kasparek <tkasparek@redhat.com> 2.1.31-1
- 1064573 - sidenav css should respect valid html constructions

* Sat Feb 15 2014 Matej Kollar <mkollar@redhat.com> 2.1.30-1
- Use jquery-timepicker-1.3.3

* Fri Feb 14 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.29-1
- datepicker needs bootstrap-datepicker and jquery-timepicker

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

