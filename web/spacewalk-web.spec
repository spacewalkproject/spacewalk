%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

Name: spacewalk-web
Summary: Spacewalk Web site - Perl modules
Group: Applications/Internet
License: GPLv2
Version: 2.1.39
Release: 1%{?dist}
URL:          https://fedorahosted.org/spacewalk/
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n) 
BuildArch: noarch
BuildRequires: perl(ExtUtils::MakeMaker)

%description
This package contains the code for the Spacewalk Web Site.
Normally this source RPM does not generate a %{name} binary package,
but it does generate a number of sub-packages.

%package -n spacewalk-html
Summary: HTML document files for Spacewalk
Group: Applications/Internet
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
Group: Applications/Internet
Summary: Programs needed to be installed on the RHN Web base classes
Requires: spacewalk-pxt
Provides: spacewalk(spacewalk-base) = %{version}-%{release}
Requires: /usr/bin/sudo 
Requires: webserver
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Obsoletes: rhn-base < 5.3.0
Provides: rhn-base = 5.3.0


%description -n spacewalk-base
This package includes the core RHN:: packages necessary to manipulate
database.  This includes RHN::* and RHN::DB::*.


%package -n spacewalk-base-minimal
Summary: Core of Perl modules for %{name} package
Group: Applications/Internet 
Provides: spacewalk(spacewalk-base-minimal) = %{version}-%{release}
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Obsoletes: rhn-base-minimal < 5.3.0
Provides: rhn-base-minimal = 5.3.0

%description -n spacewalk-base-minimal
Independent Perl modules in the RHN:: name-space.
This are very basic modules need to handle configuration files, database,
sessions and exceptions.

%package -n spacewalk-base-minimal-config
Summary: Configuration for %{name} package
Group: Applications/Internet
Provides: spacewalk(spacewalk-base-minimal-config) = %{version}-%{release}
Requires: httpd
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires: spacewalk-base-minimal = %{version}-%{release}

%description -n spacewalk-base-minimal-config
Configuration file for spacewalk-base-minimal package.


%package -n spacewalk-dobby
Summary: Perl modules and scripts to administer an Oracle database
Group: Applications/Internet
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Obsoletes: rhn-dobby < 5.3.0
Provides: rhn-dobby = 5.3.0
Requires: %{sbinpath}/runuser

%description -n spacewalk-dobby
Dobby is collection of Perl modules and scripts to administer an Oracle
database.


%package -n spacewalk-grail
Summary: Grail, a component framework for Spacewalk
Requires: spacewalk-base
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Group: Applications/Internet
Obsoletes: rhn-grail < 5.3.0
Provides: rhn-grail = 5.3.0

%description -n spacewalk-grail
A component framework for Spacewalk.


%package -n spacewalk-pxt
Summary: The PXT library for web page templating
Group: Applications/Internet
Requires: spacewalk(spacewalk-base-minimal-config)
Requires: httpd
Obsoletes: rhn-pxt < 5.3.0
Provides:  rhn-pxt = 5.3.0
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description -n spacewalk-pxt
This package is the core software of the new Spacewalk site.  It is responsible
for HTML, XML, WML, HDML, and SOAP output of data.  It is more or less
equivalent to things like Apache::ASP and Mason.


%package -n spacewalk-sniglets
Group: Applications/Internet 
Summary: PXT Tag handlers
Obsoletes: rhn-sniglets < 5.3.0
Provides:  rhn-sniglets = 5.3.0
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description -n spacewalk-sniglets
This package contains the tag handlers for the PXT templates.


%prep
%setup -q

%build
make -f Makefile.spacewalk-web PERLARGS="INSTALLDIRS=vendor" %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make -C modules install DESTDIR=$RPM_BUILD_ROOT PERLARGS="INSTALLDIRS=vendor" %{?_smp_mflags}
make -C html install PREFIX=$RPM_BUILD_ROOT
make -C include install PREFIX=$RPM_BUILD_ROOT

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
%if 0%{?fedora} < 18
rm -f $RPM_BUILD_ROOT%{perl_vendorlib}/PXT/Apache24Config.pm
%endif


%clean
rm -rf $RPM_BUILD_ROOT

%files -n spacewalk-base
%dir %{perl_vendorlib}/RHN
%dir %{perl_vendorlib}/PXT
%{perl_vendorlib}/RHN.pm
%{perl_vendorlib}/RHN/Access.pm
%{perl_vendorlib}/RHN/Access/
%{perl_vendorlib}/RHN/Action.pm
%{perl_vendorlib}/RHN/Cache/
%{perl_vendorlib}/RHN/Cert.pm
%{perl_vendorlib}/RHN/Channel.pm
%{perl_vendorlib}/RHN/ChannelEditor.pm
%{perl_vendorlib}/RHN/Cleansers.pm
%{perl_vendorlib}/RHN/ConfigChannel.pm
%{perl_vendorlib}/RHN/ConfigRevision.pm
%{perl_vendorlib}/RHN/ContactGroup.pm
%{perl_vendorlib}/RHN/ContactMethod.pm
%{perl_vendorlib}/RHN/CustomInfoKey.pm
%{perl_vendorlib}/RHN/DB/
%{perl_vendorlib}/RHN/DataSource.pm
%{perl_vendorlib}/RHN/DataSource/
%{perl_vendorlib}/RHN/Date.pm
%{perl_vendorlib}/RHN/Entitlements.pm
%{perl_vendorlib}/RHN/Errata.pm
%{perl_vendorlib}/RHN/ErrataEditor.pm
%{perl_vendorlib}/RHN/ErrataTmp.pm
%{perl_vendorlib}/RHN/FileList.pm
%{perl_vendorlib}/RHN/Form.pm
%{perl_vendorlib}/RHN/Form/
%{perl_vendorlib}/RHN/I18N.pm
%{perl_vendorlib}/RHN/KSTree.pm
%{perl_vendorlib}/RHN/Kickstart.pm
%{perl_vendorlib}/RHN/Kickstart/
%{perl_vendorlib}/RHN/Mail.pm
%{perl_vendorlib}/RHN/Manifest.pm
%{perl_vendorlib}/RHN/Org.pm
%{perl_vendorlib}/RHN/Package.pm
%{perl_vendorlib}/RHN/Package/
%{perl_vendorlib}/RHN/Profile.pm
%{perl_vendorlib}/RHN/SCDB.pm
%{perl_vendorlib}/RHN/SatCluster.pm
%{perl_vendorlib}/RHN/SatInstall.pm
%{perl_vendorlib}/RHN/SatelliteCert.pm
%{perl_vendorlib}/RHN/Scheduler.pm
%{perl_vendorlib}/RHN/SearchTypes.pm
%{perl_vendorlib}/RHN/Server.pm
%{perl_vendorlib}/RHN/ServerActions.pm
%{perl_vendorlib}/RHN/ServerGroup.pm
%{perl_vendorlib}/RHN/Session.pm
%{perl_vendorlib}/RHN/Set.pm
%{perl_vendorlib}/RHN/StoredMessage.pm
%{perl_vendorlib}/RHN/SystemSnapshot.pm
%{perl_vendorlib}/RHN/TSDB.pm
%{perl_vendorlib}/RHN/Tag.pm
%{perl_vendorlib}/RHN/Token.pm
%{perl_vendorlib}/RHN/User.pm
%{perl_vendorlib}/RHN/Utils.pm
%{_mandir}/man3/RHN::ContactGroup.3pm.gz
%{_mandir}/man3/RHN::ContactMethod.3pm.gz
%{_mandir}/man3/RHN::DB::ContactGroup.3pm.gz
%{_mandir}/man3/RHN::DB::ContactMethod.3pm.gz
%{_mandir}/man3/RHN::DB::SatCluster.3pm.gz
%{_mandir}/man3/RHN::DB::ServerGroup.3pm.gz
%{_mandir}/man3/RHN::SCDB.3pm.gz
%{_mandir}/man3/RHN::SatCluster.3pm.gz
%{_mandir}/man3/RHN::Session.3pm.gz
%{_mandir}/man3/RHN::TSDB.3pm.gz

