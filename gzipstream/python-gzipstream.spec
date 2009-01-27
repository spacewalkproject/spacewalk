%{!?python_sitelib: %define python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}

Summary: Streaming zlib (gzip) support for python
Name: python-gzipstream
Version: 1.4.0
Release: 2%{?dist}
Source0: gzipstream-%{version}.tar.gz
License: PSF
Group: Development/Libraries
BuildRoot: %{_tmppath}/%{name}-buildroot
BuildArch: noarch
BuildRequires: python-devel
Url: http://rhn.redhat.com


%description
A streaming gzip handler.
gzipstream.GzipStream extends the functionality of the gzip.GzipFile class
to allow the processing of streaming data. 


%prep
%setup -q -n gzipstream-%{version}

%build
%{__python} setup.py build

%install
rm -rf $RPM_BUILD_ROOT
%{__python} setup.py install -O1 --skip-build --root $RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{python_sitelib}/*

#$Id: gzipstream.spec,v 1.24 2006-12-07 21:16:31 rnewberr Exp $
%changelog
* Tue Jan 27 2009 Miroslav Suchý <msuchy@redhat.com> 1.4.0-2
- rename gzipstream.spec to python-gzipstream.spec

* Fri Jan 23 2009 Dennis Gilmore <dennis@ausil.us> 1.4.0-17
- BuildRequires python-devel
- lots of spec file cleanups

* Fri Aug  1 2008 Jan Pazdziora
- change .spec not to use the version file

* Wed May 21 2008 Jan Pazdziora - 1.4.0-15
- rebuild in dist-cvs.

* Thu Oct 14 2004 Todd Warner <taw@redhat.com> 1.4.0-4
- bumped release. Fixed a garbage-collection issue.

* Tue Jun 22 2004 Mihai Ibanescu <misa@redhat.com> 1.4.0-1
- Rebuilding with distutils

* Tue Aug 20 2002 Cristian Gafton <gafton@redhat.com>
- figure out automatically what python version are we building for

* Sun Mar 24 2002 Todd Warner <taw@redhat.com>
- Just some v2.2 stuff commented out. (easier testing).

* Sat Mar 23 2002 Todd Warner <taw@redhat.com>
- PythonLib is /usr/lib/python1.5, NOT .../python1.5.2

* Fri Mar 22 2002 Todd Warner <taw@redhat.com>
- Only builds for Python v1.5.2 at the moment.
- Made work with new build system.

* Fri Jan 01 2002 Todd Warner <taw@redhat.com>
- Initial rpm package

