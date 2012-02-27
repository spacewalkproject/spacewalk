Name:		spacewalk-oscap
Version:	0.0.1
Release:	1%{?dist}
Summary:	OpenSCAP plug-in for rhn-check

Group:		Applications/System
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk
Source0:	https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:	noarch
BuildRequires:	python-devel
BuildRequires:	rhnlib
Requires:	openscap-utils
Requires:	libxslt
Requires:       rhnlib
Requires:       rhn-check
%description
spacewalk-oscap is a plug-in fro rhn-check. With this plugin, user is able
to run OpenSCAP scan from Spacewalk or RHN Satellite server.

%prep
%setup -q


%build
make -f Makefile.spacewalk-oscap


%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.spacewalk-oscap install PREFIX=$RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{_datadir}/rhn/actions/scap.*
%{_datadir}/openscap/xsl/xccdf-resume.xslt


%changelog
