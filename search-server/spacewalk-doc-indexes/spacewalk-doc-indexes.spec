Name: spacewalk-doc-indexes
Version: 0.4.1
Release: 1%{?dist}
Summary: Lucene indexes of help documentation for spacewalk.

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
BuildArch: noarch

%description
Lucene generated indexes used by the spacewalk search-server for
documentation/help searches

%prep
%setup -q


%build
#nothing to do here

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes/docs
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes/docs/segments
cp -a data/crawl_www/index/* $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes/docs
cp -a data/crawl_www/segments/* $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes/docs/segments

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(644,root,root,755)
%{_prefix}/share/rhn/search/indexes/docs


%changelog
* Tue Dec 16 2008 John Matthews <jmatthews@redhat.com> 0.4.1-1
- initial