%files -n spacewalk-base-minimal
%dir %{perl_vendorlib}/RHN
%dir %{perl_vendorlib}/PXT
%{perl_vendorlib}/RHN/SessionSwap.pm
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

%files -n spacewalk-grail
%{perl_vendorlib}/Grail.pm
%{perl_vendorlib}/Grail/

%files -n spacewalk-pxt 
%{perl_vendorlib}/PXT.pm
%{perl_vendorlib}/PXT/
%exclude %{perl_vendorlib}/PXT/Config.pm
%{_mandir}/man3/PXT::ApacheHandler.3pm.gz

%files -n spacewalk-sniglets 
%{perl_vendorlib}/Sniglets.pm
%{perl_vendorlib}/Sniglets/

%files -n spacewalk-html
%{_var}/www/html/*
%{_datadir}/spacewalk/web
%doc LICENSE

%changelog
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

* Thu Jul 18 2013 Jan Dobes 2.0.2-1
- 980206 - checksum whole file, not only archive content

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.41-1
- updating copyright years

* Tue Jul 16 2013 Grant Gainey <ggainey@redhat.com> 1.10.40-1
- 985070 - Found and fixed Perl error on failed event

* Tue Jul 16 2013 Jan Dobes 1.10.39-1
- 980406 - log relative paths in backup dir
- 950382 - show actual user

* Tue Jul 16 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.38-1
- removing some dead code

* Fri Jul 12 2013 Tomas Lestach <tlestach@redhat.com> 1.10.37-1
- Adding the logging to the web (Perl) stack.
- drop and backup logging schema

* Tue Jul 09 2013 Jan Dobes 1.10.36-1
- 858655 - user postgres shouldn't be mentioned here

* Tue Jul 09 2013 Tomas Lestach <tlestach@redhat.com> 1.10.35-1
- clean up managers.pxt
- rewrite /network/software/channels/managers.pxt page to java

* Mon Jul 01 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.34-1
- 978288 - lookup for defaults also in /usr/share/rhn/config-defaults/rhn.conf

* Mon Jul 01 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.33-1
- 979924 - fixing duplicate SSM, System List page

* Thu Jun 20 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.32-1
- spacewalk-dobby: use the rhn_dobby.conf config file by default
- 815236 - add GNU General Public License

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.31-1
- more branding cleanup

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.30-1
- moved product name to work also in proxy

* Thu Jun 13 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.29-1
- 970579 - new features should be visible also from perl pages

* Wed Jun 12 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.28-1
- rhn_web.conf is no longer part of spacewalk-base-minimal

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.27-1
- rebranding RHN Proxy to Red Hat Proxy
- rebrading RHN Satellite to Red Hat Satellite

* Mon Jun 10 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.26-1
- 970146 - fix db-control examine and verify for online backups

* Wed Jun 05 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.25-1
- spacewalk-dobby: remove dependency on apache, spacewalk-base, spacewalk-setup
- Move RHN::SimpleStruct from spacewalk-base to spacewalk-base-minimal
- Split rhn_web.conf into a separate package

* Wed May 22 2013 Tomas Lestach <tlestach@redhat.com> 1.10.24-1
- removing outdated/unused web.ep_* configuration options

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.23-1
- misc branding clean up

* Thu Apr 18 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.22-1
- moved rest of pxi files to include dir
- removing dead code

* Tue Apr 16 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.21-1
- database should run when performing online restore
- let restore work for both online and offline backup
- renamed option to online-backup
- implemented shrinking segments for postgresql
- warn user about running services
- restore should not shutdown services automatically
- removing WEB_ALLOW_PXT_PERSONALITIES

* Fri Apr 12 2013 Jan Pazdziora 1.10.20-1
- 951056 - fix correct menu highlight for
  /network/systems/details/history/snapshots/add_system_tag.pxt

* Wed Apr 10 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.19-1
- unlink doesn't work on directories

* Mon Apr 08 2013 Tomas Lestach <tlestach@redhat.com> 1.10.18-1
- changing config-defaults files' rights to 644

* Fri Apr 05 2013 Tomas Lestach <tlestach@redhat.com> 1.10.17-1
- add RHN::Form::Widget::Select to ChannelEditor

* Thu Mar 28 2013 Jan Pazdziora 1.10.16-1
- We use RHN::Form::ParsedForm so we should use it.

* Tue Mar 26 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.15-1
- changing .spec to reflect changes

* Tue Mar 26 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.14-1
- removing ty from perl code as packages for kickstart are downloaded via java

* Tue Mar 26 2013 Jan Pazdziora 1.10.13-1
- Mode system_available_packages not used in web/, removing.

* Tue Mar 26 2013 Jan Pazdziora 1.10.12-1
- Use to_timestamp instead of to_date which should bring the second precision
  to PostgreSQL.

* Mon Mar 25 2013 Jan Dobes 1.10.11-1
- Adding sudo Requires for spacewalk-base package

* Mon Mar 25 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.10-1
- 918045 - fixed shring-segments for tables in recyclebin

* Fri Mar 22 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.9-1
- 919468 - fixed path in file based Requires

* Thu Mar 21 2013 Jan Pazdziora 1.10.8-1
- 922250 - use $r->useragent_ip on Apache 2.4, $r->connection->remote_ip
  otherwise.

* Fri Mar 15 2013 Jan Pazdziora 1.10.7-1
- Mode user_permissions not used, removing from web/.
- Replacing integer nvl with coalesce.
- The server_overview elaborator not used, removing.
- The mode namespaces_visible_to_user is not used anywhere, removing.
- Removing unused system_search_elaborators queries.
- Search setbuilders are no longer used in web/.
- Removing unused query definitions.
- Fixing Oracle-specific outer join syntax, use of PE.evr.*, and missing joins.

* Thu Mar 14 2013 Jan Pazdziora 1.10.6-1
- Display package list on page history/event.pxt.
- rhn-iecompat.css is never used - delete it

* Wed Mar 13 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.5-1
- removing unused styles and refactoring blue-nav-top.css and adjacent files

* Tue Mar 12 2013 Jan Pazdziora 1.10.4-1
- Methods packages_in_channel seem no longer used, removing.

* Fri Mar 08 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.3-1
- Fedora 19 does not provide /sbin/runuser

* Tue Mar 05 2013 Jan Pazdziora 1.10.2-1
- To match backend processing of the config files, do not strip comments from
  values.

* Mon Mar 04 2013 Stephen Herr <sherr@redhat.com> 1.10.1-1
- Updateing Spacewalk version to 1.10
- Bumping package versions for 1.9

* Fri Mar 01 2013 Stephen Herr <sherr@redhat.com> 1.9.21-1
- this version should not be updated yet

* Fri Mar 01 2013 Stephen Herr <sherr@redhat.com> 1.9.20-1
- Updating API versions for release
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Thu Feb 28 2013 Jan Pazdziora 1.9.19-1
- Removing the dsn parameter from initDB, removing support for --db option.

* Wed Feb 20 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.18-1
- Apache2::Provider is unused

* Tue Feb 12 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.17-1
- removed unused pxt page

* Mon Feb 11 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.16-1
- install Apache24Config.pm in on Fedora with apache 2.4

* Fri Feb 08 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.15-1
- $reqs was always equal $passes
- acl is the only one supported type now
- removed unused valid-user type
- make pxt ACL work in apache 2.4
- simplify @requires list
- merged .htaccess to main httpd configuration
- Silence the Statement unlikely to be reached at /usr/bin/db-control line 29
  warning.

* Wed Feb 06 2013 Stephen Herr <sherr@redhat.com> 1.9.14-1
- Make it possible to run db-control without doing su - oracle first.

* Tue Feb 05 2013 Jan Pazdziora 1.9.13-1
- Removing hw_prof_update_conf.pxt, pkg_prof_update_conf.pxt, and
  rhn:server_set_actions_cb as they have been replaced by .do pages.
- Removed /network/systems/ssm/misc/index.pxt, it is no longer referenced (was
  bundled with the tagging commit).

* Mon Feb 04 2013 Jan Pazdziora 1.9.12-1
- Automatic commit of package [rhncfg] release [5.10.41-1].
- Removed /network/systems/ssm/misc/index.pxt, it is no longer referenced.
- Redirect to landing.pxt to flush out the blue messages, then go to Index.do.
- The gpg_info.pxt is only referenced from channel_gpg_key, only used by rhn-
  channel-gpg-key in this page, removing.

* Fri Feb 01 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.11-1
- no-access is no more used

* Thu Jan 31 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.10-1
- moved template files out of document root
- look for pxt includes outside of document root

* Mon Jan 28 2013 Jan Pazdziora 1.9.9-1
- With removal of TracerList, all_traces is not longer used, removing.

* Thu Jan 24 2013 Tomas Lestach <tlestach@redhat.com> 1.9.8-1
- 886831 - replace sysdate with current_timestamp for package synchronisation
  removal

* Fri Jan 18 2013 Jan Pazdziora 1.9.7-1
- Removing no longer used rhnChannelDownloads, rhnDownloads, and
  rhnDownloadType.
- The channel_has_downloads acl and has_downloads are not longer used,
  removing.
- Removing the Downloads tab, it points to nonexisting
  /rhn/software/channel/downloads/Download.do page.

* Wed Jan 09 2013 Tomas Lestach <tlestach@redhat.com> 1.9.6-1
- 893068 - Fixing enable_snapshot typo

* Fri Dec 07 2012 Jan Pazdziora 1.9.5-1
- Remove sysdate keyword

* Wed Nov 28 2012 Tomas Lestach <tlestach@redhat.com> 1.9.4-1
- 470463 - fixing xmllint issue

* Wed Nov 21 2012 Jan Pazdziora 1.9.3-1
- Revert "removed dead query"
- Revert "The ssm_rollback_by_tag_action_cb method no longer referenced,
  removing."

* Fri Nov 09 2012 Jan Pazdziora 1.9.2-1
- 490524 - Return the datetime in the local time zone.
- 490524 - Epoch is always in UTC, no time_zone setting for epoch case.
- Function date_to_epoch made obsolete, not used anymore.
- The from_zone parameter is not used anywhere.
- Use RHN::Date where it is used (only).
- 490524 - Avoid initializing the object with local only to call time_zone
  right away.
- 490524 - Shortcut RHN::Date->now->long_date, avoiding DateTime.

* Wed Oct 31 2012 Jan Pazdziora 1.9.1-1
- Bumping version string to 1.9.
- Bumping package versions for 1.9.

* Tue Oct 30 2012 Jan Pazdziora 1.8.48-1
- Update the copyright year.
- Make RHN::DB::SystemSnapshot usable with strict.

* Mon Oct 22 2012 Jan Pazdziora 1.8.47-1
- 852039 - get rid of useless error messages when verifying backup with db-
  control
- 552628 - added reset-password to man page
- 552628 - alter command can't use bind variables
- 852038 - Using fetchall_arrayref instead of fullfetch_arrayref.
- 850714 - do not push strings into an array, when array is expected

* Mon Oct 22 2012 Jan Pazdziora 1.8.46-1
- removing spurious debugging line from check-database-space-usage.sh
- do not restore dirs if there is none to restore
- ignore missing backup_dir on old dumps
- 825804 - check-oracle-space-usage.sh renamed to check-database-space-usage.sh
- 815236 - use df with POSIX compatibility

* Mon Oct 22 2012 Miroslav Suchý
- 805822 - warn about parsing backup log
- 805822 - mark some commands as Oracle only and sync --help with man page
- 815236 - adopt check-oracle-space-usage.sh for PotgreSQL

* Mon Oct 22 2012 Miroslav Suchý
- 805822 - reword --help page

* Mon Oct 22 2012 Miroslav Suchý
- drop plpgsql language before restore
- implement on-line backup and restore on PG
- 805822 - edit man page to include PostgreSQL specific commands
- 663315 - wait until database is really offline
- log into control file empty directories
- correctly set ownership of restored files
- set ownership of restored files under PG
- restore selinux context after restore
- implement "db-control restore" on PG
- db-control under PG can be run as root or postgres user
- implement "db-control examine/verify" on PG
- put into control file base directory
- if size is undef write 0
- implement "db-control backup" on PG
- implement "db-control reset-password" on PG
- implement "db-control report-stats" on PG
- unify connect() with RHN::DBI
- implement "db-control gather-stats" under PG
- mark "db-control extend" and "db-control shrink-segments" as Oracle only
- implement "db-control tablesizes" under PG
- implement "db-control report" under PG
- mark set-optimizer and get-optimizer as Oracle only
- implement "db-control start" and "db-control stop" under PG
- implement "db-control status" under PG

* Tue Oct 16 2012 Jan Pazdziora 1.8.42-1
- Adding use which seems to be needed.

* Fri Oct 12 2012 Jan Pazdziora 1.8.41-1
- 844433 - fix cloning a child channel with a parent in different org
- Bind bytea with PG_BYTEA.

* Thu Oct 11 2012 Jan Pazdziora 1.8.40-1
- Dead code removal.

* Thu Oct 11 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.39-1
- 847194 - Document & set default web.smtp_server
- Module Sniglets::ListView::TracerList not used, removing.
- The database_queries.xml do not seem to be used, removing.

* Thu Oct 11 2012 Tomas Lestach <tlestach@redhat.com> 1.8.38-1
- reverting of web.chat_enabled -> java.chat_enabled translation
- Removing use which is not used.
- Methods server_group_count no longer referenced, removing.
- Methods lookup_key were deprecated long enough, removing.
- Methods compatible_with_server no longer referenced, removing.
- The org_default method no longer referenced, removing.
- Methods package_groups no longer referenced, removing.
- The has_virtualization_entitlement method no longer referenced, removing.
- ACL handler system_entitled no longer used, removing.
- ACL handler system_has_virtualization_entitlement no longer used, removing.
- The latest_packages_in_channel_tree method no longer referenced, removing.
- The /network/systems/details/kickstart/* is not used for a long time.

* Wed Oct 10 2012 Jan Pazdziora 1.8.37-1
- Dead code removal.
- RHN Proxies older than version 5 as no longer supported.

* Thu Sep 20 2012 Jan Pazdziora 1.8.36-1
- Avoid link without eid parameter filled.

* Fri Sep 07 2012 Tomas Lestach <tlestach@redhat.com> 1.8.35-1
- restore changelog
- changing web.chat_enabled -> java.chat_enabled
- move java related configuration the rhn_java.conf

* Wed Sep 05 2012 Stephen Herr <sherr@redhat.com> 1.8.34-1
- 815964 - moving monitoring probe batch option from rhn.conf to rhn_web.conf

* Fri Aug 31 2012 Jan Pazdziora 1.8.33-1
- 852048 - fix typo in db-control man page

* Tue Aug 07 2012 Jan Pazdziora 1.8.32-1
- Remove hints that should no longer be needed.

* Wed Aug 01 2012 Jan Pazdziora 1.8.31-1
- fix outer join syntax

* Mon Jul 30 2012 Tomas Lestach <tlestach@redhat.com> 1.8.30-1
- remove usage of org_applicant user role
- remove usage of rhn_support user role
- remove usage of rhn_superuser user role

* Fri Jul 20 2012 Tomas Kasparek <tkasparek@redhat.com> 1.8.29-1
- 841453  - forcing parameter to be numeric
- Forcing parameter to be string

* Fri Jul 13 2012 Jan Pazdziora 1.8.28-1
- OpenSCAP Integration -- XCCDF Scan Diff

* Thu Jul 12 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.27-1
- Fix ISE on pgsql: Error message: RHN::Exception: DBD::Pg::st execute failed

* Tue Jul 10 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.26-1
- cross-database references are not implemented: pe.evr.as_vre_simple

* Thu Jun 28 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.25-1
- removed unused query

* Wed Jun 27 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.24-1
- ORDER BY expressions must appear in select list
- removed dead query
- fixed ssm provisioning

* Wed Jun 27 2012 Jan Pazdziora 1.8.23-1
- The remove_virtualization_host_entitlement no longer used, removing.
- The rhn:delete_server_cb and delete_server_cb no longer used, removing.
- The delete_confirm.pxt was replaced by DeleteConfirm.do.

* Wed Jun 27 2012 Jan Pazdziora 1.8.22-1
- Perl Notes pages seem like dead code.

* Wed Jun 27 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.21-1
- 835608 - error messages in PostgreSQL have different pattern

* Tue Jun 26 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.20-1
- Correcting ISE on postgresql: NVL keyword

* Fri Jun 22 2012 Jan Pazdziora 1.8.19-1
- For the localhost:5432 case, use the Unix socket local connection.

* Fri Jun 08 2012 Jan Pazdziora 1.8.18-1
- 803370 - call to rhn_server.tag_delete db agnostic

* Mon Jun 04 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.17-1
- Add support for studio image deployments (web UI) (jrenner@suse.de)

* Thu May 31 2012 Jan Pazdziora 1.8.16-1
- OpenSCAP integration -- A simple search page.

* Fri May 25 2012 Stephen Herr <sherr@redhat.com> 1.8.15-1
- 824879, 825279 - Sometimes the return_link on the SSM Clear button does not
  work

* Thu May 10 2012 Jan Pazdziora 1.8.14-1
- Split OpenSCAP and AuditReviewing up (slukasik@redhat.com)

* Thu Apr 26 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.13-1
- add AS syntax for PostgreSQL

* Mon Apr 23 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.12-1
- Fix errata clone name generation in perl code

* Thu Apr 19 2012 Jan Pazdziora 1.8.11-1
- Removed double-dash from copyright notice on error pages.

* Tue Apr 17 2012 Jan Pazdziora 1.8.10-1
- Broken link patch submitted on behalf of Michael Calmer (sherr@redhat.com)

* Thu Apr 12 2012 Stephen Herr <sherr@redhat.com> 1.8.9-1
- 812031 - Update perl channel-select-dropdowns to use the same hierarchical
  sort as java pages (sherr@redhat.com)

* Thu Apr 05 2012 Jan Pazdziora 1.8.8-1
- Fix naming of cloned errata to replace only the first 2 chars
  (tlestach@redhat.com)

* Tue Apr 03 2012 Jan Pazdziora 1.8.7-1
- 806439 - Changing perl sitenav too (sherr@redhat.com)

* Wed Mar 21 2012 Jan Pazdziora 1.8.6-1
- Fixing regular_systems_in_channel_family for PostgreSQL.

* Tue Mar 20 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.5-1
- fixed rhn_server.delete_from_servergroup() call
- Show details of SCAP event.

* Mon Mar 19 2012 Jan Pazdziora 1.8.4-1
- We no longer have /install/index.pxt, so satellite_install cannot be used.

* Tue Mar 13 2012 Simon Lukasik <slukasik@redhat.com> 1.8.3-1
- OpenSCAP integration  -- Show results for system on web.
  (slukasik@redhat.com)

* Tue Mar 13 2012 Jan Pazdziora 1.8.2-1
- Need to point to ReleventErrata.do from .pxt pages as well.
- PXT::Request->clear_session is not used anywhere, thus removing
  (mzazrivec@redhat.com)

* Fri Mar 02 2012 Jan Pazdziora 1.8.1-1
- Bumping version string to 1.8.

* Fri Mar 02 2012 Jan Pazdziora 1.7.27-1
- Update the copyright year info.

* Thu Mar 01 2012 Miroslav Suchý 1.7.26-1
- call plsql function or procedure correctly

* Mon Feb 27 2012 Jan Pazdziora 1.7.25-1
- call composite type correctly on Pg (msuchy@redhat.com)
- call procedure compatible way (Pg) (msuchy@redhat.com)

* Wed Feb 22 2012 Miroslav Suchý 1.7.24-1
- automatically focus search form (msuchy@redhat.com)

* Mon Feb 20 2012 Jan Pazdziora 1.7.23-1
- Removing rhnUser synonym and just using the base web_contact.
- Methods users_in_org and users_in_org_overview do not seem to be used,
  removing.
- The valid_cert_countries in RHN::DB::SatInstall is not used, spacewalk-setup
  has its own version.

* Mon Feb 20 2012 Miroslav Suchý 1.7.22-1
- call procedure compatible way (Pg) (msuchy@redhat.com)
- check if error is RHN::Exception (msuchy@redhat.com)

* Mon Feb 20 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.21-1
- fixed list of patches in solaris package

* Thu Feb 16 2012 Jan Pazdziora 1.7.20-1
- The iso_path parameter is not used anywere, removing the verify_file_access
  cleanser.

* Thu Feb 16 2012 Jan Pazdziora 1.7.19-1
- With update_errata_cache removed, update_cache_for_server is not called
  either, removing.
- With log_user_in removed, removing mark_log_in as well.
- With log_user_in removed, removing clear_selections as well.
- With validate_password_pam gone, Authen::PAM and pam_conversation_func are no
  longer called.
- With check_login gone, validate_password (and validate_password_pam) are not
  longer used.
- With validate_cert gone and no longer calling str2time, use Date::Parse is
  not needed.
- Method has_incomplete_info no longer used, removing.
- With rhn_login_cb gone, update_errata_cache is not longer used.
- With rhn_login_cb gone, log_user_in is not longer used.
- The check_login no longer invoked, removing.
- With the if test for validate_cert gone, /errors/cert-expired.pxt is no
  longer used.
- The validate_cert is no longer called, removing.
- The clear_user method no longer invoked, removing.
- We no longer check cookie_test.
- With rhn_login_cb gone, /errors/cookies.pxt is no longer used, removing.
- The rhn:login_cb and rhn_login_cb are no longer used, removing.
- The [login_form_hidden] is not longer used, removing.
- login_form.pxi no longer used, removing.
- In the /errors/permission.pxt, redirect to the main page to log in again.
- The $package_name_ids parameter never passed.

* Wed Feb 15 2012 Jan Pazdziora 1.7.18-1
- The note_count value is nowhere used in the application code, removing from
  selects.

* Mon Feb 13 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.17-1
- PostgreSQL: Fix adding systems to a system group

* Tue Feb 07 2012 Jan Pazdziora 1.7.16-1
- Updating the oversight in license texts.

* Tue Feb 07 2012 Jan Pazdziora 1.7.15-1
- remove unused code (mzazrivec@redhat.com)
- pgsql: fix notification method deletion (mzazrivec@redhat.com)
- pgsql: fix notification method creation (mzazrivec@redhat.com)

* Wed Feb 01 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.14-1
- fixing string quoting

* Tue Jan 31 2012 Miroslav Suchý 1.7.13-1
- port usage of sequences to PostgreSQL

* Tue Jan 31 2012 Jan Pazdziora 1.7.12-1
- code cleanup: users are not created in web any more (msuchy@redhat.com)
- The RHN::DB::connect does not accept any arguments anymore.
- Factor the connection parameters config read to RHN::DBI, start to use it in
  RHN::DB, also support just one database connection.
- Removing code which is long commented out.
- Removing the web.debug_disable_database option -- it is not supported beyond
  RHN::DB anyway.

* Mon Jan 30 2012 Jan Pazdziora 1.7.11-1
- One sequence_nextval fix.
- Refactored the evr_t(null, ...) and null and max.
- The $rhn_class is always empty, removing.

* Mon Jan 30 2012 Miroslav Suchý 1.7.10-1
- In Spacewalk do not test presence of rhn-proxy family, if we want to display
  list of Proxies
- The target_systems.pxt was migrated to Java years ago.

* Thu Jan 26 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.9-1
- delete server sets at once

* Wed Jan 25 2012 Jan Pazdziora 1.7.8-1
- For DBD::Pg, just use its builtin ping, instead of doing SELECT.
- Make it easier to subclass RHN::DB, use the $class which was passed in.

* Mon Jan 23 2012 Jan Pazdziora 1.7.7-1
- 783223 - fixing sysdate issue in rhn-enable-monitoring.pl.
- Show Proxy tabs on Spacewalk (msuchy@redhat.com)

* Fri Jan 13 2012 Tomas Lestach <tlestach@redhat.com> 1.7.6-1
- 773605 - bring back deleted system_list from the other side of Styx river
  (tlestach@redhat.com)
- 515653 - unify channel architecture label (mzazrivec@redhat.com)

* Wed Jan 04 2012 Tomas Lestach <tlestach@redhat.com> 1.7.5-1
- 771634 - remove semi-colon at the end of queries (tlestach@redhat.com)

* Tue Jan 03 2012 Jan Pazdziora 1.7.4-1
- The RHN::Form::Widget::Multiple, RHN::Form::Widget::Password, and
  RHN::Form::Widget::Spacer seem not used, removing.
- After removal of RHN::CryptoKey, RHN::DB::CryptoKey is no longer used,
  removing.
- After removal of RHN::AppInstall::Parser, RHN::Form::Parser is no longer
  used, removing.
- After removal of RHN::ProxyInstall, RHN::CryptoKey is no longer used,
  removing.

* Mon Jan 02 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.3-1
- fixed merging channels

* Mon Jan 02 2012 Tomas Lestach <tlestach@redhat.com> 1.7.2-1
- 771214 - add missing widget require (tlestach@redhat.com)

* Thu Dec 22 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.7.1-1
- web.version: 1.7 nightly

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.36-1
- update copyright info

* Mon Dec 12 2011 Tomas Lestach <tlestach@redhat.com> 1.6.35-1
- add missing requires (tlestach@redhat.com)
- fix 500 Error - ISE on network/systems/ssm/provisioning/remote_command.pxt
  (tlestach@redhat.com)

* Mon Dec 12 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.34-1
- fix Package queries
- fix ORDER BY expression in DISTINCT select
- use real table name rhn_check_probe
- replace (+) with ANSI left join (PG)
- set selinux_ctx to undef if it is empty
- No need to convert numeric values to upper.
- convert decode to case

* Wed Dec 07 2011 Miroslav Suchý 1.6.33-1
- code cleanup
- do not allow to configure or activate proxy from WebUI

* Tue Dec 06 2011 Jan Pazdziora 1.6.32-1
- IPv6: reprovisioning with static network interface (mzazrivec@redhat.com)
- code cleanup - function base_entitlement is not used anymore
  (msuchy@redhat.com)
- code cleanup - function addon_entitlements is not used anymore
  (msuchy@redhat.com)
- code cleanup - function ks_session_redir is not used anymore
  (msuchy@redhat.com)
- code cleanup - callback rhn:delete_servers_cb is not used anymore
  (msuchy@redhat.com)
- code cleanup - callback server_hardware_list_refresh_cb is not used anymore
  (msuchy@redhat.com)
- code cleanup - tag rhn-server-network-details is not used anymore
  (msuchy@redhat.com)
- code cleanup - tag rhn-server-device is not used anymore (msuchy@redhat.com)
- code cleanup - tag rhn-dmi-info is not used anymore (msuchy@redhat.com)
- code cleanup - tag rhn-server-hardware-profile is not used anywhere
  (msuchy@redhat.com)

* Tue Nov 29 2011 Miroslav Suchý 1.6.31-1
- IPv6: code cleanup - package RHN::DB::Server::NetInterface is not used
  anymore
- IPv6: code cleanup - function get_net_interfaces is not used anymore
- IPv6: code cleanup - function server_network_interfaces is not used anymore
- IPv6: code cleanup - tag rhn-server-network-interfaces is not used anywhere

* Fri Nov 25 2011 Jan Pazdziora 1.6.30-1
- Replace nvl with coalesce.
- Matching the to_char prototype.
- Matching the varchar column to varchar literal.
- Replace decode with case when.
- Replace sysdate with current_timestamp.

* Wed Nov 23 2011 Jan Pazdziora 1.6.29-1
- Fixing cancel a scheduled action on a server.

* Wed Nov 16 2011 Tomas Lestach <tlestach@redhat.com> 1.6.28-1
- 754379 - fix deletion-url in pxt pages (tlestach@redhat.com)

* Fri Nov 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.27-1
- removed aliases from SET part of UPDATE

* Wed Nov 02 2011 Jan Pazdziora 1.6.26-1
- Workaround for DBD::Pg bug https://rt.cpan.org/Ticket/Display.html?id=70953.

* Fri Sep 30 2011 Jan Pazdziora 1.6.25-1
- 678118 - if system already is proxy, losen the ACL and show the tab.
- Recent commit makes version_string_to_evr_array unused, dropping.
- Removing proxy_evr_at_least, org_proxy_evr_at_least, aclOrgProxyEvrAtLeast as
  they are no longer used.
- Remove proxy_evr_at_least ACLs -- all supported proxy versions are 3+.
- Make the pxt Connection acl match the java version -- new acl
  org_has_proxies.

* Fri Sep 30 2011 Jan Pazdziora 1.6.24-1
- 621531 - update web Config to use the new /usr/share/rhn/config-defaults
  location.
- 621531 - move /etc/rhn/default to /usr/share/rhn/config-defaults (web).

* Fri Sep 23 2011 Jan Pazdziora 1.6.23-1
- The /etc/rhn/default/rhn_web.conf does not need to be provided by -pxt since
  it is provided by -base-minimal.

* Mon Sep 19 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.22-1
- 723461 - let emails be sent to localhost by default

* Fri Sep 16 2011 Jan Pazdziora 1.6.21-1
- CVE-2011-3344, 731647 - HTML-encode the self-referencing link.

* Thu Sep 15 2011 Jan Pazdziora 1.6.20-1
- Revert "529483 - adding referer check to perl stack"

* Fri Sep 09 2011 Jan Pazdziora 1.6.19-1
- 616175 - observe the port specified in the URL even for https.

* Thu Aug 25 2011 Miroslav Suchý 1.6.18-1
- 705363 - spacewalk-base and spacewalk-base-minimal are now disjunctive
  remove the provide from spacewalk-base

* Wed Aug 24 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.17-1
- fixed typo in sql query

* Tue Aug 23 2011 Miroslav Suchý 1.6.16-1
- 705363 - reformat description text for spacewalk-base-minimal not to exceed
  80 columns
- 705363 - do not provide perl(PXT::Config) by two packages

* Mon Aug 22 2011 Martin Minar <mminar@redhat.com> 1.6.15-1
- 585010 - mark the Update List button with it so that we can disable it later.
  (jpazdziora@redhat.com)

* Fri Aug 19 2011 Miroslav Suchý 1.6.14-1
- 705363 - remove executable bit from modules and javascript
- 705363 - Replace word "config" with "configuration" in spacewalk-base-minimal
  description
- 705363 - normalize home page URL

* Fri Aug 12 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.13-1
- removed unnecessary join

* Thu Aug 11 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.12-1
- fixed couple more joins
- removed typo parenthesis

* Wed Aug 10 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.11-1
- COALESCE works in both db backends

* Wed Aug 10 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.10-1
- replace oracle specific syntax with ANSI one
- made NVL2 work in both db backends

* Mon Aug 08 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.9-1
- fixed re-activation key in PostgreSQL

* Thu Aug 04 2011 Aron Parsons <aparsons@redhat.com> 1.6.8-1
- add support for custom messages in the header, footer and login pages
  (aparsons@redhat.com)

* Fri Jul 29 2011 Miroslav Suchý 1.6.7-1
- Revert "adding tomcat require to spacewalk-base-minimal"

* Fri Jul 29 2011 Miroslav Suchý 1.6.6-1
- 705363 - remove obscure keys forgotten for ages
- 705363 - Escape percentage symbol in changelog
- 705363 - include LICENSE file in spacewalk-html
- 705363 - defattr is not required any more if do not differ from default
- 705363 - add _smp_mflags macro to make to utilize all CPUs while building
- 705363 - require Perl for all subpackages with Perl modules
- code cleanup - Proxy 4.x and older are not supported for some time, removing
- 705363 - description must end with full stop
- 705363 - spacewalk-web package summary contains lower-case `rpm'
  abbreviation. Use upper case.
- 705363 - clarify description and summary
- 705363 - be more specific about license
- 705363 - change summary of package

* Fri Jul 29 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.5-1
- 724963 - use ANSI joins
- 724963 - use LEFT JOIN instead of MINUS

* Wed Jul 27 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.4-1
- fixed ORA-00904 in remote commands

* Fri Jul 22 2011 Jan Pazdziora 1.6.3-1
- We only support version 14 and newer of Fedora, removing conditions for old
  versions.

* Thu Jul 21 2011 Miroslav Suchý 1.6.2-1
- Sysdate replaced with current_timestamp

* Wed Jul 20 2011 Jan Pazdziora 1.6.1-1
- Bumping up the Spacewalk version to 1.6 (shown on the WebUI).

* Tue Jul 19 2011 Jan Pazdziora 1.5.16-1
- Updating the copyright years.

* Mon Jul 11 2011 Jan Pazdziora 1.5.15-1
- Refactor RedHat.do to Vendor.do (jrenner@suse.de)

* Mon May 30 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.14-1
- made some queries PG compatible
- fixing ISE in errata cloning

* Tue May 24 2011 Jan Pazdziora 1.5.13-1
- replaced (+) with ANSI left join (je@rockenstein.de)

* Thu May 19 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.12-1
- made queries PostgreSQL compatible

* Tue May 17 2011 Miroslav Suchý 1.5.11-1
- spacewalk-pxt.noarch: W: spelling-error %%description -l en_US equlivalent ->
  equivalent, equivalence, univalent (msuchy@redhat.com)

* Tue May 17 2011 Miroslav Suchý 1.5.10-1
- add GPLv2 LICENSE
- migrate .htaccess files to apache core configuration

* Mon May 16 2011 Miroslav Suchý 1.5.9-1
- cleanup - removing old files, and unused sections in .htaccess

* Tue May 10 2011 Jan Pazdziora 1.5.8-1
- Fix remote command schedule date on postgresql (Ville.Salmela@csc.fi)

* Fri May 06 2011 Jan Pazdziora 1.5.7-1
- Fix remote commands on Spacewalk 1.4 and PostgreSQL (Ville.Salmela@csc.fi)

* Thu May 05 2011 Miroslav Suchý 1.5.6-1
- 682112 - correct column name (mzazrivec@redhat.com)
- 682112 - correct displayed systems consuming channel entitlements
  (mzazrivec@redhat.com)

* Mon May 02 2011 Jan Pazdziora 1.5.5-1
- Fixing set_err invocation to match the prototype.

* Mon May 02 2011 Jan Pazdziora 1.5.4-1
- Patch to run remote commands on multiple machines on Spacewalk 1.4
  PostgreSQL. (Ville.Salmela@csc.fi)
- Removal of system_value_edit makes set_custom_value unused, dropping.
- Removal of remove_system_value makes remove_custom_value unused, dropping.
- The can_delete_custominfokey no longer used after previous removals,
  removing.

* Fri Apr 29 2011 Tomas Lestach <tlestach@redhat.com> 1.5.3-1
- fixing system query systems_with_package (tlestach@redhat.com)
- remove macro from changelog (msuchy@redhat.com)

* Fri Apr 15 2011 Jan Pazdziora 1.5.2-1
- show weak deps in Web UI (mc@suse.de)
- 674806 - get / set oracle db optimizer (mzazrivec@redhat.com)

* Mon Apr 11 2011 Miroslav Suchý 1.5.1-1
- bump up version of Spacewalk - both in webUI and API version
- Bumping package versions for 1.5

* Fri Apr 08 2011 Jan Pazdziora 1.4.20-1
- use new database columns errata_from and bug url also in the perl code
  (mc@suse.de)

* Fri Apr 08 2011 Jan Pazdziora 1.4.19-1
- Putting back use RHN::Exception (with explicit import of throw).

* Fri Apr 08 2011 Miroslav Suchý 1.4.18-1
- update copyright years (msuchy@redhat.com)

* Thu Apr 07 2011 Jan Pazdziora 1.4.17-1
- replace (+) with ANSI left join (PG) (michael.mraka@redhat.com)
- Removing .pxt and methods since custominfo were migrated to Java by now.
- Cleanup of use in Perl modules.
- Removing .pxt and methods after all activation key pages were migrated
  to Java by now.

* Tue Apr 05 2011 Jan Pazdziora 1.4.16-1
- Fixing PostgreSQL distinct/order by issue in
  tags_for_provisioning_entitled_in_set.

* Thu Mar 24 2011 Jan Pazdziora 1.4.15-1
- Fixing previous taggable_systems_in_set fix (Oracle, this time).
- update copyright years (msuchy@redhat.com)
- implement common access keys (msuchy@redhat.com)

* Thu Mar 24 2011 Jan Pazdziora 1.4.14-1
- As PostgreSQL does not support table aliases in updates, remove them.

* Tue Mar 22 2011 Jan Pazdziora 1.4.13-1
- Moving the Requires: httpd from sniglets to base-minimal, dobby, and pxt
  which actually have %%files with apache group in them.
- No need to require mod_perl explicitly in spacewalk-sniglets, we will get it
  via perl(Apache2::Cookie) and perl-libapreq2 from spacewalk-pxt.
- Removing RHEL 4 specific Requires as we no longer support Spacewalk on RHEL 4.
- Fixing taggable_systems_in_set PostgreSQL issues.
- Fixing custom_info_keys PostgreSQL issue.
- Fixing the system_set_supports_reboot PostgreSQL issue.

* Tue Mar 22 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.12-1
- evaluate default_connection in runtime not in use RHN::DB time

* Fri Mar 18 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.11-1
- fixed package_removal_failures in postgresql

* Wed Mar 16 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.10-1
- made /network/systems/details/history/event.pxt work on postgresql
- Fixing is_eoled, replacing sysdate with current_timestamp.

* Wed Mar 09 2011 Jan Pazdziora 1.4.9-1
- Fixing system group operations (PostgreSQL).
- Using sequence_nextval instead of .nextval.

* Wed Mar 02 2011 Tomas Lestach <tlestach@redhat.com> 1.4.8-1
- consider also package arch when searching systems accorging to a package
  (tlestach@redhat.com)
- Removal of rhn-load-config.pl made
  RHN::DB::SatInstall::get_nls_database_parameters unused, removing.
  (jpazdziora@redhat.com)
- Removal of rhn-load-config.pl made RHN::SatInstall::generate_secret unused,
  removing. (jpazdziora@redhat.com)

* Mon Feb 28 2011 Jan Pazdziora 1.4.7-1
- Replacing date arithmetics with current_timestamp + numtodsinterval().
- We need to use current_timestamp instead of sysdate.
- Use sequence_nextval function.
- PostgreSQL does not like table alias on insert.
- We need to use global evr_t_as_vre_simple instead of PE.evr.as_vre_simple().
- The use of verify_channel_role is always in scalar context, no need to user
  the user_role_check_debug.
- Prevent empty strings from being inserted to the database.
- Adding the AS keyword to column aliases for PostgreSQL.

* Fri Feb 25 2011 Jan Pazdziora 1.4.6-1
- 680375 - we do not want the locked status (icon) to hide the the other
  statuses, we add separate padlock icon.
- Fixing systems_in_channel_family query for PostgreSQL.
- The /network/systems/details/hardware.pxt was replaced by
  /rhn/systems/details/SystemHardware.do.

* Thu Feb 24 2011 Jan Pazdziora 1.4.5-1
- The module Text::Diff is no longer needed, removing its use.

* Fri Feb 18 2011 Jan Pazdziora 1.4.4-1
- Localize the filehandle globs; also use three-parameter opens.

* Wed Feb 16 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.3-1
- enable RHN Proxy 5.4 on RHEL6 (msuchy@redhat.com)
- server_event_config_deploy just called server_event_config_revisions without
  adding any value, removing. (jpazdziora@redhat.com)

* Wed Feb 09 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.2-1
- 552628 - implemented db-control reset-password
- removed remote_dsn - it's always empty
- 552628 - use database credentials from rhn.conf
- The RHN::Utils::parametrize is not used anywhere, removing.

* Wed Feb 02 2011 Tomas Lestach <tlestach@redhat.com> 1.4.1-1
- bumping web.version to 1.4 nightly (tlestach@redhat.com)
- Bumping package versions for 1.4 (tlestach@redhat.com)

* Wed Feb 02 2011 Tomas Lestach <tlestach@redhat.com> 1.3.24-1
- removing nightly from web.version (tlestach@redhat.com)

* Thu Jan 20 2011 Tomas Lestach <tlestach@redhat.com> 1.3.23-1
- updating Copyright years for year 2011 (tlestach@redhat.com)
- Removing RHN::DB::SatInstall::clear_db, it was last referenced by rhn-
  populate-database.pl. (jpazdziora@redhat.com)

* Wed Jan 19 2011 Tomas Lestach <tlestach@redhat.com> 1.3.22-1
- extending OS check expression (tlestach@redhat.com)

* Wed Jan 19 2011 Tomas Lestach <tlestach@redhat.com> 1.3.21-1
- adding tomcat require to spacewalk-base-minimal (tlestach@redhat.com)
- 670185 - rephrasing the status information to be more clear
  (tlestach@redhat.com)

* Mon Jan 03 2011 Jan Pazdziora 1.3.20-1
- token_channel_select.js not referenced, removing.
- As RHN::DB::Search is gone, system_search_setbuilder.xml is not used,
  removing.
- subscribe_confirm.pxt not referenced, removing.
- The RHL9 and RHEL 3 release notes are not referenced, removing.
- countdown.js does not seem to be used, removing.
- Since RHN::DataSource::ContactGroup is gone, contact_group_queries.xml is
  unused, removing.
- PXT::Debug::log_dump not used anywhere, removing.
- RHN::Access::User not used anywhere, removing.

* Thu Dec 23 2010 Aron Parsons <aparsons@redhat.com> 1.3.19-1
- remove symlink that accidentily got added (aparsons@redhat.com)

* Thu Dec 23 2010 Aron Parsons <aparsons@redhat.com> 1.3.18-1
- bump API version number for recent API changes (aparsons@redhat.com)

* Thu Dec 23 2010 Jan Pazdziora 1.3.17-1
- Since ssm_channel_change_conf is gone, ssm_channel_change_conf_provider is
  not used anymore, removing.
- Package RHN::Access::Errata not used, removing.
- RHN::UserActions not used anywhere, removing.

* Tue Dec 21 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.16-1
- 664487 - fixed space report query
- fixed prototype-*.js reference

* Fri Dec 17 2010 Jan Pazdziora 1.3.15-1
- 656963 - the script has to start with #!/bin/sh.
- 656963 - move "Generate jabberd config file" script to correct activity
  (msuchy@redhat.com)
- 663304 - we do not put alias in INSERTs since commit b950aa91
  (msuchy@redhat.com)

* Wed Dec 15 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.14-1
- 663304 - we do not put alias in INSERTs since commit b950aa91
- 656963 - wrap up run-script using activity

* Tue Dec 14 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.13-1
- fixed undefined variable

* Mon Dec 13 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.12-1
- 517455 - adding tablesizes to SYNOPSIS section of db-control man page.
- 617305 - exit value 0 is returned by all db-control commands by default.
- removed unused overview query
- 656963 - create jabberd config via spacewalk-setup-jabberd

* Tue Dec 07 2010 Lukas Zapletal 1.3.11-1
- 642988 - ISE when setting Software Channel Entitlements

* Thu Dec 02 2010 Lukas Zapletal 1.3.10-1
- 658256 - Error 500 - ISE - when scheduling remote commands (proper fix)

* Wed Dec 01 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.9-1
- Reverted "658256 - Error 500 - ISE - when scheduling remote commands"

* Wed Dec 01 2010 Lukas Zapletal 1.3.8-1
- 658256 - Error 500 - ISE - when scheduling remote commands

* Sat Nov 27 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.7-1
- 649706 - execute all recomendations from segment advisor

* Fri Nov 26 2010 Jan Pazdziora 1.3.6-1
- Fix handling of eval (DBD::Oracle).
- 642285 - introducing disabled TaskStatus page (tlestach@redhat.com)

* Tue Nov 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.5-1
- fixed Notification Methods (PG)

* Mon Nov 22 2010 Lukas Zapletal 1.3.4-1
- Adding missing monitoring state (UNKNOWN)

* Fri Nov 19 2010 Lukas Zapletal 1.3.3-1
- Removing from SQL clause (System_queries) causing bugs in monitoring

* Fri Nov 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.2-1
- fixed outer joins

* Thu Nov 18 2010 Lukas Zapletal 1.3.1-1
- Replacing DECODE function with CASE-SWITCH (4x)
- Marking the master as nightly. 
- Bumping package versions for 1.3. 

* Mon Nov 15 2010 Jan Pazdziora 1.2.27-1
- bumping api version (jsherril@redhat.com)

* Thu Nov 11 2010 Jan Pazdziora 1.2.26-1
- make event.pxt work with both Oracle and PostgreSQL (mzazrivec@redhat.com)
- use ansi syntax in outer join (mzazrivec@redhat.com)

* Thu Nov 11 2010 Jan Pazdziora 1.2.25-1
- Bumping up version to 1.2.

* Wed Nov 10 2010 Lukas Zapletal 1.2.24-1
- Fixing table aliases for DISTINCT queries (PG)

* Wed Nov 10 2010 Jan Pazdziora 1.2.23-1
- use ansi syntax in outer join (mzazrivec@redhat.com)
- fixing queries, where rhnServer was unexpectedly joined to the query
  (tlestach@redhat.com)

* Wed Nov 03 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.22-1
- 647099 - add API call isMonitoringEnabledBySystemId (msuchy@redhat.com)
- migrating change log to java, and making it use the rpm itself instead of the
  database (jsherril@redhat.com)

* Tue Nov 02 2010 Jan Pazdziora 1.2.21-1
- Update copyright years in web/.
- bumping API version to identify new API call availability
  (tlestach@redhat.com)
- Fixing table name aliases (PE -> SPE) (lzap+git@redhat.com)

* Mon Nov 01 2010 Jan Pazdziora 1.2.20-1
- The sequence_nextval method returns sequence value both on Oracle and
  PostgreSQL.
- Only do Oracle LOB handling for Oracle database backend.
- The sequence_nextval method returns sequence value both on Oracle and
  PostgreSQL.
- Use ANSI syntax for outer join.
- 612581 - change egrep to grep -E (msuchy@redhat.com)

* Fri Oct 29 2010 Jan Pazdziora 1.2.19-1
- Making DISTINCT-ORDER BY package/system queries portable
  (lzap+git@redhat.com)
- Simplifying ORDER BY clauses in package queries (lzap+git@redhat.com)
- Revert "Reverting "Removed unnecessary ORDER BY" commits and fixing"
  (lzap+git@redhat.com)

* Fri Oct 29 2010 Jan Pazdziora 1.2.18-1
- fix rpmlint error (msuchy@redhat.com)
- fix rpmlint error (msuchy@redhat.com)
- fix rpmlint error (msuchy@redhat.com)

* Mon Oct 25 2010 Jan Pazdziora 1.2.17-1
- To get UTF-8 strings in character semantics from DBD::Pg automatically, we
  have to enable it.
- Error in packages dependencies and obsoletes (PXT) (lzap+git@redhat.com)
- Sorting fix in packages for PostgreSQL (lzap+git@redhat.com)
- Reverting "Removed unnecessary ORDER BY" commits and fixing
  (lzap+git@redhat.com)

* Thu Oct 21 2010 Lukas Zapletal 1.2.16-1
- Sorting fix in packages for PostgreSQL 
- Fix of evr_t_as_vre_simple PostgreSQL function 
- Fix in package file list for PostgreSQL 
- Changed SQL Perl generator joins to ANSI 

* Wed Oct 20 2010 Lukas Zapletal 1.2.15-1
- Function evr_t_as_vre_simple in all package queries now general

* Wed Oct 20 2010 Lukas Zapletal 1.2.14-1
- Fix in PostgreSQL (of previous commit)
- All DECODE functions replaced with CASE-WHEN in System_queries
- Fixing system overview list for PostgreSQL 
- Port /network/systems/details/custominfo/edit.pxt 
- Port /network/systems/details/custominfo/index.pxt 
- Update Perl module to redirect to Java not PXT 
- s|/network/systems/ssm/misc/index.pxt|/rhn/systems/ssm/misc/Index.do|

* Wed Oct 13 2010 Jan Pazdziora 1.2.13-1
- 642203- Removed the Task Status page for it needs a serious work over with
  our new configs (paji@redhat.com)
- 631847 - in RHN Proxy 5.4 is used jabber 2.0 where user is called jabber
  (instead of jabberd) (msuchy@redhat.com)
- Port /network/systems/custominfo/delete.pxt (colin.coe@gmail.com)
- Port /network/systems/details/delete_confirm.pxt (colin.coe@gmail.com)

* Mon Oct 11 2010 Jan Pazdziora 1.2.12-1
- Fix indentation -- use spaces.
- Fix the ORA_BLOB issue which prevents spacewalk-schema from starting.
- 631847 - add keys for proxy 5.4 (msuchy@redhat.com)
- If host or port is not specified, we do not want to put those empty strings
  to the dbi:Pg: connect string.
- Since we use RHN::DataSource::Simple in Sniglets::ListView::ProbeList, we
  might just as well use it (I man, Perl use).

* Fri Oct 08 2010 Jan Pazdziora 1.2.11-1
- Move use DBD::Oracle to eval so that we do not get rpm dependencies
  populated.

* Wed Oct 06 2010 Jan Pazdziora 1.2.10-1
- Use current_timestamp instead of the Oracle-specific sysdate in
  set_cloned_from.
- To PostgreSQL, procedures are just functions, call them as such.
- We do not seem to be using the inout parameter anywhere in our code, remove
  the code to make porting to PostgreSQL easier.
- Use current_timestamp instead of the Oracle-specific sysdate in
  clone_channel_packages.
- Since we have trigger which sets rhnRepoRegenQueue.id since
  f2153167da508852183501f320c2e71c08a0441c, we can avoid .nextval.
- As PostgreSQL does not support table aliases in inserts, remove them.
- Make sequence_nextval method support PostgreSQL syntax.
- Do not reconnect with every sequence_nextval -- the $self should be usable
  object to call prepare on.
- Use the utility sequence_nextval method instead of direct
  rhn_channel_id_seq.nextval, to allow portable nextval operation.
- For PostgreSQL, we just select function(params) instead of begin...end block.
- 639449 - add package spacewalk-setup-jabberd to list of packages which should
  be removed in Proxy WebUI installer (msuchy@redhat.com)

* Tue Oct 05 2010 Jan Pazdziora 1.2.9-1
- Force the field names to be uppercase since that is what the application
  expects.
- Use case instead of decode, it is more portable.
- Mark aliases with AS. This is what PostgreSQL requires.
- Instead of checking user_objects which is not portable, just attempt to
  select from PXTSESSIONS directly.
- We first check if there is some object not named PLAN_TABLE, and then if
  there is some object named PXTSESSIONS. Just drop the first check.
- Port /network/account/activation_keys/child_channels.pxt
  (coec@war.coesta.com)
- Port /network/systems/ssm/system_list.pxt (coec@war.coesta.com)
- Port SSM Package Refresh Page (coec@war.coesta.com)
- Simple fixes (coec@war.coesta.com)
- Port /network/systems/ssm/index.pxt (colin.coe@gmail.com)
- Port HW refresh page (colin.coe@gmail.com)

* Mon Sep 27 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.8-1
- 636653 - Made the  Channel Family Subscribed Systems page show guest systems
  also (paji@redhat.com)
- make 'db-control report' report TEMP_TBS statistics (mzazrivec@redhat.com)
- 630585 - about-chat now points to proper channel (branding)
  (lzap+git@redhat.com)
- Cleanedup old/proted/unused config queries and updated the one for snapshot
  (paji@redhat.com)
- adding configchannel.lookupFileInfo() taking a revision id
  (jsherril@redhat.com)

* Fri Sep 10 2010 Partha Aji <paji@redhat.com> 1.2.7-1
- 629606 - Fixed a list tag check box issue (paji@redhat.com)
- 591899 - fixing error where cloning an already cloned channel would still
  result in errata showing up on the clone tab when managing it
  (jsherril@redhat.com)

* Fri Sep 10 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.6-1
- 630950 - fix ISE in proxy webUI installer

* Thu Sep 09 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.5-1
- 580080 - fix link to Proxy Guide

* Wed Sep 08 2010 Shannon Hughes <shughes@redhat.com> 1.2.4-1
- bug fixes for audit tab and proxy installer additions (shughes@redhat.com)

* Wed Sep 08 2010 Shannon Hughes <shughes@redhat.com> 1.2.3-1
- 589728 hide audit functionality for satellite product (shughes@redhat.com)

* Wed Sep 08 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.2-1
- 631847 - create 5.4 webUI installer
- 614918 - Made SSM Select Systems to work with I18n languages
  (paji@redhat.com)

* Wed Sep 01 2010 Jan Pazdziora 1.2.1-1
- 621479 - Fix missing duplicates menu (coec@war.coesta.com)
- Revert "Remove hardware.pxt" (colin.coe@gmail.com)
- Removal of unused code.
- System Notes pages PXT to java (colin.coe@gmail.com)
- bumping package versions for 1.2 (mzazrivec@redhat.com)

* Thu Aug 05 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.8-1
- Remove hardware.pxt
- Convert hardware.pxt to Java

* Wed Aug 04 2010 Jan Pazdziora 1.1.7-1
- Add system migration to webUI (colin.coe@gmail.com)

* Fri Jul 16 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.6-1
- 581812 - fixed file ordering

* Fri Jul 16 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.5-1
- added a configuration page to orgs to handle maintenance windows
- cleaned up web_customer, rhnPaidOrgs and rhnDemoOrgs

* Thu Jul 01 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.4-1
- channel nav support for repository mapping (shughes@redhat.com)
- Added flex magic to ChannelFamily -> Orgs page (paji@redhat.com)

* Mon Jun 21 2010 Jan Pazdziora 1.1.3-1
- Good Bye Channel License Code (paji@redhat.com)
- Removed unused code.
- Removed the bulk-subscribe and unsubscribe which is not used anywhere
  (paji@redhat.com)
- removed an unused method (paji@redhat.com)

* Mon May 31 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.2-1
- 577355 - fixing broken link on channel->errata->clone screen
- Setting server.nls_lang once, later in this file, should be enough.
- code cleanup - this configuration files are not used in proxy
- Removing web/conf/*.conf files that are not packages nor used.
- bump version for spacewalk 1.1
- Fixed a couple of links with respect to the delete confirm change..

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages
- Constants DEFAULT_RHN_SATCON_TREE and DEFAULT_SATCON_DICT not longer used

