
Name:		oracle-instantclient-selinux
Version:	10.2
Release:	4%{?dist}
Summary:	SELinux support for Oracle Instant Client
Group:		System Environment/Base
License:	GPLv2+
# This src.rpm is canonical upstream.
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd spacewalk
# make srpm TAG=%{name}-%{version}-%{release}
URL:		http://fedorahosted.org/spacewalk
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:	noarch

Requires(post):	/usr/sbin/semanage, /sbin/restorecon, /usr/bin/execstack
Requires(postun):	/usr/sbin/semanage, /sbin/restorecon, /usr/bin/execstack
Requires:	oracle-instantclient-basic

%description
SELinux support for Oracle Instant Client.

%prep

%build

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{rhnroot}

%clean
rm -rf $RPM_BUILD_ROOT

%define used_libs libocci.so.10.1 libclntsh.so.10.1 libnnz10.so libociei.so

%post
/usr/sbin/semanage fcontext -a -t oracle_sqlplus_exec_t '/usr/lib/oracle/10\.2\.0\.4/client/bin/sqlplus'
for i in %used_libs ; do
	/usr/sbin/semanage fcontext -a -t textrel_shlib_t '/usr/lib/oracle/10\.2\.0\.4/client/lib/'${i//./\\.}
	/usr/bin/execstack -c /usr/lib/oracle/10.2.0.4/client/lib/$i
done
/sbin/restorecon -Rvv /usr/lib/oracle/10.2.0.4/client || :

%postun
if [ $1 -eq 0 ]; then
	/usr/sbin/semanage fcontext -d -t oracle_sqlplus_exec_t '/usr/lib/oracle/10\.2\.0\.4/client/bin/sqlplus'
	for i in %used_libs ; do
		/usr/sbin/semanage fcontext -d -t textrel_shlib_t '/usr/lib/oracle/10\.2\.0\.4/client/lib/'${i//./\\.}
		/usr/bin/execstack -s /usr/lib/oracle/10.2.0.4/client/lib/$i
	done
	/sbin/restorecon -Rvv /usr/lib/oracle/10.2.0.4/client || :
fi

%files

%changelog
* Tue Dec 16 2008 Jan Pazdziora 10.2-4
- added textrel_shlib_t to libocci.so.10.1
- minor .spec cleanup

* Fri Nov 28 2008 Jan Pazdziora 10.2-3
- more textrel_shlib_t

* Wed Oct 29 2008 Jan Pazdziora 10.2-2
- escape semanage fcontext's paths
- label bin/sqlplus

* Fri Oct 10 2008 Jan Pazdziora 10.2-1
- the initial release

