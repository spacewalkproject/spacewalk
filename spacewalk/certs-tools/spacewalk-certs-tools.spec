%if 0%{?suse_version}
%global pub_bootstrap_dir /srv/www/htdocs/pub/bootstrap
%else
%global pub_bootstrap_dir /var/www/html/pub/bootstrap
%endif
%global rhnroot %{_datadir}/rhn

%if 0%{?fedora}
%global build_py3   1
%global default_py3 1
%endif

%define pythonX %{?default_py3: python3}%{!?default_py3: python2}

Name: spacewalk-certs-tools
Summary: Spacewalk SSL Key/Cert Tool
License: GPLv2
Version: 2.8.8
Release: 1%{?dist}
URL:      https://github.com/spacewalkproject/spacewalk
Source0:  https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch: noarch
Requires: %{pythonX}-%{name} = %{version}-%{release}
Requires: openssl rpm-build
Requires: tar
Requires: /usr/bin/sudo
BuildRequires: docbook-utils
BuildRequires: python
Obsoletes: rhns-certs < 5.3.0
Obsoletes: rhns-certs-tools < 5.3.0
# can not provides = %{version} since some old packages expect > 3.6.0
Provides:  rhns-certs = 5.3.0
Provides:  rhns-certs-tools = 5.3.0

%description
This package contains tools to generate the SSL certificates required by 
Spacewalk.

%package -n python2-%{name}
Summary: Spacewalk SSL Key/Cert Tool
Requires: %{name} = %{version}-%{release}
Requires: python2-rhn-client-tools
Requires: spacewalk-backend-libs >= 0.8.28
%if 0%{?rhel} && 0%{?rhel} <= 5
Requires: python-hashlib
%endif

%description -n python2-%{name}
Python 2 specific files for %{name}.

%if 0%{?build_py3}
%package -n python3-%{name}
Summary: Spacewalk SSL Key/Cert Tool
Requires: %{name} = %{version}-%{release}
Requires: python3-rhn-client-tools
Requires: python3-spacewalk-backend-libs
BuildRequires: python3-rpm-macros
BuildRequires: python3

%description -n python3-%{name}
Python 3 specific files for %{name}.
%endif

%prep
%setup -q

%build
#nothing to do here

%if 0%{?suse_version}
# we need to rewrite etc/httpd/conf => etc/apache2
sed -i 's|etc/httpd/conf|etc/apache2|g' rhn_ssl_tool.py
sed -i 's|etc/httpd/conf|etc/apache2|g' sslToolConfig.py
sed -i 's|etc/httpd/conf|etc/apache2|g' sign.sh
sed -i 's|etc/httpd/conf|etc/apache2|g' ssl-howto.txt
%endif

%install
install -d -m 755 $RPM_BUILD_ROOT/%{rhnroot}/certs
make -f Makefile.certs install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    PYTHONPATH=%{python_sitelib} PYTHONVERSION=%{python_version} \
    MANDIR=%{_mandir} PUB_BOOTSTRAP_DIR=%{pub_bootstrap_dir}
%if 0%{?build_py3}
sed -i 's|#!/usr/bin/python|#!/usr/bin/python3|' rhn-ssl-tool rhn-bootstrap
make -f Makefile.certs install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    PYTHONPATH=%{python3_sitelib} PYTHONVERSION=%{python3_version} \
    MANDIR=%{_mandir} PUB_BOOTSTRAP_DIR=%{pub_bootstrap_dir}
%endif

%define default_suffix %{?default_py3:-%{python3_version}}%{!?default_py3:-%{python_version}}
ln -s rhn-ssl-tool%{default_suffix} $RPM_BUILD_ROOT%{_bindir}/rhn-ssl-tool
ln -s rhn-bootstrap%{default_suffix} $RPM_BUILD_ROOT%{_bindir}/rhn-bootstrap

%clean

%files
%attr(755,root,root) %{rhnroot}/certs/sign.sh
%attr(755,root,root) %{rhnroot}/certs/gen-rpm.sh
%attr(755,root,root) %{rhnroot}/certs/update-ca-cert-trust.sh
%attr(755,root,root) %{_bindir}/rhn-sudo-ssl-tool
%attr(755,root,root) %{_bindir}/rhn-ssl-tool
%attr(755,root,root) %{_bindir}/rhn-bootstrap
%doc %{_mandir}/man1/rhn-*.1*
%doc LICENSE
%doc ssl-howto-simple.txt ssl-howto.txt
%{pub_bootstrap_dir}/client_config_update.py*
%if 0%{?suse_version}
%dir %{rhnroot}
%dir /srv/www/htdocs/pub
%dir %{pub_bootstrap_dir}
%endif

