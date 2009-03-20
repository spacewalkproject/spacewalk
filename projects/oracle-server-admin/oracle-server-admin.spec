Summary: Oracle Database Server command-line admin scripts
Name: oracle-server-admin
Version: 0.1
Release: 11%{?dist}
Source0: admin-wrapper.sh
License: Oracle License
Group: Oracle Server
BuildArch: noarch
Buildroot: /var/tmp/%{name}-root
Requires: oracle-server-scripts
Requires: oracle-config

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
    wrapper=$(basename %{SOURCE0})
    for s in create-db.sh start-db.sh stop-db.sh create-user.sh; do
        ln -s $wrapper $s
    done
)

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,oracle,dba)
%{oracle_admin}

%changelog
* Fri May 23 2008 Michael Mraka <michael.mraka@redhat.com> 0.1-11
- config files moved to independent package

* Thu May 15 2008 Michael Mraka <michael.mraka@redhat.com> 0.1-9
- fixed user and group creation in %pre script

* Thu Mar 27 2008 Michael Mraka <michael.mraka@redhat.com> 0.1-5
- modified according to packaging guidelines

* Mon Aug 4 2003 Mihai Ibanescu <misa@redhat.com> 0.1-1
- Initial build
