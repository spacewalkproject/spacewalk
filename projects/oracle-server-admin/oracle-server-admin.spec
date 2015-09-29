Summary: Oracle Database Server command-line admin scripts
Name: oracle-server-admin
Version: 2.5.0
Release: 1%{?dist}
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
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
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

install -m755 -d $RPM_BUILD_ROOT%{oracle_admin}
install -m755 admin-wrapper.sh $RPM_BUILD_ROOT%{oracle_admin}/
(cd $RPM_BUILD_ROOT%{oracle_admin};
    for s in create-db.sh start-db.sh stop-db.sh create-user.sh; do
        ln -s admin-wrapper.sh $s
    done
)

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,oracle,dba)
%{oracle_admin}

%changelog
* Wed Aug 22 2012 Michael Mraka <michael.mraka@redhat.com> 0.2.2-1
- link to correct script name during package build

* Mon Jul 16 2012 Jan Pazdziora 0.2.1-1
- Start using the .tar.gz in the .src.rpm for oracle-server-admin.
- All the NoTgzBuilders are now spacewalkx.builderx.NoTgzBuilder.

* Thu Sep 23 2010 Michael Mraka <michael.mraka@redhat.com> 0.1.13-1
- switched to default VersionTagger