%files -n python2-%{name}
%{python_sitelib}/certs
%attr(755,root,root) %{_bindir}/rhn-ssl-tool-%{python_version}
%attr(755,root,root) %{_bindir}/rhn-bootstrap-%{python_version}

%if 0%{?build_py3}
%files -n python3-%{name}
%{python3_sitelib}/certs
%attr(755,root,root) %{_bindir}/rhn-ssl-tool-%{python3_version}
%attr(755,root,root) %{_bindir}/rhn-bootstrap-%{python3_version}
%endif

%changelog
* Wed Mar 21 2018 Jiri Dostal <jdostal@redhat.com> 2.8.8-1
- Updating copyright years for 2018

* Tue Feb 27 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.7-1
- options are not defined

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.6-1
- removed %%%%defattr from specfile
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Thu Dec 14 2017 Eric Herget <eherget@redhat.com> 2.8.5-1
- 1456471 - PR570 - Using own certificates for installer
- 1456471 - PR570 - [RFE] Using own certifications for installer (CA, private
  key)

* Fri Oct 27 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.4-1
- python3 is missing in buildroot on Fedora 25

* Wed Oct 25 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.3-1
- python3 compatibility fixes

* Fri Oct 20 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- made code python3 compatible
- install files into python_sitelib/python3_sitelib
- splitted spacewalk-certs-tools into python2/python3 specific packages

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- use standard brp-python-bytecompile
- Bumping package versions for 2.8.

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.3-1
- update copyright year

* Thu Jun 22 2017 Grant Gainey 2.7.2-1
- Allow passing multiple GPG keys to rhn-bootstrap

* Tue May 16 2017 Grant Gainey 2.7.1-1
- 1030013 - fix minor typos in bootstrap.sh
- Remove unused imports.
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub
- Bumping package versions for 2.7.
- Bumping package versions for 2.6.

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.3-1
- updating copyright years

* Tue May 10 2016 Grant Gainey 2.5.2-1
- spacewalk-certs-tools: build on openSUSE

* Wed Feb 03 2016 Jan Dobes 2.5.1-1
- 1302900 - not run on EL5 systems
- Bumping package versions for 2.5.

* Thu Sep 24 2015 Jan Dobes 2.4.7-1
- Bumping copyright year.

* Fri Aug 07 2015 Jan Dobes 2.4.6-1
- add file to RPM

* Fri Aug 07 2015 Jan Dobes 2.4.5-1
- add file to RPM

* Thu Aug 06 2015 Jan Dobes 2.4.4-1
- trust CA certificate when client RPM is installed

* Tue Jul 14 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.3-1
- remove Except KeyboardInterrupt from imports

* Fri May 08 2015 Stephen Herr <sherr@redhat.com> 2.4.2-1
- 1219946 - We need python-hashlib for doing sha256 on RHEL 5
- 1219946 - Make rhn-ssl-tool use sha256 by default for crt / csr signatures

* Fri Apr 24 2015 Matej Kollar <mkollar@redhat.com> 2.4.1-1
- remove whitespace from .sgml files
- Bumping package versions for 2.4.

* Fri Mar 27 2015 Grant Gainey 2.3.3-1
- tuple assignment should be list in client_config_update.py

* Thu Mar 19 2015 Grant Gainey 2.3.2-1
- Updating copyright info for 2015

* Wed Jan 14 2015 Matej Kollar <mkollar@redhat.com> 2.3.1-1
- Getting rid of Tabs and trailing spaces in Python
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files
- Bumping package versions for 2.3.

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.1-1
- fix copyright years
- Bumping package versions for 2.2.

* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.6-1
- Updating the copyright years info

* Fri Jan 10 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.5-1
- 1040682 - older Proxies don't implement PRODUCT_NAME

* Mon Oct 14 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.4-1
- cleaning up old svn Ids

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.3-1
- removed trailing whitespaces

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.2-1
- Grammar error occurred

* Tue Aug 06 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.1-1
- Branding clean-up of proxy stuff in cert-tools dir
- Bumping package versions for 2.1.

