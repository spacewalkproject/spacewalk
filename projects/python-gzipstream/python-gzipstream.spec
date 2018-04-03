%if ! (0%{?fedora} || 0%{?rhel} > 5)
%{!?python_sitelib: %define python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}
%endif

%if 0%{?fedora} || 0%{?suse_version} > 1320
%global build_py3   1
%endif

Summary: Streaming zlib (gzip) support for python
Name: python-gzipstream
Version: 2.9.0
Release: 1%{?dist}
URL:        https://github.com/spacewalkproject/spacewalk/wiki/Projects_python-gzipstream
Source0:    https://github.com/spacewalkproject/spacewalk/archive/python-gzipstream-%{version}.tar.gz
License: GPLv2
BuildArch: noarch
%if (0%{?fedora} > 27 || 0%{?rhel} > 7)
BuildRequires: python2-devel
%else
BuildRequires: python-devel
%endif


%global _description\
A streaming gzip handler.\
gzipstream.GzipStream extends the functionality of the gzip.GzipFile class\
to allow the processing of streaming data.\


%description %_description

%package -n python2-gzipstream
Summary: %summary
%{?python_provide:%python_provide python2-gzipstream}

%description -n python2-gzipstream %_description

%if 0%{?build_py3}
%package -n python3-gzipstream
Summary:        %summary
BuildRequires:  python3-devel

%description -n python3-gzipstream %_description

%endif

%prep
%setup -q
mkdir ../py3
cp -a . ../py3

%build
%{__python} setup.py build
%if 0%{?build_py3}
cd ../py3
%{__python3} setup.py build

%endif

%install
%{__python} setup.py install -O1 --skip-build --root $RPM_BUILD_ROOT
%if 0%{?build_py3}
cd ../py3
%{__python3} setup.py install -O1 --skip-build --root $RPM_BUILD_ROOT --prefix %{_usr}

%endif

%files -n python2-gzipstream
%{python_sitelib}/*
%doc html
%license LICENSE

%if 0%{?build_py3}
%files -n python3-gzipstream
%{python3_sitelib}/*
%doc html
%license LICENSE

%endif

%changelog
* Mon Feb 12 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.6-1
- mark license for python3 subpackage
- remove empty section
- Update Python 2 dependency declarations to new packaging standards

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.5-1
- removed %%%%defattr from specfile
- removed Group from specfile

* Wed Nov 08 2017 Jan Dobes 2.8.4-1
- raise exception instead of returning
- fix syntax for python3
- build python3 subpackage

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.3-1
- purged changelog entries for Spacewalk 2.0 and older

* Fri Sep 01 2017 Jan Dobes 2.8.2-1
- rebuild package in Koji (rhel 7 buildroot was missing macros and python-gzipstream obsolete wasn't added)

* Thu Aug 31 2017 Jan Dobes 2.8.1-1
- in master we are on 2.8 already

* Mon Aug 21 2017 Miroslav Suchý <msuchy@redhat.com> 2.7.2-1
- modernize spec
- rename python-gzipstream to python2-gzipstream
- Bumping package versions for 2.8.

* Sat Aug 19 2017 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> - 2.7.1-2
- Python 2 binary package renamed to python2-gzipstream
  See https://fedoraproject.org/wiki/FinalizingFedoraSwitchtoPython3

* Mon Jul 17 2017 Jan Dobes 2.7.1-1
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub
- Bumping package versions for 2.7.
- Bumping package versions for 2.6.
- Bumping package versions for 2.5.
- Bumping package versions for 2.4.

* Thu Mar 19 2015 Grant Gainey 2.3.3-1
- Updating copyright info for 2015

* Thu Feb 05 2015 Stephen Herr <sherr@redhat.com> 2.3.2-1
- Relicense python-gzipstream to be GPL only

* Thu Jan 15 2015 Matej Kollar <mkollar@redhat.com> 2.3.1-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files
- Bumping package versions for 2.3.
- Bumping package versions for 2.2.

