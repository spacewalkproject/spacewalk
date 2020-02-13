%if %{_vendor} == "debbuild"
# Debian points /bin/sh to /bin/dash by default. This breaks a lot of common
# scripts that rely on bash-specific behavior, so changing the shell preempts
# a lot of these breakages.
%global _buildshell /bin/bash
%endif


# Setuptools install flags
%if %{_vendor} == "debbuild"
%global pyinstflags --no-compile -O0
%global pytargetflags --install-layout=deb
%else
%global pyinstflags -O1
%global pytargetflags %{nil}
%endif

# For systems (mostly debian) that don't define these things -------------------
%{!?__python2:%global __python2 /usr/bin/python2}
%{!?__python3:%global __python3 /usr/bin/python3}

%if %{undefined python2_sitearch}
%global python2_sitearch %(%{__python2} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(1))")
%endif

%if %{undefined python3_sitearch}
%global python3_sitearch %(%{__python3} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(1))")
%endif

%{!?py3dir: %global py3dir %{_builddir}/python3-%{name}-%{version}-%{release}}

# -----------------------------------------------------------------------------


Name: python-dmidecode
Summary: Python module to access DMI data
Version: 3.12.2
Release: 10%{?dist}

%if %{_vendor} == "debbuild"
Packager: Neal Gompa <ngompa@datto.com>
License: GPL-2.0
Group: python
%else
License: GPLv2
Group: System Environment/Libraries
%endif
URL: https://github.com/nima/python-dmidecode
Source0: https://github.com/nima/%{name}/archive/v%{version}/%{name}-%{version}.tar.gz

Patch666: Stop-linking-with-libxml2mod.patch

%if %{_vendor} == "debbuild"
BuildRequires: libxml2-dev

BuildRequires: python-dev
BuildRequires: python-libxml2

BuildRequires: python3-dev
BuildRequires: python3-libxml2
%else
BuildRequires: libxml2-devel

BuildRequires: python2-devel
BuildRequires: libxml2-python

BuildRequires: python3-devel
BuildRequires: libxml2-python3
%endif

%description
python-dmidecode is a Python extension module that uses the
code-base of the 'dmidecode' utility, and presents the data
as python data structures or as XML data using libxml2.

%package -n python2-dmidecode
Summary: Python 2 module to access DMI data
%if %{_vendor} == "debbuild"
Requires: python-libxml2
# Replaces Debian's python-dmidecode
Provides: python-dmidecode
Obsoletes: python-dmidecode
# For scriptlets
Requires(preun): python-minimal
Requires(post): python-minimal
%else
Requires: libxml2-python
%endif
%{?python_provide:%python_provide python2-dmidecode}

%description -n python2-dmidecode
python2-dmidecode is a Python 2 extension module that uses the
code-base of the 'dmidecode' utility, and presents the data
as python data structures or as XML data using libxml2.

%package -n python3-dmidecode
Summary: Python 3 module to access DMI data
%if %{_vendor} == "debbuild"
Requires: python3-libxml2
# For scriptlets
Requires(preun): python3-minimal
Requires(post): python3-minimal
%else
Requires: libxml2-python3
%endif

%description -n python3-dmidecode
python3-dmidecode is a Python 3 extension module that uses the
code-base of the 'dmidecode' utility, and presents the data
as Python 3 data structures or as XML data using libxml2.



%prep
%setup -qc

%if %{_vendor} == "debbuild"
# Apply patches for debian
pushd %{name}-%{version}
%patch666 -p1
popd
%endif

mv %{name}-%{version} python2
cp -a python{2,3}

pushd python3
sed -i 's/python2/python3/g' Makefile unit-tests/Makefile
popd


%build
# Not to get undefined symbol: dmixml_GetContent
export CFLAGS="${CFLAGS-} -std=gnu89"


for PY in python2 python3; do
  pushd $PY
  make build
  popd
done

%install
pushd python2
%{__python2} src/setup.py install %{?pyinstflags} --skip-build --root %{buildroot} %{?pytargetflags} --prefix=%{_prefix}
popd

pushd python3
%{__python3} src/setup.py install %{?pyinstflags} --skip-build --root %{buildroot} %{?pytargetflags} --prefix=%{_prefix}
popd


%if %{_vendor} != "debbuild"
%check
for PY in python2 python3; do
  pushd $PY/unit-tests
  make
  popd
done
%endif

