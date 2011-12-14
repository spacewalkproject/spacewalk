Name:		spacewalk-jpp-workaround
Version:	1.0.0
Release:	1%{?dist}
Summary:	Workaround package to fulfill jpackage broken dependencies

Group:		Applications/Internet
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

%if 0%{?rhel} > 5
Requires:	relaxngDatatype
Provides:	msv-msv = 1.0
Obsoletes:  msv-workaround
%endif

%if 0%{?fedora}
Provides:   hivemind-lib = 1.1.1.0
Obsoletes:  hivemind-lib < 1.1.1.0
Provides:   hivemind = 1.1.1.0
Obsoletes:  hivemind < 1.1.1.0
Provides:   tapestry = 4.0.2.0
Obsoletes:  tapestry < 4.0.2.0
Provides:   spring-all = 1.2.9.0
Obsoletes:  spring-all < 1.2.9.0
Provides:   spring = 1:1.2.9.0
Obsoletes:  spring < 1:1.2.9.0
%endif

%description
This package fulfills jpackage missing msv-msv dependency.

%prep
# nothing to do here

%build
# nothing to do here


%install
rm -rf $RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)


%changelog
* Wed Dec 14 2011 Tomas Lestach <tlestach@redhat.com> 1.0.0-0
- introducing spacewalk-jpp-workaround package
