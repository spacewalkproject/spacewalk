
%define selinux_variants mls strict targeted 
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp)
%define moduletype apps
%define modulename oracle-xe

Name:            oracle-xe-selinux
Version:         10.2
Release:         4%{?dist}
Summary:         SELinux policy module supporting Oracle XE
Group:           System Environment/Base
License:         GPLv2+
Source1:         %{modulename}.if
Source2:         %{modulename}.te
Source3:         %{modulename}.fc
BuildRoot:       %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires:   checkpolicy, selinux-policy-devel, hardlink
BuildArch:       noarch

%if "%{selinux_policyver}" != ""
Requires:         selinux-policy >= %{selinux_policyver}
%endif
Requires(post):   /usr/sbin/semodule, /sbin/restorecon, /sbin/ldconfig
Requires(postun): /usr/sbin/semodule, /sbin/restorecon
Requires:         oracle-xe-univ
Requires:         oracle-selinux

%description
SELinux policy module supporting Oracle XE server.

%prep
rm -rf SELinux
mkdir -p SELinux
cp -p %{SOURCE1} %{SOURCE2} %{SOURCE3} SELinux

%build
# Build SELinux policy modules
cd SELinux
for selinuxvariant in %{selinux_variants}
do
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile
    mv %{modulename}.pp %{modulename}.pp.${selinuxvariant}
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile clean
done
cd -

%install
rm -rf %{buildroot}

# Install SELinux policy modules
cd SELinux
for selinuxvariant in %{selinux_variants}
  do
    install -d %{buildroot}%{_datadir}/selinux/${selinuxvariant}
    install -p -m 644 %{modulename}.pp.${selinuxvariant} \
           %{buildroot}%{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp
  done
cd -

# Install SELinux interfaces
install -d %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}
install -p -m 644 SELinux/%{modulename}.if \
  %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

# Hardlink identical policy module packages together
/usr/sbin/hardlink -cv %{buildroot}%{_datadir}/selinux

mkdir -p $RPM_BUILD_ROOT/etc/ld.so.conf.d
echo /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/lib > $RPM_BUILD_ROOT/etc/ld.so.conf.d/oracle-xe.conf


%clean
rm -rf %{buildroot}

%define extra_restorecon /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/log /usr/lib/oracle/xe/oradata /usr/lib/oracle/xe/app
%define extra_subdirs /usr/lib/oracle/xe/app/oracle/flash_recovery_area /usr/lib/oracle/xe/app/oracle/admin /usr/lib/oracle/xe/oradata

%pre

ORACLE_UID=`id -u oracle`
if [ -z "$ORACLE_UID" ] ; then
	echo "The oracle user has to exist with uid < 500 before installing this package."
	exit 1
elif [ $ORACLE_UID -ge 500 ] ; then
	echo "The oracle user has to exist with uid < 500 before installing this package."
	echo "User with uid [$ORACLE_UID] found which is not good."
	exit 1
fi

%post
# Install SELinux policy modules
for selinuxvariant in %{selinux_variants}
  do
    /usr/sbin/semodule -s ${selinuxvariant} -i \
      %{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp &> /dev/null || :
  done

/usr/sbin/semanage port -a -t oracle_port_t -p tcp 9000 || :

# Relabel oracle-xe-univ's files
rpm -ql oracle-xe-univ | xargs -n 100 /sbin/restorecon -Rivv

# Create the extra directories if they do not exist yet, so that they
# can be restorecon'ed
mkdir -p %extra_restorecon
mkdir -p %extra_subdirs
chown oracle:dba %extra_subdirs

# Fix up additional directories, not owned by oracle-xe-univ
/sbin/restorecon -Rivv %extra_restorecon

/sbin/ldconfig
%postun
# Clean up after package removal
if [ $1 -eq 0 ]; then
  # Remove SELinux policy modules
  for selinuxvariant in %{selinux_variants}
    do
      /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} &> /dev/null || :
    done

  /usr/sbin/semanage port -d -t oracle_port_t -p tcp 9000 || :

  # Clean up oracle-xe-univ's files
  rpm -ql oracle-xe-univ | xargs -n 100 /sbin/restorecon -Rivv

  # Clean up additional directories, not owned by oracle-xe-univ
  /sbin/restorecon -Rivv %extra_restorecon
fi

%files
%defattr(-,root,root,0755)
%doc SELinux/%{modulename}.fc SELinux/%{modulename}.if SELinux/%{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
/etc/ld.so.conf.d/oracle-xe.conf

%changelog
* Wed Oct 29 2008 Jan Pazdziora 10.2-4
- /etc/init.d/oracle-xe configure with port 9000 passes without AVC denial
- creating new user via http://...:9000/apex passes without AVC denial

* Fri Oct 24 2008 Jan Pazdziora 10.2-3
- addressing first part of /etc/init.d/oracle-xe configure issues

* Thu Oct 23 2008 Jan Pazdziora 10.2-2
- require oracle-selinux

* Tue Oct  7 2008 Jan Pazdziora 10.2-1
- the initial release, based on oracle-selinux 0.1-23.1
