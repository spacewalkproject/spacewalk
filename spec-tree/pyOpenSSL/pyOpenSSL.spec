%if 0%{?fedora}
%bcond_without python2
%else
# Disable python2 build by default
%bcond_with python2
%endif

Summary: Python wrapper module around the OpenSSL library
Name: pyOpenSSL
Version: 18.0.0
Release: 1%{?dist}
Source0: https://files.pythonhosted.org/packages/source/p/pyOpenSSL/pyOpenSSL-%{version}.tar.gz

BuildArch: noarch
License: ASL 2.0
Group: Development/Libraries
URL: https://pyopenssl.readthedocs.org/

BuildRequires: python3-setuptools
BuildRequires: python3-sphinx
BuildRequires: python3-sphinx_rtd_theme

%if %{with python2}
BuildRequires: python2-devel
BuildRequires: python2-cryptography >= 2.2.1
%endif
BuildRequires: python3-devel
BuildRequires: python3-cryptography >= 2.2.1

%description
High-level wrapper around a subset of the OpenSSL library, includes among others
 * SSL.Connection objects, wrapping the methods of Python's portable
   sockets
 * Callbacks written in Python
 * Extensive error-handling mechanism, mirroring OpenSSL's error codes

%if %{with python2}
%package -n python2-pyOpenSSL
Summary: Python 2 wrapper module around the OpenSSL library
Requires: python2-cryptography >= 2.2.1
Obsoletes: pyOpenSSL < %{version}-%{release}
Provides: pyOpenSSL = %{version}-%{release}
%{?python_provide:%python_provide python2-pyOpenSSL}

%description -n python2-pyOpenSSL
High-level wrapper around a subset of the OpenSSL library, includes among others
 * SSL.Connection objects, wrapping the methods of Python's portable
   sockets
 * Callbacks written in Python
 * Extensive error-handling mechanism, mirroring OpenSSL's error codes
%endif

%package -n python3-pyOpenSSL
Summary: Python 3 wrapper module around the OpenSSL library
Requires: python3-cryptography >= 2.2.1
%{?python_provide:%python_provide python3-pyOpenSSL}

%description -n python3-pyOpenSSL
High-level wrapper around a subset of the OpenSSL library, includes among others
 * SSL.Connection objects, wrapping the methods of Python's portable
   sockets
 * Callbacks written in Python
 * Extensive error-handling mechanism, mirroring OpenSSL's error codes

%package doc
Summary: Documentation for pyOpenSSL
BuildArch: noarch

%description doc
Documentation for pyOpenSSL

%prep
%autosetup -p1 -n pyOpenSSL-%{version}

%build
%py3_build

%if %{with python2}
%py2_build
%endif

%{__make} -C doc html SPHINXBUILD=sphinx-build-3

%install
%py3_install

%if %{with python2}
%py2_install
%endif

# Cleanup sphinx .buildinfo file before packaging
rm doc/_build/html/.buildinfo

%if %{with python2}
%files -n python2-pyOpenSSL
%license LICENSE
%{python_sitelib}/OpenSSL/
%{python_sitelib}/pyOpenSSL-*.egg-info
%endif

%files -n python3-pyOpenSSL
%license LICENSE
%{python3_sitelib}/OpenSSL/
%{python3_sitelib}/pyOpenSSL-*.egg-info

%files doc
%license LICENSE
%doc CHANGELOG.rst examples doc/_build/html

%changelog
* Mon Jun 11 2018 Tomáš Mráz <tmraz@redhat.com> - 18.0.0-1
- New upstream release 18.0.0

