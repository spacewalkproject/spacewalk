Summary: Spacewalk support for yum
Name: yum-rhn-plugin
Version: 2.9.3
Release: 1%{?dist}
License: GPLv2
Source0: https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
URL:     https://github.com/spacewalkproject/spacewalk
%if %{?suse_version: %{suse_version} > 1110} %{!?suse_version:1}
BuildArch: noarch
%endif
%if 0%{?fedora} >= 28
BuildRequires: python2
%else
BuildRequires: python
%endif
BuildRequires: intltool
BuildRequires: gettext

Requires: yum >= 3.2.19-15
Requires: rhn-client-tools >= 2.8.4
Requires: m2crypto >= 0.16-6
%if 0%{?fedora} >= 28
Requires: python2-iniparse
%else
Requires: python-iniparse
%endif

# Not really, but for upgrades we need these
Requires: rhn-setup >= 2.8.4

%description
This yum plugin provides support for yum to access a Spacewalk server for
software updates.

%prep
%setup -q

%build
make -f Makefile.yum-rhn-plugin

%install
make -f Makefile.yum-rhn-plugin install VERSION=%{version}-%{release} PREFIX=$RPM_BUILD_ROOT MANPATH=%{_mandir} PYTHONPATH=%{python_sitelib}

%find_lang %{name}

%pre
# 682820 - re-enable yum-rhn-plugin after package upgrade if the system is already registered
export pluginconf='/etc/yum/pluginconf.d/rhnplugin.conf'
if [ $1 -gt 1 ] && [ -f /etc/sysconfig/rhn/systemid ] && [ -f "$pluginconf" ]; then
    if grep -q '^[[:space:]]*enabled[[:space:]]*=[[:space:]]*1[[:space:]]*$' \
       "$pluginconf"; then
        echo "1" > /etc/enable-yum-rhn-plugin
    fi
fi

%post
# 682820 - re-enable yum-rhn-plugin after package upgrade if the system is already registered
export pluginconf='/etc/yum/pluginconf.d/rhnplugin.conf'
if [ $1 -gt 1 ] && [ -f "$pluginconf" ] && [ -f "/etc/enable-yum-rhn-plugin" ]; then
    sed -i '/\[main]/,/^$/{/enabled/s/0/1/}' "$pluginconf"
    rm -f /etc/enable-yum-rhn-plugin
fi

