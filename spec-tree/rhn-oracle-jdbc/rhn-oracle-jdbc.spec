Name: rhn-oracle-jdbc
Summary: JPackage-compatible wrapper for Oracle JDBC drivers
Version: 1.0
Release: 16

License: GPLv2
Group: Applications/Databases
URL: http://rhn.redhat.com/

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch: noarch
#Obsoletes: oracle-devel-jdbc-9.2.0.6.0-4
#Obsoletes: rhn-oracle-jdbc-1.0-9

# NOTE: Depending on specific version here due to directory where this
# jar gets installed.
Requires: oracle-instantclient-basic >= 10.2.0

%description
Dummy package for symlinking the Oracle JDBC driver into Tomcat's lib 
directory.

%package tomcat5
Summary: Tomcat 5 compatibility for Oracle JDBC
Group: Applications/Databases

%description tomcat5
Tomcat 5 compatibility for oracle jdbc.

%prep

%build

%install
rm -rf $RPM_BUILD_ROOT
#install -d -m 755 $RPM_BUILD_ROOT%{_javadir}
install -d -m 755 $RPM_BUILD_ROOT/var/lib/tomcat5/webapps/rhn/WEB-INF/lib

pushd $RPM_BUILD_ROOT/var/lib/tomcat5/webapps/rhn/WEB-INF/lib
    %ifarch x86_64
    ln -s /usr/lib/oracle/10.2.0/client64/lib/ojdbc14.jar ojdbc14.jar;
    ln -s /usr/lib/oracle/10.2.0/client64/lib/ojdbc14.jar /usr/share/java/ojdbc14.jar;
    %else
    ln -s /usr/lib/oracle/10.2.0/client/lib/ojdbc14.jar ojdbc14.jar;
    ln -s /usr/lib/oracle/10.2.0/client/lib/ojdbc14.jar /usr/share/java/ojdbc14.jar;
    %endif
popd

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)

%files tomcat5
%defattr(-,root,root,-)
/var/lib/tomcat5/webapps/rhn/WEB-INF/lib

%changelog
* Wed Jul 2 2008 Mike McCune <mmccune@redhat.com> 1.0-16
- 64bit client lib location

* Thu Jun 12 2008 Mike McCune <mmccune@redhat.com> 1.0-15
- Remove tomcat4 package

* Thu Jun 12 2008 Devan Goodwin <dgoodwin@redhat.com> 1.0-14
- Switch to dependency for JDBC jar and install symlinks instead.

* Fri May 16 2008 Michael Mraka <michael.mraka@redhat.com> 1.0-13
- fixed file ownership

* Tue Jun  6 2006 Partha Aji <paji@redhat.com>
- Moving  the ojdbc14.jar location to tomcat/webapps/rhn/WEB-INF/lib

* Wed Apr  5 2006 Mike McCune <mmccune@redhat.com>
- Switching to Oracle 10g drivers.  Getting rid of requires oracle-devel-jdbc

* Fri May  6 2005 Jesus M. Rodriguez <jesusr@redhat.com>
- Removed ocrs dep, and change Requires to be oracle-devel-jdbc

* Thu Sep 23 2004 Michael Bowman <mbowman@redhat.com>
- Removed links in shared/lib

* Wed Sep 22 2004 Michael Bowman <mbowman@redhat.com>
- Added links for tomcat[4,5]/common/lib

* Mon Apr  5 2004 Chip Turner <cturner@redhat.com> oracle-jdbc
- Initial build.


