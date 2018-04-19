Name: spacewalk-doc-indexes
Version: 2.8.5
Release: 1%{?dist}
Summary: Lucene indexes of help documentation for spacewalk

License: GPLv2
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone https://github.com/spacewalkproject/spacewalk.git
# cd search-server/spacewalk-doc-indexes
# make test-srpm
URL: https://fedorahosted.org/spacewalk
Source0: %{name}-%{version}.tar.gz
Requires: nutch
BuildArch: noarch
Provides: doc-indexes

%description
Lucene generated indexes used by the spacewalk search-server for
documentation/help searches

%prep
%setup -q


%build
#nothing to do here

%install
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes/docs/en-US
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes/docs/en-US/segments
cp -a data/crawl_www/index/* $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes/docs/en-US
cp -a data/crawl_www/segments/* $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes/docs/en-US/segments

%clean


%files
%{_prefix}/share/rhn/search/indexes/docs
%if 0%{?suse_version}
%dir %{_prefix}/share/rhn
%dir %{_prefix}/share/rhn/search
%dir %{_prefix}/share/rhn/search/indexes
%endif

%changelog
* Thu Apr 19 2018 Jiri Dostal <jdostal@redhat.com> 2.8.5-1
- Update doc-indexes
- Update crawler to read new release notes page

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.4-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed Sep 27 2017 Eric Herget <eherget@redhat.com> 2.8.3-1
- fix urls, filters and conf for doc indexing
- fixing crawler filter, 5.8 doc is using lower case url

* Mon Sep 11 2017 Eric Herget <eherget@redhat.com> 2.8.2-1
- update docs urls for indexing

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Mon Jul 17 2017 Jan Dobes 2.7.1-1
- Remove more fedorahosted links
- Bumping package versions for 2.7.
- Bumping package versions for 2.6.

* Fri May 20 2016 Grant Gainey 2.5.2-1
- spacewalk-doc-indexes: build on openSUSE

* Thu Oct 15 2015 Jan Dobes 2.5.1-1
- updating doc indexes
- updating doc URLs
- Bumping package versions for 2.5.
- Bumping package versions for 2.4.

* Thu Mar 19 2015 Grant Gainey 2.3.3-1
- update crawl setting for Spacewalk 2.3

* Thu Jan 15 2015 Matej Kollar <mkollar@redhat.com> 2.3.2-1
- Getting rid of trailing spaces in XML

* Tue Nov 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.1-1
- no need to store search logs in git

* Thu Feb 27 2014 Matej Kollar <mkollar@redhat.com> 2.2.1-1
- Updating search index
- Update urls for search reindexing
- Bumping package versions for 2.2.

* Mon Nov 18 2013 Tomas Lestach <tlestach@redhat.com> 2.1.1-1
- updated documentation indexes
- index actual documentation
- Bumping package versions for 2.1.

