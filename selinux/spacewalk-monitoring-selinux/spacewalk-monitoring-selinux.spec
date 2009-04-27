
%define selinux_variants mls strict targeted
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define POLICYCOREUTILSVER 1.33.12-1

%define moduletype apps
%define modulename spacewalk-monitoring

Name:           spacewalk-monitoring-selinux
Version:        0.5.6
Release:        1%{?dist}
Summary:        SELinux policy module supporting Spacewalk monitoring

Group:          System Environment/Base
License:        GPLv2+
# This src.rpm is cannonical upstream. You can obtain it using
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd spacewalk
# make srpm TAG=%{name}-%{version}-%{release}
URL:            http://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  checkpolicy, selinux-policy-devel, hardlink
BuildRequires:  policycoreutils >= %{POLICYCOREUTILSVER}
BuildArch:      noarch

%if "%{selinux_policyver}" != ""
Requires:       selinux-policy >= %{selinux_policyver}
%endif
Requires(post):   /usr/sbin/semodule, /sbin/restorecon
Requires(postun): /usr/sbin/semodule, /sbin/restorecon
Requires:       spacewalk-selinux
Requires:       SatConfig-general
Requires:       NPalert

%description
SELinux policy module supporting Spacewalk monitoring.

%prep
%setup -q

%build
# Build SELinux policy modules
perl -i -pe 'BEGIN { $VER = join ".", grep /^\d+$/, split /\./, "%{version}.%{release}"; } s!\@\@VERSION\@\@!$VER!g;' %{modulename}.te
for selinuxvariant in %{selinux_variants}
do
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile
    mv %{modulename}.pp %{modulename}.pp.${selinuxvariant}
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile clean
done

%install
rm -rf %{buildroot}

# Install SELinux policy modules
for selinuxvariant in %{selinux_variants}
  do
    install -d %{buildroot}%{_datadir}/selinux/${selinuxvariant}
    install -p -m 644 %{modulename}.pp.${selinuxvariant} \
           %{buildroot}%{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp
  done

# Install SELinux interfaces
install -d %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}
install -p -m 644 %{modulename}.if \
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

/sbin/restorecon -rv /etc/rc.d/np.d /etc/notification /var/lib/nocpulse /var/lib/notification /var/log/nocpulse
/sbin/restorecon -rvi /var/log/SysVStep.* /var/run/SysVStep.*

%postun
# Clean up after package removal
if [ $1 -eq 0 ]; then
  for selinuxvariant in %{selinux_variants}
    do
      /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 \
        && /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} || :
    done
fi

/sbin/restorecon -rvi /etc/rc.d/np.d /etc/notification /var/lib/nocpulse /var/lib/notification /var/log/nocpulse
/sbin/restorecon -rvi /var/log/SysVStep.* /var/run/SysVStep.*

%files
%defattr(-,root,root,0755)
%doc %{modulename}.fc %{modulename}.if %{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

%changelog
* Mon Mar 16 2009 Jan Pazdziora 0.5.6-1
- donatudit sys_tty_config
- 487221 - allow monitoring to use NIS

* Fri Mar 13 2009 Jan Pazdziora 0.5.5-1
- 487280 - allow monitoring to write to console and communicate with initrc_t

* Tue Feb 10 2009 Jan Pazdziora 0.5.4-1
- allow httpd to manage /var/lib/notification

* Mon Feb  9 2009 Jan Pazdziora 0.5.3-1
- dontaudit attempts to read /etc/shadow
- allow CGI scripts to read monitoring configuration
- allow monitoring to manage spacewalk_monitoring_var_lib_t directories as well
- allow Apache to read monitoring's configuration
- allow npBootstrap.pl to connect to https
- relabel existing /var/log and /var/run files

* Sun Feb  1 2009 Jan Pazdziora 0.5.2-1
- enabled monitoring services start and stop without SELinux errors
  except for read of /etc/shadow

* Sat Jan 31 2009 Jan Pazdziora 0.5.1-1
- disabled monitoring services start and stop without SELinux errors
- monitoring can be enabled on the WebUI without SELinux errors

* Fri Jan 30 2009 Jan Pazdziora 0.5.0-1
- the initial release
- base on spacewalk-selinux
