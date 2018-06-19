%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

Name: spacewalk-web
Summary: Spacewalk Web site - Perl modules
License: GPLv2
Version: 2.9.2
Release: 1%{?dist}
URL:          https://github.com/spacewalkproject/spacewalk/
Source0:      https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch: noarch
BuildRequires: perl(ExtUtils::MakeMaker)

%description
This package contains the code for the Spacewalk Web Site.
Normally this source RPM does not generate a %{name} binary package,
but it does generate a number of sub-packages.

%package -n spacewalk-html
Summary: HTML document files for Spacewalk
Requires: webserver
Requires: spacewalk-branding
Obsoletes: rhn-help < 5.3.0
Provides: rhn-help = 5.3.0
Obsoletes: rhn-html < 5.3.0
Provides: rhn-html = 5.3.0
# files html/javascript/{builder.js,controls.js,dragdrop.js,effects.js,
# prototype-1.6.0.js,scriptaculous.js,slider.js,sound.js,unittest.js}
# are licensed under MIT license
License: GPLv2 and MIT

%description -n spacewalk-html
This package contains the HTML files for the Spacewalk web site.


%package -n spacewalk-base
Summary: Programs which need to be installed for the Spacewalk Web base classes
Provides: spacewalk(spacewalk-base) = %{version}-%{release}
Requires: /usr/bin/sudo
Requires: webserver
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires: perl(Params::Validate)
Requires: perl(XML::LibXML)
Obsoletes: rhn-base < 5.3.0
Obsoletes: spacewalk-grail < %{version}
Obsoletes: spacewalk-pxt < %{version}
Obsoletes: spacewalk-sniglets < %{version}
Provides: rhn-base = 5.3.0


%description -n spacewalk-base
This package includes the core RHN:: packages necessary to manipulate the
database.  This includes RHN::* and RHN::DB::*.


%package -n spacewalk-base-minimal
Summary: Core of Perl modules for %{name} package
Provides: spacewalk(spacewalk-base-minimal) = %{version}-%{release}
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Obsoletes: rhn-base-minimal < 5.3.0
Provides: rhn-base-minimal = 5.3.0
Requires: perl(DBI)
Requires: perl(Params::Validate)

%description -n spacewalk-base-minimal
Independent Perl modules in the RHN:: name-space.
These are very basic modules needed to handle configuration files, database,
sessions and exceptions.

%package -n spacewalk-base-minimal-config
Summary: Configuration for %{name} package
Provides: spacewalk(spacewalk-base-minimal-config) = %{version}-%{release}
Requires: httpd
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires: spacewalk-base-minimal = %{version}-%{release}

%description -n spacewalk-base-minimal-config
Configuration file for spacewalk-base-minimal package.


%package -n spacewalk-dobby
Summary: Perl modules and scripts to administer a PostgreSQL database
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Obsoletes: rhn-dobby < 5.3.0
Provides: rhn-dobby = 5.3.0
Requires: %{sbinpath}/runuser
Conflicts: spacewalk-oracle

%description -n spacewalk-dobby
Dobby is collection of Perl modules and scripts to administer a PostgreSQL
database.


%prep
%setup -q

%build
make -f Makefile.spacewalk-web PERLARGS="INSTALLDIRS=vendor" %{?_smp_mflags}

%install
make -C modules install DESTDIR=$RPM_BUILD_ROOT PERLARGS="INSTALLDIRS=vendor" %{?_smp_mflags}
make -C html install PREFIX=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name perllocal.pod -exec rm -f {} \;
find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;

mkdir -p $RPM_BUILD_ROOT/%{_var}/www/html/pub
mkdir -p $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/init.d
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/httpd/conf
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/cron.daily

install -m 644 conf/rhn_web.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults
install -m 644 conf/rhn_dobby.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults
install -m 755 modules/dobby/scripts/check-database-space-usage.sh $RPM_BUILD_ROOT/%{_sysconfdir}/cron.daily/check-database-space-usage.sh


%clean

%files -n spacewalk-base
%dir %{perl_vendorlib}/RHN
%{perl_vendorlib}/RHN.pm

%files -n spacewalk-base-minimal
%dir %{perl_vendorlib}/RHN
%dir %{perl_vendorlib}/PXT
%{perl_vendorlib}/RHN/SimpleStruct.pm
%{perl_vendorlib}/RHN/Exception.pm
%{perl_vendorlib}/RHN/DB.pm
%{perl_vendorlib}/RHN/DBI.pm
%{perl_vendorlib}/PXT/Config.pm
%doc LICENSE

%files -n spacewalk-base-minimal-config
%attr(644,root,apache) %{_prefix}/share/rhn/config-defaults/rhn_web.conf

