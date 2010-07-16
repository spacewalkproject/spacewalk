
Name:		oracle-instantclient-selinux
Version:	10.2
Release:	18%{?dist}
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

Requires(post):	/usr/sbin/semanage, /sbin/restorecon, /usr/sbin/selinuxenabled
Requires(postun):	/usr/sbin/semanage, /sbin/restorecon
Requires:	oracle-instantclient-basic
Requires:	oracle-nofcontext-selinux

%description
SELinux support for Oracle Instant Client.

%package -n oracle-instantclient-sqlplus-selinux
Summary:	SELinux support for Oracle Instant Client sqlplus
Group:		System Environment/Base
Requires:	oracle-instantclient-sqlplus
Requires:	oracle-nofcontext-selinux
Requires(post):	/usr/sbin/semanage, /sbin/restorecon, /usr/sbin/selinuxenabled
Requires(postun):	/usr/sbin/semanage, /sbin/restorecon

%description -n oracle-instantclient-sqlplus-selinux
SELinux support for Oracle Instant Client sqlplus.

%prep

%build

%define used_libs libocci.so.10.1 libclntsh.so.10.1 libnnz10.so libociei.so libocijdbc10.so

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{rhnroot}
install -d %{buildroot}%{_sbindir}

cat <<'EOS' > %{buildroot}%{_sbindir}/%{name}-enable
#!/bin/bash

for i in %used_libs ; do
	/usr/sbin/semanage fcontext -a -t textrel_shlib_t '/usr/lib/oracle/10\.2\..*/client.*/lib/'${i//./\\.}
done
/sbin/restorecon -Rvv /usr/lib/oracle/10.2.*/client* || :

EOS

cat <<'EOS' > %{buildroot}%{_sbindir}/oracle-instantclient-sqlplus-selinux-enable
#!/bin/bash

/usr/sbin/semanage fcontext -a -t oracle_sqlplus_exec_t '/usr/lib/oracle/10\.2\..*/client.*/bin/sqlplus'
/usr/sbin/semanage fcontext -a -t textrel_shlib_t '/usr/lib/oracle/10\.2\..*/client.*/lib/libsqlplus\.so'
/usr/sbin/semanage fcontext -a -t textrel_shlib_t '/usr/lib/oracle/10\.2\..*/client.*/lib/libsqlplusic\.so'
/sbin/restorecon -Rvv /usr/lib/oracle/10.2.*/client* || :

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
	/sbin/restorecon -Rvv /usr/lib/oracle/10.2.*/client* || :
fi

%postun
if [ $1 -eq 0 ]; then
	for i in %used_libs ; do
		/usr/sbin/semanage fcontext -d -t textrel_shlib_t '/usr/lib/oracle/10\.2\..*/client.*/lib/'${i//./\\.}
	done
	/sbin/restorecon -Rvv /usr/lib/oracle/10.2.*/client* || :
fi

%post -n oracle-instantclient-sqlplus-selinux
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/oracle-instantclient-sqlplus-selinux-enable
fi

%posttrans -n oracle-instantclient-sqlplus-selinux
#this may be safely remove when BZ 505066 is fixed
if /usr/sbin/selinuxenabled ; then
	/sbin/restorecon -Rvv /usr/lib/oracle/10.2.*/client* || :
fi

%postun -n oracle-instantclient-sqlplus-selinux
if [ $1 -eq 0 ]; then
	/usr/sbin/semanage fcontext -d -t oracle_sqlplus_exec_t '/usr/lib/oracle/10\.2\..*/client.*/bin/sqlplus'
	/usr/sbin/semanage fcontext -d -t textrel_shlib_t '/usr/lib/oracle/10\.2\..*/client.*/lib/libsqlplus\.so'
	/sbin/restorecon -Rvv /usr/lib/oracle/10.2.*/client* || :
fi

%files
%attr(0755,root,root) %{_sbindir}/%{name}-enable

%files -n oracle-instantclient-sqlplus-selinux
%attr(0755,root,root) %{_sbindir}/oracle-instantclient-sqlplus-selinux-enable

%changelog
* Fri Jul 16 2010 Michael Mraka <michael.mraka@redhat.com> 10.2-18
- fixed libsqlplusic.so on 32bit
- libocijdbc10 is used by jdbc:oci

* Thu Nov 26 2009 Jan Pazdziora 10.2-17
- On 64bit platform, the libsqlplusic.so needs textrel_shlib_t

* Wed Sep 09 2009 Michael Mraka <michael.mraka@redhat.com> 10.2-16
- 506951 - execstack -c moved to instantclient packages

* Mon Jun 15 2009 Miroslav Suchy <msuchy@redhat.com> 10.2-15
- 498611 - run "semodule -i" in %%post and restorecon in %%posttrans

* Thu Jun 11 2009 Miroslav Suchy <msuchy@redhat.com> 10.2-14
- return version down to 10.2

* Wed Jun 10 2009 Miroslav Suchy <msuchy@redhat.com> 10.3-1
- 498611 - run restorecon in %%posttrans

* Tue May 26 2009 Jan Pazdziora 10.2-13
- oracle-instantclient-selinux: use the correct
	oracle-instantclient-sqlplus-selinux-enable script name

* Mon May 11 2009 Jan Pazdziora 10.2-12
- do not Require oracle-instantclient-sqlplus

* Mon May 11 2009 Jan Pazdziora 10.2-11
- create oracle-instantclient-sqlplus-selinux subpackage

* Wed Apr 29 2009 Jan Pazdziora 10.2-10
- Require oracle-instantclient-sqlplus

* Wed Apr 29 2009 Jan Pazdziora 10.2-9
- move the %%post SELinux activation to
  /usr/sbin/oracle-instantclient-selinux-enable

* Tue Mar 24 2009 Jan Pazdziora 10.2-8
- make the package noarch since we use wildcards in path
- 491849 - losen the version specification of the Oracle InstantClient

* Mon Feb  9 2009 Jan Pazdziora 10.2-7
- add texrel_shlib_t to libsqlplus.so

* Thu Dec 18 2008 Jan Pazdziora 10.2-6
- 64bit InstantClient uses /usr/lib/oracle/10.2.0.4/client64
- add Requires of oracle-nofcontext-selinux

* Wed Dec 17 2008 Jan Pazdziora 10.2-5
- clear the execstack flag on InstantClient libraries

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

