Summary: Oracle Database Server command-line admin scripts
Name: oracle-server-admin
Source9999: version
Version: %(echo `awk '{ print $1 }' %{SOURCE9999}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE9999}`)%{?dist}
Source0: admin-wrapper.sh
License: Oracle License
Group: Oracle Server
BuildArch: noarch
Buildroot: /var/tmp/%{name}-root
Requires: oracle-server-scripts

%define oracle_base /opt/apps/oracle
%define oracle_admin %{oracle_base}/admin

%description
Command-line admin scripts for Oracle Server

%prep
%setup -c -T

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

install -m755 -d $RPM_BUILD_ROOT%{oracle_admin}
install -m755 %{SOURCE0} $RPM_BUILD_ROOT%{oracle_admin}/
(cd $RPM_BUILD_ROOT%{oracle_admin};
    for s in create-db.sh start-db.sh stop-db.sh create-user.sh; do
        ln -s %{SOURCE0} $s
    done
)

%clean
rm -rf $RPM_BUILD_ROOT

%pre
# Add the oracle.dba setup
getent group dba >/dev/null    || groupadd -fr dba
getent group oracle >/dev/null || groupadd -fr oracle
getent user  oracle >/dev/null || \
	useradd -g oracle -G dba -c "Oracle Server" \ -r -d %{oracle_base} oracle
exit 0

%files
%defattr(-,oracle,dba)
%{oracle_admin}

%changelog
* Thu Mar 27 2008 Michael Mraka <michael.mraka@redhat.com> 0.1-5
- modified according to packaging guidelines

* Mon Aug 4 2003 Mihai Ibanescu <misa@redhat.com> 0.1-1
- Initial build
