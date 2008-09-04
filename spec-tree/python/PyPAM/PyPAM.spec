Summary: PAM bindings for Python
Name: PyPAM
Version: 0.4.2
Release: 20%{?dist}
Source0: %{name}-%{version}.tar.gz
Patch0: PyPAM-includes.patch
Patch1: PyPAM-0.4.2-error.patch
Patch2: PyPAM-dlopen.patch
License: LGPL
Group: Development/Libraries
BuildRoot:/var/tmp/%{name}-root
BuildRequires: %{__python} python-devel pam-devel
Requires: python

%define py_ver %(%{__python} -c "import sys, string; print string.join(string.split(string.split(sys.version)[0], '.')[:2], '.')")
%define py_includes "-I/usr/include/python%{py_ver} -I%{_libdir}/python%{py_ver}/config"
%define py_execdir %{_libdir}/python%{py_ver}/site-packages
%define py_dir %{py_execdir}

%description
PAM (Pluggable Authentication Module) bindings for Python.

%prep

%setup
%configure
%patch0 -p1 -b .incl
%patch1 -p1 -b .error
%patch2 -p1 -b .dlopen

%build
make PYTHON=%{__python} PYTHON_INCLUDES=%{py_includes}

%install
rm -rf $RPM_BUILD_ROOT
make DESTDIR=$RPM_BUILD_ROOT pyexecdir=%{py_execdir} pythondir=%{py_dir} install
# Make sure we don't include binary files in the docs
rm -f examples/pamexample

%files
%defattr(-, root, root)
%{py_execdir}/PAMmodule.so
%doc AUTHORS NEWS README ChangeLog
%doc examples

# $Id: PyPAM.spec 172589 2008-05-16 12:17:20Z mmraka $
%changelog
* Fri May 16 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.2-20
- fixed file ownership

* Tue Jun 22 2004 Mihai Ibanescu <misa@redhat.com> 0.4.2-5
- Rebuilt

* Fri Jul 11 2003 Mihai Ibanescu <misa@redhat.com>
- Adapted the original rpm to build with python 2.2
