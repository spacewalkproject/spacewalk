%{!?python_sitelib: %define python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}
Name:          jabberpy
Version:       0.5
# Used like this because upstream releases like 0.5-0
Release:       0.15%{?dist}
Summary:       Python xmlstream and jabber IM protocol libs

Group:         Development/Libraries
License:       LGPLv2+
URL:           http://sourceforge.net/projects/jabberpy/
Source0:       http://downloads.sf.net/sourceforge/%{name}/%{name}-%{version}-0.tar.gz
Patch0:        jabberpy-no-init.patch
Patch1:        jabberpy-clean-sockets.patch

BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:     noarch

BuildRequires: python
Requires:      python

%description
jabber.py is a Python module for the jabber instant messaging
protocol. jabber.py deals with the xml parsing and socket code,
leaving the programmer to concentrate on developing quality jabber
based applications with Python.

%prep
%setup -q -n %{name}-%{version}-0
chmod -x examples/*.py
%patch0 -p1 -b .no-init
%patch1 -p1 -b .clean-sockets

%build
%{__python} setup.py  build

%install
rm -rf $RPM_BUILD_ROOT
%{__python} setup.py install --root=$RPM_BUILD_ROOT --record=INSTALLED_FILES

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%doc examples README
%{python_sitelib}/*


%changelog
* Mon Oct 10 2008 Michael Stahnke <stahnma@fedoraproject.org> 0.5-0.16
- Clean up for Fedora Review and submission

* Wed Sep  3 2008 Jesus Rodriguez <jesusr@redhat.com> 0.5-0.15
- remove reliance on external version file

* Tue Oct 09 2007 Pradeep Kilambi <pkilambi@redhat.com>
- clean dangling ports left out by jabberpy

* Mon Jun 14 2004 Mihai Ibanescu <misa@redhat.com>
- Initial build
- Patched to add a __init__ file
