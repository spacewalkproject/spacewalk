Summary: Oracle 9i Database Server Enterprise Edition command-line admin scripts
Name: oracle-server-admin
Version: 0.1
Release: 2
Source0: wrapper.sh
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
install -m755 %{SOURCE0} $RPM_BUILD_ROOT%{oracle_admin}/create-db.sh
(cd $RPM_BUILD_ROOT%{oracle_admin}; for s in start-db.sh stop-db.sh; do
    ln create-db.sh $s
done)

%clean
rm -rf $RPM_BUILD_ROOT

%pre
# Add the oracle.dba setup
if [ -z "$(grep '^dba:' /etc/group)" ] ; then
    /usr/sbin/groupadd -r dba >/dev/null 2>&1 || true
fi
if [ -z "$(grep '^oracle:' /etc/passwd)" ] ; then
    /usr/sbin/useradd -G dba -c "Oracle Server" \
	-r -d %{oracle_base} oracle >/dev/null 2>&1 || true
fi

%files
%defattr(-,oracle,dba)
%{oracle_admin}

%changelog
* Mon Aug 4 2003 Mihai Ibanescu <misa@redhat.com> 0.1-1
- Initial build
