Name: spacewalk-web
Summary: Spacewalk Web site packages
Group: Applications/Internet
License: GPLv2
Version: 0.2
Release: 0%{?dist}
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd web
# make test-srpm
URL:          https://fedorahosted.org/spacewalk
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n) 
BuildArch: noarch
BuildRequires: perl(ExtUtils::MakeMaker)

%description
This package contains the code for the Spacewalk Web Site.
Normally this source rpm does not generate a %{name} binary package,
but it does generate a number of subpackages

%package -n spacewalk-html
Summary: HTML document files for Spacewalk
Group: Applications/Internet
Requires: webserver
Requires: spacewalk-branding
Obsoletes: rhn-help <= 5.2
Obsoletes: rhn-html <= 5.2


%description -n spacewalk-html
This package contains the HTML files for the Spacewalk web site.


%package -n spacewalk-base
Group: Applications/Internet
Summary: Programs needed to be installed on the RHN Web base classes
Requires: spacewalk-pxt
Provides: spacewalk(spacewalk-base-minimal) = %{version}-%{release}
Provides: spacewalk(spacewalk-base) = %{version}-%{release}
Requires: webserver
Obsoletes: rhn-base <= 5.2


%description -n spacewalk-base
This package includes the core RHN:: packages necessary to manipulate
database.  This includes RHN::* and RHN::DB::*


%package -n spacewalk-base-minimal
Summary: Minimal .pm's for %{name} package
Group: Applications/Internet 
Provides: spacewalk(spacewalk-base-minimal) = %{version}-%{release}
Obsoletes: rhn-base-minimal <= 5.2

%description -n spacewalk-base-minimal
Independant perl modules in the RHN:: namespace.

%package -n spacewalk-dobby
Summary: Dobby, a collection of perl modules and scripts to administer an Oracle database
Group: Applications/Internet
Requires: spacewalk-base
Obsoletes: rhn-dobby <= 5.2

%description -n spacewalk-dobby
Dobby is collection of perl modules and scripts to administer an Oracle
database.


%package -n spacewalk-cypress
Summary: Cypress, a collection of Grail applications for Red Hat Network
Group: Applications/Internet
Obsoletes: rhn-cypress <= 5.2
%description -n spacewalk-cypress
Cypress is a collection of Components for Grail.

%package -n spacewalk-grail
Summary: Grail, a component framework for Red Hat Network
Requires: spacewalk-base
Group: Applications/Internet
Obsoletes: rhn-grail <= 5.2

%description -n spacewalk-grail
A component framework for Spacewalk.


%package -n spacewalk-pxt
Summary: The PXT library for web page templating
Group: Applications/Internet
Requires: spacewalk(spacewalk-base-minimal)
Obsoletes: rhn-pxt <= 5.2

%description -n spacewalk-pxt
This package is the core software of the new Spacewalk site.  It is responsible
for HTML, XML, WML, HDML, and SOAP output of data.  It is more or less
equlivalent to things like Apache::ASP and Mason


%package -n spacewalk-sniglets
Group: Applications/Internet 
Summary: PXT Tag handlers
Requires: mod_perl >= 2.0.0
%if 0%{?rhel} == 4
Requires: mod_jk-ap20
%else
Requires: httpd
%endif
Obsoletes: rhn-sniglets <= 5.2


%description -n spacewalk-sniglets
This package contains the tag handlers for the PXT templates


%package -n spacewalk-moon
Group: Applications/Internet  
Summary: The Moon library for manipulating and charting data
Obsoletes: rhn-moon <= 5.2

%description -n spacewalk-moon
Modules for loading, manipulating, and rendering graphed data.

%prep
%setup -q

%build
make -f Makefile.spacewalk-web INSTALLDIRS=site

%install
rm -rf $RPM_BUILD_ROOT
make -C modules install DESTDIR=$RPM_BUILD_ROOT
make -C html install PREFIX=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name perllocal.pod -exec rm -f {} \;
find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;

mkdir -p $RPM_BUILD_ROOT/%{_var}/www/html/pub
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/default
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/init.d
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/httpd/conf
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/cron.daily

