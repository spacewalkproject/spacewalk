
%define selinux_variants mls strict targeted
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define POLICYCOREUTILSVER 1.33.12-1

%define moduletype apps
%define modulename jabber

Name:           jabberd-selinux
Version:        1.4.0
Release:        3%{?dist}
Summary:        SELinux policy module supporting jabberd

Group:          System Environment/Base
License:        GPLv2+
URL:            http://fedorahosted.org/spacewalk
Source1:        %{modulename}.if
Source2:        %{modulename}.te
Source3:        %{modulename}.fc
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  checkpolicy, selinux-policy-devel, hardlink
BuildRequires:  policycoreutils >= %{POLICYCOREUTILSVER}
BuildArch:      noarch

%if "%{selinux_policyver}" != ""
Requires:       selinux-policy >= %{selinux_policyver}
%endif
Requires(post):   /usr/sbin/semodule, /sbin/restorecon, /usr/sbin/setsebool
Requires(postun): /usr/sbin/semodule, /sbin/restorecon
Requires:       jabberd

%description
SELinux policy module supporting jabberd.

%prep
rm -rf %{name}-%{version}
mkdir -p %{name}-%{version}
cp -p %{SOURCE1} %{SOURCE2} %{SOURCE3} %{name}-%{version}

%build
# Build SELinux policy modules
cd %{name}-%{version}
perl -i -pe 'BEGIN { $VER = join ".", grep /^\d+$/, split /\./, "%{version}.%{release}"; } s!\@\@VERSION\@\@!$VER!g;' %{modulename}.te
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
cd %{name}-%{version}
for selinuxvariant in %{selinux_variants}
  do
    install -d %{buildroot}%{_datadir}/selinux/${selinuxvariant}
    install -p -m 644 %{modulename}.pp.${selinuxvariant} \
           %{buildroot}%{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp
  done
cd -

# Install SELinux interfaces
install -d %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}
install -p -m 644 %{name}-%{version}/%{modulename}.if \
  %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

# Hardlink identical policy module packages together
/usr/sbin/hardlink -cv %{buildroot}%{_datadir}/selinux

%clean
rm -rf %{buildroot}

%post
# Install SELinux policy modules
for selinuxvariant in %{selinux_variants}
  do
    /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 \
      && /usr/sbin/semodule -s ${selinuxvariant} -i \
        %{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp || :
  done

/usr/sbin/semanage port -a -t jabber_interserver_port_t -p tcp 5347 || :

rpm -ql jabberd | xargs -n 1 /sbin/restorecon -ri {} || :
/sbin/restorecon -ri /var/run/jabberd || :

%postun
# Clean up after package removal
if [ $1 -eq 0 ]; then
  for selinuxvariant in %{selinux_variants}
    do
      /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 \
        && /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} || :
    done

  /usr/sbin/semanage port -d -t jabber_interserver_port_t -p tcp 5347 || :
fi

rpm -ql jabberd | xargs -n 1 /sbin/restorecon -ri {} || :
/sbin/restorecon -ri /var/run/jabberd || :

%files
%defattr(-,root,root,0755)
%doc %{name}-%{version}/%{modulename}.fc %{name}-%{version}/%{modulename}.if %{name}-%{version}/%{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

%changelog
* Thu Jan 29 2009 Jan Pazdziora 1.4.0-3
- silence restorecon in scriptlets, and ignore any errors
- avoid .src.rpm-packing-tim error when selinux-policy-devel is not installed

* Mon Jan 12 2009 Jan Pazdziora 1.4.0-2
- changes to allow /etc/init.d/jabberd start on RHEL 5.2 to run
  without any AVC denials

* Mon Jan 12 2009 Jan Pazdziora 1.4.0-1
- the initial release, with data from selinux-policy-3.3.1-42.fc9.src.rpm
- based on spacewalk-selinux
- which was inspired by Rob Myers' oracle-selinux
