Summary: Python xmlstream and jabber IM protocol libs
Name: jabberpy
Version: 0.5
Release: 0.13%{?dist}
Source0: %{name}-%{version}-0.tar.gz
Patch0: jabberpy-no-init.patch
Patch1: jabberpy-clean-sockets.patch
License: LGPL
Group: Development/Libraries
BuildRoot: %{_tmppath}/%{name}-buildroot
Prefix: %{_prefix}
BuildArchitectures: noarch
Vendor: Matthew Allum <breakfast@10.am>
Url: http://jabberpy.sf.net/

%description
jabber.py is a Python module for the jabber instant messaging
protocol. jabber.py deals with the xml parsing and socket code,
leaving the programmer to concentrate on developing quality jabber
based applications with Python.

%prep
%setup -n %{name}-%{version}-0
%patch0 -p1 -b .no-init
%patch1 -p1 -b .clean-sockets

%build
%{__python} setup.py build

%install
%{__python} setup.py install --root=$RPM_BUILD_ROOT --record=INSTALLED_FILES
%if "%dist" == ".el5"
sed -i -e 's@\(.\+\)\.pyc$@\1.pyc\n\1.pyo@' INSTALLED_FILES
%endif

%clean
rm -rf $RPM_BUILD_ROOT

%files -f INSTALLED_FILES
%defattr(-,root,root)

# $Id: jabberpy.spec 150212 2008-03-27 15:16:33Z jpazdzio $
%changelog
* Wed Sep  3 2008 Jesus Rodriguez <jesusr@redhat.com>
- remove reliance on external version file

* Tue Oct 09 2007 Pradeep Kilambi <pkilambi@redhat.com>
- clean dangling ports left out by jabberpy

* Mon Jun 14 2004 Mihai Ibanescu <misa@redhat.com>
- Initial build
- Patched to add a __init__ file