* Wed Feb 21 2018 Iryna Shcherbina <ishcherb@redhat.com> - 17.3.0-4
- Update Python 2 dependency declarations to new packaging standards
  (See https://fedoraproject.org/wiki/FinalizingFedoraSwitchtoPython3)

* Fri Feb 09 2018 Fedora Release Engineering <releng@fedoraproject.org> - 17.3.0-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_28_Mass_Rebuild

* Wed Sep 27 2017 Troy Dawson <tdawson@redhat.com> - 17.3.0-2
- Cleanup spec file conditionals

* Mon Sep 18 2017 Jeremy Cline <jeremy@jcline.org> - 17.3.0-1
- New upstream release 17.2.0
- Drop memory leak patch as it's in the 17.3.0 upstream release

* Fri Sep 08 2017 Jeremy Cline <jeremy@jcline.org> - 17.2.0-1
- New upstream release 17.2.0
- Backport a memory leak fix with CRLs (upstream PR #690).

* Thu Jul 27 2017 Fedora Release Engineering <releng@fedoraproject.org> - 17.1.0-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Mass_Rebuild

* Mon Jul 17 2017 Tomáš Mráz <tmraz@redhat.com> - 17.1.0-1
- New upstream release 17.1.0.

* Fri Apr 28 2017 Tomáš Mráz <tmraz@redhat.com> - 16.2.0-4
- Fix the obsolete version (needs to be in sync with Fedora 25) (#1446529)

* Sat Feb 11 2017 Fedora Release Engineering <releng@fedoraproject.org> - 16.2.0-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_26_Mass_Rebuild

* Mon Dec 12 2016 Stratakis Charalampos <cstratak@redhat.com> - 16.2.0-2
- Rebuild for Python 3.6

* Tue Nov  8 2016 Tomáš Mráz <tmraz@redhat.com> - 16.2.0-1
- Upgrade to 16.2.0 to fix compatibility with OpenSSL-1.1.0

* Fri Sep  9 2016 Orion Poplawski <orion@cora.nwra.com> - 16.0.0-3
- Modernize spec
- Ship python2-pyOpenSSL
- Package LICENSE

* Tue Jul 19 2016 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 16.0.0-2
- https://fedoraproject.org/wiki/Changes/Automatic_Provides_for_Python_RPM_Packages

* Tue May 10 2016 Tomáš Mráz <tmraz@redhat.com> - 16.0.0-1
- Upgrade to 16.0.0

* Thu Feb 04 2016 Fedora Release Engineering <releng@fedoraproject.org> - 0.15.1-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Tue Nov 10 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.15.1-2
- Rebuilt for https://fedoraproject.org/wiki/Changes/python3.5

* Fri Aug  7 2015 Tomáš Mráz <tmraz@redhat.com> - 0.15.1-1
- Upgrade to 0.15.1

* Thu Jun 18 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.14-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Thu May 14 2015 Tomáš Mráz <tmraz@redhat.com> - 0.14-4
- allow changing the digest used when exporting CRL and use SHA1 by default

* Fri Jan 30 2015 Miro Hrončok <mhroncok@redhat.com> - 0.14-3
- Fix bogus requires (python3-cryptography should belong to python3-pyOpenSSL)

* Wed Jan  7 2015 Tomáš Mráz <tmraz@redhat.com> - 0.14-2
- Add missing python-cryptography requires

* Wed Jan  7 2015 Tomáš Mráz <tmraz@redhat.com> - 0.14-1
- Upgrade to 0.14 with help of Matěj Cepl and Kevin Fenzi

* Sun Aug 17 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.13.1-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Sat Jun 07 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.13.1-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Tue May 27 2014 Kalev Lember <kalevlember@gmail.com> - 0.13.1-2
- Rebuilt for https://fedoraproject.org/wiki/Changes/Python_3.4

* Thu Sep  5 2013 Tomáš Mráz <tmraz@redhat.com> - 0.13.1-1
- new upstream release fixing a security issue with string
  formatting subjectAltName of a certificate

* Tue Aug 06 2013 Jeffrey C. Ollie <jeff@ocjtech.us> - 0.13-8
- Python 3 subpackage
- Split documentation off into noarch subpackage

* Sun Aug 04 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.13-7
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Thu Apr  4 2013 Tomáš Mráz <tmraz@redhat.com> - 0.13-6
- Check for error returns which cause segfaults in FIPS mode
- Fix missing error check and leak found by gcc-with-cpychecker (#800086)

* Thu Feb 14 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.13-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Fri Oct 12 2012 Petr Pisar <ppisar@redhat.com> - 0.13-4
- Do not scan documentation for dependencies (bug #865806)

* Mon Oct 08 2012 Dan Horák <dan[at]danny.cz> - 0.13-3
- rebuilt because ARM packages had wrong Requires autodetected

* Sat Jul 21 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.13-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Wed Jun 20 2012 Tomas Mraz <tmraz@redhat.com> - 0.13-1
- New upstream release

* Sat Jan 14 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.12-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Tue Jun 28 2011 Tomas Mraz <tmraz@redhat.com> - 0.12-1
- New upstream release

* Tue Feb 08 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.10-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Tue Dec 7 2010 Toshio Kuratomi <toshio@fedoraproject.org> - 0.10-2
- Fix incompatibility with python-2.7's socket module.

* Mon Oct  4 2010 Tomas Mraz <tmraz@redhat.com> - 0.10-1
- Merge-review cleanup by Parag Nemade (#226335)
- New upstream release

* Wed Jul 21 2010 David Malcolm <dmalcolm@redhat.com> - 0.9-2
- Rebuilt for https://fedoraproject.org/wiki/Features/Python_2.7/MassRebuild

* Tue Sep 29 2009 Matěj Cepl <mcepl@redhat.com> - 0.9-1
- New upstream release
- Fix BuildRequires to make Postscript documentation buildable

* Fri Aug 21 2009 Tomas Mraz <tmraz@redhat.com> - 0.7-7
- rebuilt with new openssl

* Sun Jul 26 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.7-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Thu Feb 26 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.7-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Thu Jan 15 2009 Dennis Gilmore <dennis@ausil.us> - 0.7-4
- rebuild against now openssl

* Sat Nov 29 2008 Ignacio Vazquez-Abrams <ivazqueznet+rpm@gmail.com> - 0.7-3
- Rebuild for Python 2.6

* Fri Sep 19 2008 Dennis Gilmore <dennis@ausil.us> - 0.7-2
- update threadsafe  patch
- bug#462807

* Mon Sep 15 2008 Paul F. Johnson <paul@all-the-johnsons.co.uk> 0.7-1
- bump to new release
- the inevitable patch fixes


* Wed Mar 26 2008 Tom "spot" Callaway <tcallawa@redhat.com> - 0.6-4
- fix horrific release tag
- fix license tag
- add egg-info

* Tue Feb 19 2008 Fedora Release Engineering <rel-eng@fedoraproject.org> - 0.6-3.p24.9
- Autorebuild for GCC 4.3

* Wed Dec  5 2007 Jeremy Katz <katzj@redhat.com> - 0.6-2.p24.9
- rebuild for new openssl

* Mon Dec 11 2006 Paul Howarth <paul@city-fan.org> - 0.6-1.p24.9
- add missing buildreq latex2html, needed to build HTML docs
- rewrite to be more in line with Fedora python spec template and use
  %%{python_sitearch} rather than a script-generated %%files list
- package is not relocatable - drop Prefix: tag
- buildreq perl not necessary
- fix permissions for files going into debuginfo package

* Thu Dec  7 2006 Jeremy Katz <katzj@redhat.com> - 0.6-1.p24.8
- rebuild for python 2.5

* Wed Jul 12 2006 Jesse Keating <jkeating@redhat.com> - 0.6-1.p24.7.2.2
- rebuild

* Fri Feb 10 2006 Jesse Keating <jkeating@redhat.com> - 0.6-1.p24.7.2.1
- bump again for double-long bug on ppc(64)

* Tue Feb 07 2006 Jesse Keating <jkeating@redhat.com> - 0.6-1.p24.7.2
- rebuilt for new gcc4.1 snapshot and glibc changes

* Fri Dec 09 2005 Jesse Keating <jkeating@redhat.com>
- rebuilt

* Wed Nov  9 2005 Mihai Ibanescu <misa@redhat.com> - 0.6-1.p24.7
- rebuilt against newer openssl

* Wed Aug 24 2005 Jeremy Katz <katzj@redhat.com> - 0.6-1.p24.6
- add dcbw's patch to fix some threading problems

* Wed Aug 03 2005 Karsten Hopp <karsten@redhat.de> 0.6-1.p24.5
- current rpm creates .pyo files, include them in filelist

* Thu Mar 17 2005 Mihai Ibanescu <misa@redhat.com> 0.6-1.p24.4
- rebuilt

* Mon Mar 14 2005 Mihai Ibanescu <misa@redhat.com> 0.6-1.p24.3
- rebuilt

* Mon Mar  7 2005 Tomas Mraz <tmraz@redhat.com> 0.6-1.p23.2
- rebuild with openssl-0.9.7e

* Tue Nov  9 2004 Nalin Dahyabhai <nalin@redhat.com> 0.6-1.p23.1
- rebuild

* Fri Aug 13 2004 Mihai Ibanescu <misa@redhat.com> 0.6-1
- 0.6 is out

* Tue Aug 10 2004 Mihai Ibanescu <misa@redhat.com> 0.6-0.90.rc1
- release candidate

* Thu Jun 24 2004 Mihai Ibanescu <misa@redhat.com> 0.5.1-24
- rebuilt

* Mon Jun 21 2004 Mihai Ibanescu <misa@redhat.com> 0.5.1-23
- rebuilt

* Tue Jun 15 2004 Elliot Lee <sopwith@redhat.com>
- rebuilt

* Tue Mar 02 2004 Elliot Lee <sopwith@redhat.com>
- rebuilt

* Fri Feb 13 2004 Elliot Lee <sopwith@redhat.com>
- rebuilt

* Wed Nov  5 2003 Mihai Ibanescu <misa@redhat.com> 0.5.1-20
- rebuilt against python 2.3.2

* Fri Aug  8 2003 Mihai Ibanescu <misa@redhat.com> 0.5.1-12
- lynx no longer supported, using elinks instead (patch from
  Michael Redinger <michael.redinger@uibk.ac.at>, bug #101947 )

* Wed Jun  4 2003 Elliot Lee <sopwith@redhat.com> 0.5.1-11
- Rebuilt

* Wed Jun  4 2003 Mihai Ibanescu <misa@redhat.com> 0.5.1-10.7.x
- Built on 7.x

* Mon Mar  3 2003 Mihai Ibanescu <misa@redhat.com> 0.5.1-9
- bug #73967: Added Requires: python

* Mon Feb 24 2003 Elliot Lee <sopwith@redhat.com>
- rebuilt

* Fri Feb 21 2003 Mihai Ibanescu <misa@redhat.com> 0.5.1-7
- bug #84803: Added patch to expose more flags

* Fri Jan 31 2003 Mihai Ibanescu <misa@redhat.com> 0.5.1-5
- installing to %%{_libdir}

* Wed Jan 22 2003 Tim Powers <timp@redhat.com>
- rebuilt

* Tue Jan  7 2003 Nalin Dahyabhai <nalin@redhat.com> 0.5.1-3
- rebuild

* Fri Jan  3 2003 Nalin Dahyabhai <nalin@redhat.com>
- Add -I and -L flags for finding Kerberos headers and libraries, in case
  they're referenced

* Tue Dec  3 2002 Mihai Ibanescu <misa@redhat.com>
- Fix for bug 73967: site-packages/OpenSSL not owned by this package
- Adding hacks around the lack of latex2html on ia64

* Tue Sep 24 2002 Mihai Ibanescu <misa@redhat.com>
- 0.5.1

* Thu Aug 29 2002 Mihai Ibanescu <misa@redhat.com>
- Building 0.5.1rc1 with version number 0.5.0.91 (this should also fix the big
  error of pushing 0.5pre previously, since it breaks rpm's version comparison
  algorithm).
- We use %%{__python}. Too bad I can't pass --define's to distutils.

* Fri Aug 16 2002 Mihai Ibanescu <misa@redhat.com>
- Building 0.5

* Fri Jun 14 2002 Mihai Ibanescu <misa@redhat.com>
- Added documentation
