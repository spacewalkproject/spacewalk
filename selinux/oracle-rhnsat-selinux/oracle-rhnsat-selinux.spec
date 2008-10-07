
%define selinux_variants mls strict targeted 
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp)
%define moduletype apps
%define modulename oracle-rhnsat

Name:            oracle-rhnsat-selinux
Version:         10.2
Release:         1%{?dist}
Summary:         SELinux policy module supporting Oracle
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
Requires(post):   /usr/sbin/semodule, /sbin/restorecon
Requires(postun): /usr/sbin/semodule, /sbin/restorecon
Requires:         oracle-server = 10.2.0.4
Requires:         oracle-selinux >= 0.1-23.1
Requires:         oracle-selinux < 0.1-23.2

%description
SELinux policy module supporting Satellite embedded Oracle server.

%prep
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

%clean
rm -rf %{buildroot}

%post
# Install SELinux policy modules
for selinuxvariant in %{selinux_variants}
  do
    /usr/sbin/semodule -s ${selinuxvariant} -i \
      %{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp &> /dev/null || :
  done

# Fix up oracle-server-arch files
rpm -q --whatprovides oracle-server | xargs rpm -ql | xargs -n 100 /sbin/restorecon -Rivv

# Fix up database files
/sbin/restorecon -R -v /rhnsat || :

%postun
# Clean up after package removal
if [ $1 -eq 0 ]; then
  # Remove SELinux policy modules
  for selinuxvariant in %{selinux_variants}
    do
      /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} &> /dev/null || :
    done

  # Clean up oracle-server-arch files
  rpm -q --whatprovides oracle-server | xargs rpm -ql | xargs -n 100 /sbin/restorecon -Rivv

  # Clean up any remaining file contexts (shouldn't be any really)
  /sbin/restorecon -R -v /rhnsat || :
fi

%files
%defattr(-,root,root,0755)
%doc SELinux/%{modulename}.fc SELinux/%{modulename}.if SELinux/%{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

%changelog
* Tue Oct  7 2008 Jan Pazdziora
- the initial release, based on oracle-selinux 0.1-23.1
