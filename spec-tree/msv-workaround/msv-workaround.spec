Name:		msv-workaround
Version:	1.0.1
Release:	1%{?dist}
Summary:	Workaround package to fulfill jpackage broken dependencies

Group:		Applications/Internet
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

Requires:	relaxngDataType
Provides:	msv-msv

%description
This package fulfills jpackage missing msv-msv dependecy

%prep
#%setup -q


%build
#%configure
#make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
#make install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc



%changelog
* Mon Feb 07 2011 Tomas Lestach <tlestach@redhat.com> 1.0.1-1
- Introducing msv-workaround package

* Mon Feb 07 2011 Tomas Lestach <tlestach@redhat.com> 1.0.0-1
- introducing msv-workaround package
