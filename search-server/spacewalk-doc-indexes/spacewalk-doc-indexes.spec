Name: spacewalk-doc-indexes
Version: 0.5.1
Release: 1%{?dist}
Summary: Lucene indexes of help documentation for spacewalk

Group: Applications/Internet
License: GPLv2
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd search-server/spacewalk-doc-indexes
# make test-srpm
URL: https://fedorahosted.org/spacewalk
Source0: %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
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
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes/docs/en
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes/docs/en/segments
cp -a data/crawl_www/index/* $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes/docs/en
cp -a data/crawl_www/segments/* $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes/docs/en/segments

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(644,root,root,755)
%{_prefix}/share/rhn/search/indexes/docs


%changelog
* Mon Jan 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.1-1
- requires nutch now

* Mon Jan 26 2009 John Matthews <jmatthews@redhat.com> 0.5.0-1
- update so compatible with search-server changes for multiple
  languages
* Thu Dec 18 2008 John Matthews <jmatthews@redhat.com> 0.4.5-1
- initial

