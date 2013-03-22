%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

Name:		oracle-instantclient-selinux
Version:	11.2.0.2
Release:	1%{?dist}
Summary:	SELinux support for Oracle Instant Client 11g
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

Requires(post):	/usr/sbin/semanage, %{sbinpath}/restorecon, /usr/sbin/selinuxenabled
Requires(postun):	/usr/sbin/semanage, %{sbinpath}/restorecon
Requires:	oracle-instantclient11.2-basic
Requires:	oracle-nofcontext-selinux

%description
SELinux support for Oracle Instant Client.

%package -n oracle-instantclient-sqlplus-selinux
Summary:	SELinux support for Oracle Instant Client sqlplus
Group:		System Environment/Base
Requires:	oracle-instantclient11.2-sqlplus
Requires:	oracle-nofcontext-selinux
Requires(post):	/usr/sbin/semanage, %{sbinpath}/restorecon, /usr/sbin/selinuxenabled
Requires(postun):	/usr/sbin/semanage, %{sbinpath}/restorecon

%description -n oracle-instantclient-sqlplus-selinux
SELinux support for Oracle Instant Client sqlplus.

%prep

%build

%define used_libs libocci.so.11.1 libclntsh.so.11.1 libnnz11.so libociei.so libocijdbc11.so

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{rhnroot}
install -d %{buildroot}%{_sbindir}

cat <<'EOS' > %{buildroot}%{_sbindir}/%{name}-enable
#!/bin/bash

for i in %used_libs ; do
	/usr/sbin/semanage fcontext -a -t textrel_shlib_t '/usr/lib/oracle/11\.2/client.*/lib/'${i//./\\.}
done
%{sbinpath}/restorecon -Rvv /usr/lib/oracle/11.2/client* || :

EOS

cat <<'EOS' > %{buildroot}%{_sbindir}/oracle-instantclient-sqlplus-selinux-enable
#!/bin/bash

/usr/sbin/semanage fcontext -a -t oracle_sqlplus_exec_t '/usr/lib/oracle/11\.2/client.*/bin/sqlplus'
/usr/sbin/semanage fcontext -a -t textrel_shlib_t '/usr/lib/oracle/11\.2/client.*/lib/libsqlplus\.so'
/usr/sbin/semanage fcontext -a -t textrel_shlib_t '/usr/lib/oracle/11\.2/client.*/lib/libsqlplusic\.so'
%{sbinpath}/restorecon -Rvv /usr/lib/oracle/11.2/client* || :

EOS

%clean
rm -rf $RPM_BUILD_ROOT

%post
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/%{name}-enable
fi

%posttrans
#this may be safely remove when BZ 505066 is fixed
if /usr/sbin/selinuxenabled ; then
	%{sbinpath}/restorecon -Rvv /usr/lib/oracle/11.2/client* || :
fi

%postun
if [ $1 -eq 0 ]; then
	for i in %used_libs ; do
		/usr/sbin/semanage fcontext -d -t textrel_shlib_t '/usr/lib/oracle/11\.2/client.*/lib/'${i//./\\.}
	done
	%{sbinpath}/restorecon -Rvv /usr/lib/oracle/11.2/client* || :
fi

%post -n oracle-instantclient-sqlplus-selinux
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/oracle-instantclient-sqlplus-selinux-enable
fi

%posttrans -n oracle-instantclient-sqlplus-selinux
#this may be safely remove when BZ 505066 is fixed
if /usr/sbin/selinuxenabled ; then
	%{sbinpath}/restorecon -Rvv /usr/lib/oracle/11.2/client* || :
fi

%postun -n oracle-instantclient-sqlplus-selinux
if [ $1 -eq 0 ]; then
	/usr/sbin/semanage fcontext -d -t oracle_sqlplus_exec_t '/usr/lib/oracle/11\.2/client.*/bin/sqlplus'
	/usr/sbin/semanage fcontext -d -t textrel_shlib_t '/usr/lib/oracle/11\.2/client.*/lib/libsqlplus\.so'
	/usr/sbin/semanage fcontext -d -t textrel_shlib_t '/usr/lib/oracle/11\.2/client.*/lib/libsqlplusic\.so'
	%{sbinpath}/restorecon -Rvv /usr/lib/oracle/11.2/client* || :
fi

%files
%attr(0755,root,root) %{_sbindir}/%{name}-enable

%files -n oracle-instantclient-sqlplus-selinux
%attr(0755,root,root) %{_sbindir}/oracle-instantclient-sqlplus-selinux-enable

%changelog
* Fri Mar 22 2013 Michael Mraka <michael.mraka@redhat.com> 11.2.0.2-1
- 919468 - fixed path in file based Requires
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Fri Jan 07 2011 Jan Pazdziora 11.2.0.1-1
- Updating oracle-instantclient-selinux for 11g.

* Thu Sep 23 2010 Michael Mraka <michael.mraka@redhat.com> 10.2.0.19-1
- switched to default VersionTagger

* Fri Jul 16 2010 Michael Mraka <michael.mraka@redhat.com> 10.2-18
- fixed libsqlplusic.so on 32bit
- libocijdbc10 is used by jdbc:oci

