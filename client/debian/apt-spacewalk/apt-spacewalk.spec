%{!?__python2:%global __python2 /usr/bin/python2}

%if %{undefined python2_version}
%global python2_version %(%{__python2} -Esc "import sys; sys.stdout.write('{0.major}.{0.minor}'.format(sys.version_info))")
%endif

%if %{undefined python2_sitelib}
%global python2_sitelib %(%{__python2} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
%endif

Name: apt-spacewalk
Summary: Spacewalk plugin for Advanced Packaging Tool
%if %{_vendor} == "debbuild"
Packager: Spacewalk Project <spacewalk-devel@redhat.com>
Group: admin
%endif
Version: 1.0.14
Release: 1%{?dist}
License: GPLv2
Source0: %{name}-%{version}.tar.gz
URL: https://github.com/spacewalkproject/spacewalk
BuildArch: noarch
BuildRequires: python

%description
apt-spacewalk is plugin used on Debian clients
to acquire content from Spacewalk server

%package -n apt-transport-spacewalk
Summary: APT transport for communicating with Spacewalk servers
Requires: apt
Requires: python-apt
Requires: rhn-client-tools
Requires: python-six

Recommends: rhnsd

%description -n apt-transport-spacewalk
 Supplies the APT method for fetching packages from Spacewalk.
 Adds transaction hooks to:
 1) Update APT's sourcelist with subscribed spacewalk channels
    before updating
 2) Register the machine's installed packages with the Spacewalk
    server after any dpkg invocation

%prep
%setup -q

%build
# Nothing to build

%install
mkdir -p $RPM_BUILD_ROOT/%{_prefix}/lib/apt-spacewalk
cp -a *_invoke.py $RPM_BUILD_ROOT/%{_prefix}/lib/apt-spacewalk
mkdir -p $RPM_BUILD_ROOT/%{_prefix}/lib/apt/methods
cp -a spacewalk $RPM_BUILD_ROOT/%{_prefix}/lib/apt/methods
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/apt/apt.conf.d
cp -a 50spacewalk $RPM_BUILD_ROOT/%{_sysconfdir}/apt/apt.conf.d
mkdir -p $RPM_BUILD_ROOT/%{python2_sitelib}/rhn/actions
cp -a packages.py $RPM_BUILD_ROOT/%{python2_sitelib}/rhn/actions

%files -n apt-transport-spacewalk
%license LICENSE
%{_prefix}/lib/apt-spacewalk/
%{_prefix}/lib/apt/methods/spacewalk
%config(noreplace) %{_sysconfdir}/apt/apt.conf.d/50spacewalk
%{python2_sitelib}/rhn/actions/packages.py

%if %{_vendor} == "debbuild"
%pre -n apt-transport-spacewalk
hook=/etc/apt/apt.conf.d/50spacewalk
if test -f $hook.disabled
then
    mv $hook.disabled $hook
fi

%postun -n apt-transport-spacewalk
hook=/etc/apt/apt.conf.d/50spacewalk
sourcelist=/etc/apt/sources.list.d/spacewalk.list

case "$1" in
    purge)
        rm -f $hook.disabled
        rm -f $sourcelist.disabled
        ;;

    remove)
        mv $hook $hook.disabled || :
        mv $sourcelist $sourcelist.disabled || :
        ;;

    abort-install)
        if test "x$2" != "x" && test -f $hook
        then
            mv $hook $hook.disabled || :
            mv $sourcelist $sourcelist.disabled || :
        fi
        ;;

    upgrade|failed-upgrade|abort-upgrade|disappear)
        ;;

    *)
        echo "postrm called with unknown argument \`$1'" >&2
        exit 1
esac
%endif

%changelog
* Mon Jun 18 2018 Michael Mraka <michael.mraka@redhat.com> 1.0.14-1
- client/debian: Port apt-spacewalk to be Python 3 ready

* Mon Apr 16 2018 Tomas Kasparek <tkasparek@redhat.com> 1.0.13-1
- apt-transport-spacewalk: missed part of patch within pre_invoke
- further modifications on apt-transport-spacewalk
- modify apt-transport-spacewalk to support signed repos

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 1.0.12-1
- removed BuildRoot from specfiles

* Mon Jul 17 2017 Jan Dobes 1.0.11-1
- Migrating Fedorahosted to GitHub

* Tue Feb 24 2015 Matej Kollar <mkollar@redhat.com> 1.0.10-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 1.0.9-1
- removed trailing whitespaces

* Thu Mar 21 2013 Jan Pazdziora 1.0.8-1
- forward port debian bugs #703207, 700821

* Wed Feb 06 2013 Jan Pazdziora 1.0.7-1
- update documentation on Debian packages

* Sun Jun 17 2012 Miroslav Suchý <msuchy@redhat.com> 1.0.6-1
- add copyright information to header of .py files
- ListRefresh is in APT:Update namespace

* Sun Jun 17 2012 Miroslav Suchý 1.0.5-1
- add LICENSE file for apt-spacewalk tar.gz
- %%defattr is not needed since rpm 4.4

* Thu Apr 28 2011 Simon Lukasik <slukasik@redhat.com> 1.0.4-1
- The method can be killed by the keyboard interrupt (slukasik@redhat.com)

* Sun Apr 17 2011 Simon Lukasik <slukasik@redhat.com> 1.0.3-1
- Introducing actions.packages dispatcher (slukasik@redhat.com)
- Do not use rpmUtils on Debian (slukasik@redhat.com)
- Skip the extra lines sent by Apt (slukasik@redhat.com)

* Wed Apr 13 2011 Jan Pazdziora 1.0.2-1
- utilize config.getServerlURL() (msuchy@redhat.com)

* Thu Mar 17 2011 Simon Lukasik <slukasik@redhat.com> 1.0.1-1
- new package

