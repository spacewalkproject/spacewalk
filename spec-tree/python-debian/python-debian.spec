%{!?python_sitelib: %define python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}

Name:           python-debian
Version:        0.1.16
Release:        1
Summary:        Modules for Debian-related data formats
# debfile.py, arfile.py, debtags.py are release under GPL v3 or above
# everything else is GPLv2+
License:        GPLv2+ and GPLv3+
Group:          Development/Libraries
Source0:        http://ftp.debian.org/debian/pool/main/p/python-debian/python-debian_%{version}.tar.gz
URL:            http://git.debian.org/?p=pkg-python-debian/python-debian.git
BuildRequires:  python-devel
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:      noarch
Requires:       python >= 2.4
BuildRequires:  python-devel, python-setuptools


%description
This package provides Python modules that abstract many formats of Debian 
related files. Currently handled are:
* Debtags information (debian.debtags module)
* debian/changelog (debian.changelog module)
* Packages files, pdiffs (debian.debian_support module)
* Control files of single or multiple RFC822-style paragraphs, e.g.
  debian/control, .changes, .dsc, Packages, Sources, Release, etc.
  (debian.deb822 module)
* Raw .deb and .ar files, with (read-only) access to contained
  files and meta-information


%prep
%setup -q


%build
%{__python} setup.py build


%install
rm -rf $RPM_BUILD_ROOT
%{__python} setup.py install --prefix=%{_prefix} --root=$RPM_BUILD_ROOT


%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT
%{__python} setup.py clean


%files
%defattr(-,root,root,-)
%dir %{python_sitelib}/debian
%dir %{python_sitelib}/debian_bundle
%{python_sitelib}/*.py*
%{python_sitelib}/debian/*.py*
%{python_sitelib}/debian_bundle/__init__.py*
%{python_sitelib}/python_debian*

%doc README README.changelog README.deb822 HISTORY.deb822 ACKNOWLEDGEMENTS

%changelog
* Thu Apr 22 2010 Lukáš Ďurfina <lukas.durfina@gmail.com> 0.1.16-1
- Creation of package
