Name:		spacewalk-jpp-workaround
Version:	2.3.5
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

%if 0%{?fedora} || 0%{?rhel} >= 7
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

Requires:   struts >= 1.3.10
Provides:   struts-taglib = 1.3.10
Provides:   struts-tiles = 1.3.10

Requires:   jakarta-oro
Provides:   oro
Obsoletes:  spacewalk-oro-compat
%endif

%if 0%{?fedora} >= 20 || 0%{?rhel} >= 7
Requires:   apache-commons-digester
Provides:   jakarta-commons-digester = 1.8.1
Obsoletes:  jakarta-commons-digester < 1.8.1

Requires:   apache-commons-logging
Provides:   jakarta-commons-logging = 1.1.3
Obsoletes:  jakarta-commons-logging < 1.1.3

Requires:   apache-commons-validator
Provides:   jakarta-commons-validator = 1.4.0
Obsoletes:  jakarta-commons-validator < 1.4.0

Requires:   javapackages-tools
Provides:   jpackage-utils
Obsoletes:  jpackage-utils >= 5.0.0
%endif

%if 0%{?fedora} >= 22
Requires:   apache-commons-fileupload
Provides:   jakarta-commons-fileupload = 1:1.3.0
Obsoletes:  jakarta-commons-fileupload < 1:1.3.0

Requires:   apache-commons-collections
Provides:   jakarta-commons-collections = 3.2.0
Obsoletes:  jakarta-commons-collections < 3.2.0
%endif

%if 0%{?fedora} >= 23
Provides:   mvn(org.apache.taglibs:taglibs-standard-jstlel)
%endif

%description
This package fulfills jpackage missing msv-msv dependency.

%prep
# nothing to do here

%build
# nothing to do here


%install
rm -rf $RPM_BUILD_ROOT
%if 0%{?fedora} == 19 || 0%{?rhel} == 7
mkdir -p $RPM_BUILD_ROOT/usr/share/java
ln -s apache-commons-validator.jar $RPM_BUILD_ROOT/usr/share/java/commons-validator.jar
%endif


%clean
rm -rf $RPM_BUILD_ROOT


%files
%if 0%{?fedora} == 19 || 0%{?rhel} == 7
/usr/share/java/commons-validator.jar
%endif


%changelog
* Fri Dec 04 2015 Tomas Kasparek <tkasparek@redhat.com> 2.3.5-1
- provide mvn(org.apache.taglibs:taglibs-standard-jstlel) on F23

* Fri May 29 2015 Tomas Kasparek <tkasparek@redhat.com> 2.3.4-1
- add epoch for jakarta-commons-fileupload

* Thu May 28 2015 Tomas Kasparek <tkasparek@redhat.com> 2.3.3-1
- update spacewalk-jpp-workaround for Fedora 22

* Thu Sep 11 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.2-1
- replace jakarta-commons-validator on RHEL7

* Wed Aug 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.1-1
- added obsoletes to force replacement of jakarta-common-* packages

* Fri Jun 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.3-1
- provide missing link on Fedora 19

* Wed Jun 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.2-1
- megred spacewalk-oro-compat into spacewalk-jpp-workaround
- force use of apache-commons-digester on Fedora/RHEL7+

* Wed Jun 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.1-1
- updated for RHEL7

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.3-1
- spec file polish

* Fri Jan 17 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.2-1
- obsoleted package should be also provided

* Thu Jan 16 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.1-1
- fixed tito build warning
- jpackage-utils were replaced with javapackages-tools in fc20

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
