Name: nutch
Version: 1.0
Release: 0.2.20081201040121nightly%{?dist}
Summary: open source web-search software

Group: Development/Tools
License: ASL 2.0
URL: http://lucene.apache.org/nutch/index.html
Source0: http://hudson.zones.apache.org/hudson/job/Nutch-trunk/647/artifact/trunk/build/nutch-2008-12-01_04-01-21.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires: java >= 0:1.5.0

%description
Nutch is open source web-search software. It builds on Lucene Java, 
adding web-specifics, such as a crawler, a link-graph database, parsers for 
HTML and other document formats, etc.

%prep
%setup -q -n nutch-2008-12-01_04-01-21

%build
#nothing to do here, move on

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/nutch
cp -a * $RPM_BUILD_ROOT/%{_prefix}/share/nutch

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(644,root,root,755)
%attr(755, root, root) %{_prefix}/share/nutch/bin/*
%{_prefix}/share/nutch/*



%changelog
* Fri Dec 19 2008 John Matthews <jmatthews@redhat.com> 1.0-0.2.20081201040121nightly
- initial 

