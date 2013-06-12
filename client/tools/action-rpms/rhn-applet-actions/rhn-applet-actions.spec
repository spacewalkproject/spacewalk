Summary: Scheduled actions concerning the Red Hat Satellite Applet
License: GPLv2
Group: System Environment/Base
Source0: %{name}-%{version}.tar.gz
Name: rhn-applet-actions
URL: https://rhn.redhat.com/
Version: 5.0.0
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-root
BuildArch: noarch
Requires: python >= 2.2.1
Requires: rhnlib >= 1.3
Requires: rhn-applet


%description
Scheduled actions concerning the Red Hat Satellite Applet, including redirection to an Red Hat Satellite

%prep
%setup -q

%build
make

%install
rm -fr $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT
make install PREFIX=$RPM_BUILD_ROOT


%clean
rm -fr $RPM_BUILD_ROOT

%files
/usr/share/rhn/actions/
/usr/share/rhn/actions/rhn_applet.py
/usr/share/rhn/actions/rhn_applet.pyc
/etc/sysconfig/rhn/clientCaps.d/
/etc/sysconfig/rhn/clientCaps.d/rhn_applet

%changelog
* Wed Mar 07 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.0.0-1
- adding dist tag
* Tue May 11 2004 Bret McMillan <bretm@redhat.com>
- Initial creation, stolen from rhn-applet spec

