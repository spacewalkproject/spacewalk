Name:         nocpulse-common
Version:      1.17.11
Release:      7%{?dist}
Summary:      NOCpulse common
License:      GPLv2
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/nocpulse-common
# make test-srpm
URL:          https://fedorahosted.org/spacewalk
Source0:      %{name}-%{version}.tar.gz
BuildArch:    noarch
Group:        Applications/System
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires(pre):  httpd, /usr/sbin/useradd
Requires(post): /sbin/runuser, openssh
Obsoletes:     NPusers <= 1.17.11-6

%define package nocpulse
%define identity %{_localstatedir}/lib/%{package}/.ssh/nocpulse-identity

%description
NOCpulse provides application, network, systems and transaction monitoring, 
coupled with a comprehensive reporting system including availability, 
historical and trending reports in an easy-to-use browser interface.

This package installs NOCpulse user shared by other NOCpulse packages 
and set up logrotate script

%prep
%setup -q

%build
# nothing to do

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p %{buildroot}%{_sysconfdir}/%{package}
mkdir -p %{buildroot}%{_localstatedir}/log/%{package}
mkdir -p %{buildroot}%{_localstatedir}/lib/%{package}/.ssh

# install log rotation stuff
mkdir -p $RPM_BUILD_ROOT/etc/logrotate.d
install -m644 nocpulse.logrotate \
   $RPM_BUILD_ROOT/etc/logrotate.d/%{name}

%pre
getent group %{package} >/dev/null || groupadd -r %{package}
getent passwd %{package} >/dev/null || \
useradd -r -g %{package} -G apache -d %{_localstatedir}/lib/%{package} -s /sbin/tcsh -c "NOCpulse user" %{package}
/sbin/passwd -l %{package}
exit 0

%post
if [ ! -f %{identity} ]
then
    runuser -s /bin/bash %{package} - /usr/bin/ssh-keygen -q -t dsa -N '' -f %{identity}
fi

%files
%defattr(-,%{package},%{package},-)
%dir %{_sysconfdir}/nocpulse
%{_localstatedir}/log/%{package}
%{_localstatedir}/lib/%{package}
%config(noreplace) %{_sysconfdir}/logrotate.d/%{name}

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Fri Aug  8 2008 Miroslav Suchy <msuchy@redhat.com>
- rewrite %%description
- add logrotate script
- rename to nocpulse-common

* Fri Jul  4 2008 Dan Horak <dan[at]danny.cz> 1.17.11-7
- clean spec for initial Fedora package

* Thu Jun 26 2008 Miroslav Suchy <msuchy@redhat.com>
- moving directories to complain LSB
- removing nocops user
- cleaning up spec file
- remove setting up root password

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Wed May 21 2008 Miroslav Suchy <msuchy@redhat.com> 1.17.11-6
- migrate to brew / dist-cvs