%files -f %{name}.lang
%verify(not md5 mtime size) %config(noreplace) %{_sysconfdir}/yum/pluginconf.d/rhnplugin.conf
%dir /var/lib/up2date
%{_mandir}/man*/*
%{_datadir}/yum-plugins/*
%{python_sitelib}/rhn/actions/*
%doc LICENSE

%changelog
* Wed Apr 25 2018 Tomas Kasparek <tkasparek@redhat.com> 2.9.3-1
- up2date is dead
- empty clean section is not needed

* Wed Apr 11 2018 Tomas Kasparek <tkasparek@redhat.com> 2.9.2-1
- fix condition for RHEL systems

* Tue Apr 10 2018 Tomas Kasparek <tkasparek@redhat.com> 2.9.1-1
- Update Python 2 dependency declarations to new packaging standards
- Bumping package versions for 2.9.

* Mon Mar 19 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.7-1
- Regenerating .po and .pot files for yum-rhn-plugin.

* Fri Mar 02 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.6-1
- Change man section 8 to 5

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.5-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Thu Nov 16 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.4-1
- removed settings for old RH build system

* Fri Sep 29 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.3-1
- require new version of rhn-client-tools
- move client actions to rhn namespace

* Fri Sep 22 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- move python files to sitelib

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- use standard brp-python-bytecompile
- Bumping package versions for 2.8.

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.7-1
- update copyright year

* Mon Jul 17 2017 Jan Dobes 2.7.6-1
- Regenerating .po and .pot files for yum-rhn-plugin
- Updating .po translations from Zanata

* Fri May 12 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.5-1
- 1418104 - honor yum.conf when setting repo defaults

* Mon Mar 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.4-1
- 1391867 - use retry_on_cache only if available

* Fri Mar 03 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.3-1
- 1398406 - update repo options from rhnplugin.conf even in cacheonly mode
- 1391867 - pass retry_no_cache option to urlgrabber

* Thu Mar 02 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.2-1
- 1361185 - use yum's lock to prevent concurent yum & rhn_check actions

* Fri Feb 17 2017 Jan Dobes 2.7.1-1
- fix bz1422518 - request failed: error reading the headers (CVE-2016-8743)
- Bumping package versions for 2.7.

* Wed Nov 09 2016 Gennadii Altukhov <galt@redhat.com> 2.6.3-1
- Revert Project-Id-Version for translations

* Tue Nov 08 2016 Gennadii Altukhov <galt@redhat.com> 2.6.2-1
- Regenerating .po and .pot files for yum-rhn-plugin.
- Updating .po translations from Zanata

* Mon Jul 25 2016 Tomas Kasparek <tkasparek@redhat.com> 2.6.1-1
- 1359087 - expect additional arguments
- Bumping package versions for 2.6.

* Tue May 24 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.5-1
- updating copyright years
- Regenerating .po and .pot files for rhn-client-tools.
- Updating .po translations from Zanata

* Fri Feb 19 2016 Jiri Dostal <jdostal@redhat.com> 2.5.4-1
- 1302198, 1292288 - remote package upgrade saying newer package is installed,
  but it is not

* Thu Feb 18 2016 Jan Dobes 2.5.3-1
- delete file with input files after template is created
- pulling *.po translations from Zanata
- fixing current *.po translations

* Thu Jan 21 2016 Tomas Lestach <tlestach@redhat.com> 2.5.2-1
- 1206227 - allow client responses to be in Unicode

* Fri Jan 08 2016 Grant Gainey 2.5.1-1
- 1297028 - get retrieveOnly out of the way of package-remove
- Bumping package versions for 2.5.

* Thu Sep 24 2015 Jan Dobes 2.4.6-1
- Bumping copyright year.

* Wed Sep 23 2015 Jan Dobes 2.4.5-1
- Pulling updated *.po translations from Zanata.

* Fri May 08 2015 Stephen Herr <sherr@redhat.com> 2.4.4-1
- 1172288 - bug in yum api; PackageEVR.__eq__ not correctly defined for    evrs
  with None values
- Revert "Revert "1172288 - One more occurrence of bad epoch interpretation""

* Fri May 08 2015 Stephen Herr <sherr@redhat.com> 2.4.3-1
- Revert "1172288 - One more occurrence of bad epoch interpretation"
  Unspecified epoch is supposed to be '0' here, thanks to yum. See comment 12
  in bug.

* Tue Apr 28 2015 Matej Kollar <mkollar@redhat.com> 2.4.2-1
- 1172288 - One more occurrence of bad epoch interpretation

* Thu Apr 16 2015 Matej Kollar <mkollar@redhat.com> 2.4.1-1
- 1172288 - Unspecified epoch is not epoch = '0'
- Bumping package versions for 2.4.

* Thu Mar 19 2015 Grant Gainey 2.3.3-1
- Updating copyright info for 2015

* Wed Feb 18 2015 Matej Kollar <mkollar@redhat.com> 2.3.2-1
- 729913 - typo
- 729913 - rhnplugin.conf man page clarification

* Mon Jan 12 2015 Matej Kollar <mkollar@redhat.com> 2.3.1-1
- Getting rid of Tabs and trailing spaces in Python
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files
- Bumping package versions for 2.3.

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.7-1
- fix copyright years

* Thu Jul 10 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.6-1
- Update .po and .pot files for yum-rhn-plugin.

* Thu Jul 10 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.5-1
- 1115527 - don't encode proxy url if not set

* Wed Jul 09 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.4-1
- 1115527 - encode proxy url when passing it to urlgrabber

* Tue Jul 08 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.3-1
- 1115527 - correctly initialize proxy settings for URLGrabber

* Wed Jun 18 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.2-1
- err variable needs to be initialized before assignment

* Thu Jun 12 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.1-1
- 1051972 - report unavailable packages
- 1051972 - don't fail if package is already installed

* Fri Feb 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.7-1
- 1043850 - avoid insecure use of /var/tmp

* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.6-1
- Update .po and .pot files for yum-rhn-plugin.

* Thu Oct 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.5-1
- 1018929 - removed redundant exception

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.4-1
- removed trailing whitespaces

* Mon Sep 09 2013 Stephen Herr <sherr@redhat.com> 2.1.3-1
- 1006037 - keep yum-rhn-plugins higher default timeout

* Tue Aug 13 2013 Stephen Herr <sherr@redhat.com> 2.1.2-1
- 996761 - package profile sync actions should not fail with empty transaction

* Tue Aug 06 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.1-1
- Branding clean-up of proxy stuff in client dir
- Bumping package versions for 2.1.

