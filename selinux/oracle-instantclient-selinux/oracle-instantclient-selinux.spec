
Name:            oracle-instantclient-selinux
Version:         10.2
Release:         1%{?dist}
Summary:         SELinux support for Oracle Instant Client
Group:           System Environment/Base
License:         GPLv2+
BuildRoot:       %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:       noarch

Requires(post):   /usr/sbin/semanage, /sbin/restorecon
Requires(postun):  /usr/sbin/semanage, /sbin/restorecon
Requires:         oracle-instantclient-basic

%description
SELinux support for Oracle Instant Client.

%prep

%build

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{rhnroot}

%clean
rm -rf $RPM_BUILD_ROOT

%post
/usr/sbin/semanage fcontext -a -t textrel_shlib_t /usr/lib/oracle/10.2.0/client/lib/libnnz10.so
/usr/sbin/semanage fcontext -a -t textrel_shlib_t /usr/lib/oracle/10.2.0/client/lib/libclntsh.so.10.1
/sbin/restorecon -Rvv /usr/lib/oracle/10.2.0/client/lib || :

%postun
if [ $1 -eq 0 ]; then
	/usr/sbin/semanage fcontext -d -t textrel_shlib_t /usr/lib/oracle/10.2.0/client/lib/libnnz10.so
	/usr/sbin/semanage fcontext -d -t textrel_shlib_t /usr/lib/oracle/10.2.0/client/lib/libclntsh.so.10.1
	/sbin/restorecon -Rvv /usr/lib/oracle/10.2.0/client/lib || :
fi

%files

%changelog
* Fri Oct 10 2008 Jan Pazdziora
- the initial release