install -m 644 conf/rhn_web.conf $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/default
install -m 644 conf/rhn_dobby.conf $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/default
install -m 755 modules/dobby/etc/init.d/rhn-database $RPM_BUILD_ROOT/%{_sysconfdir}/init.d/rhn-database
install -m 755 modules/dobby/scripts/check-oracle-space-usage.sh $RPM_BUILD_ROOT/%{_sysconfdir}/cron.daily/check-oracle-space-usage.sh

{
find $RPM_BUILD_ROOT/%{_prefix} -type d -print | \
        sed "s|^$RPM_BUILD_ROOT|%dir |g"
find $RPM_BUILD_ROOT/%{_prefix} -type f -print | \
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
find $RPM_BUILD_ROOT/%{_var}/www/html -type d -print | \
        sed "s|^$RPM_BUILD_ROOT|%dir |g"
find $RPM_BUILD_ROOT/%{_var}/www/html -type f -print | \
        sed "s|^$RPM_BUILD_ROOT||g"
} > html.list

# separate out different subpackages
egrep '/Cypress([/:]|\.3|$)' files.list > cypress.list
egrep '/Dobby([/:]|\.3|$)' files.list  > dobby.list
egrep '%{_bindir}/'          files.list >> dobby.list
egrep 'man1/db-control'    files.list >> dobby.list
echo  '%{_sysconfdir}/init.d/rhn-database' >> dobby.list
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

%files -n spacewalk-base -f rhn.list
%defattr(-,root,root)
%dir %{perl_sitelib}/RHN
%dir %{perl_sitelib}/PXT
%{perl_sitelib}/RHN.pm

%files -n spacewalk-base-minimal
%defattr(-,root,root)
%dir %{perl_sitelib}/RHN
%dir %{perl_sitelib}/PXT
%{perl_sitelib}/RHN/SessionSwap.pm
%{perl_sitelib}/RHN/Exception.pm
%{perl_sitelib}/RHN/DB.pm
%{perl_sitelib}/PXT/Config.pm
%attr(640,root,apache) %config %{_sysconfdir}/rhn/default/rhn_web.conf

%files -n spacewalk-cypress -f cypress.list
%defattr(-,root,root)
%{perl_sitelib}/Cypress.pm

%files -n spacewalk-dobby -f dobby.list
%defattr(-,root,root)
%{perl_sitelib}/Dobby.pm
%attr(640,root,apache) %config %{_sysconfdir}/rhn/default/rhn_dobby.conf
%attr(0755,root,root) %{_sysconfdir}/cron.daily/check-oracle-space-usage.sh

%files -n spacewalk-grail -f grail.list
%defattr(-,root,root)
%{perl_sitelib}/Grail.pm

%files -n spacewalk-pxt -f pxt.list
%defattr(-,root,root)
%{perl_sitelib}/PXT.pm
%attr(640,root,apache) %config %{_sysconfdir}/rhn/default/rhn_web.conf

%files -n spacewalk-sniglets -f sniglets.list
%defattr(-,root,root)
%{perl_sitelib}/Sniglets.pm

%files -n spacewalk-moon -f moon.list
%defattr(-,root,root)

%files -n spacewalk-html -f html.list
%defattr(-,root,root)
%if 0%{?rhel} >= 5
%{_var}/www/html/help/test-conn.pyc
%{_var}/www/html/help/test-conn.pyo
%endif
%if 0%{?fedora} >= 8
%{_var}/www/html/help/test-conn.pyc
%{_var}/www/html/help/test-conn.pyo
%endif


# $Id$
%changelog
* Wed Aug 13 2008 Mike McCune <mmccune@redhat.com 0.2-1
- fix Requires: statement to reflect new spacewalk-pxt name 

* Mon Aug  4 2008 Miroslav Suchy <msuchy@redhat.com> 0.2-0
- rename package from rhn-* to spacewalk-*
- clean up spec

* Fri Jun  6 2008 Miroslav Suchy <msuchy@redhat.com> - 5.2.0-10
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
