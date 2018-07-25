# ------------------------------- Python macros (mostly for debian) -------------------------------
%{!?__python2:%global __python2 /usr/bin/python2}
%{!?__python3:%global __python3 /usr/bin/python3}

%if %{undefined python2_version}
%global python2_version %(%{__python2} -Esc "import sys; sys.stdout.write('{0.major}.{0.minor}'.format(sys.version_info))")
%endif

%if %{undefined python3_version}
%global python3_version %(%{__python3} -Ic "import sys; sys.stdout.write(sys.version[:3])")
%endif

%if %{undefined python2_sitelib}
%global python2_sitelib %(%{__python2} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
%endif

%if %{undefined python3_sitelib}
%global python3_sitelib %(%{__python3} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
%endif
# --------------------------- End Python macros ---------------------------------------------------

%if %{_vendor} == "debbuild"
# Bash constructs in scriptlets don't play nice with Debian's default shell, dash
%global _buildshell /bin/bash
%endif

%if 0%{?fedora} >= 23 || 0%{?rhel} >= 8
%global python3rhnroot %{python3_sitelib}/spacewalk
%endif

%if 0%{?fedora} || 0%{?rhel} >= 8
%global build_py3   1
%global default_py3 1
%endif

%define pythonX %{?default_py3: python3}%{!?default_py3: python2}

%global pythonrhnroot %{python2_sitelib}/spacewalk

Name:	    spacewalk-usix
Version:	2.9.0
Release:	1%{?dist}
Summary:	Spacewalk server and client nano six library
%if %{_vendor} == "debbuild"
Group:      admin
Packager:   Spacewalk Project <spacewalk-devel@redhat.com>
%endif
License:	GPLv2
URL:		  https://github.com/spacewalkproject/spacewalk
Source0:   %{name}-%{version}.tar.gz
BuildArch: noarch

Provides:	spacewalk-backend-usix = %{version}-%{release}
Requires: %{pythonX}-%{name} = %{version}-%{release}
Obsoletes: spacewalk-backend-usix < 2.8

%description
Library for writing code that runs on Python 2 and 3

%package -n python2-%{name}
Summary: Spacewalk client micro six library
Provides: python2-spacewalk-backend-usix = %{version}-%{release}
Obsoletes: python2-spacewalk-backend-usix < 2.8
%if %{_vendor} == "debbuild"
BuildRequires: python-dev
Requires(preun): python-minimal
Requires(post): python-minimal
%else
BuildRequires: python-devel
%endif

%description -n python2-%{name}
Library for writing code that runs on Python 2 and 3

%if 0%{?build_py3}
%package -n python3-%{name}
Summary: Spacewalk client micro six library
Provides: python3-spacewalk-backend-usix = %{version}-%{release}
Obsoletes: python3-spacewalk-backend-usix < 2.8
%if %{_vendor} == "debbuild"
BuildRequires: python3-dev
Requires(preun): python3-minimal
Requires(post): python3-minimal
%else
BuildRequires: python3-devel
%endif

%description -n python3-%{name}
Library for writing code that runs on Python 2 and 3

%endif

%prep
%setup -q


%build
%define debug_package %{nil}

%install
install -m 0755 -d $RPM_BUILD_ROOT%{pythonrhnroot}/common
install -m 0644 __init__.py $RPM_BUILD_ROOT%{pythonrhnroot}/__init__.py
install -m 0644 common/__init__.py $RPM_BUILD_ROOT%{pythonrhnroot}/common/__init__.py
install -m 0644 common/usix.py* $RPM_BUILD_ROOT%{pythonrhnroot}/common/usix.py

%if 0%{?build_py3}
install -d $RPM_BUILD_ROOT%{python3rhnroot}/common
cp $RPM_BUILD_ROOT%{pythonrhnroot}/__init__.py $RPM_BUILD_ROOT%{python3rhnroot}
cp $RPM_BUILD_ROOT%{pythonrhnroot}/common/__init__.py $RPM_BUILD_ROOT%{python3rhnroot}/common
cp $RPM_BUILD_ROOT%{pythonrhnroot}/common/usix.py $RPM_BUILD_ROOT%{python3rhnroot}/common
%endif

%clean

%files

%files -n python2-%{name}
%dir %{pythonrhnroot}
%dir %{pythonrhnroot}/common
%{pythonrhnroot}/__init__.py
%{pythonrhnroot}/common/__init__.py
%{pythonrhnroot}/common/usix.py*
# These macros don't work on debbuild, but it doesn't matter because we don't do bytecompilation
# until after install anyway.
%if %{_vendor} != "debbuild"
%exclude %{pythonrhnroot}/__init__.pyc
%exclude %{pythonrhnroot}/__init__.pyo
%exclude %{pythonrhnroot}/common/__init__.pyc
%exclude %{pythonrhnroot}/common/__init__.pyo
%endif

%if 0%{?build_py3}

%files -n python3-%{name}
%dir %{python3rhnroot}
%dir %{python3rhnroot}/common
%{python3rhnroot}/__init__.py
%{python3rhnroot}/common/__init__.py
%{python3rhnroot}/common/usix.py*
%{python3rhnroot}/common/__pycache__/*
%if %{_vendor} != "debbuild"
%exclude %{python3rhnroot}/__pycache__/*
%exclude %{python3rhnroot}/common/__pycache__/__init__.*
%endif
%endif

%if %{_vendor} == "debbuild"
# Debian requires:
# post: Do bytecompilation after install
# preun: Remove any *.py[co] files

%post -n python2-%{name}
pycompile -p python2-%{name} -V -3.0

%preun -n python2-%{name}
pyclean -p python2-%{name}

%if 0%{?build_py3}
%post -n python3-%{name}
py3compile -p python3-%{name} -V -4.0

%preun -n python3-%{name}
py3clean -p python3-%{name}
%endif
%endif

%changelog
* Thu Mar 01 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.3-1
- empty %%files section is required for a package to build as a metapackage

* Wed Feb 28 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.2-1
- split spacewalk-usix into python2 and python3 variants
- build python3-spacewalk-usix also on rhel8

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed Aug 09 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.8-1
- 1477753 - precompile py3 bytecode

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.7-1
- update copyright year

* Mon Jul 17 2017 Jan Dobes 2.7.6-1
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Fri Feb 24 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.5-1
- Revert "do checks to match latest __init__.py from spacewalk-backend-libs"
- don't package pyc and pyo files

* Thu Feb 23 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.4-1
- do checks to match latest __init__.py from spacewalk-backend-libs
- don't rely on module initialization on backend-libs

* Fri Feb 17 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.3-1
- require python3 version of backend-libs on fedoras

* Fri Feb 17 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.2-1
- require spacewalk-backend-libs for usix functionality

* Wed Feb 15 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.1-1
- new package built with tito


