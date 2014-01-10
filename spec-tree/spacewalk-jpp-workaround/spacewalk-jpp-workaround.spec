Name:		spacewalk-jpp-workaround
Version:	1.0.5
Release:	1%{?dist}
Summary:	Workaround package to fulfill jpackage broken dependencies

Group:		Applications/Internet
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

%if 0%{?rhel} > 5
Requires:	relaxngDatatype
Provides:	msv-msv = 1.2.0
Obsoletes:      msv-workaround
Obsoletes:      msv
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

%if 0%{?fedora} && 0%{?fedora} >= 17
Provides:   struts-taglib = 1.3.10
Provides:   struts-tiles = 1.3.10
Requires:   struts >= 1.3.10
%endif

%if 0%{?fedora} >= 20
Provides:   jakarta-commons-logging = 1.1.3
Requires:   apache-commons-logging
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


%changelog
* Fri Jan 10 2014 Tomas Lestach <tlestach@redhat.com> 1.0.5-1
- introduce commons-logging workaround for fc20

* Fri Jul 13 2012 Tomas Lestach <tlestach@redhat.com> 1.0.4-1
- let the workaround package require fedora struts to ensure the struts-*
  provides

* Fri Jul 13 2012 Tomas Lestach <tlestach@redhat.com> 1.0.3-1
- fix typo

* Fri Jul 13 2012 Tomas Lestach <tlestach@redhat.com> 1.0.2-1
- let our workaround package provide struts-taglib and struts-tiles for fc17
- %%defattr is not needed since rpm 4.4

* Thu Dec 15 2011 Michael Mraka <michael.mraka@redhat.com> 1.0.1-1
- take msv out of yum transaction

* Wed Dec 14 2011 Tomas Lestach <tlestach@redhat.com> 1.0.0-1
- new package built with tito

* Wed Dec 14 2011 Tomas Lestach <tlestach@redhat.com> 1.0.0-0
- introducing spacewalk-jpp-workaround package