%files -n python2-dmidecode
%license python2/doc/LICENSE python2/doc/AUTHORS python2/doc/AUTHORS.upstream
%doc python2/README python2/doc/README.upstream
%{python2_sitearch}/*
%{_datadir}/python-dmidecode/

%files -n python3-dmidecode
%license python3/doc/LICENSE python3/doc/AUTHORS python3/doc/AUTHORS.upstream
%doc python3/README python3/doc/README.upstream
%{python3_sitearch}/*
%{_datadir}/python-dmidecode/

%if %{_vendor} == "debbuild"

%post -n python2-dmidecode
# Do late-stage bytecompilation, per debian policy
pycompile -p python2-dmidecode -V -3.0

%preun -n python2-dmidecode
# Ensure all *.py[co] files are deleted, per debian policy
pyclean -p python2-dmidecode

%post -n python3-dmidecode
# Do late-stage bytecompilation, per debian policy
py3compile -p python3-dmidecode -V -4.0

%preun -n python3-dmidecode
# Ensure all *.py[co] files are deleted, per debian policy
py3clean -p python3-dmidecode

%endif


%changelog
* Fri Jul 06 2018 Neal Gompa <ngompa@datto.com> - 3.12.2-10
- Add Debian/Ubuntu support

* Sat Aug 19 2017 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> - 3.12.2-9
- Python 2 binary package renamed to python2-dmidecode
  See https://fedoraproject.org/wiki/FinalizingFedoraSwitchtoPython3

* Thu Aug 03 2017 Fedora Release Engineering <releng@fedoraproject.org> - 3.12.2-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Binutils_Mass_Rebuild

* Thu Jul 27 2017 Fedora Release Engineering <releng@fedoraproject.org> - 3.12.2-7
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Mass_Rebuild

* Sat Feb 11 2017 Fedora Release Engineering <releng@fedoraproject.org> - 3.12.2-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_26_Mass_Rebuild

* Mon Dec 19 2016 Miro Hrončok <mhroncok@redhat.com> - 3.12.2-5
- Rebuild for Python 3.6

* Tue Jul 19 2016 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.12.2-4
- https://fedoraproject.org/wiki/Changes/Automatic_Provides_for_Python_RPM_Packages

* Thu Feb 04 2016 Fedora Release Engineering <releng@fedoraproject.org> - 3.12.2-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Sat Nov 07 2015 Robert Kuska <rkuska@redhat.com> - 3.12.2-2
- Rebuilt for Python3.5 rebuild

* Fri Jul 10 2015 Miro Hrončok <mhroncok@redhat.com> - 3.12.2-1
- Update to 3.12.2
- Add Python 3 subpackage (#1236000)
- Removed deprecated statements
- Moved some docs to license
- Removed pacthes
- Corrected bogus dates in %%changelog
- Build with -std=gnu89

* Thu Jun 18 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.10.13-13
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Sun Aug 17 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.10.13-12
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Sat Jun 07 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.10.13-11
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Sun Aug 04 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.10.13-10
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Thu Jun 20 2013 Ales Ledvinka <aledvink@redhat.com> - 3.10.13-9
- Attribute installed may appear as duplicate and cause invalid XML.

* Mon Jun 17 2013 Ales Ledvinka <aledvink@redhat.com> - 3.10.13-8
- Attribute dmispec may cause invalid XML on some hardware.
- Signal handler for SIGILL.

* Thu Feb 14 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.10.13-7
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Sat Jul 21 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.10.13-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Thu Jul 19 2012 Ales Ledvinka <aledvink@redhat.com> 3.10.14-5
- Upstream relocated. Document source tag and tarball generation.

* Sat Jan 14 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.10.13-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Tue Feb 08 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.10.13-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Thu Jul 22 2010 David Malcolm <dmalcolm@redhat.com> - 3.10.13-2
- Rebuilt for https://fedoraproject.org/wiki/Features/Python_2.7/MassRebuild

* Tue Jun 15 2010 Roman Rakus <rrakus@redhat.com> - 3.10.13-1
- Update to new release

* Fri Mar 12 2010 Nima Talebi <nima@it.net.au> - 3.10.12-1
- Update to new release

* Tue Feb 16 2010 Nima Talebi <nima@it.net.au> - 3.10.11-1
- Update to new release

* Tue Jan 12 2010 Nima Talebi <nima@it.net.au> - 3.10.10-1
- Update to new release

* Thu Jan 07 2010 Nima Talebi <nima@it.net.au> - 3.10.9-1
- Update to new release


* Tue Dec 15 2009 Nima Talebi <nima@it.net.au> - 3.10.8-1
- New Upstream release.
- Big-endian and little-endian approved.
- Packaged unit-test to tarball.
- Rewritten unit-test to be able to run as non-root user, where it will not
  try to read /dev/mem.
- Added two dmidump data files to the unit-test.

* Thu Nov 26 2009 David Sommerseth <davids@redhat.com> - 3.10.7-3
- Fixed even more .spec file issues and removed explicit mentioning
  of /usr/share/python-dmidecode/pymap.xml

* Wed Nov 25 2009 David Sommerseth <davids@redhat.com> - 3.10.7-2
- Fixed some .spec file issues (proper Requires, use _datadir macro)

* Wed Sep 23 2009 Nima Talebi <nima@it.net.au> - 3.10.7-1
- Updated source0 to new 3.10.7 tar ball

* Mon Jul 13 2009 David Sommerseth <davids@redhat.com> - 3.10.6-6
- Only build the python-dmidecode module, not everything

* Mon Jul 13 2009 David Sommerseth <davids@redhat.com> - 3.10.6-5
- Added missing BuildRequres for libxml2-python

* Mon Jul 13 2009 David Sommerseth <davids@redhat.com> - 3.10.6-4
- Added missing BuildRequres for python-devel

* Mon Jul 13 2009 David Sommerseth <davids@redhat.com> - 3.10.6-3
- Added missing BuildRequres for libxml2-devel

* Mon Jul 13 2009 David Sommerseth <davids@redhat.com> - 3.10.6-2
- Updated release, to avoid build conflict

* Wed Jun 10 2009 David Sommerseth <davids@redhat.com> - 3.10.6-1
- Updated to work with the new XML based python-dmidecode

* Sat Mar  7 2009 Clark Williams <williams@redhat.com> - 2.10.3-1
- Initial build.

