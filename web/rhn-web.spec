
%define perl_sitelib %(eval "`%{__perl} -V:installsitelib`"; echo $installsitelib)

Name: rhn-web
Summary: RHN Web site packages
Group: Applications/Internet
License: GPLv2
Source2: sources
%define main_source %(awk '{ print $2 ; exit }' %{SOURCE2})
Source0: %{main_source}
Source1: version
Version: %(echo `awk '{ print $1 }' %{SOURCE1}`) 
Release: %(echo `awk '{ print $2 }' %{SOURCE1}`)%{?dist}
BuildRoot: %{_tmppath}/%{name}-root
BuildArch: noarch
BuildRequires: perl(ExtUtils::MakeMaker)
%description
This package contains the code for the Red Hat Network Web Site.
Normally this source rpm does not generate a %{name} binary package,
but it does generate a number of subpackages

%package -n rhn-html
Summary: HTML document files for RHN
Group: Applications/Internet
Requires: webserver
Obsoletes: rhn-help
%description -n rhn-html
This package contains the HTML files for the RHN web site.

%package -n rhn-base
Group: Applications/Internet
Summary: Programs needed to be installed on the RHN Web base classes
Requires: rhn-pxt
Provides: rhn(rhn-base-minimal)
Provides: rhn(rhn-base)
Requires: webserver

%description -n rhn-base
This package includes the core RHN:: packages necessary to manipulate
RHN Oracle data.  This includes RHN::* and RHN::DB::*

%package -n rhn-base-minimal
Summary: Minimal .pm's for %{name} package
Group: Applications/Internet 
Provides: rhn(rhn-base-minimal)
%description -n rhn-base-minimal
Independant perl modules in the RHN:: namespace.

%package -n rhn-dobby
Summary: Dobby, a collection of perl modules and scripts to administer an Oracle database
Group: Applications/Internet
Requires: rhn-base
%description -n rhn-dobby
Dobby is collection of perl modules and scripts to administer an Oracle
database.

%package -n rhn-cypress
Summary: Cypress, a collection of Grail applications for Red Hat Network
Group: Applications/Internet
%description -n rhn-cypress
Cypress is a collection of Components for Grail.

%package -n rhn-grail
Summary: Grail, a component framework for Red Hat Network
Requires: rhn-base
Group: Applications/Internet
%description -n rhn-grail
A component framework for Red Hat Network.

%package -n rhn-pxt
Summary: The PXT library for web page templating
Group: Applications/Internet
Requires: rhn(rhn-base-minimal)
%description -n rhn-pxt
This package is the core software of the new RHN site.  It is responsible
for HTML, XML, WML, HDML, and SOAP output of data.  It is more or less
equlivalent to things like Apache::ASP and Mason

%package -n rhn-sniglets
Group: Applications/Internet 
Summary: PXT Tag handlers
Requires: mod_perl >= 2.0.0
%if 0%{?rhel} == 4
Requires: mod_jk-ap20
%endif
%if 0%{?rhel} >= 5
Requires: httpd
%endif
%description -n rhn-sniglets
This package contains the tag handlers for the PXT templates


%package -n rhn-moon
Group: Applications/Internet  
Summary: The Moon library for manipulating and charting data
%description -n rhn-moon
Modules for loading, manipulating, and rendering graphed data.

%prep
%define build_sub_dir %(echo %{main_source} | sed 's/\.tar\.gz$//')
%setup -n %build_sub_dir
cp %{SOURCE1} %{_builddir}/%build_sub_dir

%build
make -f Makefile.rhn-web PERLARGS="PREFIX=$RPM_BUILD_ROOT/usr"

%install
rm -rf $RPM_BUILD_ROOT

make -C modules install

make -C html install PREFIX=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name perllocal.pod -exec rm -f {} \;
find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;

mkdir -p $RPM_BUILD_ROOT/var/www/html/pub
mkdir -p $RPM_BUILD_ROOT/etc/rhn/default
mkdir -p $RPM_BUILD_ROOT/etc/init.d
mkdir -p $RPM_BUILD_ROOT/etc/httpd/conf
mkdir -p $RPM_BUILD_ROOT/etc/cron.daily

install -m 644 conf/rhn_web.conf $RPM_BUILD_ROOT/etc/rhn/default
install -m 644 conf/rhn_dobby.conf $RPM_BUILD_ROOT/etc/rhn/default
install -m 755 modules/dobby/etc/init.d/rhn-database $RPM_BUILD_ROOT/etc/init.d/rhn-database
install -m 755 modules/dobby/scripts/check-oracle-space-usage.sh $RPM_BUILD_ROOT/etc/cron.daily/check-oracle-space-usage.sh

{
find $RPM_BUILD_ROOT/usr -type d -print | \
        sed "s|^$RPM_BUILD_ROOT|%dir |g"
find $RPM_BUILD_ROOT/usr -type f -print | \
        sed "s|^$RPM_BUILD_ROOT||g" | \
        grep -v perllocal.pod | \
        sed "s|\(.*\)/man/\(.*\)$|\1/man/\2\*|" | \
        grep -v "\.packlist"
} > files.list
if [ ! -s files.list ] ; then
    echo "ERROR: EMPTY FILE LIST"
    exit -1
