Name:           oracle-lib-compat
Version:        10.2
Release:        6%{?dist}
Summary:        Compatibility package so that perl-DBD-Oracle will install.
Group:          Applications/Multimedia
License:        GPL
URL:            http://localhost/
BuildRoot:      %{_tmppath}/%{name}-root-%(%{__id_u} -n)
Requires:       oracle-instantclient-basic >= 10.2.0
%ifarch x86_64
%define lib64 ()(64bit)
%endif
Provides:       libocci.so.10.1%{?lib64}
Provides:       libnnz10.so%{?lib64}
Provides:       libocijdbc10.so%{?lib64}
Provides:       libclntsh.so.10.1%{?lib64}
Provides:       libociei.so%{?lib64}

%description
Compatibility package so that perl-DBD-Oracle will install.

%prep
mkdir -p $RPM_BUILD_ROOT

%build

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/usr/lib/oracle
pushd $RPM_BUILD_ROOT/usr/lib/oracle
    ln -s 10.2.0.4 10.2.0
popd

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/usr/lib/oracle/10.2.0

%post
%ifarch x86_64
ldconfig /usr/lib/oracle/10.2.0.4/client64/lib/
%endif


%changelog
* Mon Jul 29 2008 Mike McCune <mmccune@redhat.com>
- Removing uneeded Requires compat-libstdc++

* Tue Jul 2 2008 Mike McCune <mmccune@redhat.com>
- Adding ldconfig for the 64bit instantclient libs

* Tue Jul 1 2008 Mike McCune <mmccune@redhat.com>
- relaxing instantclient version requirement to be >= vs =

* Mon Jun 16 2008 Michael Mraka <michael.mraka@redhat.com>
- added 64bit libs macro

* Fri Jun 13 2008 Devan Goodwin <dgoodwin@redhat.com> 10.2-3
- Add symlink for to Oracle 10.2.0.4 libraries.

* Wed Jun 4 2008 Jesus Rodriguez <jmrodri at gmail dot com> 10.2-1
- initial compat rpm

