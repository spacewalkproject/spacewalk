%global selinux_variants mls strict targeted
%global selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%global POLICYCOREUTILSVER 1.33.12-1
%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

%global moduletype apps
%global modulename jabber

Name:           jabberd-selinux
Version:        2.5.0
Release:        1%{?dist}
Summary:        SELinux policy module supporting jabberd

Group:          System Environment/Base
License:        GPLv2+
URL:            http://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  checkpolicy, selinux-policy-devel, hardlink
BuildRequires:  policycoreutils >= %{POLICYCOREUTILSVER}
BuildArch:      noarch

%if "%{selinux_policyver}" != ""
Requires:       selinux-policy >= %{selinux_policyver}
%endif
%if 0%{?rhel} == 5
Requires:        selinux-policy >= 2.4.6-114
%endif
Requires(post):   /usr/sbin/semodule, %{sbinpath}/restorecon, /usr/sbin/setsebool, /usr/sbin/selinuxenabled
Requires(postun): /usr/sbin/semodule, %{sbinpath}/restorecon
Requires:       jabberd >= 2.2.8

%description
SELinux policy module supporting jabberd.

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

# Install jabberd-selinux-enable which will be called in %posttrans
install -d %{buildroot}%{_sbindir}
install -p -m 755 %{name}-enable %{buildroot}%{_sbindir}/%{name}-enable

%clean
rm -rf %{buildroot}

%post
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/%{name}-enable
fi

%posttrans
#this may be safely remove when BZ 505066 is fixed
if /usr/sbin/selinuxenabled ; then
  rpm -ql jabberd | xargs -n 1 %{sbinpath}/restorecon -ri {} || :
fi

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

rpm -ql jabberd | xargs -n 1 %{sbinpath}/restorecon -ri {} || :

%files
%doc %{modulename}.fc %{modulename}.if %{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
%attr(0755,root,root) %{_sbindir}/%{name}-enable

%changelog
* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Fri Mar 22 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.1-1
- 919468 - fixed path in file based Requires
- %%defattr is not needed since rpm 4.4

* Fri Sep 24 2010 Jan Pazdziora 1.5.1-1
- 627984 - Allow jabberd to read certificates.
- 627984 - Allow jabberd to use Kerberos.
- 627984 - There is no /var/run/jabberd no, pid files are in
  /var/lib/jabberd/pid.
- 627984 - jabberd 2.2.8 starts the four programs directly from the init
  script.

* Fri Aug 27 2010 Shannon Hughes <shughes@redhat.com> 1.4.9-1
- bump version 

* Fri Jan 29 2010 Jan Pazdziora 1.4.8-1
- Do not hide any error messages produced by semanage port -a.

* Thu Nov 26 2009 Miroslav Suchý <msuchy@redhat.com> 1.4.7-1
- use %%global instead of %%define

* Thu Jun 18 2009 Jan Pazdziora 1.4.6-1
- 505606 - Require at least selinux-policy 2.4.6-114

* Mon Jun 15 2009 Miroslav Suchy <msuchy@redhat.com> 1.4.5-1
- 498611 - run "semodule -i" in %%post and restorecon in %%posttrans

* Wed Jun 10 2009 Miroslav Suchy <msuchy@redhat.com> 1.4.4-1
- 498611 - run restorecon in %%posttrans

* Mon Apr 27 2009 Jan Pazdziora 1.4.3-1
- move the %%post SELinux activation to /usr/sbin/jabberd-selinux-enable
- use src.rpm packaging with single Source0
- bump version up to 1.4.3, to allow 1.4.2 to be used by Satellite 5.3.0

* Wed Apr 22 2009 jesus m. rodriguez <jesusr@redhat.com> 1.4.1-1
- Make jabberd-selinux buildable with tito. (dgoodwin@redhat.com)

* Thu Mar 12 2009 Jan Pazdziora 1.4.0-6
- 485396 - silence semanage output altogether

* Wed Feb 25 2009 Jan Pazdziora 1.4.0-5
- 485396 - silence semanage if port is already defined

* Wed Feb  4 2009 Jan Pazdziora 1.4.0-4
- use init_script_file to allow build on Fedoras

* Thu Jan 29 2009 Jan Pazdziora 1.4.0-3
- silence restorecon in scriptlets, and ignore any errors
- avoid .src.rpm-packing-time error when selinux-policy-devel is not installed

* Mon Jan 12 2009 Jan Pazdziora 1.4.0-2
- changes to allow /etc/init.d/jabberd start on RHEL 5.2 to run
  without any AVC denials

* Mon Jan 12 2009 Jan Pazdziora 1.4.0-1
- the initial release, with data from selinux-policy-3.3.1-42.fc9.src.rpm
- based on spacewalk-selinux
- which was inspired by Rob Myers' oracle-selinux