fi

{
find $RPM_BUILD_ROOT/var/www/html -type d -print | \
        sed "s|^$RPM_BUILD_ROOT|%dir |g"
find $RPM_BUILD_ROOT/var/www/html -type f -print | \
        sed "s|^$RPM_BUILD_ROOT||g"
} > html.list

# separate out different subpackages
egrep '/Cypress([/:]|\.3|$)' files.list > cypress.list
egrep '/Dobby([/:]|\.3|$)' files.list  > dobby.list
egrep '/usr/bin/'          files.list >> dobby.list
egrep 'man1/db-control'    files.list >> dobby.list
echo  '/etc/init.d/rhn-database' >> dobby.list
egrep '/Grail([/:]|\.3|$)' files.list > grail.list
egrep '/PXT([/:]|\.3|$)' files.list > pxt.list
egrep '/RHN([/:]|\.3|$)' files.list > rhn.list
egrep '/Sniglets([/:]|\.3|$)' files.list > sniglets.list
egrep '/Moon([/:]|\.3|$)' files.list > moon.list

# get the list of extra files
egrep -v '/(Cypress|Dobby|Grail|PXT|RHN|Sniglets|Moon)([/:]|\.3|$)' \
        files.list > extra.list

%clean
rm -rf $RPM_BUILD_ROOT

%files -n rhn-base -f rhn.list
%defattr(-,root,root)
%dir %{perl_sitelib}/RHN
%dir %{perl_sitelib}/PXT
%{perl_sitelib}/RHN.pm

%files -n rhn-base-minimal
%defattr(-,root,root)
%dir %{perl_sitelib}/RHN
%dir %{perl_sitelib}/PXT
%{perl_sitelib}/RHN/SessionSwap.pm
%{perl_sitelib}/RHN/Exception.pm
%{perl_sitelib}/RHN/DB.pm
%{perl_sitelib}/PXT/Config.pm
%attr(640,root,apache) %config /etc/rhn/default/rhn_web.conf

%files -n rhn-cypress -f cypress.list
%defattr(-,root,root)
%{perl_sitelib}/Cypress.pm

%files -n rhn-dobby -f dobby.list
%defattr(-,root,root)
%{perl_sitelib}/Dobby.pm
%attr(640,root,apache) %config /etc/rhn/default/rhn_dobby.conf
%attr(0755,root,root) %{_sysconfdir}/cron.daily/check-oracle-space-usage.sh

%files -n rhn-grail -f grail.list
%defattr(-,root,root)
%{perl_sitelib}/Grail.pm

%files -n rhn-pxt -f pxt.list
%defattr(-,root,root)
%{perl_sitelib}/PXT.pm
%attr(640,root,apache) %config /etc/rhn/default/rhn_web.conf

%files -n rhn-sniglets -f sniglets.list
%defattr(-,root,root)
%{perl_sitelib}/Sniglets.pm

%files -n rhn-moon -f moon.list
%defattr(-,root,root)

%files -n rhn-html -f html.list
%defattr(-,root,root)
%if 0%{?rhel} >= 5
/var/www/html/help/test-conn.pyc
/var/www/html/help/test-conn.pyo
%endif
%if 0%{?fedora} >= 8
/var/www/html/help/test-conn.pyc
/var/www/html/help/test-conn.pyo
%endif

# $Id$
%changelog
* Fri Jun  6 2008 Miroslav Suchu <msuchy@redhat.com> - 5.2.0-10
- add support for proxy on RHEL5

* Wed May 21 2008 Jan Pazdziora 5.2.0-7
- changing perl-Time-HiRes to perl(Time::HiRes)
- changing mod_jk-ap20 to mod_proxy_ajp.so on RHEL 5

* Tue May 20 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-5
- added stats options to db-control

* Fri May 16 2008 Jan Pazdziora - 5.2.0-4
- rebuilt with latest code

* Wed Apr 30 2008 Jan Pazdziora <jpazdziora@redhat.com> 5.2.0-3
- rebuilt via brew / dist-cvs

* Thu Sep  6 2007 Jan Pazdziora <jpazdziora@redhat.com>
- updated to use default httpd from distribution and mod_perl 2

* Mon May 1 2006 Partha Aji <paji@redhat.com>
- Added a cron job that checks the oracle table/space usage and emails it to the user. (Bug 182054)

* Mon Nov  7 2005 Robin Norwood <rnorwood@redhat.com>
- Remove rhn-swab, because it annoys taw

* Thu Aug  8 2002 Cristian Gafton <gafton@redhat.com>
- unified all web stuff into a single src.rpm

* Thu Mar 14 2002 Chip Turner <cturner@minbar.devel.redhat.com>
- updated for the new bs

* Thu Jun 21 2001 Cristian Gafton <gafton@redhat.com>
- build system changes

* Mon Jun  4 2001 Cristian Gafton <gafton@redhat.com>
- created first package
