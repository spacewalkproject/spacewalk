%if ! (0%{?fedora} > 12 || 0%{?rhel} > 5)
%{!?python_sitelib: %define python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}
%endif

Summary: Streaming zlib (gzip) support for python
Name: python-gzipstream
Version: 1.4.2
Release: 1%{?dist}
URL:        https://fedorahosted.org/spacewalk
Source0:    https://fedorahosted.org/releases/s/p/spacewalk/python-gzipstream-%{version}.tar.gz
License: Python and GPLv2
Group: Development/Libraries
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch
BuildRequires: python-devel


%description
A streaming gzip handler.
gzipstream.GzipStream extends the functionality of the gzip.GzipFile class
to allow the processing of streaming data.


%prep
%setup -q

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
%doc LICENSE

%changelog
* Fri Nov 26 2010 Miroslav Suchý <msuchy@redhat.com> 1.4.2-1
- put license into doc section (msuchy@redhat.com)
- make setup quiet (msuchy@redhat.com)
- correct buildroot (msuchy@redhat.com)
- correct url and source url to point to fedorahosted (msuchy@redhat.com)

* Fri Nov 26 2010 Miroslav Suchý <msuchy@redhat.com> 1.4.1-1
- new package built with tito

* Tue Jun 02 2009 Dennis Gilmore <dgilmore@redhat.com> 1.4.0-18
- bump release to 18 to ensure its highest nvr wise

* Thu Feb 26 2009 Devan Goodwin <dgoodwin@redhat.com> 1.4.0-4
- Rebuild for new rel-eng tools.

* Tue Jan 27 2009 Miroslav Suchý <msuchy@redhat.com> 1.4.0-3
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