%files -n spacewalk-dobby
%attr(755,root,root) %{_bindir}/db-control
%{_mandir}/man1/db-control.1.gz
%{perl_vendorlib}/Dobby.pm
%attr(644,root,root) %{_prefix}/share/rhn/config-defaults/rhn_dobby.conf
%attr(0755,root,root) %{_sysconfdir}/cron.daily/check-database-space-usage.sh
%{perl_vendorlib}/Dobby/

%files -n spacewalk-html
%{_var}/www/html/*
%doc LICENSE

%changelog
* Tue Jun 19 2018 Tomas Kasparek <tkasparek@redhat.com> 2.9.2-1
- Simplified version of the image deployment page

* Wed Apr 04 2018 Jiri Dostal <jdostal@redhat.com> 2.9.1-1
- Bumping package version for web.version
- Bumping package versions for 2.9.

* Wed Mar 21 2018 Jiri Dostal <jdostal@redhat.com> 2.8.6-1
- Updating copyright years for 2018

* Wed Feb 14 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.5-1
- Enhances the check-database-space-usage.sh to include the PostgreSQL 9.5
  directory and make sure the /usr/share/rhn/config-defaults/rhn_pgversion.conf
  exists
- allow software collection versions of Postgres to be used

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.4-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Mon Oct 16 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.3-1
- 1360841 - extend dobby logging to see whether action completed or not

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- purged changelog entries for Spacewalk 2.0 and older

* Thu Aug 17 2017 Eric Herget <eherget@redhat.com> 2.8.1-1
- Bumping web.version for 2.8.
- Bumping package versions for 2.8.

* Wed Aug 02 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.5-1
- 1449124 - db-control no longer works with oracle, let's add
  conflicts/obsoletes

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.4-1
- update copyright year

* Thu May 04 2017 Can Bulut Bayburt <cbbayburt@suse.com>
- PR 483 - Hides 'Save/Clear' buttons when no changes are present in action
  chain lists
- PR 483 - Fix plus/minus buttons in action chain list

* Mon Apr 24 2017 Eric Herget <eherget@redhat.com> 2.7.2-1
- 1437875 - db-control online-backup returns success even when the backup has
  failed
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Wed Nov 23 2016 Eric Herget <eherget@redhat.com> 2.7.1-1
- 1373900 - update failure message when db-control start fails
- Bumping package versions for 2.7.

* Fri Oct 14 2016 Grant Gainey 2.6.5-1
- Update specfile for RHN reference and minor wordsmithing

* Mon Oct 03 2016 Jiri Dostal <jdostal@redhat.com> 2.6.4-1
- 'shrink-segments' works on embedded PostgreSQL as well

* Mon Sep 26 2016 Eric Herget <eherget@redhat.com> 2.6.3-1
- 1373900 - db-control start/stop now returns non-zero and complains on failure
- require spacewalk-base-minimal-config from spacewalk-setup

* Mon Sep 12 2016 Jan Dobes 2.6.2-1
- spacewalk-base-minimal package description typo fixed

* Mon Jun 27 2016 Tomas Lestach <tlestach@redhat.com> 2.6.1-1
- bumping Spacewalk version
- Bumping package versions for 2.6.

* Thu Dec 17 2015 Jan Dobes 2.5.7-1
- moving non_expirable_package_urls parameter to java
- moving download_url_lifetime parameter to java

* Wed Dec 09 2015 Jan Dobes 2.5.6-1
- Revert "reintroduce call_procedure function"
- Revert "reintroduce call_function function"
- moving smtp_server parameter to java
- moving chat_enabled parameter to java
- moving actions_display_limit parameter to java
- moving base_domain and base_port parameters to java

* Wed Nov 25 2015 Jan Dobes 2.5.5-1
- reintroduce call_function function

* Wed Nov 25 2015 Jan Dobes 2.5.4-1
- reintroduce call_procedure function

* Tue Nov 24 2015 Jan Dobes 2.5.3-1
- spacewalk-web.spec: remove leftovers
- rhn-satellite-activate: manual references removed
- perl modules: drop unused Cert.pm
- perl modules: drop unused SatelliteCert.pm

* Wed Nov 04 2015 Jan Dobes 2.5.2-1
- removing unused code in RHN::DB package

* Tue Sep 29 2015 Jan Dobes 2.5.1-1
- Bumping web.version to 2.5.
- Bumping package versions for 2.5.

* Fri Aug 14 2015 Grant Gainey 2.4.2-1
- 1253793 - Fixing IE8 display issues  * Add respond.js/html5-shim for IE8  *
  Block editarea.js, which breaks respond.js under IE8, from    executing under
  IE8

* Fri Mar 27 2015 Grant Gainey 2.4.1-1
- Update web.version to 2.4
- Bumping package versions for 2.4.

* Thu Mar 19 2015 Tomas Lestach <tlestach@redhat.com> 2.3.52-1
- drop requires for perl-URI - seems to be unused
- Updating copyright info for 2015

* Tue Mar 17 2015 Tomas Lestach <tlestach@redhat.com> 2.3.51-1
- let spacewalk-base-minimal require spacewalk-base-minimal-config

* Mon Mar 16 2015 Tomas Lestach <tlestach@redhat.com> 2.3.50-1
- removing RHN::Cache::File as it isn't referenced anymore
- Apache24Config.pm has already been removed
- removing spacewalk-pxt completelly

* Fri Mar 13 2015 Jan Dobes 2.3.49-1
- removing no longer used references
- removing RHN::DB::DataSource as it isn't referenced anymore
- removing RHN::DataSource as it isn't referenced anymore
- removing RHN::DataSource::Channel as it isn't referenced anymore
- removing unused Channel_queries
- web Require cleanup
- Fix upgrade path by obsoleting spacewalk-grail and spacewalk-sniglets
- removing unused Channel_queries

* Thu Mar 12 2015 Tomas Lestach <tlestach@redhat.com> 2.3.48-1
- removing unused rhn_web.conf options
- let's remove the MANIFESTS

* Thu Mar 12 2015 Tomas Lestach <tlestach@redhat.com> 2.3.47-1
- removing unused DataSource queries
- removing unused RHN::DataSource classes
- removing unused RHN DB JoinClass and TableClass
- removing unused RHN Action related stuff
- removing SatInstall and Session related stuff
- removing SatCluster related stuff
- removing unused RHN::DataSource::General
- removing unused RHN::DB::Entitlements
- removing unused DataSource sources
- removing unused RHN::Date
- removing unused RHN::Entitlements
- removing unused RHN::Mail
- removing RHN Errata related classes
- removing RHN Channel related
- removing RHN KSTree stuff
- removing various unused stuff
- removing unused RHN User stuff
- removing RHN Scheduler stuff
- removing RHN::Cleansers
- removing RHN Kickstart stuff
- deleting RHN Package stuff
- removing unused RHN classes
- removing rest of PXT classes
- removing RHN::Access and PXT::ACL
- removing PXT::ApacheAuth as it isn't referenced anymore
- removing PXT::Apache24Config as it isn't referenced anymore

* Tue Mar 10 2015 Tomas Lestach <tlestach@redhat.com> 2.3.46-1
- removing RHN::DB::Token as it isn't referenced anymore
- removing RHN::Token as it isn't referenced anymore
- removing RHN::Utils as it isn't referenced anymore

* Mon Mar 09 2015 Tomas Lestach <tlestach@redhat.com> 2.3.45-1
- update spec file
- removing RHN::DB::ContactGroup as it isn't referenced anymore
- removing RHN::ContactGroup as it isn't referenced anymore
- removing RHN::DataSource::ContactMethod as it isn't referenced anymore
- removing RHN::DB::ContactMethod as it isn't referenced anymore
- removing RHN::Set as it isn't referenced anymore
- removing RHN::DB::ServerGroup as it isn't referenced anymore
- removing RHN::ContactMethod as it isn't referenced anymore
- removing RHN::ServerGroup as it isn't referenced anymore
- removing RHN::DB::Kickstart::Session as it isn't referenced anymore
- removing RHN::DB::ServerActions as it isn't referenced anymore
- removing RHN::Kickstart::Session as it isn't referenced anymore
- removing RHN::Access::Action as it isn't referenced anymore
- removing RHN::Access::Channel as it isn't referenced anymore
- removing RHN::Access::Package as it isn't referenced anymore
- removing RHN::Access::System as it isn't referenced anymore
- removing RHN::Access::Token as it isn't referenced anymore
- removing RHN::DataSource::CustomInfo as it isn't referenced anymore
- removing RHN::DataSource::Probe as it isn't referenced anymore
- removing RHN::DataSource::Scout as it isn't referenced anymore
- removing RHN::DataSource::User as it isn't referenced anymore
- removing RHN::SearchTypes as it isn't referenced anymore
- removing RHN::ServerActions as it isn't referenced anymore
- removing unused RHN::Form
- removing unused RHN::Access handlers

* Mon Mar 09 2015 Tomas Lestach <tlestach@redhat.com> 2.3.44-1
- removing spacewalk-grail as they are not needed any more
- removing spacewalk-sniglets as they are not needed any more
- removing unused tags from Sniglets/Users.pm
- stop using permission.pxt error document
- errata pages were ported to java long time ago
- probe pages were ported to java long time ago

* Fri Mar 06 2015 Tomas Lestach <tlestach@redhat.com> 2.3.43-1
- fixing failed spacewalk-web build

* Fri Mar 06 2015 Tomas Lestach <tlestach@redhat.com> 2.3.42-1
- include directory was already removed

* Thu Mar 05 2015 Tomas Lestach <tlestach@redhat.com> 2.3.41-1
- removing unused help/index.html
- removing unused Makefile
- removing unused nav xmls
- removing unused tags from Sniglets/Navi.pm
- deleting unused nav xmls
- remove unused Perl code

* Wed Mar 04 2015 Tomas Lestach <tlestach@redhat.com> 2.3.40-1
- removing message_queues/local.pxi as it isn't used anymore
- removing unused styles
- removing status_bar/ssm.pxi as it isn't used anymore
- removing status_bar/main.pxi as it isn't used anymore
- removing message_queues/site.pxi as it isn't used anymore
- removing the permission.pxt dependency on c.pxt
- removing legends/system-list-legend.pxi as it isn't referenced anymore
- removing unused callbacks from Sniglets/ChannelEditor.pm
- removing unused pxt error pages
- we use /rhn/errors/404.jsp as 404 ErrorDocument
- removing unused tags from Sniglets/ChannelEditor.pm
- removing unused tags from Sniglets/Errata.pm
- removing the old solaris stuff
- removing packages/package_map_raw as it isn't referenced
- removing packages/view_readme as it isn't referenced
- removing unused systems/system_list

* Tue Mar 03 2015 Tomas Lestach <tlestach@redhat.com> 2.3.39-1
- removing misc/landing.pxt as it's not referenced anymore
- removing ssm groups pages as they were ported to java
- removing /help/about.pxt as it isn't referenced anymore
- we use /rhn/help/index.do instead of /help/about.pxt
- removing original error pages

* Mon Mar 02 2015 Tomas Lestach <tlestach@redhat.com> 2.3.38-1
- remove unused Sniglets/Packages.pm callbacks
- removing left Sniglets/Servers.pm callbacks
- removing unused Sniglets/Servers.pm callbacks
- removing unused Sniglets/Servers.pm tags

* Fri Feb 27 2015 Tomas Lestach <tlestach@redhat.com> 2.3.37-1
- removing unknown_package.pxt as it's not referenced anymore
- removing unused tags in Sniglets/Packages.pm
- removing errata_list/all.pxt as it isn't referenced anymore
- removing errata_list/relevant.pxt as it isn't referenced anymore
- removing system_list/potentially_in_channel_family.pxt as it isn't referenced
  anymore
- removing system_list/proxy.pxt as it isn't referenced anymore
- removing system_list/inactive.pxt as it isn't referenced anymore
- removing system_list/ungrouped.pxt as it isn't referenced anymore
- removing system_list/unentitled.pxt as it isn't referenced anymore
- removing system_list/out_of_date.pxt as it isn't referenced anymore
- removing system_list/visible_to_user.pxt as it isn't referenced anymore
- removing unused schedule_action-interface.pxi
- removing unused reschedule_action_form.pxi
- removing unused Sniglets/ServerActions.pm
- remove unused raw_script_output.txt

* Wed Feb 25 2015 Tomas Lestach <tlestach@redhat.com> 2.3.36-1
- removing ssm schedule remote command as it was ported to java
- removing package pages as they were ported to java
- removing package_map.pxt as it was solaris related
- removing ssm system preferences as they were ported to java
- removing ssm handling custom values as it was ported to java
- removing solaris related package pages
- removing ssm provisioning pages as they were ported to java
- removing ssm apply_errata_conf.pxt as it's no longer referenced
- removing ssm solaris patchsets related pages
- removing ssm solaris patches related pages
- removing subscribers.pxt as it was ported to java
- removing errata_cache_update.pxi and manage_channels_header.pxi
- removing solaris patchsets related pages, as solaris support has been dropped
- removing solaris patches related pages, as solaris support has been dropped
- removing system details edit.pxt as it was ported to java
- removing channel clone.pxt as the page was ported to java

* Tue Feb 24 2015 Tomas Lestach <tlestach@redhat.com> 2.3.35-1
- removing errata_channel_intersection.pxt as it was ported to java
- removing unused iso download jsp
- removing unused legends
- removing scout pages as monitoring was removed
- removing subscribers.pxt as it was ported to java
- removing errata clone.pxt as it was ported to java
- removing system_detail.xml and system_details_toolbar.pxi
- removing system details history pxt files
- removing proxy.pxt and proxy-clients.pxt as they were ported to java
- removing connection.pxt as it was ported to java
- removing activation.pxt as it was ported to java
- removing monitoring notification methods

* Wed Feb 18 2015 Tomas Lestach <tlestach@redhat.com> 2.3.34-1
- 1190235 - Restore missing { to BackupCommands.pm

* Fri Feb 06 2015 Grant Gainey 2.3.33-1
- 1123374 - Fix pltclu watning on restore

* Fri Jan 23 2015 Tomas Lestach <tlestach@redhat.com> 2.3.32-1
- removing unused monitoring related SCDB and TSDB

* Fri Jan 16 2015 Stephen Herr <sherr@redhat.com> 2.3.31-1
- fix rhnChannelNewestPackage table by using refresh_newest_package function
  again
- Remove unused clone_newest_package function

* Mon Jan 12 2015 Matej Kollar <mkollar@redhat.com> 2.3.30-1
- Getting rid of trailing spaces in XML
- Getting rid of trailing spaces in Perl
- Getting rid of trailing spaces in Perl
- Getting rid of Tabs in Perl
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Wed Dec 17 2014 Stephen Herr <sherr@redhat.com> 2.3.29-1
- remove monitoring thing from web so we can run directly out of this branch

* Thu Dec 11 2014 Grant Gainey 2.3.28-1
- 1168191 - Remove vestige of ctxt-sensitive help, and teach PXT::HTML->link
  not to link when there is no url

* Mon Dec 08 2014 Jan Dobes 2.3.27-1
- generalize logic

* Fri Dec 05 2014 Stephen Herr <sherr@redhat.com> 2.3.26-1
- spacewalk-web: add Requires for used perl modules

* Wed Dec 03 2014 Grant Gainey 2.3.25-1
- 1024118 - Perl context-help doesn't notice empty help-url strings
- revert accidentaly pushed commits
- padding on all widths

* Thu Nov 27 2014 Tomas Lestach <tlestach@redhat.com> 2.3.24-1
- 1168191 - s1-sm-systems.html does not exist any more

* Thu Nov 27 2014 Jan Dobes 2.3.23-1
- render empty tag instead of empty string for proper list buttons indentation

* Wed Nov 26 2014 Jan Dobes 2.3.22-1
- fixing size of list navigation buttons
- improve header alignment
- unify style on create and edit page

* Fri Nov 21 2014 Jan Dobes 2.3.21-1
- style nav submenu on pxt pages too

* Thu Nov 20 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.20-1
- 1165057 - use scl wrapper for postgresql92 binaries
- 1165070 - use correct service name

* Wed Nov 12 2014 Stephen Herr <sherr@redhat.com> 2.3.19-1
- 1151183 - clean up remnants of prototype.js, convert to jQuery

* Wed Nov 12 2014 Grant Gainey 2.3.18-1
- 1150984 - fix form-field-name for create-notification

* Tue Nov 04 2014 Jan Dobes 2.3.17-1
- we don't actually need equal height columns there

* Tue Nov 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.16-1
- minor updates to strings / wording

* Tue Oct 21 2014 Tomas Lestach <tlestach@redhat.com> 2.3.15-1
- limit snapshot tag length to the DB field lenght
- 1150526 - introduce a check for an empty snapshot tag for ssm
- 1024118 - Remove bogus help-url/rhn-help/helpUrl links from all pages

* Wed Oct 15 2014 Jan Dobes 2.3.14-1
- there is more to hide on unauthenticated pages

* Tue Oct 14 2014 Jan Dobes 2.3.13-1
- style SSM status bar

* Thu Oct 09 2014 Jan Dobes 2.3.12-1
- style perl local messages
- style /network/software/channels/manage/edit.pxt

* Mon Oct 06 2014 Jan Dobes 2.3.11-1
- style lot of buttons
- missing bootstrap class for textarea

* Fri Sep 26 2014 Tomas Kasparek <tkasparek@redhat.com> 2.3.10-1
- patternfly: don't hide SSM when no systems are selected
- patternfly: fixed SSM animation duration
- Integrating patternfly for more awesomeness...

* Mon Sep 22 2014 Tomas Lestach <tlestach@redhat.com> 2.3.9-1
- we need Apache24Config.pm on fedoras

* Wed Sep 17 2014 Stephen Herr <sherr@redhat.com> 2.3.8-1
- 1138708, 1142110 - make child channel architecture check universal

* Thu Sep 11 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.7-1
- RHEL7 contains apache 2.4

* Tue Sep 02 2014 Stephen Herr <sherr@redhat.com> 2.3.6-1
- 1136529 - Add aarch64 and ppc64le to parent-child channel compatibility list

* Fri Aug 01 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.5-1
- 1117976 - WebUI cloning uses the same SQL query as API

* Fri Aug 01 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.4-1
- Use text mode and set editor to read only

* Tue Jul 29 2014 Jan Dobes 2.3.3-1
- update linking and delete old page

* Tue Jul 15 2014 Stephen Herr <sherr@redhat.com> 2.3.2-1
- 1117047 - db-control manpage fixes

* Mon Jul 14 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.3.1-1
- change version for Spacewalk 2.3 nightly
- Bumping package versions for 2.3.

* Mon Jul 14 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.32-1
- Removing nightly string

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.31-1
- fix copyright years

* Thu Jun 26 2014 Stephen Herr <sherr@redhat.com> 2.2.30-1
- SSM power management operation page added
- SSM power management configuration page added
- Single-system power management page added

* Fri Jun 20 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.29-1
- 249743 - add robots.txt

* Mon Jun 02 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.28-1
- removed unused code (snapshot pxt pages related)

* Fri May 30 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.27-1
- select2-bootstrap-css packaged
- select2 packaged
- jQuery UI packaged
- rewrite unservable_packages.pxt page to java

* Thu May 29 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.26-1
- removed unused code

* Thu May 29 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.25-1
- removed unused code
- removed snapshot pxt pages which were rewritten to java
- Fix refreshing of Autoinstallable Tree forms (bnc#874144)

* Tue May 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.24-1
- rewrite system snapshot to java: Rollback.do

* Mon May 26 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.23-1
- removed unused code

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.22-1
- moved system snapshots pages to java

* Thu May 22 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.21-1
- Removed groups.pxt and related code / db queries
- system groups & snapshots page: converted from pxt to java
- Add development_environment to rhn_web.conf

* Tue May 20 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.20-1
- links to Snapshot Tags pages
- removed pxt pages and related code which had been converted to java
- navigation links to new pages (Tags.do)
- The old picker in isLatin mode transmitted 1-12 not 0-11 In 24 hour format is
  0-23 even if DatePicker.getHourRange() and getHour javadoc is wrong
  (1-11!!!).
- Fix bug converting pm times to am when using locales in 24 hour format. See:
  https://www.redhat.com/archives/spacewalk-list/2014-April/msg00011.html

* Mon May 12 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.19-1
- Extract function to humanize dates so that it can be used after DOM changes

* Tue May 06 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.18-1
- remove old perl pages
- delete unused code in modules/rhn/RHN/Server.pm related to system events
- delete unused code in modules/rhn/RHN/DB/Server.pm related to system events
- rewrite pending events page from perl to java

* Wed Apr 30 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.17-1
- 1091365 - style alert messages on perl pages

* Fri Apr 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.16-1
- Replace editarea with ACE (http://ace.c9.io/) editor.

* Tue Apr 22 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.15-1
- removed obsolered code
- rewrite system snapshot to java: removed obsoleted perl page
- rewrite system snapshot to java: Packages.do
- rewrite system event page from perl to java

* Wed Apr 16 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.14-1
- rewrite system snapshot to java: removed old perl page
- rewrite system snapshot to java: Index.do

* Mon Apr 14 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.13-1
- removed unused perl code
- limit actions displayed on schedule/*actions pages

* Fri Apr 11 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.12-1
- Safer DWR callback method introduced
- Refactoring: utility method makeAjaxCallback renamed
- removed unused system_profile_comparison
- removed unused packages_for_sync_provider()

* Fri Apr 11 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.11-1
- removed unused sync_packages_to_channel_cb()
- removed unused managed_channel_merge_preview_provider()
- removed unused sync_confirm_packages_in_set_provider()
- removed unused compare_managed_channel_packages_provider()
- rewrite channel compare to java: removed obsoleted perl pages
- 903068 - fixed debian repo generation

* Mon Mar 31 2014 Stephen Herr <sherr@redhat.com> 2.2.10-1
- fixed bug unable to delete action chain
- fixed typo in action chain jsp and js
- Action Chain Edit page added
- Front-end code for action chain creation/selection added
- Javascript library jQuery UI added
- Javascript library select2 added

* Fri Mar 28 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.9-1
- Fail if rhnPackage.path is NULL
- Avoid trimming filename to 128 chars

* Fri Mar 21 2014 Stephen Herr <sherr@redhat.com> 2.2.8-1
- Update edit_notification_method.pxi
- Rewrite code for bootstrap usage

* Tue Mar 18 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.7-1
- spacewalk-web: use SHA-256 for session keys
- RHN::Session - update documentation

* Fri Mar 14 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.6-1
- update navigation link: Install -> Create First User

* Thu Mar 06 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.5-1
- remove usage of web_contact.old_password from code

* Thu Mar 06 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.4-1
- moved duplicated code to function
- system_upgradable_package_list is not referenced anymore
- on-click and node-id attributes are relevant only to pxt pages
- removed unused up2date_version_at_least()
- removed unused rhn-up2date-at-least tag

* Wed Mar 05 2014 Jan Dobes 2.2.3-1
- control menu type switching completely with css instead of javascript

* Mon Mar 03 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.2-1
- make the setup of the date picker more declarative using data- attributes in
  order to be able to share this setup with other parts of the code that will
  need a slightly different picker like the recurrent selector. It also saves
  us from outputing one <script> tag in the jsp tag implementation.

* Mon Feb 24 2014 Matej Kollar <mkollar@redhat.com> 2.2.1-1
- Bumping web version for 2.2.

* Mon Feb 24 2014 Matej Kollar <mkollar@redhat.com> 2.2.0-1
- Bumping package versions for 2.2.
* Thu Feb 20 2014 Tomas Kasparek <tkasparek@redhat.com> 2.1.59-1
- give generated buttons appropriate class
- Styling unstyled submit buttons.
- Perl Pages: Styling unstyled submit buttons
- Revert "Refeactored cookie parsing code to better handle malformed cookies"

* Mon Feb 17 2014 Matej Kollar <mkollar@redhat.com> 2.1.58-1
- Refeactored cookie parsing code to better handle malformed cookies

* Fri Feb 14 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.57-1
- make the time format also localized
- Introduce a date-time picker.

* Wed Feb 12 2014 Tomas Kasparek <tkasparek@redhat.com> 2.1.56-1
- Fixes bar going from 0..9 A..Z on
  /rhn/systems/details/packages/PackageList.do but A..Z 0..9 on
  /rhn/systems/SystemEntitlements.do and
  /network/systems/system_list/regular_in_channel_family.pxt
- different set of pagination arrows on
  /network/systems/system_list/regular_in_channel_family.pxt

* Tue Feb 11 2014 Grant Gainey 2.1.55-1
- 1063915, CVE-2013-4415 - Missed changing Search.do to post, perl-side

* Tue Feb 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.54-1
- changes in the logic to update the tick icon

* Wed Jan 29 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.53-1
- adding caller script and tick icon function

* Mon Jan 27 2014 Matej Kollar <mkollar@redhat.com> 2.1.52-1
- Fixed unstyled form in PXT page: SSM/Groups
- Fixed unstyled form in PXT page: SSM/Provisioning/TagSystems

* Mon Jan 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.51-1
- Add a rhn-date tag
- Implement rhn:formatDate that uses moment.js on the client side. It supports
  also most of fmt:formatDate options.

* Fri Jan 24 2014 Jan Dobes 2.1.50-1
- delete old pages
- porting system group monitoring probes page to java
- remove unused perl code after porting reboot_confirm.pxt to java
- port reboot_confirm.pxt from perl to java

* Thu Jan 16 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.49-1
- 1053787 - fixed icon name
- 1053787 - point links to new java ProbesList pages

* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.48-1
- Updating the copyright years info

* Fri Jan 10 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.47-1
- replaced old monitoring images with icons
- perl List port to new css/markup

* Fri Jan 10 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.46-1
- Deleting obsoleted perl pages
- removed dead js file

* Thu Jan 09 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.45-1
- use packaged upstream bootstrap js files

* Thu Dec 19 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.44-1
- updated references to new java WorkWithGroup page
- rewrite system event history page to java
- removed unused pxt page
- updated links to system group delete page
- fixing references to SSM errata page

* Mon Dec 16 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.43-1
- Remove groups/errata_list.pxt
- fixed icon names

* Fri Dec 13 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.42-1
- replaced icons with icon tag
- system group edit properties - linking + cleanup

* Wed Dec 11 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.41-1
- updated pxt pages to use <rhn-icon> tag
- updated perl modules to use PXT::HTML->icon()
- bootstrap tuning: reimplemented icon tag in pxt
- System Group / Admins - updated links and removed old page

* Mon Dec 09 2013 Jan Dobes 2.1.40-1
- system group details - linking + cleanup

* Wed Dec 04 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.39-1
- bootstrap tuning

* Wed Dec 04 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.38-1
- bootstrap tuning

* Tue Dec 03 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.37-1
- bootstrap tuning

* Tue Dec 03 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.36-1
- bootstrap tuning: fixed doubled item separator

* Mon Dec 02 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.35-1
- bootstrap tuning

* Fri Nov 29 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.34-1
- HTML 5 does allow "_new" as a valid target
- remove old debug message

* Mon Nov 18 2013 Jan Dobes 2.1.33-1
- 1012468 - errata cloning optimalizations in perl

* Mon Nov 18 2013 Tomas Lestach <tlestach@redhat.com> 2.1.32-1
- replace 'Channel Managemet Guide' docs with 'User Guide' and 'Getting Started
  Guide'

* Fri Nov 15 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.31-1
- polishing changelog
- making db-control work with pg 9.2 from rhscl

* Thu Nov 14 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.30-1
- Bootstrap 3.0 changes, brand new WebUI look

* Thu Oct 31 2013 Matej Kollar <mkollar@redhat.com> 2.1.29-1
- 1020952 - Single db root cert + option name change
- 1020952 - SSL for Postgresql: Java (Perl DBI)

* Thu Oct 24 2013 Jan Dobes 2.1.28-1
- 1015747 - cleanup
- 1015747 - new jsp page + nav stuff

* Wed Oct 23 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.27-1
- report package arch in Event History

* Tue Oct 22 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.26-1
- add support for enhances rpm weak dependency (web) (bnc#846436)
- 1020497 - provide a way to order kickstart scripts

* Tue Oct 15 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.25-1
- 1018194 - convert empty string to NULL

* Wed Oct 09 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.24-1
- cleaning up old svn Ids

* Mon Oct 07 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.23-1
- Revert "removing Perl reboot system page"
- Revert "removing Perl code associated with reboot system page"

* Tue Oct 01 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.22-1
- 1013629 - clean up old help links

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.21-1
- do not reshape logo in un-authenitaced 40x and 500 pages

* Tue Sep 10 2013 Tomas Lestach <tlestach@redhat.com> 2.1.20-1
- 1006403 - fix encodig in web

* Tue Sep 10 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.19-1
- removing Perl remote command page
- removing Perl code associated with reboot system page
- removing Perl reboot system page

* Tue Sep 03 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.18-1
- new features should be visible also from Perl pages

* Mon Sep 02 2013 Tomas Lestach <tlestach@redhat.com> 2.1.17-1
- 1001922 - set correct menu for reboot_confirm.pxt
- update Provisioning - Schedule url
- update remote command menu url
- 993978 - removing oracle specific code

* Fri Aug 30 2013 Tomas Lestach <tlestach@redhat.com> 2.1.16-1
- 1002905 - fix ISE on /network/systems/system_list/flex_in_channel_family.pxt

* Fri Aug 30 2013 Tomas Lestach <tlestach@redhat.com> 2.1.15-1
- 1001826 - restrictions to channel name (update)

* Wed Aug 28 2013 Dimitar Yordanov <dyordano@redhat.com> 2.1.14-1
- 1001826 - restrictions to channel name

* Wed Aug 28 2013 Tomas Lestach <tlestach@redhat.com> 2.1.13-1
- Revert "1001997 - let spacewalk-base-minimal require spacewalk-base-minimal-
  config"

* Wed Aug 28 2013 Tomas Lestach <tlestach@redhat.com> 2.1.12-1
- 1001997 - let spacewalk-base-minimal require spacewalk-base-minimal-config

* Thu Aug 22 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.11-1
- removing old perl code associated with dead perl pages
- removing old perl pages

* Tue Aug 20 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.10-1
- Revert "993978 - remove check-database-space-usage.sh from cron.daily"
- 993978 - make check-database-space-usage.sh usable on managed-db

* Tue Aug 20 2013 Jan Dobes 2.1.9-1
- 998862 - connect to db as postgres instead of root

* Tue Aug 20 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.8-1
- removing code associated with dead perl pages
- removing old perl pages

* Tue Aug 20 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.7-1
- Perl to JSP port: SSM/Provisioning/RemoteCommand

* Mon Aug 19 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.6-1
- 993978 - remove check-database-space-usage.sh from cron.daily

* Thu Aug 15 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.5-1
- removing code associated with old pxt pages
- deleting old pxt lock/unlock pages
- use default rhn.conf only when it exists

* Tue Aug 13 2013 Jan Dobes 2.1.4-1
- 950382 - print error message instead of perl error

* Tue Aug 06 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.3-1
- Branding clean-up of proxy stuff in web dir

* Fri Jul 19 2013 Tomas Lestach <tlestach@redhat.com> 2.1.2-1
- 726815 - parent channel cannot be a shared channel from different org when
  cloning

* Thu Jul 18 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.1-1
- bumping Spacewalk version to 2.1 nightly
- Bumping package versions for 2.1.

