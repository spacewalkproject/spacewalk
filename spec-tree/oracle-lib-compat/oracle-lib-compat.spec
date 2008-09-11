Name:           oracle-lib-compat
Version:        10.2
Release:        9%{?dist}
Summary:        Compatibility package so that perl-DBD-Oracle will install.
Group:          Applications/Multimedia
License:        GPL
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd spec-tree/oracle-lib-compat
# make srpm
URL:            https://fedorahosted.org/spacewalk
BuildRoot:      %{_tmppath}/%{name}-root-%(%{__id_u} -n)
Requires:       oracle-instantclient-basic >= 10.2.0
%ifarch x86_64
%define lib64 ()(64bit)
%endif
Provides:       libocci.so.10.1%{?lib64}   = 10.2.0
Provides:       libnnz10.so%{?lib64}       = 10.2.0
Provides:       libocijdbc10.so%{?lib64}   = 10.2.0
Provides:       libclntsh.so.10.1%{?lib64} = 10.2.0
Provides:       libociei.so%{?lib64}       = 10.2.0

%description
Compatibility package so that perl-DBD-Oracle will install.

%prep

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/%{_libdir}/oracle


ln -s /usr/lib/oracle/10.2.0.4 $RPM_BUILD_ROOT/%{_libdir}/oracle/10.2.0
# the above doesn't work with Oracle's instantclient rpm
# need to hardcode /usr/lib
%ifarch x86_64
    ln -s /usr/lib/oracle/10.2.0.4 $RPM_BUILD_ROOT/usr/lib/oracle/10.2.0
%endif

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{_libdir}/oracle/10.2.0

%post
%ifarch x86_64
ldconfig %{_libdir}/oracle/10.2.0.4/client64/lib/
%endif


%changelog
* Thu Sep 11 2008 Jesus Rodriguez <jesusr@redhat.com> 10.2-9
- fix x86_64

* Thu Sep  4 2008 Michael Mraka <michael.mraka@redhat.com> 10.2-8
- fixed rpmlint errors and warnings
- built in brew/koji

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

