%global		revision	1010
%{expand:	%%global	archivename	gyp-%{version}%{?revision:-svn%{revision}}}
%if !(0%{?fedora} || 0%{?rhel} > 5)
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%endif

Name:		gyp
Version:	0.1
Release:	0.6%{?revision:.%{revision}svn}.2%{?dist}
Summary:	Generate Your Projects

Group:		Development/Tools
License:	BSD
URL:		http://code.google.com/p/gyp/
# No released tarball avaiable. so the tarball was generated
# from svn as following:
#
# 1. svn co http://gyp.googlecode.com/svn/trunk gyp
# 2. cd gyp
# 3. version=$(grep version= setup.py|cut -d\' -f2)
# 4. revision=$(svn info|grep -E "^Revision:"|cut -d' ' -f2)
# 5. tar -a --exclude-vcs -cf /tmp/gyp-$version-svn$revision.tar.bz2 *
Source0:	%{archivename}.tar.bz2
Patch0:		gyp-rpmoptflags.patch
Patch1:		gyp-python24.patch

BuildRequires:	python2-devel
BuildArch:	noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
GYP is a tool to generates native Visual Studio, Xcode and SCons
and/or make build files from a platform-independent input format.

Its syntax is a universal cross-platform build representation
that still allows sufficient per-platform flexibility to accommodate
irreconcilable differences.


%prep
%setup -q -c -n %{archivename}
%patch0 -p1 -b .0-rpmoptflags
%patch1 -p0
for i in $(find pylib -name '*.py'); do
	sed -e '\,#![ \t]*/.*python,{d}' $i > $i.new && touch -r $i $i.new && mv $i.new $i
done

%build
%{__python} setup.py build


%install
rm -rf $RPM_BUILD_ROOT

%{__python} setup.py install --root $RPM_BUILD_ROOT --skip-build


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc AUTHORS LICENSE
%{_bindir}/gyp
%{python_sitelib}/*


%changelog
* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 0.1-0.6.1010svn.2
- spec file polish

* Tue Aug 23 2011 Akira TAGOH <tagoh@redhat.com> - 0.1-0.6.1010svn
- Rebase to r1010.

* Wed Feb 09 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.1-0.5.840svn
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Fri Aug 20 2010 Akira TAGOH <tagoh@redhat.com> - 0.1-0.4.840svn
- Rebase to r840.
- generate Makefile with RPM_OPT_FLAGS in CCFLAGS.

* Fri Aug  6 2010 Akira TAGOH <tagoh@redhat.com> - 0.1-0.3.839svn
- Drop the unnecessary macro.

* Thu Aug  5 2010 Akira TAGOH <tagoh@redhat.com. - 0.1-0.2.839svn
- Update the spec file according to the suggestion in rhbz#621242.

* Wed Aug  4 2010 Akira TAGOH <tagoh@redhat.com> - 0.1-0.1.839svn
- Initial packaging.

