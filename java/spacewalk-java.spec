%{!?__redhat_release:%define __redhat_release UNKNOWN}
%define cobprofdir      %{_localstatedir}/lib/rhn/kickstarts
%define cobprofdirup    %{_localstatedir}/lib/rhn/kickstarts/upload
%define cobprofdirwiz   %{_localstatedir}/lib/rhn/kickstarts/wizard
%define cobdirsnippets  %{_localstatedir}/lib/rhn/kickstarts/snippets
%define realcobsnippetsdir  %{_localstatedir}/lib/cobbler/snippets

%if  0%{?rhel} && 0%{?rhel} < 6
%define appdir          %{_localstatedir}/lib/tomcat5/webapps
%define jardir          %{_localstatedir}/lib/tomcat5/webapps/rhn/WEB-INF/lib
%else
%define appdir          %{_localstatedir}/lib/tomcat6/webapps
%define jardir          %{_localstatedir}/lib/tomcat6/webapps/rhn/WEB-INF/lib
%endif

%if 0%{?rhel} && 0%{?rhel} >= 6
# checkstyle is broken on Fedoras - we skip for now
# RHEL5 checkstyle4 is incompatible with checkstyle5
%define run_checkstyle  1
%endif

Name: spacewalk-java
Summary: Spacewalk Java site packages
Group: Applications/Internet
License: GPLv2
Version: 1.9.13
Release: 1%{?dist}
URL:       https://fedorahosted.org/spacewalk
Source0:   https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz 
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
ExcludeArch: ia64

Summary: Java web application files for Spacewalk
Group: Applications/Internet

# for RHEL6 we need to filter out several package versions
%if  0%{?rhel} && 0%{?rhel} >= 6
# cglib is not compatible with hibernate and asm from RHEL6
Requires: cglib < 0:2.2
# we dont want jfreechart from EPEL because it has different symlinks
Requires: jfreechart < 1.0.13
%else
Requires: cglib
Requires: jfreechart >= 1.0.9
%endif

Requires: bcel
Requires: c3p0
Requires: hibernate3 = 0:3.2.4
Requires: java >= 1:1.6.0
Requires: java-devel >= 1:1.6.0
Requires: jakarta-commons-lang >= 0:2.1
Requires: jakarta-commons-codec
Requires: jakarta-commons-discovery
Requires: jakarta-commons-cli
Requires: jakarta-commons-el
Requires: jakarta-commons-fileupload
Requires: jakarta-taglibs-standard
Requires: jcommon
Requires: jdom
Requires: jpam
Requires: jta
Requires: log4j
Requires: redstone-xmlrpc
Requires: oscache
# EL5 = Struts 1.2 and Tomcat 5, EL6+/recent Fedoras = 1.3 and Tomcat 6
%if 0%{?rhel} && 0%{?rhel} < 6
Requires: tomcat5
Requires: jasper5
Requires: tomcat5-servlet-2.4-api
Requires: struts >= 0:1.2.9
%else
Requires: tomcat6
Requires: tomcat6-lib
Requires: tomcat6-servlet-2.5-api
Requires: struts >= 0:1.3.0
Requires: struts-taglib >= 0:1.3.0
%endif
Requires: xalan-j2 >= 0:2.6.0
Requires: xerces-j2
Requires: simple-core
Requires: simple-xml
Requires: sitemesh
Requires: stringtree-json
Requires: susestudio-java-client
Requires: spacewalk-java-config
Requires: spacewalk-java-lib
Requires: spacewalk-java-jdbc
Requires: spacewalk-branding
Requires: jpackage-utils >= 0:1.5
Requires: cobbler >= 2.0.0
Requires: dojo
%if 0%{?fedora}
Requires: apache-commons-io
Requires: apache-commons-logging
%else
Requires: jakarta-commons-io
Requires: jakarta-commons-logging
%endif
BuildRequires: ant
BuildRequires: ant-apache-regexp
BuildRequires: java-devel >= 1:1.6.0
BuildRequires: ant-contrib
BuildRequires: ant-junit
BuildRequires: ant-nodeps
BuildRequires: antlr >= 0:2.7.6
BuildRequires: jpam
BuildRequires: tanukiwrapper
Requires: classpathx-mail
BuildRequires: classpathx-mail
BuildRequires: /usr/bin/xmllint
BuildRequires: /usr/bin/perl
%if 0%{?run_checkstyle}
BuildRequires: checkstyle
%endif

# Sadly I need these to symlink the jars properly.
BuildRequires: asm
BuildRequires: bcel
BuildRequires: c3p0
BuildRequires: concurrent
BuildRequires: cglib
BuildRequires: dom4j
BuildRequires: hibernate3 = 0:3.2.4
BuildRequires: jaf
BuildRequires: jakarta-commons-cli
BuildRequires: jakarta-commons-codec
BuildRequires: jakarta-commons-collections
BuildRequires: jakarta-commons-discovery
BuildRequires: jakarta-commons-el
BuildRequires: jakarta-commons-fileupload
BuildRequires: jakarta-commons-validator
BuildRequires: jakarta-taglibs-standard
BuildRequires: jcommon
BuildRequires: jdom
BuildRequires: jfreechart >= 0:1.0.9
BuildRequires: jta
BuildRequires: redstone-xmlrpc
BuildRequires: oscache
BuildRequires: quartz
BuildRequires: simple-core
BuildRequires: simple-xml
BuildRequires: stringtree-json
BuildRequires: susestudio-java-client
# EL5 = Struts 1.2 and Tomcat 5, EL6+/recent Fedoras = 1.3 and Tomcat 6
%if 0%{?rhel} && 0%{?rhel} < 6
BuildRequires: struts >= 0:1.2.9
BuildRequires: jsp
BuildRequires: jasper5
%else
BuildRequires: struts >= 0:1.3.0
BuildRequires: struts-taglib >= 0:1.3.0
BuildRequires: tomcat6
BuildRequires: tomcat6-lib
%endif
BuildRequires: sitemesh
BuildRequires: postgresql-jdbc
%if 0%{?fedora}
# spelling checker is only for Fedoras (no aspell in RHEL6)
BuildRequires: aspell aspell-en libxslt
BuildRequires: apache-commons-io
%else
BuildRequires: jakarta-commons-io
%endif
Obsoletes: rhn-java < 5.3.0
Obsoletes: rhn-java-sat < 5.3.0
Obsoletes: rhn-oracle-jdbc-tomcat5 <= 1.0
Provides: rhn-java = %{version}-%{release}
Provides: rhn-java-sat = %{version}-%{release}
Provides: rhn-oracle-jdbc-tomcat5 = %{version}-%{release}

%if 0%{?fedora} && 0%{?fedora} >= 15
Requires: classpathx-jaf
%endif

%description
This package contains the code for the Java version of the Spacewalk Web Site.

%package config
Summary: Configuration files for RHN Java
Group: Applications/Internet
Obsoletes: rhn-java-config < 5.3.0
Obsoletes: rhn-java-config-sat < 5.3.0
Provides: rhn-java-config = %{version}-%{release}
Provides: rhn-java-config-sat = %{version}-%{release}

%description config
This package contains the configuration files for the Spacewalk Java web
application and taskomatic process.

%package lib
Summary: Jar files for Spacewalk Java
Group: Applications/Internet
Obsoletes: rhn-java-lib < 5.3.0
Obsoletes: rhn-java-lib-sat < 5.3.0
Provides: rhn-java-lib = %{version}-%{release}
Provides: rhn-java-lib-sat = %{version}-%{release}

%description lib
This package contains the jar files for the Spacewalk Java web application
and taskomatic process.

%package oracle
Summary: Oracle database backend support files for Spacewalk Java
Group: Applications/Internet
Requires: ojdbc14
%if  0%{?rhel} && 0%{?rhel} < 6
Requires: tomcat5
%else
Requires: tomcat6
%endif
Provides: spacewalk-java-jdbc = %{version}-%{release}

%description oracle
This package contains Oracle database backend files for the Spacewalk Java.

%package postgresql
Summary: PostgreSQL database backend support files for Spacewalk Java
Group: Applications/Internet
Requires: postgresql-jdbc
%if  0%{?rhel} && 0%{?rhel} < 6
Requires: tomcat5
%else
Requires: tomcat6
%endif
Provides: spacewalk-java-jdbc = %{version}-%{release}

%description postgresql
This package contains PostgreSQL database backend files for the Spacewalk Java.


%if ! 0%{?omit_tests} > 0
%package tests
Summary: Test Classes for testing spacewalk-java
Group:  Applications/Internet

BuildRequires:  jmock < 2.0
Requires: jmock < 2.0
Requires: ant-junit

%description tests
This package contains testing files of spacewalk-java.  

%files tests
%{_datadir}/rhn/lib/rhn-test.jar
%{_datadir}/rhn/unit-tests/*
%{_datadir}/rhn/unittest.xml
%{jardir}/mockobjects*.jar
%{jardir}/strutstest*.jar
%endif

%package -n spacewalk-taskomatic
Summary: Java version of taskomatic
Group: Applications/Internet

# for RHEL6 we need to filter out several package versions
%if  0%{?rhel} && 0%{?rhel} >= 6
# cglib is not compatible with hibernate and asm from RHEL6
Requires: cglib < 0:2.2
# we dont want jfreechart from EPEL because it has different symlinks
Requires: jfreechart < 1.0.13
%else
Requires: cglib
Requires: jfreechart >= 1.0.9
%endif

Requires: bcel
Requires: c3p0
Requires: hibernate3 >= 0:3.2.4
Requires: java >= 0:1.6.0
Requires: java-devel >= 0:1.6.0
Requires: jakarta-commons-lang >= 0:2.1
Requires: jakarta-commons-cli
Requires: jakarta-commons-codec
Requires: jakarta-commons-dbcp
%if 0%{?fedora}
Requires: apache-commons-logging
%else
Requires: jakarta-commons-logging
%endif
Requires: jakarta-taglibs-standard
Requires: jcommon
Requires: jpam
Requires: log4j
Requires: oscache
Requires: xalan-j2 >= 0:2.6.0
Requires: xerces-j2
Requires: tanukiwrapper
Requires: simple-core
Requires: spacewalk-java-config
Requires: spacewalk-java-lib
Requires: spacewalk-java-jdbc
Requires: concurrent
Requires: quartz < 2.0
Conflicts: quartz >= 2.0
Requires: cobbler >= 2.0.0
Obsoletes: taskomatic < 5.3.0
Obsoletes: taskomatic-sat < 5.3.0
Provides: taskomatic = %{version}-%{release}
Provides: taskomatic-sat = %{version}-%{release}
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts

%description -n spacewalk-taskomatic
This package contains the Java version of taskomatic.

%prep
%setup -q

# missing tomcat juli JAR (needed for JSP precompilation) - bug 661244
if test -d /usr/share/tomcat6; then
    mkdir -p build/build-lib
    if test ! -h /usr/share/java/tomcat6/tomcat-juli.jar; then
        ln -s /usr/share/tomcat6/bin/tomcat-juli.jar \
            build/build-lib/tomcat-juli.jar
    else
        ln -s /usr/share/java/tomcat6/tomcat-juli.jar \
                build/build-lib/tomcat-juli.jar
    fi
fi

%if ! 0%{?omit_tests} > 0
#check duplicate message keys in StringResource_*.xml files
find . -name 'StringResource_*.xml' |      while read i ;
    do echo $i
    CONTENT=$(/usr/bin/xmllint --format "$i" | /usr/bin/perl -lne 'if (/<trans-unit( id=".+?")?/) { print $1 if $X{$1}++ }' )
    if [ -n "$CONTENT" ]; then
        echo ERROR - duplicate message keys: $CONTENT
        exit 1
    fi
done
%endif

%build
# compile only java sources (no packing here)
ant -Dprefix=$RPM_BUILD_ROOT init-install compile

%if 0%{?run_checkstyle}
echo "Running checkstyle on java main sources"
export CLASSPATH="build/classes:build/build-lib/*"
export BASE_OPTIONS="-Djavadoc.method.scope=public \
-Djavadoc.type.scope=package \
-Djavadoc.var.scope=package \
-Dcheckstyle.cache.file=build/checkstyle.cache.src \
-Djavadoc.lazy=false \
-Dcheckstyle.header.file=buildconf/LICENSE.txt"
find . -name *.java | grep -vE '(/test/|/jsp/|/playpen/)' | \
xargs checkstyle -c buildconf/checkstyle.xml

echo "Running checkstyle on java test sources"
export BASE_OPTIONS="-Djavadoc.method.scope=nothing \
-Djavadoc.type.scope=nothing \
-Djavadoc.var.scope=nothing \
-Dcheckstyle.cache.file=build/checkstyle.cache.test \
-Djavadoc.lazy=false \
-Dcheckstyle.header.file=buildconf/LICENSE.txt"
find . -name *.java | grep -E '/test/' | grep -vE '(/jsp/|/playpen/)' | \
xargs checkstyle -c buildconf/checkstyle.xml
%endif

find . -type f -name '*.xml' | xargs perl -CSAD -lne 'for (grep { $_ ne "PRODUCT_NAME" } /\@\@(\w+)\@\@/) { print; $exit = 1;} END { exit $exit }'

%install
rm -rf $RPM_BUILD_ROOT
%if  0%{?rhel} && 0%{?rhel} < 6
ant -Dprefix=$RPM_BUILD_ROOT install-tomcat5
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/tomcat5/Catalina/localhost/
install -m 755 conf/rhn.xml $RPM_BUILD_ROOT%{_sysconfdir}/tomcat5/Catalina/localhost/rhn.xml
%else
ant -Dprefix=$RPM_BUILD_ROOT install-tomcat6
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/tomcat6/Catalina/localhost/
install -m 755 conf/rhn.xml $RPM_BUILD_ROOT%{_sysconfdir}/tomcat6/Catalina/localhost/rhn.xml
%endif

# check spelling errors in all resources for English if aspell installed
[ -x "$(which aspell)" ] && scripts/spelling/check_java.sh .. en_US

install -d -m 755 $RPM_BUILD_ROOT%{_initrddir}
install -d -m 755 $RPM_BUILD_ROOT%{_bindir}
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/rhn
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/unit-tests
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/lib
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/classes
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults
install -d -m 755 $RPM_BUILD_ROOT%{cobprofdir}
install -d -m 755 $RPM_BUILD_ROOT%{cobprofdirup}
install -d -m 755 $RPM_BUILD_ROOT%{cobprofdirwiz}
install -d -m 755 $RPM_BUILD_ROOT%{cobdirsnippets}
install -d -m 755 $RPM_BUILD_ROOT%{_var}/spacewalk/systemlogs

install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d
install -m 644 conf/default/rhn_hibernate.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_hibernate.conf
install -m 644 conf/default/rhn_taskomatic_daemon.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
install -m 644 conf/default/rhn_org_quartz.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_org_quartz.conf
install -m 644 conf/rhn_java.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults
install -m 755 conf/logrotate/rhn_web_api $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/rhn_web_api
install -m 755 scripts/taskomatic $RPM_BUILD_ROOT%{_initrddir}
install -m 755 scripts/unittest.xml $RPM_BUILD_ROOT/%{_datadir}/rhn/
install -m 644 build/webapp/rhnjava/WEB-INF/lib/rhn.jar $RPM_BUILD_ROOT%{_datadir}/rhn/lib
%if ! 0%{?omit_tests} > 0
install -m 644 build/webapp/rhnjava/WEB-INF/lib/rhn-test.jar $RPM_BUILD_ROOT%{_datadir}/rhn/lib
cp -a build/classes/com/redhat/rhn/common/conf/test/conf $RPM_BUILD_ROOT%{_datadir}/rhn/unit-tests/
%endif
install -m 644 conf/log4j.properties.taskomatic $RPM_BUILD_ROOT%{_datadir}/rhn/classes/log4j.properties

install -m 644 conf/cobbler/snippets/default_motd  $RPM_BUILD_ROOT%{cobdirsnippets}/default_motd
install -m 644 conf/cobbler/snippets/keep_system_id  $RPM_BUILD_ROOT%{cobdirsnippets}/keep_system_id
install -m 644 conf/cobbler/snippets/post_reactivation_key  $RPM_BUILD_ROOT%{cobdirsnippets}/post_reactivation_key
install -m 644 conf/cobbler/snippets/post_delete_system  $RPM_BUILD_ROOT%{cobdirsnippets}/post_delete_system
install -m 644 conf/cobbler/snippets/redhat_register  $RPM_BUILD_ROOT%{cobdirsnippets}/redhat_register

ln -s -f /usr/sbin/tanukiwrapper $RPM_BUILD_ROOT%{_bindir}/taskomaticd
ln -s -f %{_javadir}/ojdbc14.jar $RPM_BUILD_ROOT%{jardir}/ojdbc14.jar
install -d -m 755 $RPM_BUILD_ROOT%{realcobsnippetsdir}
ln -s -f  %{cobdirsnippets} $RPM_BUILD_ROOT%{realcobsnippetsdir}/spacewalk
touch $RPM_BUILD_ROOT%{_var}/spacewalk/systemlogs/audit-review.log

# Fedoras have cglib version that is not compatible with asm and need objectweb-asm
# Unfortunately both libraries must be installed for dependencies so we override
# the asm symlink with objectweb-asm here
%if 0%{?fedora}
ln -s -f %{_javadir}/objectweb-asm/asm-all.jar $RPM_BUILD_ROOT%{jardir}/asm_asm.jar
ln -s -f %{_javadir}/objectweb-asm/asm-all.jar $RPM_BUILD_ROOT%{_datadir}/rhn/lib/spacewalk-asm.jar
%else
ln -s -f %{_javadir}/asm/asm.jar  $RPM_BUILD_ROOT%{_datadir}/rhn/lib/spacewalk-asm.jar
%endif

# 732350 - On Fedora 15, mchange's log stuff is no longer in c3p0.
%if 0%{?fedora} >= 15
ln -s -f %{_javadir}/mchange-commons.jar $RPM_BUILD_ROOT%{jardir}/mchange-commons.jar
%endif

# delete JARs which must not be deployed
rm -rf $RPM_BUILD_ROOT%{jardir}/jspapi.jar
rm -rf $RPM_BUILD_ROOT%{jardir}/jasper5-compiler.jar
rm -rf $RPM_BUILD_ROOT%{jardir}/jasper5-runtime.jar
rm -rf $RPM_BUILD_ROOT%{jardir}/tomcat6*.jar
%if 0%{?omit_tests} > 0
rm -rf $RPM_BUILD_ROOT%{_datadir}/rhn/lib/rhn-test.jar
rm -rf $RPM_BUILD_ROOT/classes/com/redhat/rhn/common/conf/test/conf
rm -rf $RPM_BUILD_ROOT%{_datadir}/rhn/unittest.xml
rm -rf $RPM_BUILD_ROOT%{jardir}/mockobjects*.jar
rm -rf $RPM_BUILD_ROOT%{jardir}/strutstest*.jar
%endif

# show all JAR symlinks
echo "#### SYMLINKS START ####"
find $RPM_BUILD_ROOT%{jardir} -name *.jar
echo "#### SYMLINKS END ####"


%clean
rm -rf $RPM_BUILD_ROOT

%pre
rm -f %{realcobsnippetsdir}/spacewalk

%post -n spacewalk-taskomatic
# This adds the proper /etc/rc*.d links for the script
/sbin/chkconfig --add taskomatic

%preun -n spacewalk-taskomatic
if [ $1 = 0 ] ; then
   /sbin/service taskomatic stop >/dev/null 2>&1
   /sbin/chkconfig --del taskomatic
fi

%files
%defattr(644,tomcat,tomcat,775)
%dir %{appdir}
%dir %{appdir}/rhn/
%{appdir}/rhn/apidoc/
%{appdir}/rhn/css/
%{appdir}/rhn/errata/
%{appdir}/rhn/help/
%{appdir}/rhn/img/
%{appdir}/rhn/META-INF/
%{appdir}/rhn/schedule/
%{appdir}/rhn/systems/
%{appdir}/rhn/users/
%{appdir}/rhn/*.jsp
%{appdir}/rhn/WEB-INF/classes
%{appdir}/rhn/WEB-INF/decorators
%{appdir}/rhn/WEB-INF/includes
%{appdir}/rhn/WEB-INF/nav
%{appdir}/rhn/WEB-INF/pages
%{appdir}/rhn/WEB-INF/*.xml
# list of all jar symlinks without any version numbers
# and wildcards (except non-symlinks dwr and velocity)
%{jardir}/antlr.jar
%{jardir}/bcel.jar
%{jardir}/c3p0.jar
%{jardir}/cglib.jar
%{jardir}/commons-beanutils.jar
%{jardir}/commons-cli.jar
%{jardir}/commons-codec.jar
%{jardir}/commons-collections.jar
%{jardir}/commons-digester.jar
%{jardir}/commons-discovery.jar
%{jardir}/commons-el.jar
%{jardir}/commons-fileupload.jar
%{jardir}/commons-io.jar
%{jardir}/commons-lang.jar
%{jardir}/commons-logging.jar
%{jardir}/commons-validator.jar
%{jardir}/concurrent.jar
%{jardir}/dom4j.jar
%{jardir}/dwr-*.jar
%{jardir}/hibernate3*
%{jardir}/jaf.jar
%{jardir}/javamail.jar
%{jardir}/jcommon.jar
%{jardir}/jdom.jar
%{jardir}/jpam.jar
%{jardir}/jta.jar
%{jardir}/log4j.jar

%if 0%{?fedora} >= 15
%{jardir}/mchange-commons.jar
%endif

%{jardir}/oro.jar
%{jardir}/oscache.jar
%{jardir}/quartz.jar
%{jardir}/redstone-xmlrpc-client.jar
%{jardir}/redstone-xmlrpc.jar
%{jardir}/rhn.jar
%{jardir}/simple-core.jar
%{jardir}/simple-xml.jar
%{jardir}/sitemesh.jar
%{jardir}/stringtree-json.jar
%{jardir}/susestudio-java-client.jar
%{jardir}/taglibs-core.jar
%{jardir}/taglibs-standard.jar
%{jardir}/tanukiwrapper.jar
%{jardir}/velocity-*.jar
%{jardir}/xalan-j2.jar
%{jardir}/xerces-j2.jar
%{jardir}/xml-commons-apis.jar

# asm-1.5.3-7.jpp5.noarch (F14, F13, EL6)
# asm-1.5.3-1jpp.ep1.1.el5.2.noarch (EL5)
%{jardir}/asm_asm.jar
#%{jardir}/asmasm.jar
#%{jardir}/asmasm-analysis.jar
#%{jardir}/asmasm-attrs.jar
#%{jardir}/asmasm-tree.jar
#%{jardir}/asmasm-util.jar
#%{jardir}/asmasm-xml.jar
#%{jardir}/asmkasm.jar

%if 0%{?fedora}
# jfreechart-1.0.10-4.fc13.noarch (F13)
# jfreechart-1.0.13-1.fc14.noarch (F14)
%{jardir}/jfreechart_jfreechart.jar
%endif

%if 0%{?rhel} && 0%{?rhel} >= 5
# jfreechart-1.0.10-1.el5.noarch (EL5)
# jfreechart-1.0.9-4.jpp5.noarch (EL6)
%{jardir}/jfreechart.jar
%endif

# EL5 = Struts 1.2 and Tomcat 5, EL6+/recent Fedoras = 1.3 and Tomcat 6
%if 0%{?rhel} && 0%{?rhel} < 6
%{jardir}/struts.jar
%else
%{jardir}/struts*.jar
%{jardir}/commons-chain.jar
%endif

%dir %{cobprofdir}
%dir %{cobprofdirup}
%dir %{cobprofdirwiz}
%dir %{cobdirsnippets}
%config %{cobdirsnippets}/default_motd
%config %{cobdirsnippets}/keep_system_id
%config %{cobdirsnippets}/post_reactivation_key
%config %{cobdirsnippets}/post_delete_system
%config %{cobdirsnippets}/redhat_register
%if  0%{?rhel} && 0%{?rhel} < 6
%config(noreplace) %{_sysconfdir}/tomcat5/Catalina/localhost/rhn.xml
%else
%config(noreplace) %{_sysconfdir}/tomcat6/Catalina/localhost/rhn.xml
%endif
%{realcobsnippetsdir}/spacewalk
%attr(755, tomcat, root) %{_var}/spacewalk/systemlogs
%ghost %attr(644, tomcat, root) %{_var}/spacewalk/systemlogs/audit-review.log

%files -n spacewalk-taskomatic
%attr(755, root, root) %{_initrddir}/taskomatic
%attr(755, root, root) %{_bindir}/taskomaticd
%attr(755, root, root) %{_datadir}/rhn/lib/spacewalk-asm.jar


%files config
%{_prefix}/share/rhn/config-defaults/rhn_hibernate.conf
%{_prefix}/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
%{_prefix}/share/rhn/config-defaults/rhn_org_quartz.conf
%{_prefix}/share/rhn/config-defaults/rhn_java.conf
%config %{_sysconfdir}/logrotate.d/rhn_web_api

%files lib
%{_datadir}/rhn/classes/log4j.properties
%{_datadir}/rhn/lib/rhn.jar

%files oracle
%defattr(644, tomcat, tomcat)
%{jardir}/ojdbc14.jar

%files postgresql
%defattr(644, tomcat, tomcat)
%{jardir}/postgresql-jdbc.jar

%changelog
* Fri Nov 16 2012 Jan Pazdziora 1.9.13-1
- add extra date parse check for errata.setDetails API

* Thu Nov 15 2012 Tomas Lestach <tlestach@redhat.com> 1.9.12-1
- extend API call errata.setDetails to support issue_date and update_date
- migrating ivy repo to my account so that we can maintain it

* Thu Nov 15 2012 Tomas Lestach <tlestach@redhat.com> 1.9.11-1
- let spacewalk-java require concrete version of jmock

* Wed Nov 14 2012 Tomas Lestach <tlestach@redhat.com> 1.9.10-1
- checkstyle fixes
- Check hostnames for special characters and whitespace
- Catch MalformedURLException in case of missing protocol etc.
- Basic normalization for SUSE Studio base URL
- Workaround for Studio API returning incomplete URLs
- 863025 - checkstyle fix
- redirect to Manage.do page after successful channel remove
- 863025 - original packages are those that are not associated with any erratum
- 835597 - bash is used as interpreter in kickstart scripts even if set by path
- 835597 - enable logging only for bash interpreter in kickstart scripts
- Fix quartz trigger initialization repeat count

* Mon Nov 12 2012 Tomas Lestach <tlestach@redhat.com> 1.9.9-1
- Fix typos
- 874278 - use iterators when going through the collection
- make notes to errata APIs, CVEs may be associated only with published errata
- it does not make much sense to use on delete cascade on many-to-many
  relations

* Mon Nov 12 2012 Tomas Lestach <tlestach@redhat.com> 1.9.8-1
- 866326 - customize KickstartFileDownloadAdvanced.do page in case of kickstart
  file DownloadException

* Fri Nov 09 2012 Michael Mraka <michael.mraka@redhat.com> 1.9.7-1
- reverted macro name translation

* Fri Nov 09 2012 Michael Mraka <michael.mraka@redhat.com> 1.9.6-1
- backported translation changes from zanata

* Mon Nov 05 2012 Tomas Lestach <tlestach@redhat.com> 1.9.5-1
- replace remaining DTD paths to www.hibernate.org/dtd with 3.2 default
  hibernate.sourceforge.net
- Fixing typo.

* Fri Nov 02 2012 Tomas Lestach <tlestach@redhat.com> 1.9.4-1
- Revert "change hibernate3 namespace"

* Fri Nov 02 2012 Michael Mraka <michael.mraka@redhat.com> 1.9.3-1
- fixing extra packages query

* Thu Nov 01 2012 Jan Pazdziora 1.9.2-1
- having html tag inside xml is not correct
- decrease distChannelMap release minimal length
- 839960 - fix system.listLatestUpgradablePackages API to list upgradable
  packages from server channels only

* Wed Oct 31 2012 Jan Pazdziora 1.9.1-1
- Use braces for accessing composite types in PG

* Wed Oct 31 2012 Jan Pazdziora 1.8.178-1
- Advertise the www.spacewalkproject.org.

* Tue Oct 30 2012 Jan Pazdziora 1.8.177-1
- Using xmllint and grep or perl is faster.

* Tue Oct 30 2012 Tomas Lestach <tlestach@redhat.com> 1.8.176-1
- fixing checkstyle

* Tue Oct 30 2012 Tomas Lestach <tlestach@redhat.com> 1.8.175-1
- rewrite distchannel APIs
- fix distchannel.listDefaultMaps API
- create dist channel map logic
- add id and org to DistChannelMap

* Tue Oct 30 2012 Jan Pazdziora 1.8.174-1
- Update the copyright year.

* Tue Oct 30 2012 Tomas Lestach <tlestach@redhat.com> 1.8.173-1
- Add SAST timezone Signed-off-by: Paresh Mutha <pmutha@redhat.com>
- Make yumrepo_last_sync optional. Do not return it, if the repo was never
  synced.

* Mon Oct 29 2012 Jan Pazdziora 1.8.172-1
- Change of message which is shown if no errata is available for package
- remove unnecessary casts
- removing @Override annotation from a method that isn't overriden

* Mon Oct 29 2012 Jan Pazdziora 1.8.171-1
- 869428 - last_checkin date should be displayed as UTC for splice integration
  API
- WebUI - link to erratas that affect package on its overview page

* Thu Oct 25 2012 Jan Pazdziora 1.8.170-1
- checkstyle fix

* Wed Oct 24 2012 Stephen Herr <sherr@redhat.com> 1.8.169-1
- fixing problems in 9d2ad9da4305d41d1d43666b2685eed2136c2f16
- WebUI - css for @media print

* Tue Oct 23 2012 Stephen Herr <sherr@redhat.com> 1.8.168-1
- 869428 - Added new API method for Splice integration
- Fixing a bunch of Generics type errors
- Expose extra packages / systems with extra packages
- 853444 - do not list custom base channel twice in the base channel combo for
  an activation key
- WebUI improvement, adding "Search Google for errata" on package details page.

* Mon Oct 22 2012 Jan Pazdziora 1.8.167-1
- WebUI improvement, showing activation key used for system activation at
  system overview page.

* Mon Oct 22 2012 Tomas Lestach <tlestach@redhat.com> 1.8.166-1
- checkstyle fixes
- Make applyErrata() work with Longs and Integers
- Show errata details for all errata in the given list
- Schedule updates for software update stack first

* Fri Oct 19 2012 Tomas Lestach <tlestach@redhat.com> 1.8.165-1
- checkstyle fix

* Fri Oct 19 2012 Jan Pazdziora 1.8.164-1
- prevent NPE, when accessing probe suite systems with no system associated
- 822834 - do not allow creating kickstart profiles that differ from existing
  ones just by case
- added missing import
- add column style class to render table border
- don't call cmd.getKickstartData() over and over

* Mon Oct 15 2012 Tomas Lestach <tlestach@redhat.com> 1.8.163-1
- intorduce first draft of read-only dist channel map page
- first row of ListTag light - similar to the ListDisplayTag
- have the list-row-even and list-row-odd class types setting constant for
  ListTag rows

* Fri Oct 12 2012 Jan Pazdziora 1.8.162-1
- fix ConfigRevisionSerializer

* Thu Oct 11 2012 Tomas Lestach <tlestach@redhat.com> 1.8.161-1
- make possible to delete more probes at once on the system monitoring page
- dropping old comment

* Thu Oct 11 2012 Tomas Lestach <tlestach@redhat.com> 1.8.160-1
- reverting of web.chat_enabled -> java.chat_enabled translation
- The /network/systems/details/kickstart/* is not used for a long time.

* Thu Oct 11 2012 Jan Pazdziora 1.8.159-1
- Checkstyle fix.

* Wed Oct 10 2012 Jan Pazdziora 1.8.158-1
- Using empty paragraph for layout purposes is rarely needed.
- 817473 - remove html markup from the kickstart.jsp.error.template_generation
  error message
- 832433 - remove html tags from the activation-key.java.exists error message
- polishing configmanager.filedetails.content.no-macro-name error message

* Tue Oct 09 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.157-1
- fixed html entities in translations

* Tue Oct 09 2012 Jan Pazdziora 1.8.156-1
- 863479 - enhancing kickstart file sync with cobbler

* Fri Oct 05 2012 Tomas Lestach <tlestach@redhat.com> 1.8.155-1
- fix PushDispatcherTest
- fix ErrataTest
- fix ActivationKeyManagerTest
- fix RequestContextTest
- fix ErrataFactoryTest.testCreateClone
- do not set last_modified for rhnPackage tests

* Fri Oct 05 2012 Jan Pazdziora 1.8.154-1
- Fixed typo on ErrataMailer.java

* Tue Oct 02 2012 Tomas Lestach <tlestach@redhat.com> 1.8.153-1
- 860002 - prevent Page Request Error when at pagination
- 860831 - fix system column value on the rhn/schedule/FailedSystems.do page
- changes required to make 'ant create-webapp-dir' work properly

* Sat Sep 29 2012 Aron Parsons <aronparsons@gmail.com> 1.8.152-1
- add API calls to manage repo filters
- add methods to add/remove ContentSourceFilter objects

* Tue Sep 25 2012 Tomas Lestach <tlestach@redhat.com> 1.8.151-1
- getting timestamp from PackageCapabilityIterator in a correct way

* Thu Sep 20 2012 Jan Pazdziora 1.8.150-1
- Checkstyle fix.
- 790120 - removing the config elaborator from a few queries where it's not
  needed
- affected_by_errata mode does not need system_monitoring elaborator
- system_entitlement_list mode does not need system_monitoring elaborator
- visible_to_user_from_sysid_list mode does not need system_monitoring
  elaborator
- target_systems_for_channel mode does not need system_monitoring elaborator
- systems_with_needed_package mode does not need system_monitoring elaborator
- target_systems_for_group mode does not need system_monitoring elaborator
- systems_in_group mode does not need system_monitoring elaborator
- systems_subscribed_to_channel mode does not need system_monitoring elaborator
- systems_with_package_nvr mode does not need system_monitoring elaborator
- ssm_remote_commandable mode does not need system_monitoring elaborator

* Wed Sep 19 2012 Jan Pazdziora 1.8.149-1
- Convert TIMESTAMP without time zone as well.
- Validate proxy format on general config page
- 790120 - make system_overview fast

* Tue Sep 18 2012 Tomas Lestach <tlestach@redhat.com> 1.8.148-1
- ssm_kickstartable mode does not need system_monitoring elaborator
- find_by_name mode does not need system_monitoring elaborator
- virtual_hosts_for_user mode does not need system_monitoring elaborator
- virtual_system_overview does not need system health information
- use system_monitoring elaborator in most_critical_systems query
- remove SystemHealthIconDecorator and appropriate query
- extract system_monitoring elaborator from system_overview
- removing @Override annotations for methods that aren't overriden
- removing @Override annotations for methods that aren't overriden
- removing unnecessarily nested else statement

* Mon Sep 17 2012 Jan Pazdziora 1.8.147-1
- 790120 - Adding the RULE hint back into the system_overview elaborator
- Checkstyle fix.

* Fri Sep 14 2012 Jan Pazdziora 1.8.146-1
- Convert TIMESTAMP WITH LOCAL TIME ZONE as well.
- 737895 - remember probe state when paginate
- 856449 - validate session key for system.getSystemCurrencyMultipliers API
- 856458 - fix system.getSystemCurrencyScores API doc
- 856553 - display error messages only once on admin/config/GeneralConfig.do
  page

* Wed Sep 12 2012 Tomas Lestach <tlestach@redhat.com> 1.8.145-1
- 855884 - fixing NumberFormatException

* Tue Sep 11 2012 Tomas Lestach <tlestach@redhat.com> 1.8.144-1
- 713684 - localize strings after import
- 855845 - escaping system name

* Fri Sep 07 2012 Tomas Lestach <tlestach@redhat.com> 1.8.143-1
- checkstyle fix

* Fri Sep 07 2012 Tomas Lestach <tlestach@redhat.com> 1.8.142-1
- changing web.login_banner -> java.login_banner
- changing web.custom_footer -> java.custom_footer
- changing web.custom_header -> java.custom_header
- changing web.chat_enabled -> java.chat_enabled
- changing web.taskomatic_cobbler_user -> java.taskomatic_cobbler_user
- changing web.excluded_countries -> java.excluded_countries
- changing web.supported_locales -> java.supported_locales
- changing web.l10n_missingmessage_exceptions ->
  java.l10n_missingmessage_exceptions
- changing web.l10n_debug -> java.l10n_debug
- changing web.l10n_debug_marker -> java.l10n_debug_marker
- changing web.errata_cache_compute_threshold ->
  java.errata_cache_compute_threshold
- changing web.sandbox_lifetime -> java.sandbox_lifetime
- changing web.apiversion -> java.apiversion
- changing web.development_environment -> java.development_environment
- changing web.customer_service_email -> java.customer_service_email
- changing web.session_delete_commit_interval ->
  java.session_delete_commit_interval
- changing web.session_delete_batch_size -> java.session_delete_batch_size
- changing web.min_user_len -> java.min_user_len
- deploy rhn_java.conf
- move java related configuration the rhn_java.conf

* Thu Sep 06 2012 Tomas Lestach <tlestach@redhat.com> 1.8.141-1
- removing unused IsoServlet
- removing java/buildconf/builder directory
- CryptoKeysHandlerTest are undertaken with OrgAdmin privileges.
- 815964 - not critical, but adding to this version of rhn_web.conf too
- 815964 - moving monitoring probe batch option from rhn.conf to rhn_web.conf

* Tue Sep 04 2012 Tomas Lestach <tlestach@redhat.com> 1.8.140-1
- 853444 - list only subscribable base channels for actiovation key
  associations
- 839960 - rewrite query for system.listLatestUpgradablePackages API

* Fri Aug 31 2012 Jan Pazdziora 1.8.139-1
- Add countries BQ, CW, SX.

* Thu Aug 30 2012 Tomas Lestach <tlestach@redhat.com> 1.8.138-1
- 851150 - make the select working on PG as well

* Thu Aug 30 2012 Tomas Lestach <tlestach@redhat.com> 1.8.137-1
- 851480 - Do not elaborate objects twice in row.
- 851480 - Revert "bz: 453477: duplicated entries in CSV download for some
  fields"
- allow complex kickstart variables containing severel '='
- 851519 - display a reasonable error message on the permission error page
- Fixing test KickstartScheduleCommandTest.testProfileArches
- fix ContentSourceFilter.findBySourceId to return list of ContentSourceFilter
  objects

* Tue Aug 28 2012 Aron Parsons <aronparsons@gmail.com> 1.8.136-1
- add listRepoFilters API call
- add lookupContentSourceFiltersById method to ChannelFactory
- add serializer for ContentSourceFilter
- add ContentSourceFilter class
- 733420 - Checking user permissions for CryptoKeysHandler

* Tue Aug 28 2012 Aron Parsons <aronparsons@gmail.com>
- add listRepoFilters API call
- add lookupContentSourceFiltersById method to ChannelFactory
- add serializer for ContentSourceFilter
- add ContentSourceFilter class
- 733420 - Checking user permissions for CryptoKeysHandler

* Fri Aug 24 2012 Stephen Herr <sherr@redhat.com> 1.8.134-1
- 818700 - allow user to set the gateway for static bonds

* Thu Aug 23 2012 Tomas Lestach <tlestach@redhat.com> 1.8.133-1
- 851040 - checkstyle issue

* Thu Aug 23 2012 Tomas Lestach <tlestach@redhat.com> 1.8.132-1
- 851040 - detect empty quartz crop expression
- 851150 - we need only unique channel list
- 850836 - display an information message about no systems being selected for
  SSM
- 850836 - fix ISE on rhn/channel/ssm/ChildSubscriptions.do page

* Tue Aug 21 2012 Tomas Kasparek <tkasparek@redhat.com> 1.8.131-1
- 846215 - Kickstarts profile visible where they should be

* Mon Aug 20 2012 Tomas Lestach <tlestach@redhat.com> 1.8.130-1
- 198887 - checkstyle fixes
- 198887 - introducing a possibility to delete archived actions
- 848368 - make IE use IE7 compatability mode for pages with editarea
- Fix missing CVEs in patches listing with Oracle 11
- 848036 - fix icons on SSM provisioning page

* Wed Aug 15 2012 Tomas Lestach <tlestach@redhat.com> 1.8.129-1
- 848036 - fix icons on SSM system list page
- 785088 - validate virt guest parameters also for API input
- 785088 - introduce regexp for virtual guest name
- 787873 - fix misleading "Filter by" label
- removing @Override annotations for methods that aren't overriden
- remove unnecessary else clauses

* Tue Aug 14 2012 Tomas Lestach <tlestach@redhat.com> 1.8.128-1
- 836656 - removed MAC Address from kickstart profile listing
- 847256 - xml escape group names
- 847308 - rhn-proxy and rhn-satellite channels shall not be associated with an
  activation key
- 846915 - systemGroup csv was including fields that have not been valid since
  bug 573153

* Fri Aug 10 2012 Jan Pazdziora 1.8.127-1
- 846221 - Don't let virtual kickstarts screw up the host's cobbler id
- Revert "removing unused string with trans-id
  'packagelist.jsp.summary.packages'"

* Wed Aug 08 2012 Stephen Herr <sherr@redhat.com> 1.8.126-1
- 818700 - adding capability for static bond

* Tue Aug 07 2012 Jan Pazdziora 1.8.125-1
- Remove hints that should no longer be needed.
- enable sorting of errata list according to synopsis on the
  rhn/channels/manage/errata/ListRemove.do page
- fix errata sort on the rhn/channels/manage/errata/ListRemove.do page

* Mon Aug 06 2012 Tomas Lestach <tlestach@redhat.com> 1.8.124-1
- detect oracle TIMESTAMPTZ objects and convert them correctly to timestamp

* Thu Aug 02 2012 Tomas Lestach <tlestach@redhat.com> 1.8.123-1
- 842992 - display a relevant error message when creating channel names/labels
  starting with rhn|redhat

* Thu Aug 02 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.122-1
- Return back some translations

* Wed Aug 01 2012 Tomas Lestach <tlestach@redhat.com> 1.8.121-1
- Construct GMT millisecond value for timestamp if DB does not store timezone
- 844048 - let errata.listPackages API return also packages associated with
  unpublished errata

* Tue Jul 31 2012 Tomas Kasparek <tkasparek@redhat.com> 1.8.120-1
- 838618 - Allowing some API calls to be called from another organizations

* Mon Jul 30 2012 Tomas Lestach <tlestach@redhat.com> 1.8.119-1
- remove usage of cert_admin user role
- remove usage of rhn_support user role
- remove usage of unused org_applicant user role
- remove rhn_superuser occurences in java translation strings
- remove usage of rhn_superuser user role
- 802267 - update ConfigurationValidationTest

* Thu Jul 26 2012 Tomas Lestach <tlestach@redhat.com> 1.8.118-1
- 816454 - do not commit already committed transaction

* Thu Jul 26 2012 Tomas Lestach <tlestach@redhat.com> 1.8.117-1
- log a message when repo sync task is triggered

* Wed Jul 25 2012 Tomas Lestach <tlestach@redhat.com> 1.8.116-1
- 843050 - fix recommended cobbler command
- 753056 - dissociate deleted crypto key from its kickstart profiles

* Tue Jul 24 2012 Jan Pazdziora 1.8.115-1
- Revert "removing unused string with trans-id 'gpgssl_keys.added'"
- Revert "removing unused string with trans-id 'gpgssl_keys.removed'"

* Mon Jul 23 2012 Tomas Lestach <tlestach@redhat.com> 1.8.114-1
- 757711 - do not start repo sync of a channel with no associated repositories
- trim all the form strings within the regular scrub
- 802267 - allow user and group name starting also with [0-9]_
- 813841 - do not cache snapshot tags within the lookup method
- Correct the localized text which describes the icon.

* Fri Jul 20 2012 Tomas Lestach <tlestach@redhat.com> 1.8.113-1
- Make the tip to be more standard English.
- Remove XCCDF Legend from places where it is not necessary.
- 840567 - prevent NPE
- 841635 - sort groups by default

* Thu Jul 19 2012 Tomas Lestach <tlestach@redhat.com> 1.8.112-1
- checkstyle fix

* Thu Jul 19 2012 Tomas Lestach <tlestach@redhat.com> 1.8.111-1
- 814365 - check not only one channel original when checking channel version
- reverting fix for 814365,839611 due to performance regression
- reverting fix for 814365,839611 due to performance regression
- cut the string only in case the string is longer than needed
- add ruby API sample script

* Wed Jul 18 2012 Jan Pazdziora 1.8.110-1
- Add translation strings for crash information
- Show crash count on system detail page
- Update server class to use crash information
- Add Crashes class and database mapping
- 840567 - limit action name to fit into the appropriate DB column
- 822918 - close session when its connection signalled a connection error

* Fri Jul 13 2012 Stephen Herr <sherr@redhat.com> 1.8.109-1
- 833474 - quick file list query now also returns files saved to system's
  'local' config 'channel'

* Fri Jul 13 2012 Tomas Lestach <tlestach@redhat.com> 1.8.108-1
- struts jars may be available in different directories
- Show XCCDF-diff icon on the XCCDF-Details page.
- Show icon when referencing to XCCDF-diff
- Show XCCDF-diff results on List-Scans page.
- Rewrite ListScap page query with Dto & elaborator.
- XCCDF Diff shall compare also scan's metadata.
- Make sure that the user has permission to see the scan (when diffing).
- Diff should show: either all, changed, or invariant items
- OpenSCAP Integration -- XCCDF Scan Diff
- checkstyle fix

* Thu Jul 12 2012 Tomas Lestach <tlestach@redhat.com> 1.8.107-1
- 829790 - fix PxtSessionDelegateImplTest test
- 829790 - fix PxtCookieManagerTest test
- 748331 - fix appropriate tests
- removing @Override annotations for methods that aren't overriden
- Copying kopts to the xen distro.

* Tue Jul 10 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.106-1
- COALESCE instead of NVL keyword for pgsql compatibility

* Thu Jul 05 2012 Stephen Herr <sherr@redhat.com> 1.8.105-1
- 837913 - work around for if hibernate loads a clonedchannel as its own
  original

* Fri Jun 29 2012 Stephen Herr <sherr@redhat.com> 1.8.104-1
- 836656 - Allow user to set MAC Address when provisioning a virtual guest

* Thu Jun 28 2012 Tomas Lestach <tlestach@redhat.com> 1.8.103-1
- 795565 - add API doc for channel.software.listErrata update_date attribute
- 795565 - remove "date" from the channel.software.listErrata API doc
- adding conflicts for quartz >= 2.0
- 706318 - Japaneese translation fix

* Wed Jun 27 2012 Tomas Lestach <tlestach@redhat.com> 1.8.102-1
- requre quartz version lower than 2.0
- change hibernate3 namespace
- require concrete hibernate version

* Wed Jun 27 2012 Jan Pazdziora 1.8.101-1
- Fixing checkstyle.

* Wed Jun 27 2012 Jan Pazdziora 1.8.100-1
- Fixing checkstyle.

* Wed Jun 27 2012 Jan Pazdziora 1.8.99-1
- checkstyle fix

* Tue Jun 26 2012 Stephen Herr <sherr@redhat.com> 1.8.98-1
- 829485 - resolveing potential deadlock during asynchronous errata clone

* Tue Jun 26 2012 Jan Pazdziora 1.8.97-1
- Each dataset must have a different name.
- Add CSV downloader for scap search page.
- Add CSV downloader to all-scans page
- Add CSV downloader for scan's details page
- Add CSV downloader for system's scans page

* Tue Jun 26 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.96-1
- Correcting two ISE on postgresql: NVRE not found

* Mon Jun 25 2012 Jan Pazdziora 1.8.95-1
- Fixing checkstyle.

* Fri Jun 22 2012 Stephen Herr <sherr@redhat.com> 1.8.94-1
- 829485 - fixed asynchronous errata cloning internal server errors
- 829790 - handle spoiled browsers separatelly

* Fri Jun 22 2012 Jan Pazdziora 1.8.93-1
- Fixing checkstyle.

* Fri Jun 22 2012 Jan Pazdziora 1.8.92-1
- 712313 - Add installed size to repodata

* Thu Jun 21 2012 Tomas Lestach <tlestach@redhat.com> 1.8.91-1
- enable filtering by synopsis for all the errata tabs
- remove simple-xml and susestudio-java-client from ivy.xml

* Wed Jun 20 2012 Stephen Herr <sherr@redhat.com> 1.8.90-1
- 823798 - update API documentation
- 748331 - remove unused import
- 748331 - do not create multiple default ks sessions
- removing @Override annotations, methods aren't overriden
- removing @Override annotation, method isn't overriden
- remove unnecessary else clause
- remove unnecessary else clause
- remove unnecessary casts
- 833474 - removed the ';' character due the error ORA-00911

* Tue Jun 19 2012 Stephen Herr <sherr@redhat.com> 1.8.89-1
- 833474 - system.config.listFiles could take > 8 minutes if there were lots of
  revisions on lots of config files
- 797906 - don't sync virt bridge nic w/ cobbler

* Tue Jun 19 2012 Tomas Lestach <tlestach@redhat.com> 1.8.88-1
- try to work with fc17 hibernate3

* Tue Jun 19 2012 Tomas Lestach <tlestach@redhat.com> 1.8.87-1
- correctly report kernel not being found at distro creation
- 822918 - impossible to get error code from PG exceptions
- Add missing dollar sign.
- Setup {inSSM} variable on audit pages.
- Add forgotten hidden form variable.
- Improve SCAP search: Return list of xccdf:TestResults-s
- Move the listset definition out off the fragment.
- Fix flawed SQL queries.

* Tue Jun 12 2012 Simon Lukasik <slukasik@redhat.com> 1.8.86-1
- Improve SCAP search: searching by scan's result
- Improve SCAP search: searching by scan date
- Bind named query dynamically.
- Add a link for easy scan reschedule.
- Forward main-form variables when going through system list
- Fix incorrect variable reference.

* Tue Jun 12 2012 Tomas Lestach <tlestach@redhat.com> 1.8.85-1
- 797124 - virt host may have several virtual instances
- 797124 - fix virt host icon issue on WebUI

* Fri Jun 08 2012 Jan Pazdziora 1.8.84-1
- 829894 - fix channel links on CloneErrata page
- Revert "removing unused string with trans-id 'schedulediff.ssm.failure'"
- Revert "removing unused string with trans-id 'schedulediff.ssm.success'"
- Revert "removing unused string with trans-id 'schedulediff.ssm.successes'"
- Refactor "default" to RhnHelper.DEFAULT_FORWARD

* Wed Jun 06 2012 Stephen Herr <sherr@redhat.com> 1.8.83-1
- 829485 - Created new asyncronous api methods for cloning errata

* Tue Jun 05 2012 Tomas Lestach <tlestach@redhat.com> 1.8.82-1
- use apache-commons-io on Fedoras instead of jakarta-commons-io
- Refactor "pageList" to RequestContext.PAGE_LIST
- Refactor struts "default" forward also in /tests.
- Refactor "default" to RhnHelper.DEFAULT_FORWARD
- Remove unneeded variable
- Do not set nonexisting localization.
- Localized defaults should be localized.
- Handle nonexistent testresult.
- Show also scan's scheduler on details page.
- Show also scan's arguments on details page.
- 811470 - proper use of xml entities in apidoc
- 811470 - fix apidoc for system.listLatestAvailablePackage()
- 811470 - fix apidoc for kickstart.profile.system.checkRemoteCommands()
- 811470 - fix apidoc of kickstart.profile.system.checkConfigManagement()
- 811470 - fix apidoc for kickstart.profile.getKickstartTree()
- 811470 - fix apidoc for kickstart.profile.comparePackages()
- 811470 - fix apidoc for distchannel.listDefaultMaps()

* Mon Jun 04 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.81-1
- Add support for studio image deployments (web UI) (jrenner@suse.de)
- 811470 - fix apidoc for channel.access.setOrgSharing() (mzazrivec@redhat.com)
- 811470 - fix apidoc for channel.listPopularChannels() (mzazrivec@redhat.com)
- 811470 - fix apidoc for activationkey.listActivatedSystems()
  (mzazrivec@redhat.com)
- 811470 - apidoc: use array_desc to remove empty list bullets
  (mzazrivec@redhat.com)
- 811470 - new macro: array_desc (mzazrivec@redhat.com)
- The ip colum is numeric, do not cast parameter to string.
  (jpazdziora@redhat.com)

* Wed May 30 2012 Tomas Lestach <tlestach@redhat.com> 1.8.80-1
- switch checkstyle to be run on RHEL6
- checkstyle: VirtualInstanceFactory - Redundant 'static' modifier.
- checkstyle: TestStatics - Utility classes should not have a public or default
  constructor.
- checkstyle: TaskConstants - Utility classes should not have a public or
  default constructor.
- checkstyle: the name [todo] is not a valid Javadoc tag name
- checkstyle: SetLabels - Utility classes should not have a public or default
  constructor.
- checkstyle 5: cannot initialize module TreeWalker - Unable to instantiate
  GenericIllegalRegexp
- checkstyle 5: cannot initialize module TreeWalker - Unable to instantiate
  TabCharacter
- checkstyle 5: TreeWalker is not allowed as a parent of RegexpHeader

* Wed May 30 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.79-1
- checkstyle fix
- omit accessible parameter
- simplify construct
- remove unnecessarily nested else clause
- remove unused imports

* Tue May 29 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.78-1
- modified java stack to use new user_role_check_debug()

* Tue May 29 2012 Simon Lukasik <slukasik@redhat.com> 1.8.77-1
- Fail gracefully on empty list of systems
- Add option to search scap within SSM.
- OpenSCAP integration -- A simple search page.
- Promote some of the rule's columns to fragment.

* Tue May 29 2012 Tomas Lestach <tlestach@redhat.com> 1.8.76-1
- 814659 - add an extra entitlement check before the key creation
- Enhancements pt_BR localization at webUI

* Fri May 25 2012 Tomas Lestach <tlestach@redhat.com> 1.8.75-1
- store also config revision changed_by_id
- fix ConfigurationFactoryTest.testRemoveConfigChannel

* Thu May 24 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.74-1
- 825024 - API *must* check for compatible channels in system.setBaseChannel()

* Thu May 24 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.73-1
- 820987 - fix error during backporting
- 820987 - do not guess creator name

* Thu May 24 2012 Tomas Lestach <tlestach@redhat.com> 1.8.72-1
- fix ConfigurationManagerTest.testCopyFile
- fix ConfigTestUtils.createConfigRevision

* Mon May 21 2012 Jan Pazdziora 1.8.71-1
- %%defattr is not needed since rpm 4.4
- Fix incorrect text fields.
- Tables on SCAP pages should have corners rounded.
- File RuleDetails page into correct item in navigation bar

* Fri May 18 2012 Tomas Lestach <tlestach@redhat.com> 1.8.70-1
- 736661 - rewrite revision creation by config file update
- Don't show empty table, if there is not ident assigned.
- Extend input cell for 20 characters.
- 822237 - there're no help pages in Spacewalk

* Wed May 16 2012 Tomas Lestach <tlestach@redhat.com> 1.8.69-1
- 736661 - prevent system.config.createOrUpdatePath causing deadlock

* Mon May 14 2012 Tomas Lestach <tlestach@redhat.com> 1.8.68-1
- remove empty test quota stuff
- remove remained usage of OrgQuota class

* Sat May 12 2012 Tomas Lestach <tlestach@redhat.com> 1.8.67-1
- remove Override annotations for non overriden methods
- remove unnecessary casts
- remove unnecessarily nested else statement
- remove rests of OrgQuota usage

* Fri May 11 2012 Tomas Lestach <tlestach@redhat.com> 1.8.66-1
- remove OrgQuota hibernate mapping
- remove OrgQuota java class
- 820920 - fix delete distribution link
- 818997 - rewrite channel.listSoftwareChannels API
- 818700 - checkstyle issues
- rhnUser synonym was removed
- 643905 - rewrite KickstartFactory.lookupAccessibleTreesByOrg

* Thu May 10 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.65-1
- 695276 - if koan is requesting anything from /cobbller_api replace hostname
  of server with hostname of first proxy in chain
- 818700 - support for cobbler v2.2

* Wed May 09 2012 Tomas Lestach <tlestach@redhat.com> 1.8.64-1
- 817433 - fix NetworkDtoSerializer API doc
- prevent storing empty string for errata refersTo
- prevent storing empty string for errata errataFrom
- prevent storing empty string for errata notes
- Split OpenSCAP and AuditReviewing up
- 818700 - Cannot submit the form with broken bonding info

* Fri May 04 2012 Stephen Herr <sherr@redhat.com> 1.8.63-1
- checkstyle fix
- 735043 - redirect to errata/manage/PublishedErrata.do page after deleting a
  published erratum
- 817528 - remember pre-filled form attributes in case of form validation error
- allow omitting string resource checks
- add extra cheetah error detection
- make the code more readable
- 817528 - marking Script Name as required filed on the KickstartScriptEdit
  page

* Fri May 04 2012 Tomas Lestach <tlestach@redhat.com> 1.8.62-1
- 818700 - make newly introduced rhn tag functions available

* Thu May 03 2012 Stephen Herr <sherr@redhat.com> 1.8.61-1
- 818700 - When kickstarting a system there is an option that allows you to
  create or re-create a network bond.
- fix listSharedChannels to only show this org's channels
- fix my_channel_tree query
- fix channel.listRedHatChannels shows custom channels
- Remove unused import
- Remove a code which duplicates ensureAvailableToUser() method.
- Eliminate a typo.
- API: list results for XCCDF scan.

* Tue May 01 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.60-1
- 817098 - fixed the Brazilian time zone
- Enhancement and fixes on Brazilian (pt_BR) localization at webUI
- Do not divide by zero. It prints a question mark.

* Mon Apr 30 2012 Jan Pazdziora 1.8.59-1
- 811470 - fixing checkstyle.

* Mon Apr 30 2012 Jan Pazdziora 1.8.58-1
- Requires are better defined elsewhere than in template. (slukasik@redhat.com)
- API: Show OpenSCAP XCCDF Details. (slukasik@redhat.com)
- 811470 - proper use of xml entities in documentation (mzazrivec@redhat.com)

* Fri Apr 27 2012 Jan Pazdziora 1.8.57-1
- API: List Xccdf Scans for given machine. (slukasik@redhat.com)

* Fri Apr 27 2012 Tomas Lestach <tlestach@redhat.com> 1.8.56-1
- use arch label in distchannel.setDefaultMap API as stated in the API doc

* Thu Apr 26 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.55-1
- 806815 - add missing acl to SSM
- 806815 - add missing links about Solaris Patches to SSM
- 816445 - fixed error in redhat_register snippet
- 816299 - Updating default config files with additional options for heapdump
  directory
- Ensure that given system has OpenSCAP capability.
- Ensure that given systems is available to user.
- Repack and throw MissingEntitlementException when occurs.
- Sort imports alphabetically.
- API: SCAP scan schedule for multiple systems
- changed kernel-params field to 1024 chars in size (bnc#698166)
- removing unused lookup
- Capitalize title to be consistent
- Put the reboot notification at the end. Make it not mutually exclusive with
  other notifications.
- API: SCAP scan schedule should accept the date of earliest occurence
- Promote read only DatePicker to fragment.
- Refactor parentUrl to ListTagHelper.PARENT_URL
- Hide the 'Schedule' tab for systems without management ent.
- 815804 - force repo regeneration, when removing package using
  packages.removePackage API
- 815804 - make the cleanupFileEntries simplier

* Tue Apr 24 2012 Simon Lukasik <slukasik@redhat.com> 1.8.54-1
- Promote Audit to separate tab within SSM. (slukasik@redhat.com)
- Show targeted systems when scheduling SCAP scan through SSM.
  (slukasik@redhat.com)
- Extract method scapCapableSystemsInSsm() (slukasik@redhat.com)
- Handle errors during SSM schedule of SCAP scan. (slukasik@redhat.com)
- OpenSCAP integration -- schedule new scan in SSM (slukasik@redhat.com)
- Extract method for scheduling xccdfEval for multiple systems.
  (slukasik@redhat.com)
- The fragment could be used as readonly for confirmation (slukasik@redhat.com)
- Refactor xccdf schedule form to jsp fragment. (slukasik@redhat.com)
- Remove redundant definitions of use_date (slukasik@redhat.com)
- 814836 - do not list ks session related activation keys (tlestach@redhat.com)
- 815372 - prevent sending XML invalid chars in system.getScriptResults API
  (tlestach@redhat.com)
- 815252 - fix errata.listPackages APIdoc (tlestach@redhat.com)

* Fri Apr 20 2012 Tomas Lestach <tlestach@redhat.com> 1.8.53-1
- remove unused paths from unprotected uris
- 728205 - do not check CSRF token for login pages
- fix errata clone name generation

* Fri Apr 20 2012 Jan Pazdziora 1.8.52-1
- Fixing checkstyle.

* Thu Apr 19 2012 Stephen Herr <sherr@redhat.com> 1.8.51-1
- 814365 - When displaying errata available for adding to channel, make sure a
  clone is not already in the channel.

* Thu Apr 19 2012 Jan Pazdziora 1.8.50-1
- Removed double-dash from WebUI copyright notice.
- fix has_errata_with_keyword_applied_since_last_reboot query (mc@suse.de)
- fix PackageEvr handling III (tlestach@redhat.com)
- increase taskomatic memory (tlestach@redhat.com)
- 803353 - fixing another two broken documentation links (tlestach@redhat.com)
- Show systems that need reboot because of an errata. (dmacvicar@suse.de)
- modify SecurityErrataOverview.callaback (tlestach@redhat.com)

* Tue Apr 17 2012 Jan Pazdziora 1.8.49-1
- Revert "removing unused string with trans-id Certificate Administrators,
  Monitoring Administrators, and Configuration Administrators"

* Tue Apr 17 2012 Jan Pazdziora 1.8.48-1
- Checkstyle fix.

* Tue Apr 17 2012 Jan Pazdziora 1.8.47-1
- Make the Invalid prefix error localizable.

* Tue Apr 17 2012 Jan Pazdziora 1.8.46-1
- fix ErrataHandlerTest (tlestach@redhat.com)
- 812053 - fix the ErrataHandler.clone method (tlestach@redhat.com)
- create a test erratum with keyword (tlestach@redhat.com)
- refactor PackageEvr handling II (tlestach@redhat.com)

* Fri Apr 13 2012 Tomas Lestach <tlestach@redhat.com> 1.8.45-1
- 809579 - make system snapshot when changing server entitlements using API
  (tlestach@redhat.com)
- 812053 - change the condition (tlestach@redhat.com)
- print extra stack trace (tlestach@redhat.com)
- 804665 - do not scrub search_string (tlestach@redhat.com)

* Fri Apr 13 2012 Jan Pazdziora 1.8.44-1
- Fixing checkstyle.

* Fri Apr 13 2012 Jan Pazdziora 1.8.43-1
- fix KickstartWizardCommandTest (tlestach@redhat.com)
- 812053 - making errata.clone api not requires cloned channels
  (jsherril@redhat.com)
- 811470 - fix documentation for getRepoSyncCronExpression API
  (mzazrivec@redhat.com)
- 811470 - make the documentation for createOrUpdateSymlink more clear
  (mzazrivec@redhat.com)
- 811470 - fix documentation for ChannelSerializer (mzazrivec@redhat.com)
- replace \r\n with \n for CustomDataValues (tlestach@redhat.com)

* Wed Apr 11 2012 Stephen Herr <sherr@redhat.com> 1.8.42-1
- 698940 - Activation Key does not have to have a base channel to add Child
  Channels (sherr@redhat.com)

* Wed Apr 11 2012 Tomas Lestach <tlestach@redhat.com> 1.8.41-1
- adding javadoc to public RhnPostMockStrutsTestCase method
  (tlestach@redhat.com)

* Wed Apr 11 2012 Tomas Lestach <tlestach@redhat.com> 1.8.40-1
- fix BaseKickstartEditTestCase tests (tlestach@redhat.com)
- fix VirtualGuestsActionTest (tlestach@redhat.com)
- fix MethodActionTest (tlestach@redhat.com)
- fix PendingActionsSetupActionTest (tlestach@redhat.com)
- fix BootstrapConfigActionTest (tlestach@redhat.com)
- fix KickstartEditPackagesTest (tlestach@redhat.com)
- fix OrgSystemSubscriptionsActionTest (tlestach@redhat.com)
- fix SystemEntitlementsSubmitActionTest (tlestach@redhat.com)
- fix ChannelFilesImportTest (tlestach@redhat.com)
- fix RegisteredSetupActionTest (tlestach@redhat.com)
- fix OrgCreateActionTest (tlestach@redhat.com)
- fix ErrataActionTest (tlestach@redhat.com)
- fix FailedActionsSetupActionTest (tlestach@redhat.com)
- fix OrgSoftwareSubscriptionsActionTest (tlestach@redhat.com)
- fix TreeActionTest - need to set ks tree installtype (tlestach@redhat.com)
- fix TreeActionTest.testCreateRefresh (tlestach@redhat.com)
- fix TreeActionTest (tlestach@redhat.com)
- fix systems/test/ErrataConfirmActionTest (tlestach@redhat.com)
- fix errata/test/ErrataConfirmActionTest (tlestach@redhat.com)
- fix KickstartAdvancedOptionsActionTest (tlestach@redhat.com)
- fix CryptoKeyDeleteActionTest (tlestach@redhat.com)
- fix CompletedActionsSetupActionTest (tlestach@redhat.com)
- fix BaseSetOperateOnDiffActionTest (tlestach@redhat.com)
- fix GeneralConfigActionTest (tlestach@redhat.com)
- fix RestartActionTest (tlestach@redhat.com)
- fix KickstartIpRangeActionTest (tlestach@redhat.com)
- fix CryptoKeyCreateActionTest (tlestach@redhat.com)
- fix CertificateConfigActionTest (tlestach@redhat.com)
- fix SystemDetailsEditActionTest (tlestach@redhat.com)
- fix PreservationListEditActionTest (tlestach@redhat.com)
- fix KickstartPartitionActionTest (tlestach@redhat.com)
- fix CreateUserActionTest (tlestach@redhat.com)
- fix CloneConfirmActionTest (tlestach@redhat.com)
- create RhnPostMockStrutsTestCase for testing POST methods
  (tlestach@redhat.com)
- statements cannot end with ";" for Oracle (tlestach@redhat.com)
- 787225 - the Log Size actually checks Log Size Growth.
  (jpazdziora@redhat.com)

* Tue Apr 10 2012 Tomas Lestach <tlestach@redhat.com> 1.8.39-1
- fix ServerConfigHandlerTest revision comparism (tlestach@redhat.com)
- fix ServerConfigHandlerTest.createRevision (tlestach@redhat.com)
- tests - set user's org to the channel created by him (tlestach@redhat.com)
- fix ProfileManagerTest (tlestach@redhat.com)
- fix org.trusts.getDetails API (tlestach@redhat.com)
- check whether it's a trusted org before accessing its attributes
  (tlestach@redhat.com)
- fix ActivationKeyTest.testDuplicateKeyCreation (tlestach@redhat.com)
- fix TraceBackEventTest (tlestach@redhat.com)
- fix SessionCancelActionTest (tlestach@redhat.com)
- run oracle specific tests only with oracle DB (tlestach@redhat.com)
- fix AdvDataSourceTest suite part (tlestach@redhat.com)
- fix CobblerCommandTest (tlestach@redhat.com)
- refactor how PackageEvr gets stored (tlestach@redhat.com)
- removing unnecessary casts (tlestach@redhat.com)
- removing unnecessary else statement (tlestach@redhat.com)
- fix ProvisionVirtualizationWizardActionTest.testStepOne (tlestach@redhat.com)

* Tue Apr 10 2012 Jan Pazdziora 1.8.38-1
- OpenSCAP integration -- view latest results of whole infrastructure
  (slukasik@redhat.com)
- The tool is called OpenSCAP actually. (slukasik@redhat.com)
- Add missing </a> tag in case when the serverName is unknown.
  (slukasik@redhat.com)
- The system.config.listFiles should return channel label, not name.
- 810871 - Reduce languages available in editarea to only common / useful ones.
  (sherr@redhat.com)

* Fri Apr 06 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.37-1
- improved performance of repomd generation

* Thu Apr 05 2012 Stephen Herr <sherr@redhat.com> 1.8.36-1
- 804810 - also making inherited virtualization entitlements work correctly in
  SSM (sherr@redhat.com)

* Thu Apr 05 2012 Jan Pazdziora 1.8.35-1
- 809897 - using the evr_t_as_vre_simple.
- adding jdom dependency (tlestach@redhat.com)
- Fixing the order of action's child elements.
- 701893 - do not show the Schedule Deploy Action and Schedule System
  Comparison links in the left pane -- the right pane has them with correct
  ACLs.
- Add ACL to VerifyPackages to match the ACL on the .jsp referencing it.
- fix typo (tlestach@redhat.com)

* Wed Apr 04 2012 Stephen Herr <sherr@redhat.com> 1.8.34-1
- 809868 - Make automatically-scheduled tasks visible on Failed and Archived
  tabs (sherr@redhat.com)
- 805952 - make the "allocation to equal" value optional.
  (jpazdziora@redhat.com)
- Fix naming of cloned errata to replace only the first 2 chars
  (tlestach@redhat.com)

* Tue Apr 03 2012 Jan Pazdziora 1.8.33-1
- 804949 - make invocation of rhn_channel.convert_to_fve database-agnostic.

* Tue Apr 03 2012 Jan Pazdziora 1.8.32-1
- 804949 - make invocation of rhn_channel.convert_to_fve database-agnostic.
- Revert "removing unused string with trans-id 'configfilefilter.path'"
  (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'configchannelfilter.name'"
  (msuchy@redhat.com)
- Revert "removing unused string with trans-id
  'config_subscribed_systems.unsubscribeSystems.success'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id
  'config_target_systems.subscribeSystems.success'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'preferences.critical-
  probes.description'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'preferences.critical-
  probes.name'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'preferences.critical-
  systems.description'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'preferences.critical-
  systems.name'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'preferences.inactive-
  systems.name'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'preferences.inactive-
  systems.description'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'sdc.config.differing.files_1'"
  (msuchy@redhat.com)
- Revert "removing unused string with trans-id
  'sdc.config.diff.files_1_dirs_0_symlinks_0'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'userlist.jsp.disabled'"
  (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'userlist.jsp.enabled'"
  (msuchy@redhat.com)
- Fix checkstyle error (invalid use of the {@inheritDoc} tag) (jrenner@suse.de)
- Add lib directory to checkstyle classpath (jrenner@suse.de)
- New web page -- details of the xccdf:rule-result (slukasik@redhat.com)

* Thu Mar 29 2012 Stephen Herr <sherr@redhat.com> 1.8.31-1
- 808210 - Fixing ISE on selecting None yum checksum type for channel
  (sherr@redhat.com)
- 808162 - Auto-import the RHEL RPM GPG key for systems we have kickstarted
  (sherr@redhat.com)

* Thu Mar 29 2012 Simon Lukasik <slukasik@redhat.com> 1.8.30-1
- Rework web interface to correspond with 0-n rule/ident mapping
  (slukasik@redhat.com)

* Wed Mar 28 2012 Tomas Lestach <tlestach@redhat.com> 1.8.29-1
- fix ConfigChannelHandlerTest revision comparism (tlestach@redhat.com)
- fix ConfigChannelHandlerTest.testDeployAllSystems (tlestach@redhat.com)
- 805275 - add missing query parameter (tlestach@redhat.com)
- fix ConfigChannelHandlerTest validation issue (tlestach@redhat.com)
- fix MDOM storage (tlestach@redhat.com)
- fix ProfileHandlerTest (tlestach@redhat.com)
- fix KickstartDataTest.testISRhelRevMethods (tlestach@redhat.com)
- fix KickstartScheduleCommandTest (tlestach@redhat.com)
- Revert "fix KickstartDataTest.testCommands" (tlestach@redhat.com)
- fix TranslationsTest (tlestach@redhat.com)
- fix FilterActionTest.testCreateSubmitFailValidation (tlestach@redhat.com)
- fix FilterActionTest.testEditExecute (tlestach@redhat.com)
- rename Filter.isRecurring to Filter.isRecurringBool (tlestach@redhat.com)
- fix ProbeGraphActionTest and MonitoringManagerTest (tlestach@redhat.com)
- fix ProbeGraphActionTest.setUp (tlestach@redhat.com)
- fix SystemManagerTest.testListInstalledPackage (tlestach@redhat.com)
- fix SystemManagerTest.testSsmSystemPackagesToRemove (tlestach@redhat.com)
- 676434 - Text for Brazil timezone is incorrect (sherr@redhat.com)

* Wed Mar 28 2012 Tomas Lestach <tlestach@redhat.com> 1.8.28-1
- let spacewalk-java-tests require ant-junit (tlestach@redhat.com)
- fix AccessTest (tlestach@redhat.com)

* Tue Mar 27 2012 Stephen Herr <sherr@redhat.com> 1.8.27-1
- 807463 - If our channel is a clone of a clone we need to find the channel
  that contains the erratum we are cloning (sherr@redhat.com)

* Tue Mar 27 2012 Tomas Lestach <tlestach@redhat.com> 1.8.26-1
- fix KickstartDataTest.testCommands (tlestach@redhat.com)
- fixin cobbler version issue (tlestach@redhat.com)
- temporary disable errata check in ChannelSoftwareHandlerTest
  (tlestach@redhat.com)
- fix parameter type (tlestach@redhat.com)
- fix UserManagerTest (tlestach@redhat.com)
- fix ActivationKeyAlreadyExistsException (tlestach@redhat.com)
- Revert "removing unused string with trans-id 'config.channels_0'"
  (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'config.channels_1'"
  (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'config.channels_2'"
  (msuchy@redhat.com)
- 806439 - Make Virtualization tab of system profile independent of
  Virtualization (Platform) entitlements (sherr@redhat.com)
- The org_id colum is numeric, do not cast parameter to string.
  (jpazdziora@redhat.com)

* Fri Mar 23 2012 Tomas Lestach <tlestach@redhat.com> 1.8.25-1
- fix VirtualGuestsActionTest (tlestach@redhat.com)
- 752416 - reload config revision from DB before returning it
  (tlestach@redhat.com)
- 806060 - Config file diffs result in Out Of Memory for large files
  (sherr@redhat.com)

* Thu Mar 22 2012 Tomas Lestach <tlestach@redhat.com> 1.8.24-1
- fix ServerFactoryVirtualizationTest (tlestach@redhat.com)
- fix ServerFactoryTest (tlestach@redhat.com)
- fix VirtualInstanceFactoryTest (tlestach@redhat.com)
- fix RamTest (tlestach@redhat.com)
- fix ServerTest (tlestach@redhat.com)
- fix AffectedSystemsActionTest (tlestach@redhat.com)
- fix KickstartManagerTest (tlestach@redhat.com)
- Revert "fix FileFinderTest.testFindFilesSubDir" (tlestach@redhat.com)

* Wed Mar 21 2012 Tomas Lestach <tlestach@redhat.com> 1.8.23-1
- fix LocalizationServiceTest (tlestach@redhat.com)
- fix AuthFilterTest (tlestach@redhat.com)
- fix PxtAuthenticationServiceTest (tlestach@redhat.com)
- fix RequestContextTest (tlestach@redhat.com)
- fix PxtSessionDelegateImplTest (tlestach@redhat.com)
- rename AuthenticationServiceTest (tlestach@redhat.com)
- rename BaseDeleteErrataActionTest (tlestach@redhat.com)
- skip executing Abstract test classes (tlestach@redhat.com)
- clean up classpath (tlestach@redhat.com)
- add slf4j.jar to classpath (tlestach@redhat.com)
- add struts.jar explicitelly to classpath (tlestach@redhat.com)
- we need to extract also the rhn.jar into the temp directory
  (tlestach@redhat.com)
- 805275 - fix for configchannel.deployAllSystems (shughes@redhat.com)
- checkstyle fixes (sherr@redhat.com)
- Ensure the comparison uses correct type (slukasik@redhat.com)
- Set column name explicitly, because it varies by db backend.
  (slukasik@redhat.com)
- Revert "removing unused string with trans-id
  'systemsearch_cpu_mhz_gt_column'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id
  'systemsearch_cpu_mhz_lt_column'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id
  'systemsearch_name_and_description_column'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id
  'systemsearch_num_of_cpus_gt_column'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id
  'systemsearch_num_of_cpus_lt_column'" (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'systemsearch_ram_gt_column'"
  (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'systemsearch_ram_lt_column'"
  (msuchy@redhat.com)
- 804810 - Taught SSM to look at flex as well as regular entitlements when
  trying to add child channels (sherr@redhat.com)
- 804702 - fixed apidoc deployAllSystems() including the date parameter
  (mmello@redhat.com)

* Mon Mar 19 2012 Jan Pazdziora 1.8.22-1
- Add a missing colon. (slukasik@redhat.com)
- Show legend on details page; suggesting what to search for
  (slukasik@redhat.com)
- Enable filtering by rule-result. (slukasik@redhat.com)
- Allow user to sort columns. (slukasik@redhat.com)
- Enable user to adjust number of items per page. (slukasik@redhat.com)
- We no longer have /install/index.pxt, so satellite_install cannot be used.

* Mon Mar 19 2012 Tomas Lestach <tlestach@redhat.com> 1.8.21-1
- fix junit classpath ordering (tlestach@redhat.com)
- 533164 - check duplicate message keys in StringResource_*.xml files
  (msuchy@redhat.com)
- Forward the page url to the list (slukasik@redhat.com)
- Polish api documentation for system.scap APIs. (slukasik@redhat.com)
- OpenSCAP integration -- Details page for XCCDF results (slukasik@redhat.com)

* Sat Mar 17 2012 Miroslav Suchý 1.8.20-1
- 521248 - correctly spell MHz (msuchy@redhat.com)

* Fri Mar 16 2012 Tomas Lestach <tlestach@redhat.com> 1.8.19-1
- 802400 - fix ISE on rhn/admin/multiorg/OrgSoftwareSubscriptions.do page
  (tlestach@redhat.com)

* Fri Mar 16 2012 Tomas Lestach <tlestach@redhat.com> 1.8.18-1
- 803353 - do not link documentation if not available (tlestach@redhat.com)
- 803353 - do not link documentation if not available (tlestach@redhat.com)
- 800364 - hide documetation link (tlestach@redhat.com)
- 803644 - fix ISE (tlestach@redhat.com)
- fix checkstyle issue (tlestach@redhat.com)
- get rid of gsbase (tlestach@redhat.com)
- 726114 - update createOrUpradePath api documentation (tlestach@redhat.com)

* Fri Mar 16 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.17-1
- require checkstyle only if we run it

* Thu Mar 15 2012 Tomas Lestach <tlestach@redhat.com> 1.8.16-1
- rewrite unittest.xml (tlestach@redhat.com)

* Thu Mar 15 2012 Stephen Herr <sherr@redhat.com> 1.8.15-1
- 790120 - Removing rule to help system overview listing happen faster,
  improving performance of api queries (sherr@redhat.com)
- Fix oracle syntax of analytical function (slukasik@redhat.com)
- Fixing typo (lookup.activatonkey.reason2 -> lookup.activationkey.reason2).
  (jpazdziora@redhat.com)
- Revert "removing unused string with trans-id 'lookup.activatonkey.reason2'"
  (msuchy@redhat.com)

* Wed Mar 14 2012 Tomas Lestach <tlestach@redhat.com> 1.8.14-1
- fix LoginActionTest (tlestach@redhat.com)

* Wed Mar 14 2012 Tomas Lestach <tlestach@redhat.com> 1.8.13-1
- remove xml formatter (tlestach@redhat.com)
- make it possible to run single testcases (tlestach@redhat.com)
- add webapps/rhn directory to classpath (tlestach@redhat.com)
- fix LoginActionTest (tlestach@redhat.com)
- add required jars to classpath (tlestach@redhat.com)
- removing unused test (tlestach@redhat.com)
- Revert "fix MockObjectTestCase issue" (tlestach@redhat.com)

* Tue Mar 13 2012 Stephen Herr <sherr@redhat.com> 1.8.12-1
- 755470 - Fixing sorting by date without replying on the inapplicable
  listdisplay-new.jspf (sherr@redhat.com)
- Revert "755470 - Fixed incorrect sorting of archived action timestamp"
  (sherr@redhat.com)

* Tue Mar 13 2012 Jan Pazdziora 1.8.11-1
- 801463 - fix binary file uploads (tlestach@redhat.com)
- Add the completetion time to the list of scap scans. (slukasik@redhat.com)
- Sort imports alphabetically. (slukasik@redhat.com)
- Remove purposeless commentary (slukasik@redhat.com)
- Remove unneccessary casts to String. (slukasik@redhat.com)
- Refactor: rename ScapAction class (slukasik@redhat.com)

* Tue Mar 13 2012 Simon Lukasik <slukasik@redhat.com> 1.8.10-1
- Checkstyle fix (slukasik@redhat.com)
- Checkstyle fix (slukasik@redhat.com)
- fix various checkstyle issues (tlestach@redhat.com)

* Tue Mar 13 2012 Simon Lukasik <slukasik@redhat.com> 1.8.9-1
- OpenSCAP integration -- Page for XCCDF scan schedule (slukasik@redhat.com)
- OpenSCAP integration  -- Show results for system on web.
  (slukasik@redhat.com)
- Add translations for the new SCAP action (slukasik@redhat.com)
- Revert "removing unused string with trans-id 'toolbar.clone.channel'"
  (msuchy@redhat.com)
- Fix usage of velocity macros for API documentation (jrenner@suse.de)
- Add support for generating DocBook XML from the API documentation
  (jrenner@suse.de)

* Fri Mar 09 2012 Stephen Herr <sherr@redhat.com> 1.8.8-1
- 782551 - Making a default selection of no Proxy when kickstarting a server
  (sherr@redhat.com)
- 773113 - Added new XMLRPC API method to allow people to change the kickstart
  preserve ks.cfg option (sherr@redhat.com)
- 755470 - Fixed incorrect sorting of archived action timestamp
  (sherr@redhat.com)
- 753064 - throw appropriate error if deleting nonexistant kickstart key
  (sherr@redhat.com)
- Revert "removing unused string with trans-id 'file_size.b'"
  (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'file_size.kb'"
  (msuchy@redhat.com)
- Revert "removing unused string with trans-id 'file_size.mb'"
  (msuchy@redhat.com)
- Just minor template fix (mkollar@redhat.com)
- 795565 - better keep the original 'date' in ErrataOverviewSerializer
  (tlestach@redhat.com)
- 795565 - let ErrataOverviewSerializer return also issue_date
  (tlestach@redhat.com)

* Fri Mar 09 2012 Miroslav Suchý 1.8.7-1
- remove RHN_DB_USERNAME from monitoring scout configuration
- remove RHN_DB_PASSWD from monitoring scout configuration
- remove RHN_DB_NAME from monitoring scout configuration
- remove tableowner from monitoring scout configuration

* Thu Mar 08 2012 Tomas Lestach <tlestach@redhat.com> 1.8.6-1
- fix SystemAclHandlerTest (tlestach@redhat.com)
- fix MessageQueueTest.testDatabaseTransactionHandling (tlestach@redhat.com)
- load test hmb.xml files when loading TestImpl (tlestach@redhat.com)
- fix MockObjectTestCase issue (tlestach@redhat.com)
- fix JarFinderTest (tlestach@redhat.com)
- fix FileFinderTest.testFindFilesSubDir (tlestach@redhat.com)
- remove test/validation/userCreateForm.xsd exclude from rhn.jar
  (tlestach@redhat.com)
- do not include test directories into rhn.jar (tlestach@redhat.com)
- consider only *Test.classes as junit tests (tlestach@redhat.com)
- add debug arguments to the junit (tlestach@redhat.com)
- point unit tests to search for configuration on a new fs location
  (tlestach@redhat.com)
- place conf directory into /user/share/rhn/unit-tests (tlestach@redhat.com)
- 801433 - save kickstart data after modifying ks profile child channels
  (tlestach@redhat.com)

* Thu Mar 08 2012 Miroslav Suchý 1.8.5-1
- Revert "removing unused string with trans-id
  'systementitlements.jsp.entitlement_counts_message_*'" (msuchy@redhat.com)
- API : KickstartHandler::renameProfile remove unused code referring to
  Kickstart Trees (shardy@redhat.com)
- API Documentation : kickstart.renameProfile renames profiles not kickstart
  trees (shardy@redhat.com)
- API Documentation : api.get_version fix typo (shardy@redhat.com)

* Wed Mar 07 2012 Jan Pazdziora 1.8.4-1
- partialy revert 423cfc6255b7e6d52da35f7e543ec38cd99e04c9 to return back
  string which are dynamicaly created (msuchy@redhat.com)

* Tue Mar 06 2012 Tomas Lestach <tlestach@redhat.com> 1.8.3-1
- 799992 - remove the error message completely (tlestach@redhat.com)
- prevent ISE on the rhn/channels/manage/errata/AddCustomErrata.do page
  (tlestach@redhat.com)
- remove unused file (tlestach@redhat.com)
- include also conf/default dir into rhn-test.jar (tlestach@redhat.com)
- do not fall, if there's no .in the filename (tlestach@redhat.com)
- make use of default kernel and initrd path (tlestach@redhat.com)
- fix KickstartableTreeTest (tlestach@redhat.com)
- remove unused buildCertificate method (tlestach@redhat.com)

* Mon Mar 05 2012 Miroslav Suchý 1.8.2-1
- removing unused strings in StringResources (msuchy@redhat.com)
- unify errata/Overview.do and errata/RelevantErrata.do
  (dmacvicar@suse.de)

* Sat Mar 03 2012 Jan Pazdziora 1.8.1-1
- Removing the Downloads tab, in points to nonexisting
  /rhn/software/channel/downloads/Download.do page.

* Fri Mar 02 2012 Jan Pazdziora 1.7.52-1
- Allow copyright line 2011--2012.

* Fri Mar 02 2012 Jan Pazdziora 1.7.51-1
- Update the copyright year info.

* Thu Mar 01 2012 Tomas Lestach <tlestach@redhat.com> 1.7.50-1
- do not check removed acl (tlestach@redhat.com)
- remove hibernate not-null constraint on bug.summary (tlestach@redhat.com)

* Wed Feb 29 2012 Tomas Lestach <tlestach@redhat.com> 1.7.49-1
- remove unused method and appropriate query (tlestach@redhat.com)
- remove unused method and appropriate query (tlestach@redhat.com)
- remove unused method and appropriate query (tlestach@redhat.com)
- remove unused methods (tlestach@redhat.com)
- remove unused methods (tlestach@redhat.com)
- remove unused methods (tlestach@redhat.com)
- remove unused method (tlestach@redhat.com)
- remove unused methods and appropriate hbm queries (tlestach@redhat.com)
- remove unused methods (tlestach@redhat.com)
- remove unused method (tlestach@redhat.com)
- remove unused method (tlestach@redhat.com)
- remove unused method (tlestach@redhat.com)
- deleting rhnDownloads and rhnChannelDownloads related java code
  (tlestach@redhat.com)
- remove unused methods and appropriate queries (tlestach@redhat.com)
- remove unused methods (tlestach@redhat.com)
- remove unused method (tlestach@redhat.com)
- remove unused methods and appropriate hbm query (tlestach@redhat.com)
- remove unused method (tlestach@redhat.com)
- remove unused methods with appropriate queries (tlestach@redhat.com)
- remove unused methods (tlestach@redhat.com)
- remove unused method and appropriate sql-query (tlestach@redhat.com)
- remove unused method (tlestach@redhat.com)
- remove unused method and appropriate sql-query (tlestach@redhat.com)
- remove unused method (tlestach@redhat.com)
- remove unused method (tlestach@redhat.com)
- remove unused methods (tlestach@redhat.com)
- remove unused methods (tlestach@redhat.com)
- remove unused method (tlestach@redhat.com)
- remove unused method (tlestach@redhat.com)
- remove unused public static final attributes (tlestach@redhat.com)
- remove unused public static final attribute and appropriate queries
  (tlestach@redhat.com)
- remove unused public static final attribute (tlestach@redhat.com)
- remove unused public static final attribute (tlestach@redhat.com)
- remove unused public static final attributes (tlestach@redhat.com)
- remove unused public static final attribute (tlestach@redhat.com)
- remove unused public static final attribute (tlestach@redhat.com)
- remove unused public static final attribute (tlestach@redhat.com)
- remove unused public static final attribute (tlestach@redhat.com)
- remove unused public static final attribute (tlestach@redhat.com)
- remove unused public static final attribute (tlestach@redhat.com)
- remove unused public static final attribute (tlestach@redhat.com)
- remove whole KickstartQueries (tlestach@redhat.com)
- remove unused public static final attributes (tlestach@redhat.com)
- remove unused public static final attributes (tlestach@redhat.com)
- remove unused public static final attributes (tlestach@redhat.com)
- remove unused public static final attributes (tlestach@redhat.com)
- remove unused protected static final attribute (tlestach@redhat.com)
- remove unused public static final attribute (tlestach@redhat.com)
- remove unused protected static final attribute (tlestach@redhat.com)
- remove unused protected static final attributes (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)

* Tue Feb 28 2012 Tomas Lestach <tlestach@redhat.com> 1.7.48-1
- remove unnecessary else statements in
  java/code/src/com/redhat/rhn/testing/TestUtils.java (tlestach@redhat.com)
- remove unnecessary else statements in java/code/src/com/redhat/rhn/manager/
  (tlestach@redhat.com)
- remove unnecessary else statements in
  java/code/src/com/redhat/rhn/manager/system/ (tlestach@redhat.com)
- remove unnecessary else statements in
  java/code/src/com/redhat/rhn/manager/kickstart/ (tlestach@redhat.com)
- remove unnecessary else statements in
  java/code/src/com/redhat/rhn/manager/channel/ChannelManager.java
  (tlestach@redhat.com)
- remove unnecessary else statements in
  java/code/src/com/redhat/rhn/taskomatic/ (tlestach@redhat.com)
- remove unnecessary else statements in rest of
  java/code/src/com/redhat/rhn/frontend/ (tlestach@redhat.com)
- remove unnecessary else statements in
  java/code/src/com/redhat/rhn/frontend/xmlrpc/ (tlestach@redhat.com)
- remove unnecessary else statements in
  java/code/src/com/redhat/rhn/frontend/action/ (tlestach@redhat.com)
- remove unnecessary else statements in
  java/code/src/com/redhat/rhn/frontend/dto/ (tlestach@redhat.com)
- remove unnecessary else statements in
  java/code/src/com/redhat/rhn/frontend/action/configuration/
  (tlestach@redhat.com)
- remove unnecessary else statements in java/code/src/com/redhat/rhn/domain/
  (tlestach@redhat.com)
- remove unnecessary else statements in
  java/code/src/com/redhat/rhn/domain/kickstart/ (tlestach@redhat.com)
- remove unnecessary else statements in rest of
  java/code/src/com/redhat/rhn/common/ (tlestach@redhat.com)
- remove unnecessary else statements in
  java/code/src/com/redhat/rhn/common/validator/ (tlestach@redhat.com)
- remove unnecessary else statements in
  java/code/src/com/redhat/rhn/common/util/ (tlestach@redhat.com)
- remove unnecessary else statements in
  java/code/internal/src/com/redhat/rhn/internal/doclet (tlestach@redhat.com)

* Tue Feb 28 2012 Tomas Lestach <tlestach@redhat.com> 1.7.47-1
- access static fields in a static way (tlestach@redhat.com)
- access static fields in a static way (tlestach@redhat.com)
- access static fields in a static way (tlestach@redhat.com)
- access static fields in a static way (tlestach@redhat.com)
- access static fields in a static way (tlestach@redhat.com)
- access static fields in a static way (tlestach@redhat.com)
- access static fields in a static way (tlestach@redhat.com)

* Tue Feb 28 2012 Tomas Lestach <tlestach@redhat.com> 1.7.46-1
- remove unused class (tlestach@redhat.com)
- remove unused private attribute (tlestach@redhat.com)
- removing unused method (tlestach@redhat.com)
- remove unused private static log (tlestach@redhat.com)
- remove unused private static log (tlestach@redhat.com)
- remove unused private static log (tlestach@redhat.com)
- remove unused private static log (tlestach@redhat.com)
- remove unused private static log (tlestach@redhat.com)
- remove unused private static log (tlestach@redhat.com)
- remove unused private log (tlestach@redhat.com)
- remove unused private final log (tlestach@redhat.com)
- remove unused private static log (tlestach@redhat.com)
- remove unused private static array (tlestach@redhat.com)
- remove unused private static log (tlestach@redhat.com)
- remove unused private attribute (tlestach@redhat.com)
- remove unused private static final attributes (tlestach@redhat.com)
- remove unused static final LOG (tlestach@redhat.com)
- remove unused private attribute (tlestach@redhat.com)
- remove empty test (tlestach@redhat.com)
- remove unused private static log (tlestach@redhat.com)
- remove unused private static log (tlestach@redhat.com)
- remove unused private static log (tlestach@redhat.com)
- remove unused private attribute (tlestach@redhat.com)
- remove unused private final log (tlestach@redhat.com)
- remove unused private attribute (tlestach@redhat.com)
- remove unused private log (tlestach@redhat.com)
- remove unused private attributes (tlestach@redhat.com)
- remove unused private static log (tlestach@redhat.com)
- remove unused private static log (tlestach@redhat.com)
- remove unused private final attributes (tlestach@redhat.com)
- remove unused private static final attribute (tlestach@redhat.com)
- remove unused private static final attributes (tlestach@redhat.com)
- remove unused test part (tlestach@redhat.com)
- remove unused private static sttribute (tlestach@redhat.com)
- remove unused private logger (tlestach@redhat.com)
- remove unused private logger (tlestach@redhat.com)
- remove unused private logger (tlestach@redhat.com)
- remove unused private logger (tlestach@redhat.com)
- remove unused private logger (tlestach@redhat.com)
- remove unused private static final attribute (tlestach@redhat.com)
- remove unused private attribute (tlestach@redhat.com)
- remove unused logger (tlestach@redhat.com)
- remove unused private static final attribute (tlestach@redhat.com)
- remove unused private static attribute (tlestach@redhat.com)
- remove unused private static attributes (tlestach@redhat.com)
- remove unused method (tlestach@redhat.com)
- remove unused method (tlestach@redhat.com)
- remove unused private methods (tlestach@redhat.com)
- remove unused private method (tlestach@redhat.com)
- removing unused private method from SystemEntitlementsSubmitAction
  (tlestach@redhat.com)

* Mon Feb 27 2012 Simon Lukasik <slukasik@redhat.com> 1.7.45-1
- OpenSCAP integration -- Frontend API for scan schedule. (slukasik@redhat.com)
- checkstyle: allow Copyright 2012. (slukasik@redhat.com)

* Mon Feb 27 2012 Tomas Lestach <tlestach@redhat.com> 1.7.44-1
- remove redundant interfaces (tlestach@redhat.com)
- remove redundant assignments (tlestach@redhat.com)
- binaryInput cannot be null at this location (tlestach@redhat.com)
- baos cannot be null at this location (tlestach@redhat.com)
- remove redundant assignements (tlestach@redhat.com)
- toChannel cannot be null at this location (tlestach@redhat.com)
- user cannot be null at this location (tlestach@redhat.com)
- selectedChannel can only be null at this location (tlestach@redhat.com)
- regCount cannot be null at this location (tlestach@redhat.com)
- pkgs cannot be null at this location (tlestach@redhat.com)
- parent cannot be null at this location (tlestach@redhat.com)
- pAdded cannot be null at this location (tlestach@redhat.com)
- mtime cannot be null at this location (tlestach@redhat.com)
- mess can only be null at this location (tlestach@redhat.com)
- kss cannot be null at this location (tlestach@redhat.com)
- key cannot be null at this location (tlestach@redhat.com)
- info cannot be null at this location (tlestach@redhat.com)
- currentErrata cannot be null at this location (tlestach@redhat.com)
- cr cannot be null at this location (tlestach@redhat.com)
- cr cannot be null at this location (tlestach@redhat.com)
- count cannot be null at this location (tlestach@redhat.com)
- compoundLocales cannot be null at this location (tlestach@redhat.com)
- channel cannot be null at this location (tlestach@redhat.com)
- updates cannot be null at this location (tlestach@redhat.com)
- optimize code based on null and non-empty conditions (tlestach@redhat.com)
- rebootAction cannot be null at this location (tlestach@redhat.com)
- proposed cannot be null at this location (tlestach@redhat.com)
- o can only be null at this location (tlestach@redhat.com)
- is can only be null at this location (tlestach@redhat.com)
- name cannot be null at this location (tlestach@redhat.com)
- hostDir cannot be null at this location (tlestach@redhat.com)
- epoch cannot be null at this location (tlestach@redhat.com)
- desc cannot be null at this location (tlestach@redhat.com)
- do not allocate object that will never be used in UpdateErrataCacheCommand
  (tlestach@redhat.com)
- do not allocate object that will never be used in SystemHandler
  (tlestach@redhat.com)
- remove dead code in DeleteFileAction (tlestach@redhat.com)
- remove dead code in PatchConfirmInstallAction (tlestach@redhat.com)
- remove dead code in PatchConfirmAction (tlestach@redhat.com)
- remove dead code in KickstartFormatter (tlestach@redhat.com)
- remove dead code in ErrataQueueWorker (tlestach@redhat.com)
- remove dead code in ActionExecutor (tlestach@redhat.com)
- remove unnecessary semicolons (tlestach@redhat.com)
- remove unnecessary casts (tlestach@redhat.com)
- do not check whether Org expression is an instance of Org
  (tlestach@redhat.com)

* Mon Feb 27 2012 Tomas Lestach <tlestach@redhat.com> 1.7.43-1
- remove unused hbm query - TaskoBunch.lookupById (tlestach@redhat.com)
- remove unused hbm query - TaskoTask.lookupByName (tlestach@redhat.com)
- remove unused hbm query - TaskoTask.lookupById (tlestach@redhat.com)
- remove unused hbm query - TaskoRun.listRunsWithStatus (tlestach@redhat.com)
- remove unused hbm query - UserState.lookupById (tlestach@redhat.com)
- remove unused hbm query - User.findAllUsers (tlestach@redhat.com)
- remove unused hbm query - Address.findById (tlestach@redhat.com)
- remove unused hbm query - VirtualInstance.findAllUnregisteredGuests
  (tlestach@redhat.com)
- remove unused hbm query - VirtualInstance.findAllRegisteredGuests
  (tlestach@redhat.com)
- remove unused hbm query - PushClientState.findByLabel (tlestach@redhat.com)
- remove unused hbm sql-query - ServerGroup.lookupByTypeLabelAndOrg2
  (tlestach@redhat.com)
- remove unused hbm query - PackageProvider.findById (tlestach@redhat.com)
- remove unused hbm query - PackageDelta.findById (tlestach@redhat.com)
- remove unused hbm query - PackageKey.findById (tlestach@redhat.com)
- remove unused hbm query - PackageCapability.findById (tlestach@redhat.com)
- remove unused hbm query - PackageName.findById (tlestach@redhat.com)
- remove unused hbm query - ProfileType.loadAll (tlestach@redhat.com)
- remove unused hbm query - Role.loadRoles (tlestach@redhat.com)
- remove unused hbm query - UserGroup.findByRole (tlestach@redhat.com)
- remove unused hbm query - OrgEntitlementType.findAll (tlestach@redhat.com)
- remove unused hbm query - Task.deleteTaskQueue (tlestach@redhat.com)
- remove unused hbm query - PackageActionResult.findByKey (tlestach@redhat.com)
- remove unused hbm query - ActionStatus.loadAll (tlestach@redhat.com)
- remove unused hbm query - ActionType.findByName (tlestach@redhat.com)
- remove unused hbm query - ActionType.loadAll (tlestach@redhat.com)
- remove unused hbm query - ConfigFileName.findByPath (tlestach@redhat.com)
- remove unused hbm query - Severity.findByLabel (tlestach@redhat.com)
- remove unused hbm query - PublishedErrataFile.listByErrata
  (tlestach@redhat.com)
- remove unused hbm query - UnpublishedBug.findById (tlestach@redhat.com)
- remove unused hbm query - UnpublishedErrata.findByAdvisoryType
  (tlestach@redhat.com)
- remove unused hbm query - UnpublishedErrataFile.listByErrata
  (tlestach@redhat.com)
- remove unused hbm query - PublishedBug.findById (tlestach@redhat.com)
- remove unused hbm query - KickstartSessionHistory.findById
  (tlestach@redhat.com)
- remove unused hbm query - KickstartTreeType.findByName (tlestach@redhat.com)
- remove unused hbm query - KickstartTreeType.loadAll (tlestach@redhat.com)
- remove unused hbm query - KickstartInstallType.findByName
  (tlestach@redhat.com)
- remove unused hbm query - KickstartSession.findById (tlestach@redhat.com)
- remove unused hbm query - KickstartIpRange.findById (tlestach@redhat.com)
- remove unused hbm query - KickstartSessionState.findById
  (tlestach@redhat.com)
- remove unused hbm query - KickstartVirtualizationType.findById
  (tlestach@redhat.com)
- remove unused hbm query - Channel.findById (tlestach@redhat.com)
- remove unused hbm query - ProvisionState.findById (tlestach@redhat.com)
- remove unused hbm query - ArchType.findByName (tlestach@redhat.com)
- remove unused hbm query - ArchType.loadAll (tlestach@redhat.com)
- remove unused hbm query - ChecksumType.loadAll (tlestach@redhat.com)
- remove unused hbm query - FileList.findById (tlestach@redhat.com)
- remove unused hbm query - Probe.listForOrg (tlestach@redhat.com)
- remove unused KickstartFactory public static methods (tlestach@redhat.com)
- audit: cache search results (Joshua.Roys@gtri.gatech.edu)

* Mon Feb 27 2012 Tomas Lestach <tlestach@redhat.com> 1.7.42-1
- remove unused jsp - pages/user/create/createaccount.jsp (tlestach@redhat.com)
- remove unused jsp - pages/software/downloads/isotree.jsp
  (tlestach@redhat.com)
- remove unused jsp - pages/configuration/channel/addfiles.jsp
  (tlestach@redhat.com)
- remove unused jsp - pages/kickstart/pre.jsp (tlestach@redhat.com)
- remove unused jsp - pages/kickstart/post.jsp (tlestach@redhat.com)
- remove unused jsp - pages/channel/relevant.jsp (tlestach@redhat.com)
- remove unused jsp - pages/common/errors/service.jsp (tlestach@redhat.com)
- remove unreferenced do page and appropriate jsp - /users/RPCPlaceholder
  (tlestach@redhat.com)
- remove unused jsp - /common/email_sent.jsp (tlestach@redhat.com)
- remove unreferenced do page - /users/VerificationSent (tlestach@redhat.com)
- remove unreferenced do page - /account/VerificationSent (tlestach@redhat.com)
- remove unused KickstartGuestInstallLog class and appropriate hbm.xml file
  (tlestach@redhat.com)
- remove unreferenced do page together with appropriate action -
  /kickstart/DownloadLog (tlestach@redhat.com)

* Mon Feb 27 2012 Tomas Lestach <tlestach@redhat.com> 1.7.41-1
- remove unreferenced do page together with appropriate action and jsp -
  /software/downloads/Help (tlestach@redhat.com)
- remove unreferenced do page - /configuration/DeleteChannelSubmit
  (tlestach@redhat.com)
- remove unreferenced do page together with appropriate action -
  /kickstart/KickstartsSubmit (tlestach@redhat.com)
- remove unreferenced do page together with appropriate action -
  /systems/details/packages/profiles/CompareSystemsSubmit (tlestach@redhat.com)
- remove unreferenced do page together with appropriate action -
  /systems/details/packages/profiles/CompareProfilesSubmit
  (tlestach@redhat.com)
- remove unreferenced do page - /systems/SystemGroupListSubmit
  (tlestach@redhat.com)
- remove unreferenced do page together with appropriate action and test -
  /systems/ProxyListSubmit (tlestach@redhat.com)
- remove unreferenced do page together with appropriate action and test -
  /systems/InactiveSubmit (tlestach@redhat.com)
- remove unreferenced do page together with appropriate action and test -
  /systems/UngroupedSubmit (tlestach@redhat.com)
- remove unreferenced do page together with appropriate action and test -
  /systems/UnentitledSubmit (tlestach@redhat.com)
- remove unreferenced do page together with appropriate action and test -
  /systems/OutOfDateSubmit (tlestach@redhat.com)
- remove unreferenced do page - /systems/SystemListSubmit (tlestach@redhat.com)
- remove unreferenced do page - /users/DisabledListSubmit (tlestach@redhat.com)
- delete unused do page and appropriate action - /users/UserListSubmit
  (tlestach@redhat.com)
- remove unused action - BaseFilterAction (tlestach@redhat.com)
- remove unused method - listAllFilesWithTotalSize (tlestach@redhat.com)
- remove unused action - QuotaAction (tlestach@redhat.com)
- removing unused action VirtualSystemsListAction (tlestach@redhat.com)
- removing unused action - ConfigDateAction (tlestach@redhat.com)

* Thu Feb 23 2012 Jan Pazdziora 1.7.40-1
- The com.redhat.rhn.taskomatic.task.CleanCurrentAlerts is not longer needed
  because nothing inserts to rhn_current_alerts, removing.
- optionaly omit building spacewalk-java-tests subpackage (tlestach@redhat.com)
- Use table RHN_CURRENT_ALERTS directly instead of the synonym.

* Wed Feb 22 2012 Tomas Lestach <tlestach@redhat.com> 1.7.39-1
- remove unused method (tlestach@redhat.com)
- remove unused action (tlestach@redhat.com)
- drop system_search (tlestach@redhat.com)
- 790803 - use loopback IPs in case the host has no DNS entry
  (tlestach@redhat.com)

* Wed Feb 22 2012 Miroslav Suchý 1.7.38-1
- automatically focus search form (msuchy@redhat.com)
- typo fix (mzazrivec@redhat.com)
- deleting commented unused code (tlestach@redhat.com)
- fix rhn/multiorg/channels/OrgList.do?cid=<cid> on PG (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- prevent calling listErrata APIs with empty startDate and non-empty endDate
  (tlestach@redhat.com)
- remove duplicate information (tlestach@redhat.com)
- no need to select other columns, when the elaborator fetches them anyway
  (tlestach@redhat.com)
- 795565 - list errata according to issue_date, not last_modified
  (tlestach@redhat.com)
- We update stock tomcat server.xml with spacewalk-setup.
  (jpazdziora@redhat.com)
- We do not use subversion for some time. (jpazdziora@redhat.com)
- The java/conf/rhn/rhn.conf is not packaged, nor used. (jpazdziora@redhat.com)

* Tue Feb 21 2012 Tomas Lestach <tlestach@redhat.com> 1.7.37-1
- 790803 - fix javadoc of ip6In (tlestach@redhat.com)
- The dbchange is not used anywhere, removing. (jpazdziora@redhat.com)
- More replaces of rhnuser synonym with web_contact. (jpazdziora@redhat.com)

* Mon Feb 20 2012 Tomas Lestach <tlestach@redhat.com> 1.7.36-1
- 790803 - use sat_node (tlestach@redhat.com)
- 790803 - add ip6 to rhn_sat_node (tlestach@redhat.com)
- 790803 - store vip and vip6 separately (tlestach@redhat.com)
- 790803 - add vip6 to rhn_sat_cluster (tlestach@redhat.com)
- validate IPv6 address using regex (mzazrivec@redhat.com)

* Mon Feb 20 2012 Jan Pazdziora 1.7.35-1
- Removing rhnUser synonym and just using the base web_contact.
- The switchenv.py is not useful externally.

* Mon Feb 20 2012 Tomas Lestach <tlestach@redhat.com> 1.7.34-1
- fix checkstyle issue (tlestach@redhat.com)
- making errata clone api calls re-use cloned errata, if the given adivsory is
  itself a clone (jsherril@redhat.com)

* Thu Feb 16 2012 Justin Sherrill <jsherril@redhat.com> 1.7.33-1
- adding jmock and gsbase as build requires (jsherril@redhat.com)

* Thu Feb 16 2012 Justin Sherrill <jsherril@redhat.com> 1.7.32-1
- moving strutstest to tempjars (jsherril@redhat.com)
- adding mockobjects to tempjars (jsherril@redhat.com)
- adding unit test ant file to java-test package (jsherril@redhat.com)
- initial work go create a java-testing rpm (jsherril@redhat.com)

* Thu Feb 16 2012 Tomas Lestach <tlestach@redhat.com> 1.7.31-1
- remove <isRequired> from xsd, as it is completelly ignored
  (tlestach@redhat.com)
- several tokens may by associated with one server (tlestach@redhat.com)
- advisoryTypeLabels must be pre-filled, when there're form validation errors
  on the errata/manage/Edit page (tlestach@redhat.com)
- current value does not matter by checking RequiredIf (tlestach@redhat.com)
- check date type only if attribute's requiredIf is fulfilled
  (tlestach@redhat.com)
- validate int attributes in the same way as long attributes
  (tlestach@redhat.com)
- 787223 - do not offer to display graph for probes without metrics
  (tlestach@redhat.com)
- correct column aliasing (mzazrivec@redhat.com)
- use ansi outer join syntax (mzazrivec@redhat.com)

* Wed Feb 15 2012 Jan Pazdziora 1.7.30-1
- The noteCount attribute is not used anywhere, removing.
- Removing unused imports.
- The note_count value is nowhere used in the application code, removing from
  selects.

* Wed Feb 15 2012 Milan Zazrivec <mzazrivec@redhat.com> 1.7.29-1
- time_series revamped: fully async deletion of monitoring data
- 784911 - add package_arch to PackageMetadataSerializer

* Tue Feb 14 2012 Tomas Lestach <tlestach@redhat.com> 1.7.28-1
- introduce optional tag for xsd parameter validation (tlestach@redhat.com)
- Revert "790120: improve system overview query performance"
  (jpazdziora@redhat.com)
- 790120: improve system overview query performance (shughes@redhat.com)

* Mon Feb 13 2012 Tomas Lestach <tlestach@redhat.com> 1.7.27-1
- 574975 - fix setChildChannelArch js function (tlestach@redhat.com)
- 786829 - use ks script position as it is stored in the DB
  (tlestach@redhat.com)
- prevent ISE, when creating notification filter wihout having any probe
  defined (tlestach@redhat.com)
- 788988 - check whether interface has an address assigned
  (mzazrivec@redhat.com)

* Thu Feb 09 2012 Tomas Lestach <tlestach@redhat.com> 1.7.26-1
- select first probe by deafult, when creating new notification filter in
  probes scope (tlestach@redhat.com)

* Wed Feb 08 2012 Tomas Lestach <tlestach@redhat.com> 1.7.25-1
- no need to call selectScope on body load (tlestach@redhat.com)
- workaround a jsp bug (tlestach@redhat.com)
- do not disable recurring_frequency by default (tlestach@redhat.com)

* Wed Feb 08 2012 Tomas Lestach <tlestach@redhat.com> 1.7.24-1
- keep the other xsd entry for recurring_duration (tlestach@redhat.com)
- do not validate data type for empty strings, but validate empty numbers
  (tlestach@redhat.com)

* Wed Feb 08 2012 Tomas Lestach <tlestach@redhat.com> 1.7.23-1
- checkstyle fix (tlestach@redhat.com)

* Tue Feb 07 2012 Tomas Lestach <tlestach@redhat.com> 1.7.22-1
- validate also empty form strings (tlestach@redhat.com)
- remove duplicate xsd entry (tlestach@redhat.com)
- convert boolean when storing it to DB char(1) (tlestach@redhat.com)
- store recurring boolean object as number (tlestach@redhat.com)

* Tue Feb 07 2012 Jan Pazdziora 1.7.21-1
- Updating the oversight in license texts.
- Removing unused package.htmls.
- The create_package_doc.pl si not used, removing.

* Mon Feb 06 2012 Tomas Lestach <tlestach@redhat.com> 1.7.20-1
- fix monitoring probe graph time axis (tlestach@redhat.com)
- 785599 - fix jsp condition (tlestach@redhat.com)

* Sat Feb 04 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.19-1
- pgsql: fix probe status list
- fixed list of notifications in ActiveFilters.do

* Thu Feb 02 2012 Jan Pazdziora 1.7.18-1
- 785599 - No helpful NOTE if we are yet to create the kickstart profile.

* Wed Feb 01 2012 Justin Sherrill <jsherril@redhat.com> 1.7.17-1
- improving speed of errata cloning within the spacewalk api
  (jsherril@redhat.com)

* Wed Feb 01 2012 Tomas Lestach <tlestach@redhat.com> 1.7.16-1
- convert boolean value when storing it to DB varchar(1) (tlestach@redhat.com)
- do not store DB information into the rhn_config_macro (tlestach@redhat.com)

* Tue Jan 31 2012 Tomas Lestach <tlestach@redhat.com> 1.7.15-1
- prevent having unsued idle PG transaction/session (tlestach@redhat.com)

* Tue Jan 31 2012 Jan Pazdziora 1.7.14-1
- Removing the web.debug_disable_database option -- it is not supported beyond
  RHN::DB anyway.

* Mon Jan 30 2012 Jan Pazdziora 1.7.13-1
- Casting the user id to string to make rhn_install_org_satellites happy.

* Mon Jan 30 2012 Tomas Lestach <tlestach@redhat.com> 1.7.12-1
- close session after the DB won't be accessed any more from this thread
  (tlestach@redhat.com)

* Fri Jan 27 2012 Jan Pazdziora 1.7.11-1
- 784013 - casting the probe id to string since that is what the substr
  expression in the DELETE returns.
- unify virtual guest defaults used in API and WebUI (tlestach@redhat.com)
- 703273 - save information messages only if having messages to display
  (tlestach@redhat.com)

* Wed Jan 25 2012 Tomas Lestach <tlestach@redhat.com> 1.7.10-1
- 749476 - return default (empty) string instead of omitting the attribute for
  channel.software.getDetails API (tlestach@redhat.com)
- close session after initial taskorun check (tlestach@redhat.com)

* Mon Jan 23 2012 Tomas Lestach <tlestach@redhat.com> 1.7.9-1
- include Base64 from gpache.commons.codec.binary (tlestach@redhat.com)

* Mon Jan 23 2012 Tomas Lestach <tlestach@redhat.com> 1.7.8-1
- enable requesting base64 encoded config file ervisions (tlestach@redhat.com)
- 702019 - use --log option for anaconda script logging starting from rhel6
  (tlestach@redhat.com)
- 648483 - setting kickstart host for virtual guest provisioning
  (tlestach@redhat.com)
- 702019 - add extra newline to ks file (tlestach@redhat.com)
- Error banner on (re)login page indicating schema upgrade is required.
  (mzazrivec@redhat.com)
- make sure a request url gets displayed in the traceback e-mail
  (tlestach@redhat.com)

* Wed Jan 18 2012 Tomas Lestach <tlestach@redhat.com> 1.7.7-1
- 725889 - cannot compare an Object with null using equals
  (tlestach@redhat.com)

* Tue Jan 17 2012 Tomas Lestach <tlestach@redhat.com> 1.7.6-1
- reinitialize schedules at the taskomatic start when detecting runs in the
  future (tlestach@redhat.com)

* Tue Jan 17 2012 Tomas Lestach <tlestach@redhat.com> 1.7.5-1
- set includeantruntime to true (tlestach@redhat.com)

* Tue Jan 17 2012 Tomas Lestach <tlestach@redhat.com> 1.7.4-1
- remove duplicate struts-config entry (tlestach@redhat.com)
- define includeantruntime for javac build (tlestach@redhat.com)
- Show Proxy tabs on Spacewalk (msuchy@redhat.com)

* Fri Jan 13 2012 Milan Zazrivec <mzazrivec@redhat.com> 1.7.3-1
- 574975 - child channel arch defaults to parent's arch (mzazrivec@redhat.com)
- 703273 - fix multiple server subscriptions to a channel (tlestach@redhat.com)
- 770143 - pass checksum, when changing org sharing to private
  (tlestach@redhat.com)
- 515653 - unify channel architecture label (mzazrivec@redhat.com)

* Fri Jan 06 2012 Tomas Lestach <tlestach@redhat.com> 1.7.2-1
- removing hibernate not-null constraint (tlestach@redhat.com)
- 756097 - remove 'Spacewalk' from log messages (tlestach@redhat.com)
- introduce validator checks for kickstart scripts (tlestach@redhat.com)

* Wed Jan 04 2012 Tomas Lestach <tlestach@redhat.com> 1.7.1-1
- 700711 - redirect SessionStatus page page to systems overview after the
  system profile gets deleted (tlestach@redhat.com)
- Bumping package versions for 1.7. (mzazrivec@redhat.com)

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.101-1
- update copyright info

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.100-1
- start using RHN_TASKO_RUN_ID_SEQ sequence for the rhnTaskoRun table
  (tlestach@redhat.com)

* Tue Dec 20 2011 Tomas Lestach <tlestach@redhat.com> 1.6.99-1
- 702019 - enable ks logging for older clients as well (tlestach@redhat.com)

* Tue Dec 20 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.98-1
- 753728 - test database connection prior running query

* Mon Dec 19 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.97-1
- IPv6: rename getIp6Addresses() -> getGlobalIpv6Addresses()
- IPv6: sync IPv6 data w/ cobbler
- 672652 - kernel options stored before update might be stored as strings
  (tlestach@redhat.com)
- 740940 - fix config channel rhnSet usage (tlestach@redhat.com)
- 755854 - fix packages.getDetails API documentation (tlestach@redhat.com)
- unify channel.software.clone and channel.software.getDetails API parameters
  (tlestach@redhat.com)
- IPv6: extend address validation with IPv6 logic

* Thu Dec 15 2011 Tomas Lestach <tlestach@redhat.com> 1.6.96-1
- 756097 - there're several valid initrd paths for kickstart trees
  (tlestach@redhat.com)

* Thu Dec 15 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.95-1
- msv-workaround has been replaced by spacewalk-jpp-workaround

* Wed Dec 14 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.94-1
- IPv6: allow multiple IPv6 addresses per net. interface

* Wed Dec 14 2011 Tomas Lestach <tlestach@redhat.com> 1.6.93-1
- remove spring-dedicated conflict of spacewalk-java (tlestach@redhat.com)
- fix ksdevice cmd line argument for static intf. provisioning
  (mzazrivec@redhat.com)
- IPv6: fix static intf. provisioning using SSM (mzazrivec@redhat.com)
- fix the spring issue (tlestach@redhat.com)
- make ScalableFileSystem repository available for RHEL6 kickstarts
  (tlestach@redhat.com)

* Tue Dec 13 2011 Tomas Lestach <tlestach@redhat.com> 1.6.92-1
- prevent yum to update fedora spring with broken version numbering
  (tlestach@redhat.com)
- IPv6: fix static network line syntax for particular distros
  (mzazrivec@redhat.com)
- IPv6: add --noipv4 to ks.cfg in case interface does not have an IPv4 address
  (mzazrivec@redhat.com)

* Mon Dec 12 2011 Miroslav Suchý 1.6.91-1
- fix checkstyle
- IPv6: --ipv6 is not a valid ks option in RHEL-5 (mzazrivec@redhat.com)
- introduce setSelectable(Integer) method for VisibleSystems
  (pcasenove@gmail.com)

* Sun Dec 11 2011 Aron Parsons <aronparsons@gmail.com> 1.6.90-1
- use a stanza/snippet accordingly for kickstart_{start,done}
  (aronparsons@gmail.com)
- add a static method to return the Cobbler version (aronparsons@gmail.com)
- pass a CobblerConnection object to Network so it can determine the Cobbler
  version (aronparsons@gmail.com)
- account for the rename of the subnet variable to netmask in Cobbler 2.2
  (aronparsons@gmail.com)
- added getVersion method to CobblerConnection (aronparsons@gmail.com)

* Fri Dec 09 2011 Jan Pazdziora 1.6.89-1
- Checkstyle fixes.

* Fri Dec 09 2011 Tomas Lestach <tlestach@redhat.com> 1.6.88-1
- fix cfg template handling at kickstart profile rename (tlestach@redhat.com)
- Fix display of static snippets. (ug@suse.de)
- 752480 - point directly back to the Preferences page, as we do not ship
  online documentation with Spacewalk. (jpazdziora@redhat.com)
- 750475 - point to the latest Apache Lucene documentation as the link to 2.3.2
  is not longer valid. (jpazdziora@redhat.com)
- 672652 - fix behaviour with cosmetic issues (tlestach@redhat.com)
- fix checkstyle issue (tlestach@redhat.com)
- IPv6: RHEL-5 registration may return "global" for an IPv6 address
  (mzazrivec@redhat.com)
- IPv6: don't update non-existing cobbler profile (mzazrivec@redhat.com)
- 735381 - schedule errata update, when turning on auto_errata_update via
  system.setDetails API (tlestach@redhat.com)

* Wed Dec 07 2011 Tomas Lestach <tlestach@redhat.com> 1.6.87-1
- 751681 - fix ISE, when changing tree of a kickstart with deleted --url option
  (tlestach@redhat.com)
- make ant build working on F16 (tlestach@redhat.com)
- replace '= null' with 'is null' (tlestach@redhat.com)

* Mon Dec 05 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.86-1
- fixed list of config channels relevant to SSM

* Mon Dec 05 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.85-1
- IPv6: allow for IPv6 search without having to escape colons

* Mon Dec 05 2011 Jan Pazdziora 1.6.84-1
- Fix query to determine config channels in SSM (jrenner@suse.de)
- fix checkstyle issues (tlestach@redhat.com)

* Fri Dec 02 2011 Jan Pazdziora 1.6.83-1
- 672652 - fixed allowing duplicate key for kernel_post_options and
  kernel_options (mmello@redhat.com)
- IPv6: reprovisioning with static network interface (mzazrivec@redhat.com)
- 758697 - PG syntax for trust_overview (slukasik@redhat.com)

* Tue Nov 29 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.82-1
- unit test fix (mzazrivec@redhat.com)

* Tue Nov 29 2011 Miroslav Suchý 1.6.81-1
- IPv6: disabled interface - take IPv6 addresses into account
  (mzazrivec@redhat.com)
- IPv6: unit test fixes (mzazrivec@redhat.com)
- IPv6: also browse through NIC's IPv6 addresses (mzazrivec@redhat.com)
- IPv6: duplicate system comparison based on IPv6 (webui)
  (mzazrivec@redhat.com)
- IPv6: find system duplicates based on IPv6 (mzazrivec@redhat.com)
- IPv6: fix duplicates based on IP comparison (mzazrivec@redhat.com)
- IPv6: system.getNetworkDevices() modifications (API) (mzazrivec@redhat.com)
- api doc: typo fix (mzazrivec@redhat.com)
- IPv6: system.getNetwork() modifications (API) (mzazrivec@redhat.com)
- IPv6: SystemHardware.do (webui) modifications (mzazrivec@redhat.com)
- IPv6: update NetworkInterface.* (mzazrivec@redhat.com)
- IPv6: updated hibernate mappings for network tables (mzazrivec@redhat.com)

* Mon Nov 28 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.80-1
- 747037 - disable connects to svn.terracotta.org

* Wed Nov 23 2011 Jan Pazdziora 1.6.79-1
- No scrubbing of key description and custom key value, also escape the value
  which can now contain full range of characters.

* Mon Nov 21 2011 Jan Pazdziora 1.6.78-1
- Remove markup from another error message (jrenner@suse.de)
- Remove markup from error message in all translation files (jrenner@suse.de)
- Catch a java.lang.NullPointerException when web_contact got deleted and
  rhnServerCustomDataValue.created_by became null.
- Fix the *callerIp* in API logfile (jrenner@suse.de)

* Tue Nov 15 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.77-1
- 738999 - VirtualInstance.confirmed is number not boolean

* Wed Nov 09 2011 Tomas Lestach <tlestach@redhat.com> 1.6.76-1
- 682845 - check the input parameters for repo related APIs
  (tlestach@redhat.com)
- 699489 - regenerate affected kickstart profiles, when updating crypto key
  (tlestach@redhat.com)
- This field is actually optional; it might not be specified.
  (slukasik@redhat.com)

* Wed Nov 09 2011 Tomas Lestach <tlestach@redhat.com> 1.6.75-1
- precompile also apidoc jsp pages (tlestach@redhat.com)
- 682845 - fix channel.software.listUserRepos API doc (tlestach@redhat.com)
- 682845 - fix channel.software.getRepoSyncCronExpression API doc
  (tlestach@redhat.com)
- example with usage of xmlrpclib.DateTime is presented twice, remove one
  (msuchy@redhat.com)

* Mon Nov 07 2011 Tomas Lestach <tlestach@redhat.com> 1.6.74-1
- 680489 - fix system.provisioning.snapshot.addTagToSnapshot API doc
  (tlestach@redhat.com)
- 680489 - fix system.deleteTagFromSnapshot API doc return type
  (tlestach@redhat.com)
- 680489 - fix system.tagLatestSnapshot API doc return type
  (tlestach@redhat.com)
- fix system.createSystemRecord API doc return type (tlestach@redhat.com)
- delete redundant comments (tlestach@redhat.com)
- 734799 - Correct API documentation (slukasik@redhat.com)

* Sat Nov 05 2011 Simon Lukasik <slukasik@redhat.com> 1.6.73-1
- 725050 - fix activationkey.[gs]etDetails apidoc (slukasik@redhat.com)

* Fri Nov 04 2011 Tomas Lestach <tlestach@redhat.com> 1.6.72-1
- 723528 - fix template attribute type in kickstart.profile API documentation
  (tlestach@redhat.com)
- 699505 - restrict manageable flag only for custom channels
  (tlestach@redhat.com)
- 699505 - fix typo: *managable -> *mangeable in channel.software APIs and
  their doc (tlestach@redhat.com)
- 593300 - handle directoriy and symlink config revision comparism
  (tlestach@redhat.com)

* Thu Nov 03 2011 Tomas Lestach <tlestach@redhat.com> 1.6.71-1
- 725050 - fix activationkey.setDetails apidoc (tlestach@redhat.com)
- 723528 - fix kickstart.profile.listScripts apidoc (tlestach@redhat.com)
- 610784 - fix system.listNotes apidoc (tlestach@redhat.com)
- 610157 - fix system.getScriptActionDetails apidoc (tlestach@redhat.com)
- 751017 - item identifing user which scheduled the action is optional
  (slukasik@redhat.com)

* Wed Nov 02 2011 Tomas Lestach <tlestach@redhat.com> 1.6.70-1
- introducing name for scripts in kickstart profiles in the webinterface
  (berendt@b1-systems.de)

* Mon Oct 31 2011 Tomas Lestach <tlestach@redhat.com> 1.6.69-1
- 593300 - do not create same revision as the last one (tlestach@redhat.com)

* Mon Oct 31 2011 Simon Lukasik <slukasik@redhat.com> 1.6.68-1
- 662200 - Added validation of input map. (slukasik@redhat.com)

* Fri Oct 28 2011 Jan Pazdziora 1.6.67-1
- 600527 - for kickstart session (re)activation keys, always set the
  deployConfigs to false.
- The KickstartSessionCreateCommand is duplicated in KickstartWizardHelper.
- For the default_session, use better note in rhnregtoken table.
- declare net.sf.antcontrib.logic.For task to fix create-webapp-dir
  (berendt@b1-systems.de)
- adding xalan-j2 to the build.jar.dependencies property
  (berendt@b1-systems.de)
- When there are not ks-pre.log files, do not return error.
- Doing replacement on all files is not nice.
- The -n and -p are exclusive in perl, let us just settle on -p.
- 748903 - extend search_string maxlenght (tlestach@redhat.com)

* Wed Oct 26 2011 Martin Minar <mminar@redhat.com> 1.6.66-1
- 737838 - allow org admins to unschedule repo sync (org tasks)
  (tlestach@redhat.com)
- 692357 - clone also kernel and kernel post options when cloning a ks profile
  (tlestach@redhat.com)
- DISTINCT is equivalent to UNIQUE. (jpazdziora@redhat.com)
- 726114 - allow macro delimiters in configchannel.createOrUpdatePath for
  directories (tlestach@redhat.com)

* Tue Oct 25 2011 Jan Pazdziora 1.6.65-1
- 682845 - get rid of ChannelFactory.lookupContentSource(id) method without org
  param (tlestach@redhat.com)
- 682845 - get rid of ChannelFactory.lookupContentSource(label) method without
  org param (tlestach@redhat.com)
- Amending incorrect substitution from ee3623222bf. (slukasik@redhat.com)
- 682845 - fix apidoc of repository related APIs (tlestach@redhat.com)
- Do not hardcode config identifier, use defaults instead.
  (slukasik@redhat.com)

* Mon Oct 24 2011 Simon Lukasik <slukasik@redhat.com> 1.6.64-1
- No need to have separate configuration per Tomcat's version
  (slukasik@redhat.com)
- 748341 - No need to specify docBase, when it's the same as appBase
  (slukasik@redhat.com)

* Fri Oct 21 2011 Miroslav Suchý 1.6.63-1
- 627809 - write out storage devices if *storage* device list is not empty
- 627809 - send xen virtual block devices to rhnParent
- 736381,732091 - adding api doc (tlestach@redhat.com)
- 680489 - fix api doc (tlestach@redhat.com)

* Mon Oct 17 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.62-1
- 746090 - fixed join condition in query
- 589799 - omit number of selected items for SSM related system selections

* Thu Oct 13 2011 Miroslav Suchý 1.6.61-1
- 745102 - display IPv6 from networkinfo in SDC and in system search

* Thu Oct 13 2011 Tomas Lestach <tlestach@redhat.com> 1.6.60-1
- fixing checkstyle issues (tlestach@redhat.com)

* Thu Oct 13 2011 Tomas Lestach <tlestach@redhat.com> 1.6.59-1
- Fixed pam setting on user page not saving (jrenner@suse.de)
- Set breed in cobbler correctly (ug@suse.de)

* Wed Oct 12 2011 Jan Pazdziora 1.6.58-1
- 691849 - Add missing fix for schedule command AFTER package install.
  (jrenner@suse.de)

* Mon Oct 10 2011 Jan Pazdziora 1.6.57-1
- 741476, 743407 - it is the null dmi.getBios() which caused the problem in bug
  452956 actually.
- 421991 - in SSM add link to list of systems subscribed to channels
  (msuchy@redhat.com)

* Thu Oct 06 2011 Tomas Lestach <tlestach@redhat.com> 1.6.56-1
- 738988 - erratum associated with an ActionMessage might be deleted in the
  mean time (tlestach@redhat.com)

* Tue Oct 04 2011 Tomas Lestach <tlestach@redhat.com> 1.6.55-1
- 729784 - support for passalgo in advanced options of kickstart profiles
  (tlestach@redhat.com)
- add exception handling for server deletion (tlestach@redhat.com)

* Mon Oct 03 2011 Miroslav Suchý 1.6.54-1
- 229836 - allow empty prefix for user

* Sun Oct 02 2011 Jan Pazdziora 1.6.53-1
- Removing unused imports.

* Sun Oct 02 2011 Jan Pazdziora 1.6.52-1
- Removing unused imports.

* Fri Sep 30 2011 Jan Pazdziora 1.6.51-1
- 678118 - if system already is proxy, losen the ACL and show the tab.
- Removing make_server_proxy query as it is no longer used.
- Removing org_proxy_servers_evr query as it is no longer used.
- Removing proxy_evr_at_least, org_proxy_evr_at_least, aclOrgProxyEvrAtLeast as
  they are no longer used.
- Remove proxy_evr_at_least ACLs -- all supported proxy versions are 3+.
- 602179 - limit fake generated password to maximal password length
  (tlestach@redhat.com)

* Fri Sep 30 2011 Jan Pazdziora 1.6.50-1
- 621531 - update java build configs to use the new /usr/share/rhn/config-
  defaults location.
- 621531 - update java Config and taskomatic to use the new /usr/share/rhn
  /config-defaults location.
- 621531 - move /etc/rhn/default to /usr/share/rhn/config-defaults (java).
- fix xmlrpc returntypes (tlestach@redhat.com)
- 682845 - schedule repo synchronization through API (tlestach@redhat.com)

* Thu Sep 22 2011 Tomas Lestach <tlestach@redhat.com> 1.6.49-1
- 610157 - introduce system.getScriptActionDetails API (tlestach@redhat.com)
- 740427 - use sequence_nextval function (tlestach@redhat.com)
- 610784 - adding 'updated' attribute to system.listNotes API
  (tlestach@redhat.com)

* Thu Sep 22 2011 Tomas Lestach <tlestach@redhat.com> 1.6.48-1
- 680489 - introduce tag system tag related API calls (tlestach@redhat.com)
- 680489 - intorduce system.provisioning.snapshot.addTagToSnapshot API call
  (tlestach@redhat.com)
- checkstyle issues (tlestach@redhat.com)
- 740306 - fix delete -> register reprovisioning scenario
  (mzazrivec@redhat.com)

* Fri Sep 16 2011 Tomas Lestach <tlestach@redhat.com> 1.6.47-1
- 717984 - list only ssm systems in SSM Selected Systems List tab
  (tlestach@redhat.com)
- update copyright info (mzazrivec@redhat.com)
- 619723 - Add support for open ranges, like bytes=9500- or bytes=-500.
  (jpazdziora@redhat.com)
- 509563 - add missing import (mzazrivec@redhat.com)
- 509563 - remove system profile from cobbler during system deletion
  (mzazrivec@redhat.com)
- 732350 - link mchange-commons jar to taskomatic (tlestach@redhat.com)

* Fri Sep 16 2011 Jan Pazdziora 1.6.46-1
- CVE-2011-2927, 730955 - remove markup from localized string resources as
  well.
- CVE-2011-2927, 730955 - remove markup from the error messages.
- CVE-2011-2927, 730955 - replace <html:errors> with loop that can use c:out to
  escape HTML.
- CVE-2011-2927, 730955 - using struts quotes values properly.
- CVE-2011-2920, 681032 - escape the hidden element value to avoid XSS.
- Encode the & in makeParamsLink.
- CVE-2011-2919, 713478 - URL-encode parameter names, not just values, in the
  URL.
- CVE-2011-1594, 672167 - only local redirects are allowed
  (michael.mraka@redhat.com)

* Thu Sep 15 2011 Miroslav Suchý 1.6.45-1
- 719677 - download comps file of child channels during kickstart

* Thu Sep 15 2011 Jan Pazdziora 1.6.44-1
- Revert "529483 - adding referer check for HTTP requests to java stack"
- We should not pass empty strings to SQL, use null instead.

* Mon Sep 12 2011 Jan Pazdziora 1.6.43-1
- 585010 - We need to render the object.

* Mon Sep 12 2011 Jan Pazdziora 1.6.42-1
- 554781 - add green check to Sync system to package profile when profile is
  being synced.

* Fri Sep 09 2011 Martin Minar <mminar@redhat.com> 1.6.41-1
- 736381 - New API: system.deleteGuestProfiles() (mzazrivec@redhat.com)

* Wed Sep 07 2011 Jan Pazdziora 1.6.40-1
- Do not send error message in case of success (jrenner@suse.de)

* Mon Sep 05 2011 Jan Pazdziora 1.6.39-1
- 732350 - On Fedora 15, mchange's log stuff is no longer in c3p0.

* Fri Sep 02 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.38-1
- fixed column alias syntax
- suite_id is number not string
- replaced alias with table name

* Fri Sep 02 2011 Miroslav Suchý 1.6.37-1
- show cname aliases in hw tab from config file (msuchy@redhat.com)
- Checkstyle fixes (mzazrivec@redhat.com)

* Fri Sep 02 2011 Tomas Lestach <tlestach@redhat.com> 1.6.36-1
- checkstyle fix (tlestach@redhat.com)

* Fri Sep 02 2011 Martin Minar <mminar@redhat.com> 1.6.35-1
- 734799 - New API: configchannel.getFileRevision (mzazrivec@redhat.com)
- 734799 - New API: configchannel.getFileRevisions (mzazrivec@redhat.com)
- 734799 - New API: configchannel.deleteFileRevisions (mzazrivec@redhat.com)

* Wed Aug 31 2011 Tomas Lestach <tlestach@redhat.com> 1.6.34-1
- fix NPE for KickstartDetailsEditAction (tlestach@redhat.com)

* Wed Aug 31 2011 Tomas Lestach <tlestach@redhat.com> 1.6.33-1
- 725059 - en/disable kickstart profiles using API (tlestach@redhat.com)
- 725050 - en/disable activation keys using API (tlestach@redhat.com)

* Tue Aug 30 2011 Tomas Lestach <tlestach@redhat.com> 1.6.32-1
- 640535 - add extra spaces between topic, description and note in Errata Alert
  e-mails (tlestach@redhat.com)
- 640535 - lower amount of logging mailer messages (tlestach@redhat.com)
- 640535 - prevent listing duplicate servers in the Errata Alert e-mails
  (cperry@redhat.com)
- 730999 - fixed bad indentation (michael.mraka@redhat.com)

* Tue Aug 30 2011 Martin Minar <mminar@redhat.com> 1.6.31-1
- update custom info changes (tlestach@redhat.com)
- 699527 - introduce system.custominfo.updateKey API (tlestach@redhat.com)
- 692797 - display asterisk explanation only when asterisk was used on the page
  (tlestach@redhat.com)
- 663697 - adding system id to system currency csv export (tlestach@redhat.com)
- 709724 - bounce to default url for expired POST requests
  (mzazrivec@redhat.com)

* Thu Aug 25 2011 Tomas Lestach <tlestach@redhat.com> 1.6.30-1
- 699489 - introduce kickstart.keys.update API (tlestach@redhat.com)

* Wed Aug 24 2011 Tomas Lestach <tlestach@redhat.com> 1.6.29-1
- 662200 - allow modification of selected channel attributes via API
  (tlestach@redhat.com)

* Tue Aug 23 2011 Tomas Lestach <tlestach@redhat.com> 1.6.28-1
- make the taskomatic cleanup delete faster for Postgresql (jonathan.hoser
  @helmholtz-muenchen.de)

* Mon Aug 22 2011 Miroslav Suchý 1.6.27-1
- read cnames from rhn.conf and polish UI
- show cnames aliases in hardware tab in webui
- Allow to specify host for kickstart in free form

* Mon Aug 22 2011 Tomas Lestach <tlestach@redhat.com> 1.6.26-1
- fix deleting kickstart tree distribution (tlestach@redhat.com)
- do not see a reason to set these attributes (tlestach@redhat.com)

* Mon Aug 22 2011 Martin Minar <mminar@redhat.com> 1.6.25-1
- 585010 - mark the Update List button with it so that we can disable it later.
  (jpazdziora@redhat.com)
- 691849 - forward only sid parameter (tlestach@redhat.com)
- 691849 - it's not allowed to store empty string to the DB
  (tlestach@redhat.com)
- removing showImg attribute from SetTag (tlestach@redhat.com)

* Thu Aug 18 2011 Tomas Lestach <tlestach@redhat.com> 1.6.24-1
- 658533 - unify score computing for WebUI and API (tlestach@redhat.com)
- 663697 - enable csv export of System Currency Report (tlestach@redhat.com)
- removing eclipse.libsrc.dirs since the directory was removed
  (tlestach@redhat.com)

* Thu Aug 18 2011 Tomas Lestach <tlestach@redhat.com> 1.6.23-1
- 658533 - remove default currency from backend part of rhn.conf
  (tlestach@redhat.com)

* Tue Aug 16 2011 Tomas Lestach <tlestach@redhat.com> 1.6.22-1
- 654996 - sort activation key packages by name (tlestach@redhat.com)

* Tue Aug 16 2011 Simon Lukasik <slukasik@redhat.com> 1.6.21-1
- 570925 - provide only a day for the subject of daily summary mail
  (slukasik@redhat.com)
- Revert "do not reuse system CLASSPATH variable" (tlestach@redhat.com)
- 729975 - do not allow to edit Red Hat errata (tlestach@redhat.com)
- do not reuse system CLASSPATH variable (msuchy@redhat.com)

* Thu Aug 11 2011 Simon Lukasik <slukasik@redhat.com> 1.6.20-1
- 724918 - added missing acl checks (slukasik@redhat.com)

* Thu Aug 11 2011 Jan Pazdziora 1.6.19-1
- 728638 - Fixed kickstart.profile.setAdvancedOptions() to renderize the
  kickstart after invocating method. (mmello@redhat.com)

* Sun Aug 07 2011 Jan Pazdziora 1.6.18-1
- Silencing checkstyle.

* Fri Aug 05 2011 Tomas Lestach <tlestach@redhat.com> 1.6.17-1
- 728572 - Number is a common interface for both Integer and Long
  (tlestach@redhat.com)
- 722454 - removing file attribute from PackageDto and introducing a common
  method for getting filename from the package path (tlestach@redhat.com)

* Fri Aug 05 2011 Jan Pazdziora 1.6.16-1
- 710169 - correct documentation for api.getApiCallList() API call
  (msuchy@redhat.com)
- 710162 - correct documentation for api.getApiNamespaceCallList() API call
  (msuchy@redhat.com)
- 710152 - correct documentation for api.getApiNamespaces() API call
  (msuchy@redhat.com)

* Fri Aug 05 2011 Miroslav Suchý 1.6.15-1
- checkstyle - Line is longer than 92 characters.

* Thu Aug 04 2011 Aron Parsons <aparsons@redhat.com> 1.6.14-1
- add support for custom messages in the header, footer and login pages
  (aparsons@redhat.com)

* Thu Aug 04 2011 Tomas Lestach <tlestach@redhat.com> 1.6.13-1
- remove unused ChannelEditor method (tlestach@redhat.com)
- remove unused OvalServlet method (tlestach@redhat.com)
- remove unused SystemEntitlementsSubmitAction method (tlestach@redhat.com)
- remove unused Token method (tlestach@redhat.com)
- remove unused Server method (tlestach@redhat.com)
- reuse unused copyKickstartCommands method (tlestach@redhat.com)
- remove unused HibernateFactory method (tlestach@redhat.com)
- fix PMD BrokenNullCheck (tlestach@redhat.com)
- fix PMD BooleanInstantiation rule break (tlestach@redhat.com)

* Thu Aug 04 2011 Simon Lukasik <slukasik@redhat.com> 1.6.12-1
- 727984 - include static mappings for 6ComputeNode (slukasik@redhat.com)
- 725889 - show only channels for which the user has entitlements
  (slukasik@redhat.com)
- listRedHatBaseChannelsByVersion() was never used, removing
  (slukasik@redhat.com)

* Thu Aug 04 2011 Jan Pazdziora 1.6.11-1
- 508936 - rhn-actions-control honor the allowed-actions/scripts/run for remote
  commands (mmello@redhat.com)
- 679846 - regenerate kickstart file after modifying kickstart scripts
  (mosvald@redhat.com)

* Wed Aug 03 2011 Tomas Lestach <tlestach@redhat.com> 1.6.10-1
- adding @param tag (tlestach@redhat.com)

* Tue Aug 02 2011 Tomas Lestach <tlestach@redhat.com> 1.6.9-1
- 723528 - make templating flag for kickstart scripts accessible also for API
  (tlestach@redhat.com)

* Mon Aug 01 2011 Tomas Lestach <tlestach@redhat.com> 1.6.8-1
- 706416 - do not modify activation key base channel in kickstart stuff
  (tlestach@redhat.com)
- 706416 - do not add automatically tools channel to an activation key
  (tlestach@redhat.com)

* Mon Aug 01 2011 Jan Pazdziora 1.6.7-1
- Fix software rollback to profiles (jrenner@suse.de)

* Thu Jul 28 2011 Tomas Lestach <tlestach@redhat.com> 1.6.6-1
- 658533,722455  - sort systems according to currency score
  (tlestach@redhat.com)

* Thu Jul 28 2011 Jan Pazdziora 1.6.5-1
- 601524 - kickstart.profile.setAdvancedCall apidoc fix (tlestach@redhat.com)
- 725555 - fix typo for test in c.size() to match the logging message
  (mmello@redhat.com)
- Fixed typo at Query bindParameters() (mmello@redhat.com)

* Mon Jul 25 2011 Tomas Lestach <tlestach@redhat.com> 1.6.4-1
- 722453 - fix sort according to Installed time on PackageList.do
  (tlestach@redhat.com)
- removing some dead code (tlestach@redhat.com)

* Fri Jul 22 2011 Jan Pazdziora 1.6.3-1
- We only support version 5 and newer of RHEL, removing conditions for old
  versions.
- We only support version 14 and newer of Fedora, removing conditions for old
  versions.

* Fri Jul 22 2011 Jan Pazdziora 1.6.2-1
- 622013 - sort group list (tlestach@redhat.com)

* Thu Jul 21 2011 Jan Pazdziora 1.6.1-1
- Fixing typo (snv vs. svn).

* Wed Jul 20 2011 Jan Pazdziora 1.5.60-1
- Do not create the 2011--2011 copyright years.

* Tue Jul 19 2011 Jan Pazdziora 1.5.59-1
- Allow the 2010--2011 copyright year in the checkstyle.

* Tue Jul 19 2011 Jan Pazdziora 1.5.58-1
- Updating the copyright years.

* Mon Jul 18 2011 Jan Pazdziora 1.5.57-1
- On Fedora 15, classpathx-jaf needs to be spelled out as Requires.
- 722454 - let errata.listPackages return file attribute (tlestach@redhat.com)

* Thu Jul 14 2011 Miroslav Suchý 1.5.56-1
- changing query to cursor mode - avoid loading all records (4M+ records) into
  memory (msuchy@redhat.com)
- 720282 - fix some issues when spacewalk-koan needs to be installed for
  systems to kickstart (tlestach@redhat.com)

* Wed Jul 13 2011 Jan Pazdziora 1.5.55-1
- 720533 - replacing rhnServerNeededView with custom subselect which is
  generally equivalent, in the erratamailer_get_relevant_servers context.

* Tue Jul 12 2011 Jan Pazdziora 1.5.54-1
- Using http://struts.apache.org/tags-* uris, fixing build issue on Fedoras and
  RHEL 6.

* Mon Jul 11 2011 Jan Pazdziora 1.5.53-1
- 719632 - include security token in system search filter
  (mzazrivec@redhat.com)
- Refactor and deprecate API method to listVendorChannels (jrenner@suse.de)
- Refactor RedHat.do to Vendor.do (jrenner@suse.de)

* Tue Jun 28 2011 Tomas Lestach <tlestach@redhat.com> 1.5.52-1
- 646802 - Fix to have consistent channel name max length to 256
  (pmutha@redhat.com)

* Tue Jun 28 2011 Tomas Lestach <tlestach@redhat.com> 1.5.51-1
- fix never ending loop, when entering an invalid storage value
  (tlestach@redhat.com)
- rename localStorageMegabytes -> localStorageGigabytes (tlestach@redhat.com)
- storage isn't set in MB, but in GB (ug@suse.de)
- prevent setting virtual bridge to null (ug@suse.de)
- 699505 - introduce channel.software.setUserManagable and
  channel.software.isUserManagable API calls (tlestach@redhat.com)

* Mon Jun 27 2011 Tomas Lestach <tlestach@redhat.com> 1.5.50-1
- 710433 - fix kickstart via proxy from RHEL6 Satellite (tlestach@redhat.com)

* Fri Jun 24 2011 Jan Pazdziora 1.5.49-1
- 699523 - extend user.GetDetails by PAM usage info (tlestach@redhat.com)
- let finish the kickstart profile creation by the Enter button
  (tlestach@redhat.com)

* Tue Jun 21 2011 Jan Pazdziora 1.5.48-1
- 690842 - fix check for existing activation key (tlestach@redhat.com)
- 648483 - fix system.provisionVirtualGuest NPE (tlestach@redhat.com)
- 710959 - rename acl: not file_is_directory -> is_file (tlestach@redhat.com)
- 708957 - remove RHN Satellite Proxy Release Notes link (tlestach@redhat.com)

* Fri Jun 17 2011 Jan Pazdziora 1.5.47-1
- 709724 - check session validity first, security token next
  (mzazrivec@redhat.com)
- CVE-2009-4139 - cross site request forging vulnerability fix
  (mzazrivec@redhat.com)

* Wed Jun 15 2011 Jan Pazdziora 1.5.46-1
- Make the line shorter to pass checkstyle.

* Tue Jun 14 2011 Miroslav Suchý 1.5.45-1
- add missing semicolon (msuchy@redhat.com)

* Tue Jun 14 2011 Miroslav Suchý 1.5.44-1
- fix content-length setting (msuchy@redhat.com)
- 711377 - remove confusing 'create schedule' link (tlestach@redhat.com)

* Mon Jun 13 2011 Jan Pazdziora 1.5.43-1
- content-length should be sent even for HEAD (msuchy@redhat.com)

* Wed Jun 01 2011 Tomas Lestach <tlestach@redhat.com> 1.5.42-1
- 709365 - fixed delete kickstart API docs (mmello@redhat.com)

* Mon May 30 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.41-1
- made some queries PG compatible

* Fri May 27 2011 Tomas Lestach <tlestach@redhat.com> 1.5.40-1
- 443126 - introduce notifications for custom errata (tlestach@redhat.com)

* Fri May 27 2011 Jan Pazdziora 1.5.39-1
- 703858 - virt. channel subscription: mimic the behavior of original channel
  (mzazrivec@redhat.com)

* Thu May 26 2011 Tomas Lestach <tlestach@redhat.com> 1.5.38-1
- 708083 - clone Red Hat errata, when associating them into a cloned channel
  (tlestach@redhat.com)
- create special symlink for f15 tomcat-juli.jar (tlestach@redhat.com)

* Thu May 26 2011 Tomas Lestach <tlestach@redhat.com> 1.5.37-1
- adding jaf build require for spacewalk-java (tlestach@redhat.com)

* Wed May 25 2011 Tomas Lestach <tlestach@redhat.com> 1.5.36-1
- 707658 - generate errata cache for the correct erratum (tlestach@redhat.com)

* Tue May 24 2011 Jan Pazdziora 1.5.35-1
- 703273 - check, whether subscription is possible (tlestach@redhat.com)

* Fri May 20 2011 Tomas Lestach <tlestach@redhat.com> 1.5.34-1
- 659138 - extend schedule creation error handling (tlestach@redhat.com)
- 659138 - do not forward parameter map in case of success
  (tlestach@redhat.com)
- 706399 - "<" is not the best thing in xml (tlestach@redhat.com)

* Fri May 20 2011 Jan Pazdziora 1.5.33-1
- 706399 - replacing rhnServerNeededView with custom subselect

* Thu May 19 2011 Tomas Lestach <tlestach@redhat.com> 1.5.32-1
- 659138 - fix Custom Quartz format error handling (tlestach@redhat.com)
- 659138 - fix repeat-task-picker input tag (tlestach@redhat.com)

* Wed May 18 2011 Tomas Lestach <tlestach@redhat.com> 1.5.31-1
- 659138 - fix message on the schedule create page (tlestach@redhat.com)

* Tue May 17 2011 Tomas Lestach <tlestach@redhat.com> 1.5.30-1
- 643905 - make sure hibernate doesn't use cached kickstart trees, but takes
  actual DB state (tlestach@redhat.com)

* Mon May 16 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.29-1
- 704446 - removed unnecessary cast to string
- fixed SQL typo

* Fri May 13 2011 Jan Pazdziora 1.5.28-1
- introduce NoSuchConfigFilePathException for configchannel and server.config
  APIs (tlestach@redhat.com)
- 703143 - changed (+) to ANSI JOIN (michael.mraka@redhat.com)
- 678721 - errata.cloneAsOriginal API call (mzazrivec@redhat.com)

* Wed May 11 2011 Tomas Lestach <tlestach@redhat.com> 1.5.27-1
- 659138 - change jsp rendering when taskomatic is down (tlestach@redhat.com)
- 659138 - skip code, if taskomatic is down (tlestach@redhat.com)
- 659138 - fix emptykey message (tlestach@redhat.com)

* Tue May 10 2011 Tomas Lestach <tlestach@redhat.com> 1.5.26-1
- repo generation quick fix (tlestach@redhat.com)

* Tue May 10 2011 Jan Pazdziora 1.5.25-1
- 678519 - moving MOTD into a separate kickstart snippent
  (mario@mediatronix.de)

* Tue May 10 2011 Jan Pazdziora 1.5.24-1
- 638571 - set correctly the Channels column (tlestach@redhat.com)
- 636614 - mark system_groups of org.listOrgs API as optional
  (tlestach@redhat.com)
- 636614 - fix system_groups for org.listOrgs API (tlestach@redhat.com)
- 703064 - changing WebUI message (tlestach@redhat.com)
- 659138 - fix button submit detection (tlestach@redhat.com)
- 659138 - schedule description strings update (tlestach@redhat.com)

* Mon May 09 2011 Tomas Lestach <tlestach@redhat.com> 1.5.23-1
- 659138 - change runs ordering (tlestach@redhat.com)
- 659138 - first schedule, then display (tlestach@redhat.com)
- 659138 - update single run action message (tlestach@redhat.com)
- 659138 - display times in current timezone (tlestach@redhat.com)
- 659138 - fix scheduling of single runs for specific time
  (tlestach@redhat.com)
- 659138 - reinit for possible single task schedules (tlestach@redhat.com)

* Fri May 06 2011 Jan Pazdziora 1.5.22-1
- 673392 - correct entitlement count logic for custom channels
  (mzazrivec@redhat.com)

* Thu May 05 2011 Tomas Lestach <tlestach@redhat.com> 1.5.21-1
- 659138 - fix ordering of runs (tlestach@redhat.com)
- introduce taskomatic reinit schedules (tlestach@redhat.com)

* Wed May 04 2011 Tomas Lestach <tlestach@redhat.com> 1.5.20-1
- 648640 - keep fineGrained option when changing number of custom items
  (tlestach@redhat.com)
- 648640 - introduce errata analyzer for rhn-search (tlestach@redhat.com)

* Wed May 04 2011 Miroslav Suchý 1.5.19-1
- sort inputs on the page
- 683200 - encode hostname to IDN in MonitoringConfig.do page

* Tue May 03 2011 Miroslav Suchý 1.5.18-1
- 682112 - correct displayed systems consuming channel entitlements
- 683200 - encode hostname to IDN in GeneralConfig.do page
- 683200 - encode hostname to IDN in BootstrapConfig.do page
- 683200 - encode hostname to IDN in systems/Search.do page
- 683200 - encode hostname to IDN in DuplicateHostName.do page

* Tue May 03 2011 Miroslav Suchý 1.5.17-1
- checkstyle - Line has trailing spaces (msuchy@redhat.com)

* Tue May 03 2011 Miroslav Suchý 1.5.16-1
- 673392 - alter channel subscriptions: display flex consumption

* Mon May 02 2011 Tomas Lestach <tlestach@redhat.com> 1.5.15-1
- removing unused imports (tlestach@redhat.com)

* Mon May 02 2011 Tomas Lestach <tlestach@redhat.com> 1.5.14-1
- 659138 - set start time for skipped queue jobs (tlestach@redhat.com)
- 659138 - style id support for repeat-task-picker (tlestach@redhat.com)
- 659138 - introduce WebUI interface for taskomatic schedule management
  (tlestach@redhat.com)

* Sat Apr 30 2011 Simon Lukasik <slukasik@redhat.com> 1.5.13-1
- Remove the static comps file mapping for RHEL 5.0 trees (slukasik@redhat.com)

* Fri Apr 29 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.5.12-1
- remove unused imports

* Fri Apr 29 2011 Jan Pazdziora 1.5.11-1
- 683539 - system overview: display flex entitlement usage
  (mzazrivec@redhat.com)

* Thu Apr 28 2011 Jan Pazdziora 1.5.10-1
- 680176 - display unlimited subscriptions if applicable (mzazrivec@redhat.com)
- 699753 - use the primary IP address from the rhnServerNetwork table
  (tlestach@redhat.com)

* Mon Apr 25 2011 Jan Pazdziora 1.5.9-1
- 679009 - fixing the regular expression.

* Wed Apr 20 2011 Jan Pazdziora 1.5.8-1
- checkstyle fixes.

* Wed Apr 20 2011 Jan Pazdziora 1.5.7-1
- * added support for SUSE autoinstallation (kickstarts) and some cleanup
  (ug@suse.de)

* Mon Apr 18 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.6-1
- postgresql can't order by column alias (PG)
- don't convert ids to strings
- fixing ErrataSearchActionTest.testExecute test
- fixing EditActionTest.testUpdateErrata test

* Fri Apr 15 2011 Jan Pazdziora 1.5.5-1
- generate weak-deps into primary.xml (mc@suse.de)
- A bunch of fixes in pt_BR translation. (mmello@redhat.com)

* Thu Apr 14 2011 Tomas Lestach <tlestach@redhat.com> 1.5.4-1
- fixing ErrataManagerTest.testCreate (tlestach@redhat.com)
- fixing ErrataSearchActionTest.testExecute (tlestach@redhat.com)
- fixing EditActionTest.testUpdateErrata (tlestach@redhat.com)
- adding jakarta-commons-io Require (tlestach@redhat.com)
- adding jakarta-commons-fileupload Require from spacewalk-java
  (tlestach@redhat.com)

* Thu Apr 14 2011 Tomas Lestach <tlestach@redhat.com> 1.5.3-1
- adding jakarta-commons-fileupload Require (tlestach@redhat.com)

* Wed Apr 13 2011 Tomas Lestach <tlestach@redhat.com> 1.5.2-1
- 644700 - do not return text file contents in case it contains xml invalid
  chars (tlestach@redhat.com)

* Wed Apr 13 2011 Jan Pazdziora 1.5.1-1
- 648640 - introduce fine grained search (tlestach@redhat.com)

* Fri Apr 08 2011 Jan Pazdziora 1.4.35-1
- errata_from and bug url added to errata pages (ug@suse.de)

* Fri Apr 08 2011 Jan Pazdziora 1.4.34-1
- 679009 - replace tab by spaces (tlestach@redhat.com)

* Fri Apr 08 2011 Miroslav Suchý 1.4.33-1
- 679009 - fixing checkstyle issue (line length) with the previous commit.
  (jpazdziora@redhat.com)
- 679009 - update noSSLServerURL option as well, for RHEL 3 and 4.
  (jpazdziora@redhat.com)

* Thu Apr 07 2011 Jan Pazdziora 1.4.32-1
- 694393 - provide original channel for cloned channels in
  channel.software.getDatails API (tlestach@redhat.com)

* Thu Apr 07 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.31-1
- 688509 - generate errata cache when cloning channel via API
- fixed javax.servlet.ServletException: Cannot specify "styleId"

* Thu Apr 07 2011 Jan Pazdziora 1.4.30-1
- Removing packages.verifyAll capability; it was never used. (slukasik@redhat.com)
- The nvl2 is not supported by PostgreSQL, replacing by case when in
  non_managed_elaborator.
- 693994 - correct bogus Franch translation (msuchy@redhat.com)
- Merge branch 'master' into rhn-client-tools-deb2 (slukasik@redhat.com)
- Removing packages.verifyAll capability; it was never used.
  (slukasik@redhat.com)

* Wed Apr 06 2011 Jan Pazdziora 1.4.29-1
- 693889 - fix the update status icon not displayed in Chrome browser
  (mmello@redhat.com)
- SELECT UNIQUE is not supported by PostgreSQL, fixing.

* Mon Apr 04 2011 Miroslav Suchý 1.4.28-1
- when hostname is unknown print "unknown"
- 683200 - IDN.toUnicode does not allow null value

* Mon Apr 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.27-1
- fixed queries on Virtual system Overview page
- correct form property
- Fix to remove message on entitlement consumption for virt guest subscribed to
  cloned channels

* Fri Apr 01 2011 Jan Pazdziora 1.4.26-1
- 627791 - extending child channel selection area (tlestach@redhat.com)
- Do not show success message when passwords don't match (jrenner@suse.de)

* Thu Mar 31 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.25-1
- replaced check_probe synonym with original table

* Wed Mar 30 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.24-1
- jakarta-commons-io is unused once jakarta-commons-fileupload is gone

* Wed Mar 30 2011 Miroslav Suchý 1.4.23-1
- 683200 - convert IDN hostname in webUI from Pune encoding

* Wed Mar 30 2011 Jan Pazdziora 1.4.22-1
- 664715 - catch exception, if no data found (tlestach@redhat.com)
- hibernate 3.3 needs provider_class to be set (michael.mraka@redhat.com)
- fix ChannelEditorTest.testAddRemovePackages test (tlestach@redhat.com)
- 690767 - check that the result has some elements.
- correct input attribute (mzazrivec@redhat.com)

* Thu Mar 24 2011 Jan Pazdziora 1.4.21-1
- automatically set focus on filter input field (msuchy@redhat.com)
- implement common access keys (msuchy@redhat.com)

* Wed Mar 23 2011 Tomas Lestach <tlestach@redhat.com> 1.4.20-1
- make sure we work with long ids when removing packages (tlestach@redhat.com)

* Tue Mar 22 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.19-1
- no class from commons-fileupload is used
- notice also non-existing packages when adding them to a channel

* Wed Mar 16 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.18-1
- 644880 - fix the condition (tlestach@redhat.com)

* Fri Mar 11 2011 Tomas Lestach <tlestach@redhat.com> 1.4.17-1
- 644880 - fix Long comparism (tlestach@redhat.com)
- 644880 - fix permission check to packages (tlestach@redhat.com)
- Casting compare in rhn_probe to string. (jpazdziora@redhat.com)
- Adding the AS keyword to column aliases (for PostgreSQL).
  (jpazdziora@redhat.com)

* Thu Mar 10 2011 Tomas Lestach <tlestach@redhat.com> 1.4.16-1
- 644880 - speed up channel.software.addPackages API (tlestach@redhat.com)
- Subquery in FROM must have an alias in PostgreSQL. (jpazdziora@redhat.com)
- reprovisioning should not fail completely if python modules are missing
  (michael.mraka@redhat.com)

* Mon Mar 07 2011 Jan Pazdziora 1.4.15-1
- 682258 - fix unit test (mzazrivec@redhat.com)
- 682258 - removed unused imports (mzazrivec@redhat.com)
- 682258 - createDisplayMap should be private (mzazrivec@redhat.com)
- 682258 - java docs (mzazrivec@redhat.com)
- 682258 - removed unused imports (mzazrivec@redhat.com)
- 682258 - removed unused imports (mzazrivec@redhat.com)
- 682258 - specify user locale when creating new user (mzazrivec@redhat.com)
- Fixed pt_BR translations issues at Kickstart Create. (mmello@redhat.com)
- fixing previous typo in all StringResource files (tlestach@redhat.com)
- fixed typo in kickstart.script.summary and post.jsp.summary
  (tlestach@redhat.com)
- Fixed some pt_BR translations issues (mmello@redhat.com)

* Wed Mar 02 2011 Tomas Lestach <tlestach@redhat.com> 1.4.14-1
- 639134 - consider also package arch when searching systems according to a
  package (tlestach@redhat.com)
- 640958 - fixing NullPointerException (tlestach@redhat.com)
- do not show delete link on creation of notes (bnc#672090) (jrenner@suse.de)

* Mon Feb 28 2011 Jan Pazdziora 1.4.13-1
- No need to convert numeric values to upper.
- Fixing affected_by_errata for PostgreSQL.

* Mon Feb 28 2011 Jan Pazdziora 1.4.12-1
- For PostgreSQL and setAlreadyCloned, we need to accept also Integer and cast
  it to Long.
- Small fix on pt_BR translations (mmello@redhat.com)

* Fri Feb 25 2011 Jan Pazdziora 1.4.11-1
- Fix SSM buttons translation. (jfenal@redhat.com)
- 680375 - we do not want the locked status (icon) to hide the the other
  statuses, we add separate padlock icon.
- The /network/systems/details/hardware.pxt was replaced by
  /rhn/systems/details/SystemHardware.do.
- We want to show the bios information if it is *not* empty.
- 673394 - correct entitlement logic when altering channel subscriptions
  (mzazrivec@redhat.com)

* Thu Feb 24 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.10-1
- always generate new session after login
- set timeout after unsuccessful login

* Wed Feb 23 2011 Tomas Lestach <tlestach@redhat.com> 1.4.9-1
- 679374 - clone also "Don't install @Base package group" and "Ignore missing
  packages" kickstart profile atributes (tlestach@redhat.com)
- remove dead code (tlestach@redhat.com)
- replace servletapi5 require by tomcatX-servlet-2.X-api (tlestach@redhat.com)

* Tue Feb 22 2011 Tomas Lestach <tlestach@redhat.com> 1.4.8-1
- replace jasper5 with tomcat6-lib for tomcat6 (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- selectedChannel is always null at this place (tlestach@redhat.com)
- fix CreateCommandTest.testVerifyChannelName test (tlestach@redhat.com)
- fix SystemHandlerTest.testGetSubscribedBaseChannel test (tlestach@redhat.com)

* Mon Feb 21 2011 Jan Pazdziora 1.4.7-1
- Typo in the log message (luc@delouw.ch)
- fix testGetSubscribedBaseChannel test (tlestach@redhat.com)
- 658533 - enable sorting according all the columns except of score on
  SystemCurrency.do page (tlestach@redhat.com)
- 657548 - do not allow channel names to begin with a digit
  (tlestach@redhat.com)

* Fri Feb 18 2011 Jan Pazdziora 1.4.6-1
- Check upon build time that we did not get the @@PRODUCT_NAME@@ template
  translated.
- 678583 - The @@PRODUCT_NAME@@ template must not be translated (pt_BR, ja).
- 652788 - do not return null via xmlrpc, if a system has no base channel
  (tlestach@redhat.com)

* Thu Feb 17 2011 Tomas Lestach <tlestach@redhat.com> 1.4.5-1
- remove ehcache from java/ivy.xml (tlestach@redhat.com)
- remove ehcache from java/buildconf/build-props.xml (tlestach@redhat.com)
- removing ehcache buildrequire (tlestach@redhat.com)
- 601524 updating kickstart.profile.setAdvancedOptions apidoc
  (tlestach@redhat.com)
- 601524 - fixing allowed kickstart advanced options (pmutha@redhat.com)
- 669167 - add apidoc for activationkey.setDetails parameters
  (tlestach@redhat.com)
- Extend the copyright year to 2011. (jpazdziora@redhat.com)

* Fri Feb 11 2011 Tomas Lestach <tlestach@redhat.com> 1.4.4-1
- 645391 - fixing improper actions, when adding virtualization entitlement to
  the activation key (tlestach@redhat.com)
- 676581 - navigate to a different jsp, when logging in with a wrong
  username/password (cherry picked from commit
  0405f53a84f2acc9b1dd5d189706e689f2f45809) (tlestach@redhat.com)

* Thu Feb 10 2011 Tomas Lestach <tlestach@redhat.com> 1.4.3-1
- let spacewalk-java require msv-workaround on RHEL6 (tlestach@redhat.com)

* Wed Feb 09 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.2-1
- fix outer join syntax in Channel.accessibleChildChannelIds

* Mon Feb 07 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.1-1
- fixed javax.servlet.ServletException: Cannot specify "styleId" when in XHTML
  mode as the HTML "id" attribute is already used to store the bean name
- Fixing type (removing extra comma, left there by

* Thu Jan 27 2011 Tomas Lestach <tlestach@redhat.com> 1.3.52-1
- Password with less than minlength characters accepted (jrenner@suse.de)

* Thu Jan 27 2011 Tomas Lestach <tlestach@redhat.com> 1.3.51-1
- Revert "671450 - do not set null for maxFlex and maxMembers ChannelOverview
  attributes" (tlestach@redhat.com)

* Thu Jan 27 2011 Tomas Lestach <tlestach@redhat.com> 1.3.50-1
- removing remains of RhnDaemonState table (tlestach@redhat.com)
- Improving spelling script and adding few ignore words (lzap+git@redhat.com)
- Automatic detection of tomcat Ant property (lzap+git@redhat.com)
- 671450 - do not set null for maxFlex and maxMembers ChannelOverview
  attributes (tlestach@redhat.com)

* Wed Jan 26 2011 Tomas Lestach <tlestach@redhat.com> 1.3.49-1
- 460356 - time not needed on errata search (tlestach@redhat.com)
- fixed channel list in create kickstart profile (PG)
  (michael.mraka@redhat.com)

* Fri Jan 21 2011 Tomas Lestach <tlestach@redhat.com> 1.3.48-1
- fixing ISE when deleting software channel from the
  rhn/channels/manage/Repositories.do page (tlestach@redhat.com)
- unschedule eventual repo sync schedules, when deleting channel
  (tlestach@redhat.com)

* Wed Jan 12 2011 Tomas Lestach <tlestach@redhat.com> 1.3.47-1
- asm requires different handling on fedoras and rhels (tlestach@redhat.com)
- replace jakarta-commons-logging with apache-commons-logging on F14
  (tlestach@redhat.com)

* Wed Jan 12 2011 Lukas Zapletal 1.3.46-1
- Using objectweb-asm symlink on Fedoras
- 522251 - no post_install_network_config snippet on s390(x)

* Tue Jan 11 2011 Tomas Lestach <tlestach@redhat.com> 1.3.45-1
- change taskomatic library path to use oracle-instantclient11.x
  (tlestach@redhat.com)
- removing spacewalk-asm.jar symlink (tlestach@redhat.com)

* Tue Jan 11 2011 Lukas Zapletal 1.3.44-1
- Removed unnecessary require in spw-java

* Mon Jan 10 2011 Tomas Lestach <tlestach@redhat.com> 1.3.43-1
- 668539 - make possible to clone Red Hat errata even if you specify the
  "Channel Version" (tlestach@redhat.com)
- 663403 - correctly escape updateinfo.xml (tlestach@redhat.com)

* Mon Jan 10 2011 Lukas Zapletal 1.3.42-1
- Solving asm CNF exception in Hudson

* Sat Jan 08 2011 Lukas Zapletal 1.3.41-1
- Correcting symlink for Fedoras (jfreechart)

* Sat Jan 08 2011 Lukas Zapletal 1.3.40-1
- Adding missing struts-taglib require into the spec file and asm/jfreechart

* Fri Jan 07 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.39-1
- do not cast to string, when db expect number (msuchy@redhat.com)

* Fri Jan 07 2011 Lukas Zapletal 1.3.38-1
- Building spacewalk-java.spec on RHEL6

* Thu Jan 06 2011 Tomas Lestach <tlestach@redhat.com> 1.3.37-1
- 628755 - fix searching for the primary network interface
  (tlestach@redhat.com)
- remove MigrationManagerTest.testRemoveVirtualGuestAssociations test
  (tlestach@redhat.com)

* Thu Jan 06 2011 Tomas Lestach <tlestach@redhat.com> 1.3.36-1
- removing unused import (tlestach@redhat.com)

* Wed Jan 05 2011 Tomas Lestach <tlestach@redhat.com> 1.3.35-1
- 663490 - identify, when package is too large to download via API
  (tlestach@redhat.com)
- temporary allow 2010 and 2011 headers (tlestach@redhat.com)
- 667432 - don't untie host from guests during host migration
  (mzazrivec@redhat.com)
- 661212 - setting probe suite name for ProbeSuiteListProbes.do
  (tlestach@redhat.com)

* Mon Jan 03 2011 Jan Pazdziora 1.3.34-1
- display also error parameters when throwing InvalidKickstartTreeException
  (tlestach@redhat.com)
- Correct the Filename tag in Packages.gz (slukasik@redhat.com)

* Thu Dec 23 2010 Aron Parsons <aparsons@redhat.com> 1.3.33-1
- add package ID to array returned by system.listPackages API call

* Wed Dec 22 2010 Tomas Lestach <tlestach@redhat.com> 1.3.32-1
- 640928 - convert List<Integer> serverIds to List<Long> (tlestach@redhat.com)

* Tue Dec 21 2010 Jan Pazdziora 1.3.31-1
- Rewrite remove_unowned_errata and remove_nonrhn_unowned_errata not to use
  rowid.
- No need to subselect from dual.
- 642926 - offer correct Channel and Channel Version for child channel errata
  listings (tlestach@redhat.com)
- 664717 - removing unused ks install type translations (tlestach@redhat.com)
- 664717 - adding RHEL6 dist channel map translations (tlestach@redhat.com)

* Mon Dec 20 2010 Tomas Lestach <tlestach@redhat.com> 1.3.30-1
- 662981 - change warnings to errors, if required channels not found when
  adding virt entitlement (tlestach@redhat.com)
- 662981 - fix ISE, when adding virt entitlement and current org has no access
  to the VT channel (tlestach@redhat.com)

* Mon Dec 20 2010 Tomas Lestach <tlestach@redhat.com> 1.3.29-1
- 640958 - do not zero (non)flex entitlements, when updating the others
  (tlestach@redhat.com)

* Thu Dec 16 2010 Aron Parsons <aparsons@redhat.com> 1.3.28-1
- fix testSystemSearch JUnit test (aparsons@redhat.com)

* Tue Dec 14 2010 Jan Pazdziora 1.3.27-1
- Checkstyle: bumping up the max method length to 180 lines.
- checkstyle fix (aparsons@redhat.com)
- 661263 - fixing issue where private channels in one org could be seen by
  other orgs.  Please note that this only fixes newly created orgs, existing
  orgs with the problem will continue to experience it (jsherril@redhat.com)

* Fri Dec 10 2010 Aron Parsons <aparsons@redhat.com> 1.3.26-1
- added API call system.getUuid (aparsons@redhat.com)
- added API call system.search.uuid (aparsons@redhat.com)
- add support for searching by system UUID to the web interface
  (aparsons@redhat.com)
- add support for searching for systems by UUID (aparsons@redhat.com)

* Fri Dec 10 2010 Tomas Lestach <tlestach@redhat.com> 1.3.25-1
- add tomcat require for spacewalk-java-oracle and -postgres
  (tlestach@redhat.com)

* Thu Dec 09 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.24-1
- 646488 - fixed systemGroups.jsp according to new query
- removed unused code
- removed unused overview query

* Wed Dec 08 2010 Tomas Lestach <tlestach@redhat.com> 1.3.23-1
- change default owner:group of ojdbc14.jar and postgresql-jdbc.jar
  (tlestach@redhat.com)

* Wed Dec 08 2010 Lukas Zapletal 1.3.22-1
- Revert "spacewalk-java.spec change - jasper was merged into tomcat-lib"

* Tue Dec 07 2010 Tomas Lestach <tlestach@redhat.com> 1.3.21-1
- adding cleanup-packagechangelog-data translation key (tlestach@redhat.com)
- add example of usage of DateTime in python API scripts (msuchy@redhat.com)

* Tue Dec 07 2010 Lukas Zapletal 1.3.20-1
- 642988 - ISE when setting Software Channel Entitlements

* Mon Dec 06 2010 Tomas Lestach <tlestach@redhat.com> 1.3.19-1
- 581832 - return correct package info according to the comparism result
  (tlestach@redhat.com)
- 658653 - fixing dupliclates from showing up on eligible flex guests page
  (jsherril@redhat.com)
- 620578 - just fix the exception handling (tlestach@redhat.com)
- 620578 - introduce errata.publishAccordingToParents API (tlestach@redhat.com)
- fixing VirtualizationEntitlementsManagerTest.testConvertToFlex
  (tlestach@redhat.com)
- spacewalk-java.spec change - jasper was merged into tomcat-lib
  (lzap+git@redhat.com)
- 659364 - fix syntax error (mzazrivec@redhat.com)
- 659364 - allow files without checksums in the file list
  (mzazrivec@redhat.com)
- 658653 - converting flex entitlement pages under "Virt Entitlements" to use
  the normal list tag instead of the fancy new tree tag,  This enables the page
  to be usable where there are hundreds of children for each channel family
  (jsherril@redhat.com)

* Wed Dec 01 2010 Jan Pazdziora 1.3.18-1
- 658167 - fix cases, when quartz triggers a job earlier, than the job info
  lands in the DB (tlestach@redhat.com)
- 516570 - just unify channel dates format (tlestach@redhat.com)
- comment unused query in Task_queries (tlestach@redhat.com)
- remove dead queries from User_queries (tlestach@redhat.com)
- remove dead queries from test_queries (tlestach@redhat.com)
- remove dead queries from System_queries (tlestach@redhat.com)
- remove dead query from Org_queries (tlestach@redhat.com)
- remove dead queries from General_queries (tlestach@redhat.com)
- remove dead queries from Channel_queries (tlestach@redhat.com)
- remove dead query from Action_queries (tlestach@redhat.com)
- 642285 - remove old TaskStatus related code (tlestach@redhat.com)
- removing unused SetItemSelected action (tlestach@redhat.com)

* Thu Nov 25 2010 Tomas Lestach <tlestach@redhat.com> 1.3.17-1
- 642285 - introducing disabled TaskStatus page (tlestach@redhat.com)

* Thu Nov 25 2010 Lukas Zapletal 1.3.16-1
- Bug 657259 - Enable Spacewalk Configuration Management fails

* Wed Nov 24 2010 Lukas Zapletal 1.3.15-1
- 615026 - [Multi-Org] Grants for channel permission edits throws ISE
- 642226 - do not look for the VT channel in case of RHEL6 base channels
- adding last_modified attribute to the ChannelSerializer

* Tue Nov 23 2010 Lukas Zapletal 1.3.14-1
- 646817 - System health indicator in "Systems" related pages not displayed

* Mon Nov 22 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.13-1
- PE2.evr.as_vre_simple() -> evr_t_as_vre_simple(PE2.evr) (PG)
- removed rowid from query (PG)
- 646401 - setting missing RhnSetDecl

* Mon Nov 22 2010 Lukas Zapletal 1.3.12-1
- Fixing two queries in system overview (monitoring)
- Replacing DECODE with ANSI compatible CASE-WHEN
- Adding missing monitoring state (UNKNOWN)

* Mon Nov 22 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.11-1
- 655519 - PE2.evr.as_vre_simple() -> evr_t_as_vre_simple(PE2.evr) (PG)
- 655515 - changed DECODE to ANSI CASE (PG)
- fixing several issues in system_overview query

* Fri Nov 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.10-1
- fixed wrongly rendered API doc

* Fri Nov 19 2010 Lukas Zapletal 1.3.9-1
- Fixing JOIN in monitoring status query (System_queries.xml)

* Fri Nov 19 2010 Lukas Zapletal 1.3.8-1
- Removing from SQL clause (System_queries) causing bugs in monitoring

* Fri Nov 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.7-1
- fixed outer joins

* Thu Nov 18 2010 Lukas Zapletal 1.3.6-1
- Replacing DECODE function with CASE-SWITCH (multiple times)
- 642599 use redhat_management_server insted of http_server in reactivation
  snippet 

* Thu Nov 18 2010 Tomas Lestach <tlestach@redhat.com> 1.3.5-1
- 654275 - make repo generation faster in the RHN way (tlestach@redhat.com)
- checkstyle fix (tlestach@redhat.com)
- fix CreateProfileWizardTest.testSuccess test (tlestach@redhat.com)
- store null as empty argumets (instead of empty string) (tlestach@redhat.com)
- fix DataSourceParserTest.testNullParam (tlestach@redhat.com)
- check for parameter presence in the CachedStatement (tlestach@redhat.com)

* Tue Nov 16 2010 Lukas Zapletal 1.3.4-1
- Replacing sysdate in SQL INSERT with current_timestamp

* Tue Nov 16 2010 Lukas Zapletal 1.3.3-1
- Adding one jar ignore to spacewalk-java.spec for F14 
- Turning off checkstyle in the java spec for F14 
- Adding requires for F14 in spacewalk-java.spec 

* Tue Nov 16 2010 Lukas Zapletal 1.3.2-1
- No longer distributing jar symlinks with version numbers
- use an existing column name in ORDER BY statements 
- Revert "Implement new API call packages.getPackageIdFromPath"
- Implement new API call packages.getPackageIdFromPath 
- allow setting null value as paramter 
- fix TaskManagerTest.testGetCurrentDBTime test 
- 645694 - introducing cleanup-packagechangelog-data task 

* Mon Nov 15 2010 Tomas Lestach <tlestach@redhat.com> 1.3.1-1
- checkstyle fix (tlestach@redhat.com)
- Bumping package versions for 1.3. (jpazdziora@redhat.com)

* Mon Nov 15 2010 Jan Pazdziora 1.2.111-1
- 653305 - do not access the login information, if the user is null
  (tlestach@redhat.com)

* Sat Nov 13 2010 Tomas Lestach <tlestach@redhat.com> 1.2.110-1
- better call stored functions with correct parameter order
  (tlestach@redhat.com)
- fix daily-summary task(PG) (tlestach@redhat.com)
- comapre chars with chars(PG) (tlestach@redhat.com)
- Restore 'yumrepo_last_sync' (colin.coe@gmail.com)
- Update the ChannelSerializer to show all associated repos
  (colin.coe@gmail.com)
- removing old changelog hibernate stuff that no longer works now that things
  are stored differently (jsherril@redhat.com)

* Fri Nov 12 2010 Lukas Zapletal 1.2.109-1
- Deletion from base table and not from view (PG)

* Fri Nov 12 2010 Tomas Lestach <tlestach@redhat.com> 1.2.108-1
- replace the rest of (+)s in config_queries.xml (tlestach@redhat.com)
- replace the rest of NVL functions in config_queries.xml (tlestach@redhat.com)
- enable comparism of sandbox other files(PG) (tlestach@redhat.com)
- enable config file deployment(PG) (tlestach@redhat.com)
- enable config target systems page (tlestach@redhat.com)
- enable config subscribed systems page (tlestach@redhat.com)
- enable deply file page(PG) (tlestach@redhat.com)
- enable "Manage Revisions" page (tlestach@redhat.com)
- store NULL if selinuxCtx is empty (tlestach@redhat.com)
- enable listing of config managed systems(PG) (tlestach@redhat.com)
- list centrally managed congif files(PG) (tlestach@redhat.com)
- enable listing of config files(PG) (tlestach@redhat.com)
- enable upload of config files(PG) (tlestach@redhat.com)
- do not set null value of type Types.VARCHAR for prepared statements
  (tlestach@redhat.com)
- enable (un)subscription to config channels via SSM(PG) (tlestach@redhat.com)
- replacing another MINUS by OUTER JOIN(PG) (tlestach@redhat.com)
- replacing NVL by COALESCE(PG) (tlestach@redhat.com)
- rewriting MINUS to OUTER JOIN(PG) (tlestach@redhat.com)
- enable creation of config channels(PG) (tlestach@redhat.com)

* Fri Nov 12 2010 Lukas Zapletal 1.2.107-1
- Revert "Removing commons-discovery jar from spacewalk-java.spec"
- Add missing file from previous commit 
- Implement getRepoDetails API calls 
- Correct the xmlrpc.doc 
- 647806 - Implement API calls for external repos 
- 652626 - correct typo in named query 

* Fri Nov 12 2010 Lukas Zapletal 1.2.106-1
- Removing jasper5-compiler jar from spacewalk-java.spec 
- Removing commons-discovery jar from spacewalk-java.spec 

* Fri Nov 12 2010 Lukas Zapletal 1.2.105-1
- Adding missing jakarta-commons-discovery require for RHEL6+/FC13+

* Thu Nov 11 2010 Lukas Zapletal 1.2.104-1
- Removing extra slash after RPM_BUILD_ROOT 
- We do not distribute jspapi.jar now - according to Servlet Spec 2.3
- Add missing ssm.migrate.systems.notrust to StringResource
- Implement channel.software.listUserRepos API call 

* Thu Nov 11 2010 Lukas Zapletal 1.2.103-1
- Replacing one more NVL with COALESCE function 
- Replacing NVL with COALESCE function 

* Thu Nov 11 2010 Lukas Zapletal 1.2.102-1
- Correcting one more ANSI JOIN syntax in channel queries (PG)
- Correcting ANSI JOIN syntax in channel queries 
- Correcting spaces in channel queries xml file 
- Making two server group portable 
- Correcting NULL values in channel manager repo gen 

* Thu Nov 11 2010 Lukas Zapletal 1.2.101-1
- Correcting spacewalk-java.spec - removing doubled files

* Thu Nov 11 2010 Lukas Zapletal 1.2.100-1
- Correcting spacewalk-java.spec - JDBC driver links

* Wed Nov 10 2010 Lukas Zapletal 1.2.99-1
- Fixing table aliases for DISTINCT queries (PG)

* Wed Nov 10 2010 Tomas Lestach <tlestach@redhat.com> 1.2.98-1
- updating alias to match the dto object attribute (tlestach@redhat.com)
- setting an alias for subquery(PG) (tlestach@redhat.com)
- enable SSM Package upgrade process(PG) (tlestach@redhat.com)
- fix OUTER JOIN from recent commit (tlestach@redhat.com)
- fix OUTER JOIN from recent commit (tlestach@redhat.com)
- fix OUTER JOIN from recent commit (tlestach@redhat.com)
- fixing queries, where rhnServer was unexpectedly joined to the query
  (tlestach@redhat.com)
- fixing broken queries (due to ORDER BY statements) (tlestach@redhat.com)
- setting action name for package verification (tlestach@redhat.com)

* Wed Nov 10 2010 Lukas Zapletal 1.2.97-1
- Correcting spec for spacewalk-java (JAR symlinks)

* Tue Nov 09 2010 Tomas Lestach <tlestach@redhat.com> 1.2.96-1
- enable SSM Package remove process(PG) (tlestach@redhat.com)
- enable SSM Package install process(PG) (tlestach@redhat.com)
- enable SSM Package upgrade page(PG) (tlestach@redhat.com)
- enable SSM Package remove page(PG) (tlestach@redhat.com)
- enable SSM Package install page(PG) (tlestach@redhat.com)
- enable Virtual Systems page(PG) (tlestach@redhat.com)

* Mon Nov 08 2010 Tomas Lestach <tlestach@redhat.com> 1.2.95-1
- fix creating of groups(PG) (tlestach@redhat.com)
- do not pass string params, when numeric are expected(PG)
  (tlestach@redhat.com)
- reduced logging of RpmRepositoryWriter (tlestach@redhat.com)
- create setters with byte[] param(PG) for repo generation code
  (tlestach@redhat.com)
- updating logging of ChannelRepodataWorker (tlestach@redhat.com)
- updated logging of ChannelRepodataDriver (tlestach@redhat.com)
- adding extra logging to KickstartFileSyncTask (tlestach@redhat.com)
- removing unused code from KickstartFileSyncTask (tlestach@redhat.com)

* Fri Nov 05 2010 Tomas Lestach <tlestach@redhat.com> 1.2.94-1
- removing insert of NULL value(PG) (tlestach@redhat.com)

* Fri Nov 05 2010 Lukas Zapletal 1.2.93-1
- Two config queries are ported to PostgreSQL 
- rewriting INSERT ALL in insert_channel_packages_in_set (PG)

* Thu Nov 04 2010 Lukas Zapletal 1.2.92-1
- Replacing 4 occurances of NVL with ANSI COALESCE 
- 645842 - return macro delims for config files 

* Thu Nov 04 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.91-1
- fixing build errors (msuchy@redhat.com)

* Thu Nov 04 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.90-1
- fixing build errors (msuchy@redhat.com)

* Wed Nov 03 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.89-1
- 647099 - add API call isMonitoringEnabledBySystemId (msuchy@redhat.com)

* Wed Nov 03 2010 Tomas Lestach <tlestach@redhat.com> 1.2.88-1
- 649319 - enable upload of binary files (tlestach@redhat.com)
- removing dead code (tlestach@redhat.com)
- use public static string instead of directly calling query name
  (tlestach@redhat.com)
- migrating change log to java, and making it use the rpm itself instead of the
  database (jsherril@redhat.com)

* Wed Nov 03 2010 Lukas Zapletal 1.2.87-1
- Using general nextval function in ssm operation queries 
- fixing some fedora 14 provisioning issues 

* Tue Nov 02 2010 Lukas Zapletal 1.2.86-1
- Removing unnecessary JSPF fragment file 

* Tue Nov 02 2010 Lukas Zapletal 1.2.85-1
- Fixing unambiguous column 'name' for PostgreSQL 
- 645829 - make it possile to update macro delimiters 
- 645829 - do not trim curly brackets in macro delimiters 
- removing unnecessary condition 

* Tue Nov 02 2010 Lukas Zapletal 1.2.84-1
- Changing the way how taskomatic connects to PostgreSQL db
- Replacing some constants with ConfigDefaults in java codebase

* Tue Nov 02 2010 Jan Pazdziora 1.2.83-1
- Typo in a java resource (lzap+git@redhat.com)
- Spelling java resource script correction + retab (lzap+git@redhat.com)
- ErrataMailer improvements (tlestach@redhat.com)
- bumping API version to identify new API call availability
  (tlestach@redhat.com)

* Tue Nov 02 2010 Lukas Zapletal 1.2.82-1
- Renaming two ignored unit tests properly 
- Removing unused methods from java db manager 
- Removing unused class from java db manager 
- Removing unused class - Worker 
- Removing dead code in two tests 
- Fixing table name aliases 
- Two classes were not serializabled while putting them into HttpSession
- Fixing date diff in alerts 
- making kickstart channel list sorted alphabetically 
- sorting activation key base channel drop down by alphabetical order
- 648470 - changing manage package page to sort channels by name
- 644880 - check for arch compatibility when adding packages into a channel
- 647099 - introducing satellite.isMonitoringEnabled API 
- replace web.is_monitoring_backend with
  ConfigDefaults.WEB_IS_MONITORING_BACKEND 
- fixing ISE on package deletion due to RHNSAT.RHN_PFDQUEUE_PATH_UQ violation

* Mon Nov 01 2010 Tomas Lestach <tlestach@redhat.com> 1.2.81-1
- updating logging of SessionCleanup task (tlestach@redhat.com)
- checkstyle fix (tlestach@redhat.com)

* Mon Nov 01 2010 Tomas Lestach <tlestach@redhat.com> 1.2.80-1
- adding new TimeSeriesCleanUp taskomatic task (tlestach@redhat.com)
- Fixing system_available_packages -- the order by got lost in previous
  commits, and the name_upper is still there. (jpazdziora@redhat.com)

* Mon Nov 01 2010 Tomas Lestach <tlestach@redhat.com> 1.2.79-1
- 645702 - remove rhnPaidErrataTempCache temporary table (tlestach@redhat.com)

* Fri Oct 29 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.78-1
- removing unused imports

* Fri Oct 29 2010 Jan Pazdziora 1.2.77-1
- removed unused Spacewalk (Certificate Signing Key) <jmrodri@nc.rr.com> key
  from keyring (michael.mraka@redhat.com)
- Operations on rhnSatelliteChannelFamily are not longer called, removing the
  queries.
- Method deactivateSatellite not used (presumably hosted only), removing.
- Queries channel_download_categories_by_type and
  satellite_channel_download_categories_by_type not used after previous
  removal, removing.
- ISOCategory not referenced, removing.
- The listDownloadCategories is not used, removing.

* Fri Oct 29 2010 Lukas Zapletal 1.2.76-1
- Making DISTINCT-ORDER BY package/system queries portable
- Removing unnecessary subselect 
- Simplifying ORDER BY clauses in package queries 
- Revert "Reverting "Removed unnecessary ORDER BY" commits and fixing"
  

* Wed Oct 27 2010 Shannon Hughes <shughes@redhat.com> 1.2.75-1
- fix for checkstyle (shughes@redhat.com)

* Wed Oct 27 2010 Lukas Zapletal 1.2.74-1
- Fixing missing brace in Taskomatic query 
- Addressing issue in system overview 
- PostgreSQL needs FROM keyword in DELETE 
- Adding missing interval keyword to Taskomatic 
- Protocol config value is now used in Taskomatic 
- Getting taskomatic working on PostgreSQL 
- removing unneeded insmod on kickstart %pre script, since they are already
  loaded 
- fixing query to run correctly, c.id was not valid because the join did not
  come directly after rhnChannel c 
- adding missing import 
- 646892 - fixing issue where kickstart expiration would occur after current
  date and not scheduled date of kickstart 
- removing need of setNvreUpper method in PackageOverview 
- fixing broken if statement in snippet 
- fixing broken query used by SSM System delete 

* Mon Oct 25 2010 Lukas Zapletal 1.2.73-1
- Fixing Taskomatic blob handling (now binary)
- Support for PostgreSQL driver in Taskomatic
- Implement API calls for System Currency

* Mon Oct 25 2010 Lukas Zapletal 1.2.72-1
- Addressing subquery in FROM must have an alias issue (fix)
- Sorting fix in packages for PostgreSQL
- Reverting "Removed unnecessary ORDER BY" commits and fixing
- Default cast fix for PostgreSQL
- Use the { call ... } syntax instead of the direct PL/SQL.

* Mon Oct 25 2010 Jan Pazdziora 1.2.71-1
- 639999 - adding %end tags to generated kickstart files if os is fedora or
  RHEL 6 (jsherril@redhat.com)

* Thu Oct 21 2010 Jan Pazdziora 1.2.70-1
- Fix checkstyle errors (colin.coe@gmail.com)

* Thu Oct 21 2010 Lukas Zapletal 1.2.69-1
- Fixed all LEFT OUTER JOINs in Channels 
- Fixed LEFT OUTER JOIN for PostgreSQL in Software Channels
- Removed unnecessary ORDER BY in DISTINCT query. 
- Simplified SQL query with evr_t_as_vre_simple function. 
- Fixed composite type accessing for PostgreSQL for all packages
- Simplified SQL query with evr_t_as_vre_simple function. 
- Fixed composite type accessing for PostgreSQL 
- Sorting fix in packages for PostgreSQL 
- Fix of evr_t_as_vre_simple PostgreSQL function 
- ANSI JOIN syntax fix for PostgreSQL in system update 
- PostgreSQL fix in package search 
- Integer-Long fix in channel subscribers for PostgreSQL 
- Update System Currency to use rhn.cfg file 

* Wed Oct 20 2010 Lukas Zapletal 1.2.68-1
- Rewrite of LEFT OUTER JOIN into ANSI syntax 
- Function evr_t_as_vre_simple in all package queries now general
- Using date time function instead of arithmetics 
- Sysdate replaced with current_timestamp 
- Removed unnecessary ORDER BY in SELECT COUNT
- Use the global function evr_t_as_vre_simple in package_ids_in_set instead of
  method .as_vre_simple; this works on PostgreSQL as well.

* Wed Oct 20 2010 Jan Pazdziora 1.2.67-1
- Delete from rhnPackageChangeLogRec, not from the view.
- Fix ISE in AK child channel page (colin.coe@gmail.com)

* Wed Oct 20 2010 Lukas Zapletal 1.2.66-1
- Removed unnecessary ORDER BY 
- Using date time function instead of arithmetics 
- Added setHasSubscription for Integer 
- Using date time function instead of arithmetics 
- Fix in PostgreSQL (ORDER BY) in Out Of Date system list.
- Fixed comma in ANSI JOIN syntax from previous commit 
- Left join now in ANSI syntax for virtual system list. 
- Fix in PostgreSQL plus NVL fix
- All DECODE functions replaced with CASE-WHEN in System_queries
- Fixing system overview list for PostgreSQL 

* Tue Oct 19 2010 Tomas Lestach <tlestach@redhat.com> 1.2.65-1
- removing unused imports (tlestach@redhat.com)
- 644361 - use cache instead of view for update check (tlestach@redhat.com)
- Port /network/systems/groups/create.pxt, part 2 (colin.coe@gmail.com)
- Port /network/systems/groups/create.pxt (colin.coe@gmail.com)
- Port /network/systems/details/custominfo/new_value.pxt (colin.coe@gmail.com)
- Port /network/systems/details/custominfo/remove_value_conf.pxt
  (colin.coe@gmail.com)
- More checkstyle fixes (colin.coe@gmail.com)
- Fix checkstyle errors (colin.coe@gmail.com)
- Fix missing links (colin.coe@gmail.com)
- Fix /rhn/systems/details/UpdateCustomData.do (colin.coe@gmail.com)
- Port /network/systems/details/custominfo/edit.pxt (colin.coe@gmail.com)
- Fix NPE when lastModifier is null (colin.coe@gmail.com)
- Port /network/systems/details/custominfo/index.pxt (colin.coe@gmail.com)
- Fix page not updating description (colin.coe@gmail.com)
- Checkstyle fixes (colin.coe@gmail.com)
- Port /network/systems/custominfo/edit.pxt (colin.coe@gmail.com)
- 644349 - remove hasProcessedErrata method (tlestach@redhat.com)
- 644349 - extend ErrataMailer logging (tlestach@redhat.com)
- 644349 - do not update/delete all errata entries when the erratum affects
  multiple channels (tlestach@redhat.com)
- 644349 - do not list one system several times in the errata notification
  e-mail (tlestach@redhat.com)

* Tue Oct 19 2010 Lukas Zapletal 1.2.64-1
- Fixing system list for Oracle

* Mon Oct 18 2010 Jan Pazdziora 1.2.63-1
- fixing broken tag

* Mon Oct 18 2010 Lukas Zapletal 1.2.62-1
- DECODE replaced with ANSI compatible CASE WHEN

* Mon Oct 18 2010 Jan Pazdziora 1.2.61-1
- Better exception logging in cached statement (lzap+git@redhat.com)
- System list now working on Postgresql (lzap+git@redhat.com)

* Fri Oct 15 2010 Lukas Zapletal 1.2.60-1
- Checkstyle fixes 
- Checkstyle testing report now part of java spec 
- Removed unused query 
- Made the list tag dataset manipulator handle maps 

* Wed Oct 13 2010 Tomas Lestach <tlestach@redhat.com> 1.2.59-1
- 642519 - associate only unique keywords with an erratum (tlestach@redhat.com)
- 642203- Removed the Task Status page for it needs a serious work over with
  our new configs (paji@redhat.com)

* Tue Oct 12 2010 Tomas Lestach <tlestach@redhat.com> 1.2.58-1
- 630884 - send email notification when errata get synced (tlestach@redhat.com)
- Checkstyle fixes (colin.coe@gmail.com)
- Port /network/systems/custominfo/delete.pxt (colin.coe@gmail.com)
- Port /network/systems/details/delete_confirm.pxt (colin.coe@gmail.com)
- Move the cobbler requirement to version 2.0.0. (jpazdziora@redhat.com)

* Mon Oct 11 2010 Lukas Zapletal 1.2.57-1
- Added Hibernate empty varchar interceptor
- Fixed empty varchars during admin registration

* Fri Oct 08 2010 Jan Pazdziora 1.2.56-1
- PostgreSQL does not like to ORDER BY by something which is not in DISTINCT.
- Since query Channel.findAllBaseChannels was replaced with sql-query, removing
  the query.
- The query visible_to_user_ids-back does not seem to be referenced from
  anywhere, removing.
- Moving the quartz-oracle Requires from spacewalk-taskomatic to spacewalk-
  oracle.
- Replace nvl with coalesce in user_permissions.
- Removing unused import and fixed checkstyle. (slukasik@redhat.com)
- Added missing javadoc (internal class) (lzap+git@redhat.com)

* Thu Oct 07 2010 Jan Pazdziora 1.2.55-1
- Use current_timestamp instead of the Oracle-specific sysdate in
  schedule_pkg_for_delete_from_set.
- PostgreSQL NVL2 function (CASE WHERE) typo fix. (lzap+git@redhat.com)
- Removed unnecessary rhn.jar Ant dependency in a unit test
  (lzap+git@redhat.com)
- Replace Oracle outer join syntax with ANSI syntax for
  Channel.findCustomBaseChannels (lzap+git@redhat.com)
- Need to make the select a subselect, to be able to use the column alias in
  order by.
- Use the global function evr_t_as_vre_simple in package_ids_in_set instead of
  method .as_vre_simple; this works on PostgreSQL as well.

* Thu Oct 07 2010 Tomas Lestach <tlestach@redhat.com> 1.2.54-1
- 640520 - removing default/rhn_taskomatic.conf file (tlestach@redhat.com)

* Thu Oct 07 2010 Lukas Zapletal 1.2.53-1
- 640926 - commons-logging library is now explicitly configured in Jasper2
- PostgreSQL does not have NVL2 function and we have to use CASE WHERE.

* Wed Oct 06 2010 Jan Pazdziora 1.2.52-1
- Use the global function evr_t_as_vre_simple instead of method .as_vre_simple;
  this works on PostgreSQL as well.
- Remove all from cache, not only rpm specific metadata. (slukasik@redhat.com)
- Implement isChannelRepodataStale for debian channels. (slukasik@redhat.com)
- Rpm and Deb metadata creation differs, moving to separate classes.
  (slukasik@redhat.com)

* Wed Oct 06 2010 Tomas Lestach <tlestach@redhat.com> 1.2.51-1
- 640520 - removing old taskomatic static configuration (tlestach@redhat.com)

* Tue Oct 05 2010 Jan Pazdziora 1.2.50-1
- Replace Oracle outer join syntax with ANSI syntax for
  Channel.findAllBaseChannels and Channel.findByIdAndUserId.
- Use current_timestamp instead of the Oracle-specific sysdate in
  request_repo_regen.
- Avoid using rhn_repo_regen_queue_id_seq.nextval Oracle syntax in
  request_repo_regen.
- spacewalk-java.spec now check for spelling errors in build time.
  (lzap+git@redhat.com)

* Mon Oct 04 2010 Justin Sherrill <jsherril@redhat.com> 1.2.49-1
- 639999 - removing management entitlement requirment from a bunch of user
  pages (jsherril@redhat.com)
- 639134 - use proper function when searching package using id
  (tlestach@redhat.com)
- Port /network/account/activation_keys/child_channels.pxt
  (coec@war.coesta.com)
- Create cache directory for both rpm and deb channels. (slukasik@redhat.com)
- Use US spelling of 'organisation' (coec@war.coesta.com)
- Port /network/systems/ssm/system_list.pxt (coec@war.coesta.com)
- SSM System migration (coec@war.coesta.com)
- distinguish spacewalk and satellite email body, when certificate expires
  (tlestach@redhat.com)
- Hardware Refresh - Create only one action (coec@war.coesta.com)
- Package Refresh - Create only one action (coec@war.coesta.com)
- Port SSM Package Refresh Page (coec@war.coesta.com)
- Port /network/systems/ssm/index.pxt (colin.coe@gmail.com)
- Implement schedule.archiveActions (coec@war.coesta.com)

* Thu Sep 30 2010 Lukas Zapletal 1.2.48-1
- jspf pages are now precompiled too
- deleted jpsf that was no longer in use
- known error (628555) is solved by jspf precompilation

* Wed Sep 29 2010 Shannon Hughes <shughes@redhat.com> 1.2.47-1
- fix incorrect adding of trust set for system migrate (shughes@redhat.com)

* Tue Sep 28 2010 Shannon Hughes <shughes@redhat.com> 1.2.46-1
- checkstyle fixes (shughes@redhat.com)
- 636610 alternative set add due to ibm jvm issue (shughes@redhat.com)
- fixing possible ISE where a cobbler system record already exists, but is not
  associated to a system when re-provisioning is initiated
  (jsherril@redhat.com)
- fixing issue where kickstarts woudl not show up for provisioning if the
  distro was created since the last tomcat restart (jsherril@redhat.com)
- adding ext4 support for duplicate systems (jsherril@redhat.com)
- 637696 - fixing issue where kickstart could hang, either because of a rhel
  5.5 kernel panic, or because RHEL 6 does not allow pre-scripts to continue
  running in the background (jsherril@redhat.com)

* Mon Sep 27 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.45-1
- Revert "591291 - added new API calls
  channel.software.mergeErrataWithPackages" (aparsons@redhat.com)
- fixing unit tests (jsherril@redhat.com)
- fixing some strings associated with repo syncing (jsherril@redhat.com)
- 636442 - fixing issue where calling packages.removePackage() api call could
  result in a unique constraint exception (jsherril@redhat.com)
- Fixed mroe checkstyle errors (paji@redhat.com)
- Fixed a checkstyle error (paji@redhat.com)
- 634230 - fixing issue where errata mailer would run continuously and never
  mark the notification queue as being finished (jsherril@redhat.com)
- 636610 - Small fix for the migration jsp bug (paji@redhat.com)
- redundancy is the spice of life, adding back rhnServer to table joins since
  its not so redundant.  Reverts 9f09cf8bb9854c9f8bc6f4e497a49abec3affee2
  (jsherril@redhat.com)
- 629971 - added two county codes, better Localizer error message
  (lzap+git@redhat.com)

* Thu Sep 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.44-1
- fixed erratamailer_fill_work_queue
- resource spelling script and several typo corrections

* Thu Sep 23 2010 Lukas Zapletal 1.2.43-1
- 636740 - asterisks in package search fixed
- 636120 - fixed an ISE in the org.listSystemEntitlements call to deal with null
  Used/Allocated entitlements
- 630877 - XMLRPC Documentation fix
- 634230 - fixing slowness in email sending
- 636587- Fixed a query showing the system counts in the Software Entitleements
  page
- 630585 - about-chat string correction
- 634263 - Fix to allow guests to register across orgs + UI fixes for the
  Virtual systems page

* Tue Sep 21 2010 Aron Parsons <aparsons@redhat.com> 1.2.42-1
- added new API call channel.software.removeErrata (aparsons@redhat.com)
- 591291 - added new API calls channel.software.mergeErrataWithPackages
  (aparsons@redhat.com)
- added a new variation of channel.software.mergeErrata API call that allows
  the user to pass in a list of advisory names (aparsons@redhat.com)
- 630585 - about-chat now points to proper channel (branding)
  (lzap+git@redhat.com)
- 634834 - fixing ISE when putting in invalid day of week (jsherril@redhat.com)
- 634910 - fixing permission denied error on manage channel errata that should
  not have been denied (jsherril@redhat.com)
- checkstyle fix for previous commit (lzap+git@redhat.com)
- various checkstyle fixes for previous commit (lzap+git@redhat.com)
- 634884 - managing repositories within channels through XMLRPC API disabled
  (lzap+git@redhat.com)
- fixed NPE when spacewalk_reposync_logpath is set to nonexisting dir
  (lzap+git@redhat.com)
- 633956 -fixing error popup on YourRhn when a warning or critical probe exists
  (jsherril@redhat.com)

* Thu Sep 16 2010 Lukas Zapletal 1.2.41-1
- 595500 - added contents_enc64 param to createOrUpdatePath XMLAPI
- making taskmoatic work with the rkbloom driver
- 633535 - added RHEL 5 subrepos as well as stopped showing repos not valid for
  a particular release
- adding configchannel.lookupFileInfo() taking a revision id
- implement <label> for form fields - systems/probes/edit.jsp
- implement <label> for form fields - systems/systemsearch.jsp
- 627920 - Added a larger config file icon for symlinks. Thanks to Joshua Roys.

* Tue Sep 14 2010 Justin Sherrill <jsherril@redhat.com> 1.2.40-1
- 630980 - fixing ise on package details page (jsherril@redhat.com)

* Tue Sep 14 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.39-1
- 632561 - two typos in string resource xml (en_US)
- 580998 - making deprecatedVersion become deprecatedReason
- don't fail if service is already running

* Fri Sep 10 2010 Tomas Lestach <tlestach@redhat.com> 1.2.38-1
- 606555 - provide more information into the XmlRpcFault when method not found
  (tlestach@redhat.com)

* Thu Sep 09 2010 Partha Aji <paji@redhat.com> 1.2.37-1
- 625730 - Fixed the create config file/dir javascript to work with google
  chrome (paji@redhat.com)

* Thu Sep 09 2010 Partha Aji <paji@redhat.com> 1.2.36-1
- 627874 - Quick fix to disable Macro Delims for Config Directories
  (paji@redhat.com)
- 629974 - fixing ISE on select all on the channel repos page
  (jsherril@redhat.com)
- 630595 - fixing issue where a taskomatic restart was required for distros to
  be synced (jsherril@redhat.com)
- widening text file upon user request (jsherril@redhat.com)
- 623447 - improving speed of providing_channles call, which is only used
  through the api, and so its ok to just use org id and not go through the
  rhNAvailableChannels view which seems very slow for large satellites.  We
  should improve this in the future (jsherril@redhat.com)
- let sandbox task log when removing some files/channels (tlestach@redhat.com)
- 570393 - return empty map as DMI in case no hardware info is available
  (tlestach@redhat.com)
- 570393 - return empty map as CPU in case no hardware info is available
  (tlestach@redhat.com)

* Thu Sep 09 2010 Tomas Lestach <tlestach@redhat.com> 1.2.35-1
- add None as channel checksum type option on the webUI (tlestach@redhat.com)

* Wed Sep 08 2010 Shannon Hughes <shughes@redhat.com> 1.2.34-1
- bug fixes for audit tab and proxy installer additions (shughes@redhat.com)
- 630876 - fixing ISE if viewing the hardware of a system registered with no
  hardware (jsherril@redhat.com)

* Wed Sep 08 2010 Shannon Hughes <shughes@redhat.com> 1.2.33-1
- 589728 hide audit functionality for satellite product (shughes@redhat.com)

* Wed Sep 08 2010 Partha Aji <paji@redhat.com> 1.2.32-1
- 630877 - Updated a couple of documentation comments in the get/setVariables
  XMLRPC call (paji@redhat.com)

* Wed Sep 08 2010 Partha Aji <paji@redhat.com> 1.2.31-1
- 630877 - Improved the documentation on get/set Variables call
  (paji@redhat.com)
- 617044 - enabling reprovisioning for KVM and fully virt XEN guests
  (jsherril@redhat.com)
- xliff fixes for previous translations commit (enUS) (shughes@redhat.com)
- checkstyle fixes,  hit 150 line limit on a method, got around it, but we
  should either change the limit or refactor this method (jsherril@redhat.com)
- fixing common typo pacakges -> packages (tlestach@redhat.com)
- translated xliff string update (shughes@redhat.com)
- handle repo generation when channel checksum not set (tlestach@redhat.com)

* Tue Sep 07 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.30-1
- fixed errataqueue_find_autoupdate_servers
- removign srcjars from java
- fix latest errata cache changes

* Tue Sep 07 2010 Tomas Lestach <tlestach@redhat.com> 1.2.29-1
- update method name to make the code compilable (tlestach@redhat.com)

* Tue Sep 07 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.28-1
- 573630 - reused pl/sql implementation of update_needed_cache in java
- newPackages() is dead since update_needed_cache move to pl/sql
- improved errataqueue_find_autoupdate_servers

* Mon Sep 06 2010 Tomas Lestach <tlestach@redhat.com> 1.2.27-1
- removing hibernate commit from the populateWorkQueue (tlestach@redhat.com)
- fix query for errata mailer (tlestach@redhat.com)

* Mon Sep 06 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.26-1
- fixed imports

* Mon Sep 06 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.25-1
- 573630 - reuse pl/sql implementation of update_needed_cache in java
- file attribute was removed from the wrong method in PackageHelper
- 614918 - Made SSM Select Systems to work with I18n languages
- 598845 - fixing issue where syncing errata would fail with a Hibernate
  NonUniqueObjectException because keywords on errata were being duplicated
  durign sync

* Fri Sep 03 2010 Tomas Lestach <tlestach@redhat.com> 1.2.24-1
- 567178 - adding Pacific/Auckland time zone (tlestach@redhat.com)
- 495973 - adding America/Regina time zone (tlestach@redhat.com)
- 623447 - making errata.listPackages maintain api compatibility since it is to
  be backported to 5.3 (jsherril@redhat.com)
- 623447 - speeding up errata.listPackages api call (jsherril@redhat.com)
- 591291 - do not touch packages in mergeErrata api call (tlestach@redhat.com)
- make null checks for cron expressions (tlestach@redhat.com)
- add sanity check for predefined tasks (tlestach@redhat.com)
- check only active schedules when checking DB for initialization
  (tlestach@redhat.com)

* Wed Sep 01 2010 Partha Aji <paji@redhat.com> 1.2.23-1
- 518664 - Made spacewalk search deal with other locales (paji@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- 616570 - adding support for looking up debuginfo rpms if they are located on
  the satellite itself (jsherril@redhat.com)
- fixing kickstart %post script logging to actually work and not break
  kickstarts (jsherril@redhat.com)
- fix ClearLogHistory (tlestach@redhat.com)

* Wed Sep 01 2010 Tomas Lestach <tlestach@redhat.com> 1.2.22-1
- 627905 - taskomatic requires jakarta-commons-dbcp (tlestach@redhat.com)

* Tue Aug 31 2010 Partha Aji <paji@redhat.com> 1.2.21-1
- 577921 - Removed references to redhat-release package (paji@redhat.com)

* Tue Aug 31 2010 Partha Aji <paji@redhat.com> 1.2.20-1
- 628097 - Removed kickstart partition validation logic (paji@redhat.com)

* Tue Aug 31 2010 Tomas Lestach <tlestach@redhat.com> 1.2.19-1
- 626741 - do not allow two repos with same label or repository url
  (tlestach@redhat.com)
- As 00-spacewalk-mod_jk.conf which referenced workers.properties is gone,
  remove it now as well. (jpazdziora@redhat.com)

* Mon Aug 30 2010 Partha Aji <paji@redhat.com> 1.2.18-1
- 628100 - fix for Activation Keys - Config channels issue (paji@redhat.com)
- cleaned up KickstartData object a bit (paji@redhat.com)
- 591291 - list errata packages only associated to the given channel
  (tlestach@redhat.com)
- checkstyle fix (tlestach@redhat.com)
- 627149 - do not return installtime via xmlrpc when not defined
  (tlestach@redhat.com)
- better create a separate method than override an existing in this case
  (tlestach@redhat.com)
- do not log if queue is empty for queue tasks (tlestach@redhat.com)
- 529232 - add 'no base' and 'ignore missing' options to kickstart
  (coec@war.coesta.com)
- Removed unnecessary NVLs from a config query (paji@redhat.com)
- 624377 - restore original functionality and information (coec@war.coesta.com)
- Fix hardware page (colin.coe@gmail.com)

* Fri Aug 27 2010 Tomas Lestach <tlestach@redhat.com> 1.2.17-1
- add repo type to the RepoSyncTask (tlestach@redhat.com)
- fix user email notification (tlestach@redhat.com)
- fix ChannelSoftwareHandlerTest.testMergeErrataByDate test
  (tlestach@redhat.com)
- 484895 - Stop the release link giving a 404 (colin.coe@gmail.com)

* Thu Aug 26 2010 Tomas Lestach <tlestach@redhat.com> 1.2.16-1
- 591291 - faster handling of mergeErrata API call (tlestach@redhat.com)
- fix ErrataQueueTest unit test (tlestach@redhat.com)
- 580939 - fixing invalid html with alter channels page (jsherril@redhat.com)
- unit test fix (jsherril@redhat.com)
- Fixed struts form bloopered entry (paji@redhat.com)
- making taskoamtic api handler be ignored by the api doc generation
  (jsherril@redhat.com)
- a bunch of unit test fixes (jsherril@redhat.com)

* Tue Aug 24 2010 Partha Aji <paji@redhat.com> 1.2.15-1
- checkstyle error fix (jsherril@redhat.com)
- Making repo sync screen display an error if taskomatic isnt up, and disable
  the buttons (jsherril@redhat.com)
- removing serializer entry for removed serializer (jsherril@redhat.com)

* Tue Aug 24 2010 Partha Aji <paji@redhat.com> 1.2.14-1
- 593896 - Moved Kickstart Parition UI logic (paji@redhat.com)
- remove updateSchedule method (tlestach@redhat.com)
- rename mathod names to match taskomatic terms (tlestach@redhat.com)
- reschedule = unschedule + schedule (tlestach@redhat.com)
- fix just log formatting (tlestach@redhat.com)
- do not email when tasko job get skipped (tlestach@redhat.com)
- adding the rest of the recurring event picker to the reposync stuff
  (jsherril@redhat.com)
- more work on reposync/taskomatic UI (jsherril@redhat.com)
- fixing path for chrooted post script log file (jsherril@redhat.com)
- introduce interface to get active schedules by bunch name
  (tlestach@redhat.com)
- change log info for skipped queue tasks (tlestach@redhat.com)
- change path for taskomatic logs (tlestach@redhat.com)
- enable repo sync schedule from web ui (tlestach@redhat.com)
- rewrite RepoSyncTask (tlestach@redhat.com)
- adding missing import (tlestach@redhat.com)
- checking in some missing files (jsherril@redhat.com)
- making the sync repos page do different things depending on the button
  (jsherril@redhat.com)
- Fixed a compile error (paji@redhat.com)
- Removed a bunch of duplicate dynaforms to use no_scrub and no_paren_scrub
  (paji@redhat.com)
- adding early draft of recurring event picker (jsherril@redhat.com)

* Thu Aug 19 2010 Tomas Lestach <tlestach@redhat.com> 1.2.13-1
- Fix typo (joshua.roys@gtri.gatech.edu)
- 601656 - fix user permission check for errata.create call
  (tlestach@redhat.com)

* Thu Aug 19 2010 Tomas Lestach <tlestach@redhat.com> 1.2.12-1
- return only information, run has /(not) a log (provide no file path)
  (tlestach@redhat.com)
- just call satellite-sync without sudo (tlestach@redhat.com)
- fix comparism of log outputs (tlestach@redhat.com)
- fix check whether a run is associated with the given org
  (tlestach@redhat.com)
- enable taskomatic logging in the correct file (tlestach@redhat.com)
- better uncomment used code (tlestach@redhat.com)

* Wed Aug 18 2010 Partha Aji <paji@redhat.com> 1.2.11-1
- 623683-Fixed a dupes bug where config channels were not getting shown..
  (paji@redhat.com)

* Wed Aug 18 2010 Tomas Lestach <tlestach@redhat.com> 1.2.10-1
- requires simple-core instead of obsolete (tlestach@redhat.com)

* Wed Aug 18 2010 Tomas Lestach <tlestach@redhat.com> 1.2.9-1
- status has to be saved (tlestach@redhat.com)
- fix check if a run belong to a certain org (tlestach@redhat.com)

* Wed Aug 18 2010 Tomas Lestach <tlestach@redhat.com> 1.2.8-1
- serialize dataMap even if empty (tlestach@redhat.com)
- enable task logging to files (tlestach@redhat.com)

* Tue Aug 17 2010 Partha Aji <paji@redhat.com> 1.2.7-1
- Added API calls to create/update symlinks (paji@redhat.com)
- Fixed the manage config file page to not show 'upload' for symlinks
  (paji@redhat.com)

* Tue Aug 17 2010 Tomas Lestach <tlestach@redhat.com> 1.2.6-1
- rename, update and schedule ClearLogHistory (tlestach@redhat.com)
- email support (tlestach@redhat.com)
- Fix missing functionality on System Hardware page (colin.coe@gmail.com)

* Mon Aug 16 2010 Tomas Lestach <tlestach@redhat.com> 1.2.5-1
- fix ErrataQueueTest unit test (tlestach@redhat.com)
- do not print stacktrace, when logging disabled (tlestach@redhat.com)
- do not use TaskoFactory inside of the start() and finish() methods
  (tlestach@redhat.com)
- load errata after closing session to be used later on (tlestach@redhat.com)
- add simple-core dependecies (tlestach@redhat.com)
- chekstyle fix (tlestach@redhat.com)

* Sun Aug 15 2010 Tomas Lestach <tlestach@redhat.com> 1.2.4-1
- taskomatic enhancements (tlestach@redhat.com)
- 620149 - Restore Users tab for Org Admins (colin.coe@gmail.com)
- System Notes pages PXT to java (colin.coe@gmail.com)

* Thu Aug 12 2010 Justin Sherrill <jsherril@redhat.com> 1.2.3-1
- fixing compile errors (jsherril@redhat.com)

* Wed Aug 11 2010 Partha Aji <paji@redhat.com> 1.2.2-1
- 562555 - Added code to scrub activation key names and descriptions
  (paji@redhat.com)
- Removed a stupid class that was unused (paji@redhat.com)

* Tue Aug 10 2010 Partha Aji <paji@redhat.com> 1.2.1-1
- 622715 - Fixed dups profile bug where unentitled systems were being wrongly
  reported as entitled (paji@redhat.com)
- 620463 - Fixed a KS bug (paji@redhat.com)
- fixing issue where "guests consuming regular entitlement page" would show
  guests that were recieving free entitlements because their host had a virt
  entitlement (jsherril@redhat.com)
- bumping package versions for 1.2 (mzazrivec@redhat.com)

* Tue Aug 10 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.50-1
- 621528 - Fixed dupes sys compare page to deal with unentitled systems

* Mon Aug 09 2010 Partha Aji <paji@redhat.com> 1.1.49-1
- 620341 - Fixed a dupes query (paji@redhat.com)
- 576779 - fixing issue where selecting systems to apply a single errata to
  would only work on the first page ful (jsherril@redhat.com)
- 619301 - Fixed a ypo in a i18n string (paji@redhat.com)

* Mon Aug 09 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.48-1
- Massaged the sys ents page a little more (paji@redhat.com)
- Added some tool tips on the Multi Org System Entitlements page
  (paji@redhat.com)
- fixing unit test that was written incorrectly to start with
  (jsherril@redhat.com)
- I18nized Manage and Clear (paji@redhat.com)

* Thu Aug 05 2010 Partha Aji <paji@redhat.com> 1.1.47-1
- 621520 - Fixed a bug where the 'clear' box ignored extra request parameters
  (paji@redhat.com)
- Fixed a couple of dup queries to use having (paji@redhat.com)
- making the editarea not highlight by default (jsherril@redhat.com)
- 616041 - fixing issue where deploying config files for multiple servers
  scheduled multiple actions instead of one (jsherril@redhat.com)
- 596831 - fixing issue where non-internationalized strings were stored and
  displayed for the SSM operations pages (jsherril@redhat.com)

* Thu Aug 05 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.46-1
- 616785 - fixing issue where selecting "update Properties" on the system
  details edit page would set "Auto Update Errata" to no, even if it had been
  previously set to yes
- 601058 - fixing issue where hitting update on the kickstart operating system
  tab would overwrite the custom url
- 575981 - fixing issue where non-user scheduled actions wouldnt show up in the
  scheduled list
- convert hardware.pxt to Java

* Tue Aug 03 2010 Partha Aji <paji@redhat.com> 1.1.45-1
- Fixed byte[] -> string conversion bugs that were created during the
  blob->binary commit (paji@redhat.com)

* Tue Aug 03 2010 Shannon Hughes <shughes@redhat.com> 1.1.44-1
- we need to use epoch of 1 for 1.6.0 and greater according to fedora java package rules (shughes@redhat.com)

* Mon Aug 02 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.43-1
- use objectweb-asm for Fedora-13 and beyond

* Mon Aug 02 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.42-1
- point taskomatic to slf4j jars

* Fri Jul 30 2010 Justin Sherrill <jsherril@redhat.com> 1.1.41-1
- 619381 - fixing issue where reprovisioning a system would cause registration
  to fail in the %post section resulting in the system not being registered at
  all. (jsherril@redhat.com)

* Fri Jul 30 2010 Shannon Hughes <shughes@redhat.com> 1.1.40-1
- modify build requires java for epoc 1:1.6.0 

* Fri Jul 30 2010 Justin Sherrill <jsherril@redhat.com> 1.1.39-1
- few more changes for asm vs objectweb-asm detection (jsherril@redhat.com)

* Fri Jul 30 2010 Justin Sherrill <jsherril@redhat.com> 1.1.38-1
- taking a stab at alternating between asm.jar and objectweb-asm/asm.jar to
  handle errors with taskomatic on fedora13 (jsherril@redhat.com)

* Thu Jul 29 2010 Partha Aji <paji@redhat.com> 1.1.37-1
- Config Management schema update + ui + symlinks (paji@redhat.com)
- 603133 - fixing issue where system within a group that were unentitled would
  still factor into whether the group would show up with an exclamation point
  (jsherril@redhat.com)
- Symlink /var/www/html/pub in devel environment (coec@spacey.coesta.com)
- Fix checkstyle errors (coec@spacey.coesta.com)
- 563797 - changing behavior of lookup exceptions to print a smaller error as
  well as not send an email by default (jsherril@redhat.com)
- 533190 - fixing issue where deleting more than 1000 errata would throw a
  database error (jsherril@redhat.com)
- 514426 - changing list tag behavior to show fliter box even if the user has
  filtered something and got no results (jsherril@redhat.com)
- 595524 - changing improper accesses to /ks/dist to return a file not found
  (jsherril@redhat.com)
- getting rid of tabs (jsherril@redhat.com)
- 591863 - making pre and post logging work for scripts that are not bash
  scripts (jsherril@redhat.com)
- fixing missing escaped command that broke kickstart rendering
  (jsherril@redhat.com)
- System currency phase 2 (coec@spacey.coesta.com)
- Fix 'Duplicate message key found in XML Resource file' message
  (coec@spacey.coesta.com)
- added new API functions system.listPackageProfiles and
  system.deletePackageProfile (aparsons@redhat.com)
- fixed the system counts in the *_action_list queries (aparsons@redhat.com)
- 580086 - cleaning up some code related with system group intersection and
  fixing one possible cause of not calculating the intersection correctly
  (jsherril@redhat.com)
- checkstyle fixes (jsherril@redhat.com)
- checkstyle fixes (jsherril@redhat.com)
- 582085 - fixing issue where renaming an errata with keywords would fail
  (jsherril@redhat.com)
- 582995 - fixing the automatic escaping of dollar signs within a raw kickstart
  (jsherril@redhat.com)
- removing mistakenly included debug message (jsherril@redhat.com)
- 616267 - fixing issue where system.listPackages api call would return nothing
  if the client had not uploaded the arch for the installed packages (older
  rhel 4 clients) (jsherril@redhat.com)

* Mon Jul 26 2010 Tomas Lestach <tlestach@redhat.com> 1.1.36-1
- alter the return type of system.listLatestAvailablePackage
  (aparsons@redhat.com)
- added new API call system.listLatestAvailablePackage that will list the
  latest available version of a package for each system in the list
  (aparsons@redhat.com)
- add counts for the number of completed/failed/inprogress systems to the
  ScheduledAction DTO and schedule.list*Actions API calls (aparsons@redhat.com)
- added new API call schedule.rescheduleActions (aparsons@redhat.com)

* Fri Jul 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.35-1
- fixing new connection stuff to allow for the thin client
- Add system migration to webUI

* Thu Jul 22 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.34-1
- modified java to use global database information
- fixed asm for Fedora 13

* Tue Jul 20 2010 Justin Sherrill <jsherril@redhat.com> 1.1.33-1
- Initial set of changes to show the 'files' include info on dirs and symlinks
  (paji@redhat.com)
- Making spacewalk-java build correctly for fedora 13 (jsherril@redhat.com)
* Tue Jul 20 2010 Justin Sherrill <jsherril@redhat.com> 1.1.32-1
- fixing java build scripts to use objectweb-asm library if it exists versus
  the normal asm (jsherril@redhat.com)
- add path to oracle xe library for taskomatic (msuchy@redhat.com)
- converting hibernate blobs to binary data types to hopefully work better in
  postgresql (jsherril@redhat.com)

* Tue Jul 20 2010 Tomas Lestach <tlestach@redhat.com> 1.1.31-1
- checkstyle fix (tlestach@redhat.com)
- 584860 - do not return empty partition strings (tlestach@redhat.com)
- 584860 - kickstart.profile.system.getPartitioningScheme does not return
  include statements (aparsons@redhat.com)
- 584864 - added API method kickstart.profile.downloadRenderedKickstart
  (aparsons@redhat.com)
- 584852 - added API configchannel.listSubscribedSystems (aparsons@redhat.com)
- Added a nice org updated message for the org config page (paji@redhat.com)
- 599612 - making the SSM able to subscripe systems to shared channels
  (jsherril@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- making kickstarts not fail if multiple of the same NVREA are in the same
  channel (jsherril@redhat.com)
- 600502 - speeding up system.getId() api call (jsherril@redhat.com)

* Mon Jul 19 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.30-1
- use db_* options from rhn.conf to retrieve database connection info
- Added unit tests for SystemHandlerTest.convertToFlex
- unit test fix
- fixing un-escaped dollar sign in %post script that deals with rewriting
  /etc/sysconfig/rhn/up2date

* Fri Jul 16 2010 Justin Sherrill <jsherril@redhat.com> 1.1.29-1
- fixing compile breakage (jsherril@redhat.com)

* Fri Jul 16 2010 Partha Aji <paji@redhat.com> 1.1.28-1
- Forgot to add Exception Message ... (paji@redhat.com)

* Fri Jul 16 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.27-1
- fixed typo in system_currency query
- Added a convert to flex api call and misc improvements on unit tests

* Thu Jul 15 2010 Justin Sherrill <jsherril@redhat.com> 1.1.26-1
- adding a couple of temp jars back for build system builds
  (jsherril@redhat.com)

* Thu Jul 15 2010 Justin Sherrill <jsherril@redhat.com> 1.1.25-1
* Thu Jul 15 2010 Justin Sherrill <jsherril@redhat.com> 1.1.24-1
- moving temp jars to ivy, and adding needed slf4j jars for quartz unit tests
  (jsherril@redhat.com)
- fix checksum info across mulitorg grant actions (shughes@redhat.com)
- fixed system_currency query (michael.mraka@redhat.com)

* Thu Jul 15 2010 Tomas Lestach <tlestach@redhat.com> 1.1.23-1
- [PATCH] allow multiple systems to be scheduled for an erratum via the API
  (aron@redhat.com)
- checkstyle fixes (tlestach@redhat.com)
- [PATCH] alter system.scheduleRunScript API call to schedule multiple systems
  (aron@redhat.com)
- removed dead file not used anywhere (michael.mraka@redhat.com)
- oracle client has been removed from /opt/oracle ages ago
  (michael.mraka@redhat.com)
- Add system currency report (colin.coe@gmail.com)
- Added API to list flex guests and eligible flex guests (paji@redhat.com)
- Added a Configuration page to Orgs to handle maintenance windows
  (paji@redhat.com)
- Added the lookupAndBind org to RequestContext so it could be used in various
  actions (paji@redhat.com)
- added a simple test to check for stagin content (paji@redhat.com)
- adding flex guest support for some of the org-entitlement apis
  (jsherril@redhat.com)
- making Channel package add page much faster (jsherril@redhat.com)
- Cleaned up web_customer, rhnPaidOrgs, and rhnDemoOrgs inaddition to moving
  OrgImpl- Org. These are unused tables/views/columns.. Added upgrade scripts
  accordingly (paji@redhat.com)
- fixed a goof up on preferences jspf that didn;t escape content
  (paji@redhat.com)
- fixed a comment typo (paji@redhat.com)
- Added an extra column mapping to OrgImpl object (paji@redhat.com)
- updating api doc for system.getScriptResults (adding serverId)
  (tlestach@redhat.com)
- add serverId to structure returned by system.getScriptResults() API call
  (aparsons@redhat.com)
- Corrected a couple of jsp pages where 'label for' was not used
  (paji@redhat.com)
- Fix checkstyle errors (colin.coe@gmail.com)
- Use correct tomcat version (colin.coe@gmail.com)
- Remove println used in testing (colin.coe@gmail.com)
- Display calina.out in admin tab, part 2 (colin.coe@gmail.com)
- Display calina.out in admin tab (colin.coe@gmail.com)

* Fri Jul 09 2010 Justin Sherrill <jsherril@redhat.com> 1.1.22-1
- 576139 - fixing issue where auto-application of errata would be triggered
  before the new repodata was generated. (jsherril@redhat.com)

* Thu Jul 08 2010 Shannon Hughes <shughes@redhat.com> 1.1.21-1
- removing log5j until we get fedora approval; removed velocity since its in
  tempjars; adding new versions of quartz for cron taskomatic scheduler
  (shughes@redhat.com)

* Thu Jul 08 2010 Justin Sherrill <jsherril@redhat.com> 1.1.20-1
- 603258 - fixing issue where channel.software.mergeErrata and mergePackages
  would not populate the errata/package cache corerctly (jsherril@redhat.com)

* Thu Jul 08 2010 Tomas Lestach <tlestach@redhat.com> 1.1.19-1
- CobblerSyncTask fix (tlestach@redhat.com)
- Made entitlement logic handle flex guests when the host is virt (un)entitled
  (paji@redhat.com)
- 608811 - fixing issue where virt guest creation would not create the guests
  to use a virtual bridge. (jsherril@redhat.com)

* Fri Jul 02 2010 Jan Pazdziora 1.1.18-1
- Use the { call ... } syntax instead of the direct PL/SQL.
- fix broken repo sync download log file logic (shughes@redhat.com)
- fixed a couple of issues with the sat scrubber test (paji@redhat.com)

* Thu Jul 01 2010 Tomas Lestach <tlestach@redhat.com> 1.1.17-1
- replacing ExceptionTranslator for SqlExceptionTranslator and its convert()
  method for sqlException() (tlestach@redhat.com)
- Added a sat scrubber test that wipes out old test artifactsw
  (paji@redhat.com)
- Added an automatic db test cleanup script as a part of tests
  (paji@redhat.com)
- fix bug Validation i18n key (shughes@redhat.com)
- bug fixing for reposync (shughes@redhat.com)
- junit modification for repo sync (shughes@redhat.com)
- checkstyle fix, extra java import (shughes@redhat.com)
- hook to call create repo sync task in taskomatic (shughes@redhat.com)
- remove call to repo task from the channel edit/update cmds
  (shughes@redhat.com)
- add last log repo sync to edit channel (shughes@redhat.com)
- remove old repo fields from channel edit page, clean up i18n strings
  (shughes@redhat.com)
- making links between repo objects and taskomatic (shughes@redhat.com)
- lots of checkstyle fixes (shughes@redhat.com)
- add channel count access for repo objects (shughes@redhat.com)
- general repo cleanup, bugfixing (shughes@redhat.com)
- new page: list of repos to sync (session sets) (shughes@redhat.com)
- struts support for repo sync action (shughes@redhat.com)
- adding new sync nav, moving add/remove to new tab (shughes@redhat.com)
- remove debug messages, add extra i18n update string (shughes@redhat.com)
- db mapping logic for channel repos (shughes@redhat.com)
- preselect set channel repo logic (shughes@redhat.com)
- initial jsp support for channel to repo mapping (shughes@redhat.com)
- change from rhnset to sessionset for repo maps (shughes@redhat.com)
- intial strut action for channel repository mapping (shughes@redhat.com)
- strut support for channel repository mapping (shughes@redhat.com)
- channel nav support for repository mapping (shughes@redhat.com)
- modify verbage for repo list summary (shughes@redhat.com)
- logic to delete content sources from db (shughes@redhat.com)
- minor syntax issue with i18n repo delete strings (shughes@redhat.com)
- initial files to support Repo delete (shughes@redhat.com)
- bug fixes for EditRepo, strut path fixes (shughes@redhat.com)
- RepoEdit page cleanup, jsp fixes (shughes@redhat.com)
- fix hibernate content obj named queries for Edit Repo (shughes@redhat.com)
- starting checking content objects off id and org for security; also fix query
  for taskomatic (shughes@redhat.com)
- commit before master merge (shughes@redhat.com)
- adding repo edit commands (shughes@redhat.com)
- refactoring repo commands to use base class (shughes@redhat.com)
- more repo content obj clean up (shughes@redhat.com)
- fix link for repo edit (shughes@redhat.com)
- quick fix to remove sync query from content source obj (shughes@redhat.com)
- update channel to handle sync date; remove from content source
  (shughes@redhat.com)
- fix incorrect reference to sync column of content source (shughes@redhat.com)
- adding org id mapping to content source objects (shughes@redhat.com)
- ise fixes for repo create (shughes@redhat.com)
- adding url field to repo details form/jsp (shughes@redhat.com)
- pushing changes to prepare for master merge (shughes@redhat.com)
- fixed incorrect url syntax for repocreate (shughes@redhat.com)
- adding repo domain creation logic to manager/action layer
  (shughes@redhat.com)
- pushing minor changes before master merge (shughes@redhat.com)
- repo struts action fnd jsp or creating repo objects. (shughes@redhat.com)
- support classes for adding a Repo object (shughes@redhat.com)
- repo validation xsd schema (shughes@redhat.com)
- adding nav entries for repo create and edit (shughes@redhat.com)
- struts entries for repo create and edit pages (shughes@redhat.com)
- adding dynaform for content source creation (shughes@redhat.com)
- fixing toolbar syntax for repo (shughes@redhat.com)
- minor tweaks to struts url path and hibernate fix (shughes@redhat.com)
- adding repolist page to struts (shughes@redhat.com)
- datasource queries for repolist listtag page (shughes@redhat.com)
- adding ContentSource DTO object for repo listtags (shughes@redhat.com)
- setting up ContentSource queries (shughes@redhat.com)
- fixing compile errors on RepoLister (shughes@redhat.com)
- initial classes for Repolisting (shughes@redhat.com)
- adding repo list jsp page (shughes@redhat.com)
- Revert "fixing accidental branch creation, removing cobbler stubs"
  (shughes@redhat.com)
- fixing accidental branch creation, removing cobbler stubs
  (shughes@redhat.com)
- new jsp for the repo list (shughes@redhat.com)
- adding nav menu for external repo management (shughes@redhat.com)
- minor changes to tests (shughes@redhat.com)
- more compiliation fixes to support many2many (shughes@redhat.com)
- fixing breakage after adding many2many objects for yum repo sync
  (shughes@redhat.com)
- minor updates to Channel object to add repos (shughes@redhat.com)
- initial hibernate changes to support many2many relationships of channel to
  repos (shughes@redhat.com)
- hibernate changes for existing content source objects (shughes@redhat.com)
- Fixed some checkstyle errors (paji@redhat.com)
- 605383 - fixing issue where adding errata to a channel with 'package
  association' unchecked wouldn't handle arches correctly (jsherril@redhat.com)

* Wed Jun 30 2010 Tomas Lestach <tlestach@redhat.com> 1.1.16-1
- 591291 - fix also mergeErrata with given start and end date
  (tlestach@redhat.com)
- remove exceptions from method definitions that aren't thrown
  (tlestach@redhat.com)
- More unit test fixes (paji@redhat.com)
- Cleared more unit test (paji@redhat.com)
- Fixed another checkstyle issue (paji@redhat.com)
- Speeded up a unit test .... (paji@redhat.com)
- Fixed a checkstyle issue (paji@redhat.com)
- Fixed fve unit tests Hopefully... (paji@redhat.com)
- Fixed a dupe key issue (paji@redhat.com)
- if file is rpm package, use checksum from db, otherwise read whole file
  (msuchy@redhat.com)
- Fixed a compile error.... (paji@redhat.com)
- Added more tests on Orphaned gets entitlements (paji@redhat.com)
- Added unit tests for VirtEntitlementsManager (paji@redhat.com)
- Fixed some typos (paji@redhat.com)
- Added page sizes to flex multiorg pages (paji@redhat.com)
- fixed a line typo where I forgot to clear the map create in session
  (paji@redhat.com)
- Added sorting to channel family-> orgs page (paji@redhat.com)
- Added flex magic to ChannelFamily -> Orgs page (paji@redhat.com)
- Added alphabar columns for the mutli org pages (paji@redhat.com)
- More verbiage on software entitlements page (paji@redhat.com)
- Updated the software entitlements page to deal with FVE (paji@redhat.com)
- Added a couple of enhancements on the Org software subs pager
  (paji@redhat.com)
- Fixed checkstyle errors (paji@redhat.com)
- Added code to get multiorgs org -> software channel ents page work with flex
  entitlements (paji@redhat.com)
- Forgot to commit EligibleFlexGuestAction (paji@redhat.com)
- Added the convert to flex plsql operation (paji@redhat.com)
- More updates to the UI (paji@redhat.com)
- More UI updates on the Flex Guest Pages added Nav stuff (paji@redhat.com)
- Made the Flexguest page show entitlements (paji@redhat.com)
- Initial cut to list eligible flex guests page (paji@redhat.com)
- Slight refactoring of Virtual Enttitlements (paji@redhat.com)
- Initial cut of the Flex Guests Page (paji@redhat.com)
- adding flex guest entitlement columns on the org entitlments page
  (jsherril@redhat.com)
- updating rhn_entitlement package for cert activation (jsherril@redhat.com)
- having setters do the right thing (jsherril@redhat.com)
- matching hosteds column names for flex guests (jsherril@redhat.com)
- adding hibernate mapping for flex guests (jsherril@redhat.com)

* Wed Jun 23 2010 Jan Pazdziora 1.1.15-1
- Fixed a couple of checkstyle errors (paji@redhat.com)

* Mon Jun 21 2010 Jan Pazdziora 1.1.14-1
- updating rhnPackageRepodata table to not use a reserved word.
  (jsherril@redhat.com)
- Fixed a typo in the previous commit (paji@redhat.com)
- Good Bye Channel License Code (paji@redhat.com)

* Fri Jun 18 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.13-1
- implement <label> for form fields - sdc/details.jsp (msuchy@redhat.com)
- implement <label> for form fields - user/create/usercreate.jsp
  (msuchy@redhat.com)
- implement <label> for form fields - activationkeys/details.jspf
  (msuchy@redhat.com)
- implement <label> for form fields - edit.jsp (msuchy@redhat.com)
- implement <label> for form fields - orgcreate.jsp (msuchy@redhat.com)
- implement <label> for form fields - probe-edit.jsp (msuchy@redhat.com)
- implement <label> for form fields - filter-form.jspf (msuchy@redhat.com)
- implement <label> for form fields - restart.jsp (msuchy@redhat.com)
- implement <label> for form fields - monitoring.jsp (msuchy@redhat.com)
- implement <label> for form fields - bootstrap.jsp (msuchy@redhat.com)
- implement <label> for form fields - general.jsp (msuchy@redhat.com)
- 585176 - changing the behavior of the SSM package upgrade screen to handle
  system and their packages for upgrade invidually, so only packages needed on
  a system will be installed.  This means that each system is scheduled
  individually, but at least it is correct (jsherril@redhat.com)

* Thu Jun 17 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.12-1
- Made the duplicate compares page do confirm delete differently
  (paji@redhat.com)
- Added a sort of 'confirm' logic for delete systems in dup compares page
  (paji@redhat.com)
- 602591 - "Content-Length" added to response header for different download
  contents (tlestach@redhat.com)
- 603890 - fix/rewrite system.listSubscribableBaseChannels API
  (tlestach@redhat.com)
- 576314 - fix for errata being added to the email queue multiple times before
  it can be run (jsherril@redhat.com)
- bumping up heap to 512m for jsp compiles (shughes@redhat.com)
- bumping up build heap to 512m (shughes@redhat.com)
- Removed an unnecessary abstraction for VirtEntitlements (paji@redhat.com)
- 591291 - associate packages also (when mergeing errata) (tlestach@redhat.com)
- 601656 - fix channel permission check for errata.clone (tlestach@redhat.com)
- 601656 - fix channel permission check for channel.software.mergePackages
  (tlestach@redhat.com)
- fixing issue where package summary could be null, causing NPE
  (jsherril@redhat.com)
- 601656 - fix channel permission check (tlestach@redhat.com)
- 591291 - clone errata instead of associating them to custom channels
  (tlestach@redhat.com)
- fixing hashCode for Errata (tlestach@redhat.com)
- 529359: Fixed a couple of bugs related to Remote Command Package upgrade
  (paji@redhat.com)
- 595473 525588 - fixing small query issue and moving the ssm operation
  creation to before the (jsherril@redhat.com)
- 595473 525588 - fixing issue where child channel subscription changes would
  not use the stored procedure and would instead update rhnServerChannel table
  directly, bypassing all entitelment logic (jsherril@redhat.com)
- 525588 - changing SSM child channel subscription page to not use hibernate
  when doing subscribng (jsherril@redhat.com)
- Correct 'checkstyle' errors (colin.coe@gmail.com)
- checkstyle fixes (jsherril@redhat.com)
- Update errata.setDetails to allow setting CVEs (colin.coe@gmail.com)
- Allow CVEs to be set on unpublished errata (colin.coe@gmail.com)
- 585176 - fixing issue where packages were excluded from update on SSM
  upgradable packages page when the packages had multiple arches
  (jsherril@redhat.com)
- 585965 - fixing issue with multilib packages and errata-cache generation,
  where updating one arch of a package would indicate that the other one was
  updated as well (jsherril@redhat.com)
- 563859 - fixing issue where adding errata to x86_64 channels would only get
  packages of one arch, even if the errata had two (lib packages)
  (jsherril@redhat.com)
- unit test fix (jsherril@redhat.com)
- Adding the correct checkstyle for inactive systems (paji@redhat.com)
- 576953 - fixing errata search case sensitivity and not searching on partial
  cve name (jsherril@redhat.com)
- 588367 - introducing systemgroup.scheduleApplyErrataToActive API call
  (tlestach@redhat.com)
- 588367 move applyErrataHelper to ErrataManager (tlestach@redhat.com)
- Added the dupe compare css and javascript magic (paji@redhat.com)
- 590204 - fixing issue where pagination wasnt working properly on normal user
  list page (jsherril@redhat.com)
- Made the default dups compare page preselect a bunch of items
  (paji@redhat.com)
- Improved a error message on Dups systems page (paji@redhat.com)
- Fix style of commit c4e387bbb1c5cf16f54a2fa968a5613121bc1d7a
  (lukas.durfina@gmail.com)
- A more functional dupes compare page (paji@redhat.com)
- adding distro deletion to cleanup script (jsherril@redhat.com)
- Removed a no white space after a type cast check since we are not enforcing
  it anywhere (paji@redhat.com)
- unit test fix (jsherril@redhat.com)
- Generate Debian repository (lukas.durfina@gmail.com)
- Fixed broken unit tests (paji@redhat.com)
- checkstyle fix (joshua.roys@gtri.gatech.edu)
- Updated a typo in the  string (paji@redhat.com)
- Updated a resource string (paji@redhat.com)
- Added i18n strings for the systemdetails page (paji@redhat.com)
- Limit automatic config comparisons to diff enabled systems
  (joshua.roys@gtri.gatech.edu)

* Mon May 10 2010 Partha Aji <paji@redhat.com> 1.1.11-1
- Added an option to selectively delete instead of reactivate when a system is
  being reprovisioned (paji@redhat.com)
- Made ssm operations use OperationDetailsDto instead of just dealing with
  plain maps and random attributes (paji@redhat.com)
- unit tset fix (jsherril@redhat.com)
- 528884 - fixing issue where cloning ks profiles wouldnt clone virt info
  (jsherril@redhat.com)
- Added stubs for the duplicate profiles compare page (paji@redhat.com)
- Fixed a hibernate bug on capabilities object. Removed created and modified
  from mapping (paji@redhat.com)
- 568962 - get correct set of errata to merge (tlestach@redhat.com)
- Fix a NPE in the Audit code (joshua.roys@gtri.gatech.edu)
- Added the import tree.js part to the expansion decorator so its used on a
  need to use bases (paji@redhat.com)
- Added the logic to handle Delete from the Dup Systems page (paji@redhat.com)
- Made the dup systems page use ssm (paji@redhat.com)
- Made the expansion decorator show the show all|hide all correctly
  (paji@redhat.com)
- queuing channel repo generation for new channels (jsherril@redhat.com)
- Fixed a pagination issue that occured on first page load (paji@redhat.com)
- ignoring virt bonded interfaces, changing dups page to not sure the same set,
  and fixing inactive counts on mac and hostname pages (jsherril@redhat.com)
- 585901 - add an extra null condition (tlestach@redhat.com)
- Added a form var to keep track of inactive count (paji@redhat.com)
- Added logic for all the 3 tabs to use the same set as they refer to the same
  list (paji@redhat.com)
- Added Nav Tabs + hostname /mac address functionality + cleaned up the i18n
  Strings (paji@redhat.com)
- adding inactive drop down box and select inactive button
  (jsherril@redhat.com)
- Changed the tree behaviour to always expand (paji@redhat.com)
- Fixed checkstyle (paji@redhat.com)
- Commiting the Select All magic stuff (paji@redhat.com)
- 588901 - fix to_package_id (joshua.roys@gtri.gatech.edu)

* Wed May 05 2010 Tomas Lestach <tlestach@redhat.com> 1.1.10-1
- 585901 - recursive comps search (tlestach@redhat.com)
- More work on select all magic (paji@redhat.com)
- 588901 - Fix listLatestUpgradablePackages API results
  (joshua.roys@gtri.gatech.edu)
- Fixed an accidental compile error that occured due to a previous commit
  (paji@redhat.com)
- Added some magic to show the system names and url instead of ids in the dups
  page (paji@redhat.com)
- added an nbsp to space the text better (paji@redhat.com)
- Added a new tag attribute to filter by ip address (paji@redhat.com)
- More list tag enhancements (paji@redhat.com)
- Updated the list tag to deal with parent vs child filtering (paji@redhat.com)
- More changes to properly handle selection javascript magic (paji@redhat.com)
- Needed to add more JS magic to get selections to work (paji@redhat.com)
- Quick fix to deal with a null pointer that would ve occued on a logdebg
  (paji@redhat.com)
- Added code to get checkbox grouping to work (paji@redhat.com)
- Got the tree filters working (paji@redhat.com)
- Fixed a checkstyle error (paji@redhat.com)
- fixing RowRenderer, to do coloring more like the mockups
  (jsherril@redhat.com)
- Made the post reactivation key logic more fail safe.. (paji@redhat.com)

* Thu Apr 29 2010 Partha Aji <paji@redhat.com> 1.1.9-1
- Added new cobbler snippets to enable sytem reactivation on bare metal reprovisioning
  (paji@redhat.com)
- Added code to show general snippets created in spacewalk.
- Remove spammy audit types from default search (joshua.roys@gtri.gatech.edu)

* Thu Apr 29 2010 Tomas Lestach <tlestach@redhat.com> 1.1.8-1
- introducing DistChannelHandler (tlestach@redhat.com)
- add 2 new DistChannelMap related queries with appropriate methods
  (tlestach@redhat.com)
- rename {lookup,find}ByOsReleaseAndChannelArch ->
  ByProductNameReleaseAndChannelArch (tlestach@redhat.com)
- Added all the javascript macgic needed to show and hide stuff
  (paji@redhat.com)
- Fixed a Compile typo to work with 1.5 compiler (paji@redhat.com)

* Wed Apr 28 2010 Jan Pazdziora 1.1.7-1
- Added new expandable and non-expandable columns. Also UI improvements
  (paji@redhat.com)
- adding expandable row renderer and adding it to duplicate page
  (jsherril@redhat.com)
- Added an 'expandable' tag function to differentiate between parent/child
  (paji@redhat.com)
- Got the new treeable list tag in a more stable state (paji@redhat.com)
- Better looking Duplicate Ips page (paji@redhat.com)
- The relativeFilename in rhnChannelComps is really relative, need to join with
  slash.
- converting Duplicate dtos to use new expandable interface
  (jsherril@redhat.com)
- Added initial entry point for duplicate ip page (paji@redhat.com)
- Added initial mods to list tag to deal with simple trees (paji@redhat.com)
- adding row renderer (jsherril@redhat.com)
- creating RowRenderer to provide alternate ways to render the styles of each
  row (jsherril@redhat.com)
- remove @Override, since it is not an Override (tlestach@redhat.com)
- Change from nested select to inner join (colin.coe@gmail.com)
- Got the delete systems  confirm page completed. (paji@redhat.com)
- Make bash the default for syntax highlighting (colin.coe@gmail.com)

* Fri Apr 23 2010 Justin Sherrill <jsherril@redhat.com> 1.1.6-1
- adding duplicate system manager layer and api calls (jsherril@redhat.com)
- adding server delete event for duplicate profiles (shughes@redhat.com)
- Moved SSM System DeleteConfirm page to java to facilitate Deletion using the
  message queue infrastructure (paji@redhat.com)
- allowing the period character is cobbler system records (jsherril@redhat.com)

* Wed Apr 21 2010 Justin Sherrill <jsherril@redhat.com> 1.1.5-1
- adding feature to preselect a kickstart profile for provisioning if the
  cobbler system record for that system has it selected (jsherril@redhat.com)
- 580927 - sorting advanced options (jsherril@redhat.com)
- fixing broken unit tests and properly picking the right exception
  (jsherril@redhat.com)
- Addition of channel.software.getChannelLastBuildById API call
  (james.hogarth@gmail.com)

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.4-1
- 576211 - fixed server name replacement pattern
- removing log5j stuff
- fix issue with PSQLException

* Fri Apr 16 2010 Justin Sherrill <jsherril@redhat.com> 1.1.2-1
- bumping spec files to future 1.1 packages (shughes@redhat.com)
- 516983 - making it clearer that a distro cannot be deleted if profiles are
  associated with it. Also fixing the nav for that page (jsherril@redhat.com)
- Fix the SELinux regex to handle MLS categories better
  (joshua.roys@gtri.gatech.edu)
- Fix SSM 'Select All' button on configuration pages
  (joshua.roys@gtri.gatech.edu)
- xmlrpc: Put the symlink target in 'contents' (joshua.roys@gtri.gatech.edu)
- adding velocity dep (jsherril@redhat.com)
- Add 'arch' to channel.list*Channels (colin.coe@gmail.com)
- Fix xmlrpc file-type for symlinks (joshua.roys@gtri.gatech.edu)
- adding log5j to ivy stuff, and moving the repo to parthas fedorapeople
  account (jsherril@redhat.com)
- 576907 - making same display changes for system sync (tlestach@redhat.com)
- Move systemlogs directory out of /var/satellite (joshua.roys@gtri.gatech.edu)
- 580227 - displaying dates in the same format (tlestach@redhat.com)

* Wed Apr 07 2010 Tomas Lestach <tlestach@redhat.com> 0.9.17-1
- introducing kickstart.cloneProfile API call (tlestach@redhat.com)

* Wed Apr 07 2010 Justin Sherrill <jsherril@redhat.com> 0.9.16-1
- 573153 - improving performance of the systems group overview page
  considerably (jsherril@redhat.com)
- adding NVL to query which needed it (jsherril@redhat.com)
- fixing small issue with query that resulted in odd error, inconsistent
  datatypes: expected UDT got CHAR (jsherril@redhat.com)
- Implement 'channel.software.listChildren' API call (colin.coe@gmail.com)

* Fri Apr 02 2010 Tomas Lestach <tlestach@redhat.com> 0.9.15-1
- 576907 - supporting multilib packages for syncing systems/profiles
  (tlestach@redhat.com)
- fixing taskomatic problem (tlestach@redhat.com)
- 577074 - Fix to remove invalid characters from a cobbler system record name
  (paji@redhat.com)
- 574594 - Fixed date based sorting issues on 4 User List pages.
  (paji@redhat.com)
- 577224 - Fixed an issue where when cloning KS profiles variables were not
  getting copied (paji@redhat.com)

* Wed Mar 31 2010 Justin Sherrill <jsherril@redhat.com> 0.9.14-1
- 531122 - fixing issue where system records created with cobbler would not use
  all the correct activation keys once keys were changed from a profile
  (jsherril@redhat.com)
- 522497 - Fixed a ks system details bug (paji@redhat.com)
- Remove audit review cruft from spacewalk-setup (joshua.roys@gtri.gatech.edu)

* Fri Mar 26 2010 Justin Sherrill <jsherril@redhat.com> 0.9.13-1
- 576301, 576314 - fixing issues where auto-apply of errata was applying even
  for systems that did not need the errata and was being scheduled multiple
  times for systems (once for every channel that contained that errata)
  (jsherril@redhat.com)
- changing cobbler call to use automated user since it could go through
  taskomatic (jsherril@redhat.com)
- API to list API (tlestach@redhat.com)
- 559693 - fixing apidoc (tlestach@redhat.com)
- 559693 - allow channel.software.listAllPackages to return the checksum
  (colin.coe@gmail.com)
- added packages no more automaticaly required in tomcat6
  (michael.mraka@redhat.com)

* Fri Mar 26 2010 Tomas Lestach <tlestach@redhat.com> 0.9.12-1
- API to list API (tlestach@redhat.com)
- 559693 - fixing apidoc (tlestach@redhat.com)
- 559693 - allow channel.software.listAllPackages to return the checksum
  (colin.coe@gmail.com)

* Wed Mar 24 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.11-1
- fixed Requires for tomcat6
- test case fix for SystemHandlerTest

* Mon Mar 22 2010 Tomas Lestach <tlestach@redhat.com> 0.9.10-1
- 575796 - make system.get_name API call faster (tlestach@redhat.com)
- 529359 - attempting to fix issue where solaris packages couldnt be installed,
  may break unit test, we will see (jsherril@redhat.com)
- 529359 - Fix for this error (paji@redhat.com)
- Basically removed the listAllSystems call in SystemManager (paji@redhat.com)
- 574197 - making cobbler name seperator configurable (jsherril@redhat.com)

* Wed Mar 17 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.9-1
- 568958 - package removal and verify
- 516048 - syncing java stack with perl stack on channel naming convention
- 510383 - Create/Update user commands use the max_user_len and min_user_len values
- 574065 - shared channel couldnt properly be used as a distros channel
- fixed syntax highliging in editarea textareas
- 510383 - fixes on the UI side for password length issue 
- 572277 - package profile sync
- added an API function: errata.listUnpublishedErrata
- 559551 - ISE fixed for SyncSystems.do
- making Channel.getPackages() much more verbose
- 570560 - fixing misleading channel creation warning message
- 514554 - adding back the ability to delete virt guests
- 529962 - nav not showing the current tab
- 531122 - <<inherit>> would appear within system records when modifying activation key
- 493176 - kickstart.tree.getDetails
- 562881 - save cobbler object after setting kickstart variables
- 562881 - cobbler system record check

* Fri Feb 19 2010 Tomas Lestach <tlestach@redhat.com> 0.9.8-1
- 566434 - manage base entitlements with system.add/removeEntitlements API call
  (tlestach@redhat.com)
- combine several API call params to a single Map parameter
  (tlestach@redhat.com)

* Tue Feb 16 2010 Justin Sherrill <jsherril@redhat.com> 0.9.7-1
- fixing issue with conflict between javamail package and classpathx-mail
  (which provides javamail as a provides).  The fedora 12 build was building
  against the javamail package which broke the deployment when it wasnt
  installed (jsherril@redhat.com)

* Mon Feb 15 2010 Justin Sherrill <jsherril@redhat.com> 0.9.6-1
- changing new rev number to be one more than latest, not one more than current
  (jsherril@redhat.com)
-  510100 - adding the ability to set a config file to a certain revision
  (jsherril@redhat.com)
- making timezone still null errors a bit quieter.  Maybe once we really add
  all the timezones we can really do a warning (jsherril@redhat.com)
- Automatic commit of package [spacewalk-java] release [0.9.4-1].
  (jsherril@redhat.com)
- fixing rhn.xml for tomcat6 (jsherril@redhat.com)
- 562881 - new api calls introduced (tlestach@redhat.com)

* Thu Feb 11 2010 Justin Sherrill <jsherril@redhat.com> 0.9.4-1
- adding snippet api unit tests (jsherril@redhat.com)

* Wed Feb 10 2010 Justin Sherrill <jsherril@redhat.com> 0.9.2-1
- initial tomcat6 stuff (jsherril@redhat.com)
- change checkstyle Header to RegexpHeader (tlestach@redhat.com)
- change copyright preferencies for newly created java files
  (tlestach@redhat.com)
- updated copyrights in all java files to make hudson happy
  (michael.mraka@redhat.com)
- adding createOrUpdate and delete to snippet handler as well as tests
  (jsherril@redhat.com)
- 558628 - fixing issue with configure-proxy script as well as making /cblr
  rewrites work over SSL too (jsherril@redhat.com)
- commiting missing files from previous commit that converted target systems
  page to java (jsherril@redhat.com)
- adding kickstart.snippet.list* (jsherril@redhat.com)
- fixing issue where select all and update set would clear the set before
  redisplaying the page (jsherril@redhat.com)
- fixing issue where probe suite probe list was not generating probe links
  correctly resulting in an error when trying to edit or view the probe
  (jsherril@redhat.com)
- let's start Spacewalk 0.9 (michael.mraka@redhat.com)

* Sat Feb 06 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.11-1
- Fix a NPE in CompareConfigFilesTask

* Thu Feb 04 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.10-1
- updated copyrights
- 556956 - fixed listSubscribedSystems api call would error
- 559015 - fixed target systems page
- removed handler org_has_scouts
- 531454 - provide architecture even for downgrade/upgrade
- removed config values web.public_errata_*
- 561068 - fixed api breakage with new cobbler version

* Fri Jan 29 2010 Miroslav Suchý <msuchy@redhat.com> 0.8.9-1
- 539159 - offering only ssm systems with appropriate permissions for config channel unsubscription (tlestach@redhat.com)
- 539159 - offering only ssm systems with appropriate permissions for config channel subscription (tlestach@redhat.com)
- 538435 - fixing issue where cloning a channel wouldnt properly clone the activation keys, and wouldnt update the default session key properly (jsherril@redhat.com)
- 506950 - fixing issue where RedHat channels tab would show up for spacewalk users (jsherril@redhat.com)
fixing issue that kept spacewalk from working with the newest cobbler (jsherril@redhat.com)
- 559284 - fixing issue where _ & - characters were being removed from cobbler names (jsherril@redhat.com)

* Wed Jan 27 2010 Justin Sherrill <jsherril@redhat.com> 0.8.8-1
- fixing api doc (jsherril@redhat.com)

* Wed Jan 27 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.7-1
- 529460 - fixing detection of disconnected satellite
- 530177 - moving cobbler snippet usage before user %post scripts
- 543879 - support for downloading kickstart profiles through a proxy
- 493176 - introducing kickstart.tree.getDetails API call
- 382561 - fixing daily status message to be formatted correctly
- 543184 - ability to change logging on a kickstart file from the api
- 513716 - prefix check simplification
- 506279 - speeding up channel.software.addPackages
- 518127 - adding a configchannel.deployAllSystems api call

* Fri Jan 15 2010 Tomas Lestach <tlestach@redhat.com> 0.8.6-1
- removing logic for channel checksum type completion (tlestach@redhat.com)
- 549752 - fix for check "channel in set" in UpdateChildChannelsCommand
  (tlestach@redhat.com)
- 555212 - changing the path we use for downloading package updates in
  kickstarts from $http_server to $redhat_management_server so that distros can
  be located externally without breaking this functionality
  (jsherril@redhat.com)
- 549752 - throwing exception, if subscribing system to a wrong child via api
  (tlestach@redhat.com)
- 537147 - removign unused row in column on user details page
  (jsherril@redhat.com)
- 514759 - stripping space chars from activation keys (jsherril@redhat.com)
- 554516 - adding better formatting for config file diffs (jsherril@redhat.com)
- 513716 - prefix validation added when creating a user (tlestach@redhat.com)
- 554767 - fixing issue where file preservation list details wouldnt always
  show up under the correct tab (jsherril@redhat.com)
- 543461 - fixing issue where csv downloader for systems errata list was not
  showing up (jsherril@redhat.com)
- 549553 - speeding up package removal from channel (jsherril@redhat.com)
- 553262 - fixing issue where kickstart label wasnt printed on software profile
  page (jsherril@redhat.com)

* Fri Jan 08 2010 Justin Sherrill <jsherril@redhat.com> 0.8.5-1
- 553265 - fixing issue where stored profile list wasnt sorted by name
  (jsherril@redhat.com)
- 552900 - fixing issue where variables would have a newline on the end
  (jsherril@redhat.com)
- Update copyright years to end with 2010. (jpazdziora@redhat.com)
- adding "Yum Repository Checksum Type" info to the channels/ChannelDetail.do
  page (tlestach@redhat.com)
- 526823 - improving speed of scheduling package installs for 1000s of systems
  (jsherril@redhat.com)
- 549391 - ISE when audit searching without any machine information
  (tlestach@redhat.com)

* Fri Dec 18 2009 Tomas Lestach <tlestach@redhat.com> 0.8.4-1
- fixed exception handling (tlestach@redhat.com)
- modifying Checksum.toString() for easier debugging (tlestach@redhat.com)
- sha256 changes for taskomatic (tlestach@redhat.com)
- adding checksum type for rhn/errata/details/Packages.do page
  (tlestach@redhat.com)
- displaying checkum type on rhn/software/packages/Details.do page
  (tlestach@redhat.com)
- download_packages.pxt was in the second rhn-tab-url in both
  channel_detail.xmls, and not referenced from anywhere else, removing.
  (jpazdziora@redhat.com)
- The webapp.conf is not used anywhere. (jpazdziora@redhat.com)
- adding channel.software.regenerateYumCache() api call (jsherril@redhat.com)
- making selinux not required for server.config.createOrUpdate() api call, also
  adding selinux_ctx to the documentation (jsherril@redhat.com)
- changing mock request to default to a POST request (jsherril@redhat.com)

* Wed Dec 16 2009 Tomas Lestach <tlestach@redhat.com> 0.8.3-1
- modifying spacewalk-java build propetries to enable f12 builds
  (tlestach@redhat.com)
- Remove the spacewalk-moon (sub)package as it is not used anywhere.
  (jpazdziora@redhat.com)
- correcting the action that the POST check was done for errata add package
  (jsherril@redhat.com)
- adding post checking to a couple of pages (jsherril@redhat.com)
- 545995 - adding package signing key to the package details page
  (jsherril@redhat.com)
- The email.verify.body trans-unit is not used anywhere, removing as dead text.
  (jpazdziora@redhat.com)

* Thu Dec 10 2009 Michael Mraka <michael.mraka@redhat.com> 0.8.2-1
- fixed support for SHA256 rpms

* Fri Dec  4 2009 Miroslav Suchý <msuchy@redhat.com> 0.8.1-1
- sha256 support

* Wed Dec 02 2009 Tomas Lestach <tlestach@redhat.com> 0.7.24-1
- 537094 - yum list-sec CVE's on cloned channels doesn't work
  (tlestach@redhat.com)
- fixing checksum empty string in the repo metadata (tlestach@redhat.com)
- checking return value of channel.getChecksum() (tlestach@redhat.com)
- 543347 - Security errata with enhancement advisory icons
  (tlestach@redhat.com)
- fixing ISE when cloning channel (tlestach@redhat.com)
- fixing ISE when adding Red Hat Errata to custom channel (tlestach@redhat.com)

* Tue Dec  1 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.23-1
- 542830 - fixing three api calls that were using very inefficient queries to use the same queries that were used in sat 5.2 (jsherril@redhat.com)
- converting old hibernate max in clause limit fix to use new fix (jsherril@redhat.com)
- 538559 - fixing issue where about 300 errata could not be applied to a system due to inefficient hibernate usage (jsherril@redhat.com)
- fixing list borders on errata apply confirm page (jsherril@redhat.com)
- Fix creating new config-managed symlinks (joshua.roys@gtri.gatech.edu)

* Mon Nov 30 2009 Tomas Lestach <tlestach@redhat.com> 0.7.21-1
- checking return value of channel.getChecksum() (tlestach@redhat.com)
- adding checkstyle build dependency (tlestach@redhat.com)
- updating ant-contrib path (tlestach@redhat.com)

* Wed Nov 25 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.19-1
- improving the system channels page by increasing the base channel selector box size and having the custom channels sorted by name (jsherril@redhat.com)
- another small display issue fix for list (jsherril@redhat.com)
- fixing sort on channel manage page to sort by name and not id (jsherril@redhat.com)
- fixing a bunch of list display issues that have bugged me for a while (jsherril@redhat.com)
- 519788 - fixing set selection on two config management lists (jsherril@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- unit test fixes (jsherril@redhat.com)
- unit test fix - reloading the "Action" hibernate object seemed to cause issues with the user object that it was associated with, so instead lets try refreshing (jsherril@redhat.com)

* Fri Nov 20 2009 Tomas Lestach <tlestach@redhat.com> 0.7.18-1
- some columns not filled on webui for non-cve errata (tlestach@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- 512844 - fixing inefficient query in package set clenaup
  (jsherril@redhat.com)
- unit test fix - we no longer do validation checking on kickstart partitions,
  so no need to test it (jsherril@redhat.com)
- unit test fix - kickstart compare packages was not working correctly
  (jsherril@redhat.com)
- 537491 - fixing issue with cloned kickstart profiles losing the package list
  during cloning (jsherril@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- unit test fix (jsherril@redhat.com)
- unit test fix (jsherril@redhat.com)

* Thu Nov 12 2009 Tomas Lestach <tlestach@redhat.com> 0.7.17-1
- 536825 - storing "@ Base" KickstartPackage into DB (tlestach@redhat.com)
- java code enhancements according to jsherrill's comments
  (tlestach@redhat.com)
- unit test fix (jsherril@redhat.com)

* Tue Nov 10 2009 Tomas Lestach <tlestach@redhat.com> 0.7.16-1
- WebUI Errata & CVEs enhancements (tlestach@redhat.com)
- unit test fixes (jsherril@redhat.com)
- 531649 - fixed issue where confirmation message was not displayed after using
  channel merge/compare feature (jsherril@redhat.com)
- 531645 - fixing query with mistaken id reference (jsherril@redhat.com)
- standart Red Hat header added to CompareConfigFilesTask.java
  (tlestach@redhat.com)
- Show number of differing config files in overview
  (joshua.roys@gtri.gatech.edu)
- Set CompareConfigFilesTask to run at 11pm (joshua.roys@gtri.gatech.edu)
- Add task to schedule config file comparisons (joshua.roys@gtri.gatech.edu)
- Fix two more fd leaks (joshua.roys@gtri.gatech.edu)
- Plug fd leak (joshua.roys@gtri.gatech.edu)
- Fix system comparison file/dir/symlink counts (joshua.roys@gtri.gatech.edu)
- 508771 - fixing incorrect sort on channel errata list page
  (jsherril@redhat.com)
- 531091 - fixing issue that would result in odd hibernate errors due to
  hibernate objects being used across hibernate sessions (jsherril@redhat.com)
- 531059 - fixing issue where certain characters in the org name would cause
  errors when trying to create things in cobbler (jsherril@redhat.com)

* Tue Oct 27 2009 Tomas Lestach <tlestach@redhat.com> 0.7.15-1
- replacing HashSet with TreeSet (tlestach@redhat.com)
- checkstyle errors removed (tlestach@redhat.com)
- 525561 - fixing issue where ksdata without associated kickstart defaults
  would try to be synced to cobbler and fail (jsherril@redhat.com)

* Mon Oct 26 2009 Tomas Lestach <tlestach@redhat.com> 0.7.13-1
- 527724 - fix for kickstart upgrade issue (tlestach@redhat.com)
- 449167 - it looks better when architecture column is not thin column
  (msuchy@redhat.com)

* Fri Oct 23 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.10-1
- 449167 - show rpm install date in webui
- 144325 - recommiting this without the unintended sql commit  <jsherril@redhat.com>
- 144325 - moving probes and probe suite pages over to new list tag <jsherril@redhat.com>

* Tue Oct 20 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.9-1
- Make spacewalk use the editarea RPM and remove supplied editarea files (colin.coe@gmail.com)

* Tue Oct 20 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.8-1
- reverting parthas patch that was trying to automatically get connection info, but cause too many issues (jsherril@redhat.com)
- 522526 - fixing small issue where updating advanced options page would remove custom partitioning script (jsherril@redhat.com)
- 522526 - fixing issue where snippets couldnt be used in the partitioning section of the kickstart wizard (jsherril@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- 523624 - fixing issue where snippets were written with a carraige return (jsherril@redhat.com)
- 526823 - fixing issue where SSM package removal pages were taking way too long and timing out with 11000 systems (jsherril@redhat.com)
- 525575 - imporoving performance of system group overview query (michaels fix) (jsherril@redhat.com)

* Thu Oct  1 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.7-1
- 476851 - removing column "ENVIRONMENT" from ConfigMacro
- workaround for hibernate not handling in caluses of more than 1000 <jsherril@redhat.com>
- 523673 - generate repomd for zstreams too
- adding workaround for hibernate oddity/bug <jsherril@redhat.com>
- checkstyle fixes <jsherril@redhat.com>
- 525549 - fixing issue where SSM package operations would run out of memory <jsherril@redhat.com>
- adding script to help diagnose spacewalk-cobbler login issues <jsherril@redhat.com>
- Fix audit machine listing/paginatio <joshua.roys@gtri.gatech.edu>
- Make reviewing empty audit sections possible <joshua.roys@gtri.gatech.edu>
- Display 'File Type' as 'Symlink' in file details <joshua.roys@gtri.gatech.edu>
- 523926 - fixing issue with schedule event package list not paginating properly <jsherril@redhat.com>

* Thu Sep 17 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.6-1
- 523631 - Files in /etc/rhn/default should not be "noreplace"
- fixing broken path in eclipse classpath generation
- 523146 - fix typo in name of column
- 476851 - removal of tables: rhn_db_environment, rhn_environment
- Made hibernate configs use new configs.
- fixing issue where repo_sync tasks would not get removed under certain conditions
- fixing issue where errata cache task was pulling ALL tasks out of the queue and not just the two it actually was using

* Wed Sep 02 2009 Michael Mraka <michael.mraka@redhat.com> 0.7.5-1
- Add symlink capability to config management (joshua.roys@gtri.gatech.edu)

* Tue Sep 01 2009 Michael Mraka <michael.mraka@redhat.com> 0.7.4-1
- 498661 - added missing oracle/monitoring translation

* Tue Sep 01 2009 Michael Mraka <michael.mraka@redhat.com> 0.7.3-1
- moved database specific files to subpackages
- 518227 - missing repo label would result in invalid summary error
- 498009 - kickstart label would not show up on kickstart variables page
- setting the default checksum type for channels to be sha1 instead of sha256
- making RepoSyncTask use the --quiet flag for repo syncing
- new way of waiting on process for RepoSync task.  Hopefully this does not
  bail out after a long time

* Thu Aug 20 2009 jesus m. rodriguez <jesusr@redhat.com> 0.7.2-1
- fix duplicate base channels listed in the "Parent Channel" dropdown (jesusr@redhat.com)
- Log files should be ghosted rather than belonging to a package (m.d.chappell@bath.ac.uk)

* Wed Aug 19 2009 jesus m. rodriguez <jesusr@redhat.com> 0.7.1-1
- add the Chat graphic as an advertisement to the layouts. (jesusr@redhat.com)
- allow users to chat with spacewalk members on IRC via the web.
  (jesusr@redhat.com)
- 518342 - adding workaround for RHEL5u4 bug failing to register when dbus and
  hal are not running (jsherril@redhat.com)
- Checkstyle fix (jason.dobies@redhat.com)
- 518262 - Fixed select all buttons when selecting erratum packages to push to
  a channel. (jason.dobies@redhat.com)
- 516863 - Fix Schedule page date sorting. (dgoodwin@redhat.com)
- adding config option for disabling the ability to access child channel repo
  through kickstart (jsherril@redhat.com)
- adding support for child channel repos during kickstart (jsherril@redhat.com)
- 517567 - fixing issue with ISE with page sort on org trust page
  (jsherril@redhat.com)
- 517551 - fixing issue where a migrated system couldnt provision a guest
  (jsherril@redhat.com)
- unit test (jsherril@redhat.com)
- 517421 - allow shared channels as parents to child channels
  (jesusr@redhat.com)
- 494409 - Update TrustAction to removed shared subscriptions before removing
  trusts (jortel@redhat.com)
- fixing the cloned channel creation to use the original channels checksum type
  and set to db. Once the cloned logic is converted from perl to java we can do
  this more nicely. (pkilambi@redhat.com)
- 509430 - fixing issue where the provisioning tab would ISE on 2.1 systems
  (jsherril@redhat.com)
- 517076 - Added association of servers in the SSM to the package upgrade task
  log. See comment in the code for more information. (jason.dobies@redhat.com)
- 517086 - Added note to indicate the types of SSM tasks to expect to see on
  that page to minimize confusion. (jason.dobies@redhat.com)
- 514305 - switching the algorithm for reading the file into memory.
  (mmccune@redhat.com)
- 517074 - Systems were pulled from the SSM rhnSet without being scoped to a
  specific user ID. Updated the query to take user IDs into account.
  (jason.dobies@redhat.com)
- Fixed typo. (jason.dobies@redhat.com)
- 483606 - Added clause to SSM system retrieval query to filter out proxies.
  (jason.dobies@redhat.com)
- fixing checkstyle (pkilambi@redhat.com)
- fixing unit test breakage (pkilambi@redhat.com)
- 509364 - Fix to show Package Arch name correctly in SSM Package isntall
  (paji@redhat.com)
- 516220 - Fixed bug in SSM query that was looking for systems in any set, not
  just the SSM specific rhnSet. (jason.dobies@redhat.com)
- Reapplying accidentally reverted commit: "Revert "478397 - fixing issue where
  rhnpush would schedule a taskomatic task to regenerate needed cache and was
  using a query that didnt generate for all channels (even though it was
  deleting from all channels)"" (jason.dobies@redhat.com)
- 443500 - Made sure the call to complete the SSM async operation always takes
  place. Added hook to associate servers with the operation.
  (jason.dobies@redhat.com)
- Revert "478397 - fixing issue where rhnpush would schedule a taskomatic task
  to regenerate needed cache and was using a query that didnt generate for all
  channels (even though it was deleting from all channels)"
  (jason.dobies@redhat.com)
- 478397 - fixing issue where rhnpush would schedule a taskomatic task to
  regenerate needed cache and was using a query that didnt generate for all
  channels (even though it was deleting from all channels)
  (jsherril@redhat.com)
- adding reposync task to taskomatic config (jsherril@redhat.com)
- bumping versions to 0.7.0 (jmatthew@redhat.com)

* Wed Aug 05 2009 John Matthews <jmatthew@redhat.com> 0.6.41-1
- 509474 - make sure we symlink to stringtree-json (mmccune@redhat.com)
- 509474 - fixing NPE (joshua.roys@gtri.gatech.edu)
- 509474 - removing un-needed check now that RPM installs this dir
  (mmccune@redhat.com)
- 509474 - adding directory to RPM installation and fixing jsps
  (joshua.roys@gtri.gatech.edu)
- 509474 - switching to exists() check (mmccune@redhat.com)
- 509474 - integration of Joshua's audit feature. (joshua.roys@gtri.gatech.edu)

* Wed Aug 05 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.6.40-1
- Merge branch 'master' of ssh://pkilambi@git.fedorahosted.org/git/spacewalk
  (joshua.roys@gtri.gatech.edu)
- bugfix patch on selinux config file deploy (joshua.roys@gtri.gatech.edu)

* Wed Aug 05 2009 Jan Pazdziora 0.6.39-1
- Fixed unit tests (paji@redhat.com)
- 514291 - Fix for KS by IP (paji@redhat.com)
- enhancing logging mechanism for spacewalk-repo-sync (jsherril@redhat.com)
- 514800 - added logic to check for channel managers per cid
  (shughes@redhat.com)
- 514291 - Fix to properly schedule ssm ks over IP range (paji@redhat.com)
- adding last_boot to system.getDetails() api call, per user request (jlsherri
  @justin-sherrills-macbook-2.local)
- 514994 - added logic to keep channel family name lengh at 128 or lower
  (shughes@redhat.com)
- 514792 - fix spelling error for form var on jsp page (shughes@redhat.com)
- Merge branch 'master' into repo-sync (jsherril@redhat.com)
- Patch: Selinux Context support for config files (joshua.roys@gtri.gatech.edu)
- merge conflict (jsherril@redhat.com)
- 515219 - We can have a channel with null description. In the
  packagedetailsaction we call replace on description  without checking if its
  a valid string resulting in Null Pointer Exception. (pkilambi@redhat.com)
- 496080 - fixing issue where if the rhn tools beta channel was synced, you
  would get an ISE when trying to give the virt entitlement within an org that
  did not have access to that channel (jsherril@redhat.com)
- check style fixes (jsherril@redhat.com)
- 494409 - fix to unsubscribe child channels during trust removal
  (shughes@redhat.com)
- 514591 - fixing issue where empty string being passed in for some values on
  errata.create api would result in ISE 500 (jsherril@redhat.com)
- unit test fixes (jsherril@redhat.com)
- some repo sync task fixes (jsherril@redhat.com)
- updating task to include log file and more logging (jsherril@redhat.com)
- adding sync repo option to channel details, and taskomatic task
  (jsherril@redhat.com)
- 51455, 513683, 514291, 513539 - Fixed a bunch of bugs related to KS
  provisioning. (paji@redhat.com)
- adding repo sync task and other UI bits for spacewalk repo sync
  (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- adding sync repo option to UI for yum repos (jsherril@redhat.com)
- initial yum repo sync schema and UI work (jsherril@redhat.com)

* Tue Jul 28 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.6.38-1
-  Adding a new create channel api using checksumtype as a params.
  (pkilambi@redhat.com)
- 513786 - api - org.create - update api to support pam authentication
  (bbuckingham@redhat.com)

* Mon Jul 27 2009 John Matthews <jmatthew@redhat.com> 0.6.37-1
- 513683 - Added 'link' as a network device option (paji@redhat.com)
- 515539 - Made the cobbler create system record command always delete and
  create a new version of system (paji@redhat.com)
- 510299 & 510785- Fixed issues pertaining to static network and upgrade.
  (paji@redhat.com)

* Thu Jul 23 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.6.35-1
-  Sha256 support for channel creation: (pkilambi@redhat.com)
- checkstyle (mmccune@redhat.com)
- 512814 - unit test fix (mmccune@redhat.com)

* Wed Jul 22 2009 John Matthews <jmatthew@redhat.com> 0.6.34-1
- 512814 - adding spot to add 'upgrade' logic to our startup of tomact.
  (mmccune@redhat.com)

* Tue Jul 21 2009 John Matthews <jmatthew@redhat.com> 0.6.33-1
- 512679 - Fix to guess a sensible default virt path for Xen/KVM virt type
  (paji@redhat.com)
- 510785 - Removed the 'valid' column from the ks profiles list
  (paji@redhat.com)
- 512396 - Cobbler's KS meta can store ints while our code was expecting them
  to be all  strings (paji@redhat.com)
- Fixed unit tests (paji@redhat.com)
- 510785 - Handled an edge case where there are NO valid trees available in KS
  raw mode.. (paji@redhat.com)
- 510785 - Major commit to deal with KS/Distro upgrade scenarios
  (paji@redhat.com)
- 509409 - rewrote package file naming when pushed from proxy
  (shughes@redhat.com)
- 510785 - modifying query to now show profiles on provisioning schedule pages
  if the profiles cobbler id is null (jsherril@redhat.com)
- 512224 - improving handling of invalid network interfaces when adding them to
  cobbler (jsherril@redhat.com)
- 510785 - updating cobbler sync tasks to ignore kickstarts and trees when the
  tree is not able to be synced to cobbler (jsherril@redhat.com)
- 511963 - fixing issue where changing distro  from non-para virt to paravirt
  would not update cobbler objects correctly (or vice-versa)
  (jsherril@redhat.com)
- 510785 - Initial stab on the Invalid KS Distro Base Path issue.
  (paji@redhat.com)
- 508331 - sha256 checksum support for yum repo generation stuff through
  taskomatic. (pkilambi@redhat.com)
- 510329 - Fix SSM package operations UI timeout. (dgoodwin@redhat.com)
- 509589 - fix for org counts (shughes@redhat.com)
- 510299 - Big commit to get static networking to work (paji@redhat.com)
- 509409 - correct package display for rhn_package_manager (shughes@redhat.com)

* Thu Jul 09 2009 John Matthews <jmatthew@redhat.com> 0.6.32-1
- 510122 -  ErrataSearch now filters results so it won't display errata from a
  non-sharing Org (jmatthew@redhat.com)
- 509589 - fixing ise on single default org sys ent page (shughes@redhat.com)
- 509215 - update SDC packages->upgrade to show pkg arch when available
  (bbuckingham@redhat.com)
- checkstyle (jsherril@redhat.com)
- 510334 - Fix the comps.xml timestamp in repomd.xml to compute the timestamp
  value correctly. (pkilambi@redhat.com)
- 510146 - Fix 2002-08 to 2002-09 copyright in non-English resource bundles.
  (dgoodwin@redhat.com)
- 510146 - Update copyright years from 2002-08 to 2002-09.
  (dgoodwin@redhat.com)
- 509268 - Fixed incorrect filterattr values (jason.dobies@redhat.com)
- 509589 - clean up software and system entitlement subscription pages
  (shughes@redhat.com)
- 496174 - removing usage of rhnPrivateErrataMail view and tuning query
  (mmccune@redhat.com)
- 508931 - bumping taskomatic default max memory to 512 and min to 256 to avoid
  OutOfMemoryError's on s390 (pkilambi@redhat.com)
- fix prads oops (shughes@redhat.com)
- 509911 - Dont compute date if the file is missing that way we dont show 1969
  for last build. Also changing the jsp logic to only show as complete if both
  last build and status are not null (pkilambi@redhat.com)
- 509394 - update System/Profile comparison to not display duplicate error
  messages (bbuckingham@redhat.com)
- 508980 - converting SSM kickstart to java (jsherril@redhat.com)
- small request to add orgid for pkilambi (shughes@redhat.com)
- 509457 - incorrectly using user id twice in channel query
  (shughes@redhat.com)
- 509377 - confirmation pgs for Pkg Install & Remove updated to include pkg
  arch (bbuckingham@redhat.com)

* Mon Jul 06 2009 John Matthews <jmatthew@redhat.com> 0.6.30-1
- 509444 - remove delete action system from virt page (shughes@redhat.com)
- 509371 - SSM->Install,Remove,Verify - minor fixes to Package Name and Arch
  (bbuckingham@redhat.com)
- 509411 - make sure we delete the ks template when we delete a profile
  (mmccune@gibson.pdx.redhat.com)
- 509364 - fix SSM->Upgrade arch that being listed (bbuckingham@redhat.com)
- 509376 - add Shared Channels to side navigation of Channels tab
  (bbuckingham@redhat.com)
- 509270 - clarify text on Channels -> All Channels page
  (bbuckingham@redhat.com)
- 509019 - adding tooltip on howto copypaste (mmccune@gibson.pdx.redhat.com)
- 509221 - System->Package->Install incorrectly using arch name vs label
  (bbuckingham@redhat.com)
- 509213 - fixed channel provider column, don't link red hat inc
  (shughes@redhat.com)
- 509027 - kickstart profile edit - update length of supported kernel and post
  kernel options (bbuckingham@redhat.com)
- 509011 - apidoc - kickstart.deleteProfile - update kslabel description
  (bbuckingham@redhat.com)
- refactor config constants to their own class with statics and methods.
  (mmccune@gibson.pdx.redhat.com)
- 509037 - fixing issue where looking for packages in child channels would
  result in base channels (jsherril@redhat.com)
- 508790 - switch to /var/lib/libvirt/images for our default path
  (mmccune@gibson.pdx.redhat.com)
- 508966 - fixed issue where could not set package profile for a kickstart,
  rewrote to new list tag (jsherril@redhat.com)
- 508789 - Block deletion of last remaining Satellite Administrator.
  (dgoodwin@redhat.com)
- Bumping timeout on Message Queue Test. (dgoodwin@redhat.com)
- 508962 - Fixed KS software edit page to hide repo section if tree is not rhel
  5 (paji@redhat.com)
- 508790 - use virbr0 for KVM guest defaults (mmccune@gibson.pdx.redhat.com)
- 508705 - Fixed KS details page to hide virt options if virt type is none
  (paji@redhat.com)
- 508885 - fixed ks schedule pages to remember proxy host (paji@redhat.com)
- Made the radio button in schedule ks page choose scheduleAsap by default
  (paji@redhat.com)
- 508736 - Corrected spec to properly  set the cobbler/snippets/spacewalk
  symlink (paji@redhat.com)
- 508141 - api - system.config.deployAll updated w/ better exception when
  system not config capable (bbuckingham@redhat.com)
- 508323 - fixing issue with creating cobbler system records with spaces (which
  would fail) (jsherril@redhat.com)
- 508220 - fixed channel sharing syntax error on english side
  (shughes@redhat.com)
- Fix API call to remove server custom data value. (dgoodwin@redhat.com)
- ErrataSearch, add "synopsis" to ALL_FIELDS (jmatthew@redhat.com)

* Thu Jun 25 2009 John Matthews <jmatthew@redhat.com> 0.6.29-1
- Remove catch/log return null of HibernateExceptions. (dgoodwin@redhat.com)
- Fix server migration when source org has > 1000 org admins.
  (dgoodwin@redhat.com)
- Fix to make sure kernel param entries don;t get duplicated (paji@redhat.com)
- 492206 - Fixed kickstart template error (paji@redhat.com)
- 507533 - added catch around unhandled exception for pkg in mutiple channels
  (shughes@redhat.com)
- 507862 - Fixed an ise that occured when config deploy was selected on a
  profile (paji@redhat.com)
- 507863 - fixing issue where enabling remote commands would not be saved
  (jsherril@redhat.com)
- 507888 - Set the default virt mem value to 512 instead of 256
  (paji@redhat.com)
- hopeflly fixing unit test (jsherril@redhat.com)
- Fixed a unit test (paji@redhat.com)
- 506702 - Converted probe details page to use the new list to get the correct
  csv (paji@redhat.com)
- Fixed a nitpick that memory didnt sya memMb (paji@redhat.com)
- 507097 - Fixed guest provisioning virt settings (paji@redhat.com)
- Adding repodata details for a given channel to channelDetails page.
  (pkilambi@redhat.com)
- 506816 - fixing issue where virt hosts that begin to use sat 5.3 could not
  install spacewalk-koan (jsherril@redhat.com)
- 506693 - removed more contact.pxt references (shughes@redhat.com)
- 507046 & 507048 - Fixed a couple of cobbler issues (paji@redhat.com)
- Added a fix to master to ignore profiles that have not yet been synced to
  cobbler.. (paji@redhat.com)
- Fix for html:errors and html:messages to be consitently viewed in the UI
  (paji@redhat.com)
- 506726 - do not allow links for null org channel management
  (shughes@redhat.com)
- 506705 - removed invalid rhn require tag (shughes@redhat.com)
- 506693 - remove contact.pxt link from 404 message (shughes@redhat.com)
- 506509 - Fixed an ssm query.. Accidental typo.. (paji@redhat.com)
- 506509 - Fixed ISE on Config Deploy pages (paji@redhat.com)
- Checkstyle fix. (dgoodwin@redhat.com)
- 506608 - fixing issue where source packages could not be downloaded from the
  package details page (jsherril@redhat.com)
- Fix monitoring action unit tests. (dgoodwin@redhat.com)
- Attempt to fix ChannelManagerTest.testListErrata. (dgoodwin@redhat.com)
- 506342 - fix system count for consumed channel sharing (shughes@redhat.com)
- 506341 - fix system count for provided shared channels (shughes@redhat.com)
- 495406 - Changed package arch lookup for ACLs to use arch labels instead of
  hibernate objects. (jason.dobies@redhat.com)
- 506489 - remove the link associated with the org name present in the UI
  header (bbuckingham@redhat.com)
- Adding missed EusReleaseComparator file. (dgoodwin@redhat.com)
- 506492, 506139 - PackageSearch default quick search to searching all arches &
  fix no result if systems aren't registered (jmatthew@redhat.com)
- 506296 - Repair EUS logic after removal of is_default column.
  (dgoodwin@redhat.com)
- 506144 - apidoc - packages.search - adding missing files to return value
  (bbuckingham@redhat.com)
- fix unit test cases (shughes@redhat.com)
- removed a duplicate string resources entry (paji@redhat.com)
- Fix some of the failing EUS unit tests. (dgoodwin@redhat.com)
- 505616 - Fixing the eus logic that gets the latest and the default eus
  channels to not depend on is_default column. Thanks to jsherril for his help
  on this. (pkilambi@redhat.com)
- Fixed a set of unit tests which owere looking for ActtionMessagess instead of
  ActionErrors (paji@redhat.com)
- Unit test fix (paji@redhat.com)
- Fixed unit test: was looking for errors as part of action messages
  (jason.dobies@redhat.com)
- Remove hibernate mappings for rhnReleaseChannelMap is_default column.
  (dgoodwin@redhat.com)
- unit test fix (jsherril@redhat.com)
- unit test fix (jsherril@redhat.com)
- 431673 - reworking rhnServerNeededView for performance fixes.
  (mmccune@gmail.com)
- 505170 - api - proxy.deactivateProxy - was generating internal exception
  (bbuckingham@redhat.com)
- 505327 - fixing url parse for advanced kickstart options (shughes@redhat.com)
- 498650 - HTML escape monitoring data before displaying. (dgoodwin@redhat.com)
- Revert "498650 - html escape of monitoring data before displaying on the
  WEBUI" (dgoodwin@redhat.com)
- 498650 - html escape of monitoring data before displaying on the WEBUI
  (tlestach@redhat.com)
- 492206 - Fixed cobbler error url to point to KS file download page which has
  better info on cheetah stacktrace (paji@redhat.com)
- 505188 - fixing issues causing rhel2.1 provisioning to not work
  (jsherril@redhat.com)
- 490960 - ErrataSearch, fix for multiorg channel permissions
  (jmatthew@redhat.com)
- fix to shwo the correct error message css (paji@redhat.com)
- 504804 - Need to stuff the relevant flag back into the request so it's used
  in the package name URLs. (jason.dobies@redhat.com)

* Wed Jun 10 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.26-1
- 504806 - Added missing channel_filter attribute that was being lost during
  pagination. (jason.dobies@redhat.com)
- 487014 - SystemSearch remove score requirement to redirect to SDC on 1 result
  (jmatthew@redhat.com)
- 490770 - Skip and warn if multiple virt channels are found.
  (dgoodwin@redhat.com)
- 503801 - update channel details edit to not refresh package cache
  (bbuckingham@redhat.com)

* Tue Jun 09 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.25-1
- 470991 - spacewalk-java requires jakarta-commons-io and spacewalk-branding.
  (jesusr@redhat.com)
- 501388 - Fixed the guest provisioning side of things also to conform to the
  new UI (paji@redhat.com)
- 501388 - fixing kernel options on profile and scheduling pages to use newer
  CobblerObject based parsing (jsherril@redhat.com)
- 504652 - remove default column from rhnchanneldist map query
  (shughes@redhat.com)
- Update for python 2.5+ (jmatthew@redhat.com)
- 501388 - kernel options and post kernel options redesign (paji@redhat.com)
- Fix to include html:errors wherever html:messages is used so that errors can
  be reported. (paji@redhat.com)
- 504049 - adding functionality to keep the  cobbler profile and system records
  redhat managemnet keys in line with whats set in the Kickstart Profile on
  satellite (jsherril@redhat.com)
- 499471 - list default org in subscription list (shughes@redhat.com)
- 504014 - Fix to show an error message on No Kicktstart tree on KS OS page
  (paji@redhat.com)
- 504227 - apidoc - kickstart handler - add 'none' as a supported virt type
  (bbuckingham@redhat.com)
- 500505 - apidoc - packages.findByNvrea - update docs (bbuckingham@redhat.com)

* Fri Jun 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.24-1
- good bye StrutsDelegateImpl and StrutsDelegateFactory (paji@redhat.com)
- 502959 - skip null date values for taskomatic status (shughes@redhat.com)
- Fixed code that would show up even error messages as good messages in the UI
  (paji@redhat.com)
- 504054 - api - errata.getOval - commenting out api (bbuckingham@redhat.com)
- 502941 - Now that 495506 is verified, removing the log message spam.
  (jason.dobies@redhat.com)
- Restore ChannelManager.getLatestPackageEqualInTree. (dgoodwin@redhat.com)
- 484294 - Fix to complain a channel with distros cant be deleted.
  (paji@redhat.com)
- 499399 - api call proxy.createMonitoringScout now return scout shared key
  (msuchy@redhat.com)
- Revert "adding better support for kickstart cent, whereby we install/udpate
  the client packages on all distros and not just RHEL-2,3,4"
  (dgoodwin@redhat.com)
- 499399 - save scout to db (msuchy@redhat.com)
- 504023 - fixing repodata generation to skip solaris custom channels
  (pkilambi@redhat.com)
- 495594, 504012 - Fixed issue where invert flag disappeared on pagination;
  fixed ISE when search produces no results. (jason.dobies@redhat.com)
- 503642 - update KickstartScheduleCommand to store action id after the action
  has been saved to the db (bbuckingham@redhat.com)
- 502905 - fixing issue where non virt kickstarts would show up on virt
  provisioning page (jsherril@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- 502259 - fixing query error that prevented solaris patch clusters from being
  installed (jsherril@redhat.com)
- 503545 - api - system.migrateSystems - update to handle systems that are in a
  system group (bbuckingham@redhat.com)
- 435043 - adding errata sync page for syncing out of date errata (that have
  been updated by red hat) (jsherril@redhat.com)
- 502646 - Fixed list tag filter issue hitting the enter key in IE
  (paji@redhat.com)
- 501224 - api - enhance system.listSystemEvents to include more detail on
  events executed (bbuckingham@redhat.com)
- Made default virt options in a profile configurable and other anomalies
  related to virt options (paji@redhat.com)

* Mon Jun 01 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.23-1
- 496933 - update the errata index when publishing an errata. (jesusr@redhat.com)
- 492206 - Fixed an issue ' bad cobbler template' parsing (paji@redhat.com)
- PackageSearchHandler apidoc cleanup (jmatthew@redhat.com)
- 457316 - Added search for packages in a particular channel. (jason.dobies@redhat.com)
- 502076 - Fixed kickstarting using a system profile (paji@redhat.com)
- 487014 - SystemSearch reducing scrore threshold for a single result to
  redirect to SDC page (jmatthew@redhat.com)
- 501797 - no need to install Monitoring service (msuchy@redhat.com)
- 502923 - Fixed a null pointer that occured on saving non existent xen distro. (paji@redhat.com)
- 490960 - ErrataSearch limit returned results to current or trusted orgs (jmatthew@redhat.com)
- remove todo indicator from code (bbuckingham@redhat.com)
- 501358 - api - channel.software.create - update to provide more detail on
  label/name errors (bbuckingham@redhat.com)
- 499399 - create new api call proxy.createMonitoringScout (msuchy@redhat.com)
- 502848 - adding hooks to better assist automation with the systems channel
  subscription page (jsherril@redhat.com)
- 496105 - Fix for setting up activaiton key for para-host provisioning (paji@redhat.com)
- 498467 - A few changes related to the channel name limit increase. (jason.dobies@redhat.com)
- 502099 - api - update systemgroup.addOrRemoveAdmins to not allow changes to
  access for sat/org admins (bbuckingham@redhat.com)
- Fix tests and actions broken by recent change to set clearing logic. (dgoodwin@redhat.com)
- 472545 - update to the webui translation strings (shughes@redhat.com)
- 502853 - improving support for CentOS by not looking only in the base channel
  for the UPDATE pacakges (jsherril@redhat.com)
- 501387 - adding kernel opts and post kernel opts  to distro edit/create page (jsherril@redhat.com)

* Tue May 26 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.22-1
- 500366 - ssm pkg verify - fix string in resource bundle
  (bbuckingham@redhat.com)
- 501389 - splitting up virt types none and kvm guests, as well as improving
  virt type names (jsherril@redhat.com)
- 500444 - Clear system set when beginning a new config deploy pageflow.
  (dgoodwin@redhat.com)
- 492902 - Updated a config target systems query to include unprovisioned
  machines (paji@redhat.com)
- 502146 - Added validation to custom system info key label to line up with
  macro argument validation. (jason.dobies@redhat.com)
- 502186 - Added missing resource key for solaris patches
  (jason.dobies@redhat.com)
- adding missing slash on paths (jsherril@redhat.com)
- 502068 - having cobbler distro create/edit/sync use correct kernel and initrd
  for ppc distros (jsherril@redhat.com)
- 457350 - adding api for package search with activation key
  (jmatthew@redhat.com)

* Thu May 21 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.21-1
- cleanup duplicate changelog entry
- 501837 - api - doc - update channel.software.listAllPackages / listAllPackagesByDate returns
  (bbuckingham@redhat.com)
- 500501 - improving message displayed when trying to delete a kickstart (jsherril@redhat.com)

* Thu May 21 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.17-1
- Added a comment to the spec (paji@redhat.com)
- 496254 - now requires commons-io (because of fileupload) (paji@redhat.com)
- 457350 - added api for advanced search filtered by channel (jmatthew@redhat.com)
- 501376 - deprecate system.applyErrata (bbuckingham@redhat.com)
- 457350 - added package search apis to match functionality webui provides (jmatthew@redhat.com)
- 501077 - preferences.locale.setTimeZone - fix signature (bbuckingham@redhat.com)
- 501392 - system.schedulePackageRefresh - fix return docs (bbuckingham@redhat.com)
- fixing issue introduced by the recent rewrite of the profile list on
  provisioning wizard pages (jsherril@redhat.com)
- 501065 - fixing issue where guest provisioning would fail if host had a
  system record (jsherril@redhat.com)
- Fixed a null check while sorting for '' attributes (paji@redhat.com)
- changing download file processing to look in a distro path, if the file is an
  rpm and it is not in the channel (jsherril@redhat.com)
- Fixed sorting to use javascript (paji@redhat.com)
- 500895 - allowing creation of kickstart variables with spaces (jsherril@redhat.com)
- 500719 - Ported delete channel page to Java; success/failure messages now
  properly displayed on manage channels page. (jason.dobies@redhat.com)
- 498251 - add new api proxy.listAvailableProxyChannels (msuchy@redhat.com)
- 497404 - Ported KS schedule page to new list tag (paji@redhat.com)
- SearchServer - refactoring package search-server interactions into a helper class (jmatthew@redhat.com)
- SearchServer - fixes free-form search for Documentation Search (jmatthew@redhat.com)
- SearchServer - Fixing "free form" search.  Adding a boolean flag which when passed (jmatthew@redhat.com)
- Added a Radio Column tag to be used with the New List Tag (paji@redhat.com)
- 251920 - fixed small issue where errata status message after being picked up
  (but before finishing) was still showing as pending (jsherril@redhat.com)
- 501074 - fixing issue where ks profile url option was being generated with
  the entire hostname and not just the path (jsherril@redhat.com)
- checkstyle fix, and changing dates to be localized (jsherril@redhat.com)
- 500499 - fixed issue where task engine times were not displayed, the old perl
  code had been ripped out, so i converted it to java (jsherril@redhat.com)
- 491361 - Added note to error messages to check the log for error messages. (jason.dobies@redhat.com)
- 500891 - fixed an unescaped string on snippets delete confirm page (paji@redhat.com)
- 500887 -Fix to not escape contents in cobbler snippet detials page (paji@redhat.com)
- 5/14 update of webui translation strings (shughes@redhat.com)
- 500727 - Just noticed this was flagged as NOTABUG since we don't want to
  allow this functionality, so removing checkbox. (jason.dobies@redhat.com)
- 491361 - Added ability to pass the --ignore-version-mismatch flag to the
  certificate upload page. (jason.dobies@redhat.com)
- 489902 - add help link to Systems->ActivationKeys (bbuckingham@redhat.com)
- 489902 - fix broken help link on ManageSoftwareChannels pg (bbuckingham@redhat.com)
- Fixed unit tests (paji@redhat.com)
- 432412 - update context help link for Config Mgmt page (bbuckingham@redhat.com)
- 497424 - Slight redesign of the KS Virt UI to deal with duplicate virt paths (paji@redhat.com)
- 500160 - fix precision on org trust details page for date (shughes@redhat.com)
- Fixed incorrect message key (jason.dobies@redhat.com)
- 499980 - Clear the set after adding the packages in case the user hits the
  back button and tries to submit it twice. (jason.dobies@redhat.com)
- 500482 - deprecate kickstart.listKickstartableTrees (bbuckingham@redhat.com)
- 500147 - update update errata list/remove to use advisoryName vs advisory (bbuckingham@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- fixing issue where kickstart file was not written during Cobbler Profile creation (jsherril@redhat.com)
- 500415 - api - deprecating errata.listByDate (bbuckingham@redhat.com)
- 495506 - Added temporary verbose logging in case of failed ACL checks for
  package details page to debug this issue in the next QA build; will remove
  afterwards. (jason.dobies@redhat.com)
- 497119 - channel changes - update to use hibernate refresh vs reload (bbuckingham@redhat.com)
- major cleanup of build files: reformat, remove old targets, etc. (jesusr@redhat.com)
- removing duplicate query and fixing small issue with errata add page (jsherril@redhat.com)
- Added new 'rhn:required-field' tag to help with displayed required fields in UI. (paji@redhat.com)
- 494930 - distros of the same label cannot exist in 2 different orgs fixed (jsherril@redhat.com)
- 500169 - changing cobbler path doesn't change distro kernel and initrd paths (jsherril@redhat.com)
- 472545 - updated  translations strings for java webui (shughes@redhat.com)
- 499537 - removing references to faq links (shughes@redhat.com)
- 499515 - fix ISEs with Solaris patch install/remove and cluster install (bbuckingham@redhat.com)
- Fixed a compile error that occured with 1.5 compilers (paji@redhat.com)
- 499473 - api - added 2 new api calls to org for listing entitlements (bbuckingham@redhat.com)
- 499508 - Removed Run Remote Command buttons from package install/upgrade (jason.dobies@redhat.com)

* Thu May 07 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.16-1
- remove @Override for java 1.5 builds (jesusr@redhat.com)

* Thu May 07 2009 Justin Sherrill <jsherril@redhat.com> 0.6.15-1
- Split log4.properties files into two so taskomatic and tomcat are using different ones 

* Thu May 07 2009 Tomas Lestach <tlestach@redhat.com> 0.6.14-1
- 499038 - channel list doesn't contain non globablly subscribable channels
  (tlestach@redhat.com)

* Wed May 06 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.13-1
- 469937 - Fixed a deactivateProxy issue. (s/reload/refresh) (paji@redhat.com)
- 499258 - update Alter Channel Subscriptions to not ISE when base channel is
  changed (bbuckingham@redhat.com)
- 499037 - fixing issue wher errata cache entires werent being generated if an
  errata publication did not cause packages to be pushed to a channel
  (jsherril@redhat.com)
- 495789 - fixing issue where taskomtaic would create the api log first,
  thereby stopping tomcat from being able to write to it (jsherril@redhat.com)
- 437361 - Added all orgs (except default org) to the entitlement's org subtab.
  (jason.dobies@redhat.com)
- unit test fixes (jlsherri@justin-sherrills-macbook-2.local)
- 499233 - Download CSV link on monitoring page should have the same look as on
  others pages (msuchy@redhat.com)
- unit test fix (jsherril@redhat.com)
- 499258 - update Alter Channel Subscriptions to not ISE when base channel is
  changed (bbuckingham@redhat.com)
- compile fix (jsherril@redhat.com)
- Fixed an accidental removal of a string resource entry (paji@redhat.com)
- Applying changes suggested by zeus (paji@redhat.com)
- 499046 - making it so that pre/post scripts can be templatized or not,
  defaulting to not (jsherril@redhat.com)
- Changed the gen-eclipse script to add things like tools.jar and ant-junit &
  ant.jar (paji@redhat.com)
- 433660 - Removed the restriction in the UI that prevents orgs with 0
  entitlements from being shown on the org page of an entitlement.
  (jason.dobies@redhat.com)

* Mon May 04 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.12-1
- add BuildRequires for jakarta-commons-codec (jesusr@redhat.com)
- remove our requirement on commons-configuration (jesusr@redhat.com)
- 498455 - fixing tooltip for guests alter channel subscription page
  (jsherril@redhat.com)
- fixing junit breakage for ChannelFactoryTest (shughes@redhat.com)
- unit test fix (jsherril@redhat.com)
- unit test fix (jsherril@redhat.com)
- fixing unit test by fixing bad hibernate mapping (jsherril@redhat.com)
- unit test fix (jsherril@redhat.com)
- changing junit tests to use joust (jsherril@redhat.com)
- fixing unit test (jsherril@redhat.com)
- 497122 - Fixed error message where no selected organizations would appear as
  a selection error. (jason.dobies@redhat.com)
- 498441 - fixing issue where removing package from a channel didnt regenerate
  repo cache (jsherril@redhat.com)
- 498275 - api - system.obtainReactivationKey updated to replace existing key
  (bbuckingham@redhat.com)

* Thu Apr 30 2009 Tomas Lestach <tlestach@redhat.com> 0.6.10-1
- 454876 - not setting cookie domain (tlestach@redhat.com)
- 497458 - fixing ISE with errata cloning (jsherril@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- 219179 - setting redhat_management_server for the system records like we do
  for server (jsherril@redhat.com)
- 480011 - Added organization to the top header near the username.
  (jason.dobies@redhat.com)
- 497867 - fixed bug in logic after changing hibernate mappings
  (jsherril@redhat.com)
- 497917 - fixing issue where select all did not work on errata list/remove
  packages (jsherril@redhat.com)
- 497867 - fixing reboots taking place even if provisioning fails
  (jsherril@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- 219179 - fixed some issues related to reprovisioning through proxy
  (jsherril@redhat.com)
- 481578 - Ported manage software channels page from perl to java
  (jason.dobies@redhat.com)
- 498208 - cobbler webui string correction (shughes@redhat.com)
- 461704 - clean time_series when deleting a monitoring probe
  (mzazrivec@redhat.com)
- 497925 - we search and replace the cobbler host with proxy
  (mmccune@gmail.com)
- Added code to ensure name is required .... (paji@redhat.com)
- 497872 - skip 'fake' interfaces when looking up system records.
  (mmccune@gmail.com)
- Updated the Kickstart Advanced mode page to include edit area instead of the
  standard text area for uploading kicktstart information.. (paji@redhat.com)
- 497964 - Made the config file create and file details page use edit area..
  Fancy editor... (paji@redhat.com)
- 444221 - Updated the Create/Modify and the delete snippets pages based on
  Mizmo's suggestions (paji@redhat.com)
- 489902 - fix help links to work with rhn-il8n-guides (bbuckingham@redhat.com)
- Checkstyle fixes (jason.dobies@redhat.com)
- 494627 - Added more fine grained error messages for invalid channel data.
  (jason.dobies@redhat.com)
- 485849 - merging RELEASE-5.1 bug into spacewalk (mmccune@gmail.com)
- 496259 - greatly improved errata deletion time (jsherril@redhat.com)
- 444221 - Cobbler Snippet Create page redesign (paji@redhat.com)
- 444221 - Initial improvement on Cobbler Snippets List page based on the bug..
  (paji@redhat.com)

* Fri Apr 24 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.8-1
- removing some debug statements (jsherril@redhat.com)
- 495961 - greatly improving performance of add errata page (jsherril@redhat.com)
- Removed outdated @version requirement (jason.dobies@redhat.com)
- 497119 - support to remove child channel subscriptions from orgs that have
  systems subscribed when denied access to protected channel (shughes@redhat.com)
- 495846 - Oops, missed a file (jason.dobies@redhat.com)
- 495847 - New ListTag 3 functionality to add selected servers to SSM.
  (jason.dobies@redhat.com)
- 497538 - remove shared child channel subscriptions when removing subscription
  from parent (shughes@redhat.com)

* Thu Apr 23 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.7-1
- 496080 - Fix channel with package lookup to filter on org.
  (dgoodwin@redhat.com)

* Wed Apr 22 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.6-1
- 496719 - generate error for invalid keys in input maps (bbuckingham@redhat.com)
- 494976 - adding missing file (jsherril@redhat.com)
- 496303 - 'select all' button fixed on errata list/remove packages page (jsherril@redhat.com)
- 480010 - minor syntax changes to organization channel sharing consumption (shughes@redhat.com)
- Fixed a couple of bugs related to the snippets page. (paji@redhat.com)
- 496272 - Updates/clean up to relogin text. (jason.dobies@redhat.com)
- 496710 - system.listSystemEvents - convert dates in return to use Date (bbuckingham@redhat.com)
- 494976 - adding cobbler system record name usage to reprovisioning (jsherril@redhat.com)
- 495506 - Fixed issue when determining package ACLs. (jason.dobies@redhat.com)
- Removed a couple of needless if statements (paji@redhat.com)
- Added some unit tests for the cobbler snippets (paji@redhat.com)
- 495946 - Rewrite of Cobbler Snippets. (paji@redhat.com)
- 496318 - api - unable to register system using key generated by
  system.obtainReactivationKey (bbuckingham@redhat.com)
- 467063 - Fixed issue where the form variables were reset when the page size
  was changed. (jason.dobies@redhat.com)
- 496666 - apidoc - add some deprecations to the activation key handler
  (bbuckingham@redhat.com)
- 443500 - Changed logic to determine packages to remove to include the
  server's current package information. (jason.dobies@redhat.com)
- 495897 - Fix broken Activated Systems links. (dgoodwin@redhat.com)
- adding fallbackAppender for log4j (jsherril@redhat.com)
- fixing checkstyle and a commit that did not seem to make it related with
  log4j (jsherril@redhat.com)
- 496104 - fixing double slash and downloads with ++ in the filename. (mmccune@gmail.com)
- 495616 - throw permission error if url is modified (jesusr@redhat.com)
- fixing error in specfile after accidental commit of
  d8903258b897c9d6527a1a64b70b8a2610c2e3ce (jsherril@redhat.com)

* Mon Apr 20 2009 Partha Aji <paji@redhat.com> 0.6.5-1
- 495946 - Got a workable edition of cobbler snippets.

* Fri Apr 17 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.4-1
- 495789 - changing the way apis are logged to fall back to RootAppender if
  there is an error (jsherril@redhat.com)
- logrotate (jsherril@redhat.com)
- 496161 - fixing broken system group links (jsherril@redhat.com)
- 495789 - enabling api logging by default (jsherril@redhat.com)
- 494649 - fix resource bundle text for changing channel to protected
  (bbuckingham@redhat.com)
- 496003 - api - fix system.isNvreInstalled(n,v,r) to properly handle packages
  that have an epoch (bbuckingham@redhat.com)
- 494450 - api - add permissions_mode to ConfigRevisionSerializer & fix doc on
  system.config.createOrUpdatePath (bbuckingham@redhat.com)
- 493163 - fixing ISE when renaming distros and profiles (jsherril@redhat.com)

* Thu Apr 16 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.3-1
- remove Proxy Release Notes link and unused Developer's area. (jesusr@redhat.com)
- 487209 - enhanced system search for hardware devices (jmatthew@redhat.com)
- 450954 - changing reprovisioning to allow reactivation with an activation key
  of a conflicting base channel (jsherril@redhat.com)
- 487185 - Fixed system-search by needed package (jmatthew@redhat.com)
- 494920 - fixing ISE when cloning errata, after channel was cloned
  (jsherril@redhat.com)
- Fix null pointer in scheduleAutoUpdates(). (jortel@redhat.com)
- SystemSearch lowering threshold of a single match to cause a redirect to SDC.
  (jmatthew@redhat.com)
- 495133 - changing send notifications button to populate channel id as well
  (jsherril@redhat.com)
- 495133 - fixing errata mailer such that mails are only sent for a particular
  channel that was changed (jsherril@redhat.com)
- 495065 - channel name appears on private/protected confirm page
  (jesusr@redhat.com)
- 492906 - Fixed spacewalk reference in cobbler config (paji@redhat.com)
- 491130 - improved a kickstart edit page message a little more..
  (paji@redhat.com)
- 491130 - improved a kickstart edit page message.. (paji@redhat.com)
- 494673 - update system migration to support null config channels
  (bbuckingham@redhat.com)
- Clarifying that search must be restarted after running cleanindex
  (jmatthew@redhat.com)
- 487158 - SystemSearch fixed search by customInfo (jmatthew@redhat.com)
- 458205 - Fixed KS Ipranges URL (paji@redhat.com)
- 495786 - fixing issue where some updates were being ignored for RHEL 4
  systems (jsherril@redhat.com)
- 487192 - Fixed system search, search by registration (jmatthew@redhat.com)
- 490904 - change all references to /rhn/help/*/en/ -> /rhn/help/*/en-US/
  (jesusr@redhat.com)
- fix duplicate string resource entry (jesusr@redhat.com)
- 480674 - allow shared channels to appear in act. keys creation
  (jesusr@redhat.com)
- 495585 - fixing Errata Search by Issue Date (jmatthew@redhat.com)
- SystemSearch fix hwdevice result gathering.  Keep highest scoring match per
  system-id (jmatthew@redhat.com)
- 488603 - Fix to deal with blank space interpreter for post scripts
  (paji@redhat.com)
- 234449 - moved block of code to only count real downloads (mmccune@gmail.com)
- 488603 - KickstartFileFormat fix, to deal with blank space interpreter
  (paji@redhat.com)
- 492902 - Fixed 2 queries for Config Target Systems page (paji@redhat.com)
- 486029 - being more consistent with the kickstart label  string
  (jsherril@redhat.com)
- 493163 - fixing ise on update distro page with RHEL 4 distros
  (jsherril@redhat.com)
- 494884 - sub class needs to have protected method to behave as desired
  (jsherril@redhat.com)
- checkstyle fix (jsherril@redhat.com)
- 493647 - Fix for unselect all malfunction... (paji@redhat.com)
- 443500 - Refactored SSM remove packages to only create a single action for
  all servers/packages selected. (jason.dobies@redhat.com)
- 494914 - fix to create a network interface for cobbler system records on
  guest provisioning (jsherril@redhat.com)
- 493718 - minor syntax message change for private channel access
  (shughes@redhat.com)
- 493110 - Changed package installation through SSM to only create one action
  (jason.dobies@redhat.com)
- 494686 - changing it such that you have to provide a virt guest name, not
  letting koan make one (jsherril@redhat.com)
- Fixed the cobbler MockConnection to work with find_* calls (paji@redhat.com)
- api doclet - enhanced to support a 'since' tag, tagged snapshot apis and
  bumped api version (bbuckingham@redhat.com)
- 487566 - fix broken junit in ServerFactoryTest (bbuckingham@redhat.com)
- 442439 - internationalize strings for system search csv export
  (jmatthew@redhat.com)
- 442439 - enhancing csv for systemsearch (jmatthew@redhat.com)
- 494593 - fixing the repofile compare to use the right type for java date
  object obtained through hibernate (pkilambi@redhat.com)
- Updated documentation (jason.dobies@redhat.com)
- 493744 - Added configuration admin ACL to configuration tab
  (jason.dobies@redhat.com)
- 487566 - api/script - initial commit of snapshot script and mods to snapshot
  apis (bbuckingham@redhat.com)
- bumping the protocol version on exporter (pkilambi@redhat.com)
- 492206-Fix for Kickstart Profile Template parse error. (paji@redhat.com)
- 492206-Fix for Kickstart Profile Template parse error. (paji@redhat.com)
- 484435 - add union to query to allow shared child channel subscription access
  (shughes@redhat.com)
- 442439 - system search CSV update to dataset name (jmatthew@redhat.com)
- Removing the last bastions of 1.4 code.. Where logic went like if cobbler
  version < 1.6 do one set else do other wise... (paji@redhat.com)
- Made the configuraiton manager instance static final instead of just static..
  Made no sense for it to be static... (paji@redhat.com)
- 494409 - unsubscribe affected systems after trust removal
  (shughes@redhat.com)
- 494475,460136 - remove faq & feedback code which used customerservice emails.
  (jesusr@redhat.com)
- 487189 -  System Search fixed search by checkin (jmatthew@redhat.com)
- fixing small NPE possibility (jsherril@redhat.com)
- 492949 - setting cobblerXenId appropriately (jsherril@redhat.com)
- 492949 - having CobblerSync task, reuse existing distros if they already
  exist (by name) (jsherril@redhat.com)
- adding single page doclet supporting macros (jsherril@redhat.com)
- 443132 - couple of small fixes for the revamped action pages
  (jsherril@redhat.com)

* Sun Apr 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.2-1
- 470991 - remove unused jar files from taskomatic_daemon.conf (jesusr@redhat.com)
- 437547 - include instructions for regenerating indexes (jmatthew@redhat.com)
- 483611 - Remove search links from YourRhn tasks module (jmatthew@redhat.com)
- 480060 - improve performance of All and Relevant (mmccune@gmail.com)
- 494066 - removed the trailing \n from strings returned from cobbler. (mmccune@gmail.com)
- 489792 - listErrata api docuementation corrected (jsherril@redhat.com)
- 484659 - taskmoatic no longer throws cobbler errors on restart (jsherril@redhat.com)
- 221637 - Removed no-op channels from SSM subscribe config channels (jason.dobies@redhat.com)
- 490866 - distros now properly synced after sat-sync (jsherril@redhat.com)
- 493173 - add redirect in struts config for errata/manage/Delete (bbuckingham@redhat.com)
- 487418 - Added a 'None' option to the available virt type (paji@redhat.com)
- 493187 - Changed empty list message to be a variable and set in calling pages specific to need (published v. unpublished) (jason.dobies@redhat.com)
- fix junit assertion error in testDeleteTreeAndProfiles (bbuckingham@redhat.com)
- 485317 - phantom kickstart sessions no longer show up on kickstart overview (jsherril@redhat.com)

* Thu Apr 02 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.1-1
- 481130 - Move preun scriptlet to taskomatic subpackage. (dgoodwin@redhat.com)
- 487393 - fixed issue where list count was wrong on provisioning page
  (jsherril@redhat.com)
- 493111 - api - errata.delete added & fixed add/removePackages & setDetails to
  only modify custom errata (bbuckingham@redhat.com)
- 493421 - api - kickstart.tree.deleteTreeAndProfiles fixed to delete
  associated profiles (bbuckingham@redhat.com)
- 487688 - adding text during ks tree creation to explain more detail of what
  is needed (jsherril@redhat.com)
- 462593 - fixing issue where creating or renaming a profile with a name that
  already exists would give ISE (jsherril@redhat.com)
- 492903 - api - channel.software.create - updates so that new channels will
  show on Channel tab (bbuckingham@redhat.com)
- 492980 - api - errata.getDetails - add release, product and solution to
  return and clarify last_modified_date in docs (bbuckingham@redhat.com)
- 458838 - adding new files for kickstart exception 404 (jsherril@redhat.com)
- 490987 - fixed issue where errata files werent being refreshed, by removing
  the need for errata files (jsherril@redhat.com)
- 458838 - changing kickstart download 404s to have a descriptive message
  (jsherril@redhat.com)
- removed jasper5* from run time dependencies and made them build time
  instead. (paji@redhat.com)
- 489532 - unsubscribe multiorg shared channel when moving access from public
  to protected with deny selection (shughes@redhat.com)

* Mon Mar 30 2009 Mike McCune <mmccune@gmail.com> 0.5.44-1
- 472595 - ported query forgot to check child channels
- 144325 - converting system probe list to the new list tag, featuring all the bells and 
  whistles the new list tag has to offer
- 492478 - modifying the system applicable errata page so that you can filter on the 
  type of errata you want to see, also linking a couple of critical errata li
- 467063 - Port of clone errata functionality to new list tag
- 492418 - adding missing channel title when creating new software channels
- 492476 - fixing issue where critical  plus non-critical errata for a system (on the system details page) did not  total errata
- 492146 - fixing issue where system icons are not clickable


* Thu Mar 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.41-1
- 437359 - redirect org creation to the orgsystemsubscription page
- 489007 - add system.getConnectionPath for listing proxies a server connected through
- 489736 - generate non-expiring kickstart package download url
- 489736 - download_url_lifetime of 0 disables expiration server wide
- 489736 - can disable expiration by package name by non_expirable_package_urls
- 489486 - added updated message when changing channel access from public to private
- Adding support for comps info to be added to repomd.xml.
- Updated documentation

* Thu Mar 26 2009 Mike McCune <mmccune@gmail.com> 0.5.40-1
- 492137 - fixing ISE for virt 

* Thu Mar 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.39-1
- 484852 - user taken to meaningful error pages instead of ISEs.

* Wed Mar 25 2009 Partha Aji <paji@redhat.com> 0.5.38-1
- Added code to take advantage of cobbler 1.6 perf enhancements
- if the customer has that installed.

* Wed Mar 25 2009 Mike McCune <mmccune@gmail.com> 0.5.37-1
- 491978 - fixing status reporting in webui for kickstarts.
- Added resource bundle entries for admin/config/Cobbler.do
- 467063 - Ported published and unpublished errata to new list tag to get new navigation features
- 446269 - fixed issue where you could not remove a package from a system 

* Fri Mar 20 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.36-1
- bring over jta from satellite build.
- fix the jfreechart requires to be 0:1.0.9 everywhere

* Thu Mar 19 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.34-1
- ServerFactory - fix wording in method header
- 486212 - api - added system.deleteCustomValues

* Thu Mar 19 2009 Mike McCune <mmccune@gmail.com> 0.5.33-1
- 474774 - adding jfreechart 1.0 version requires

* Wed Mar 18 2009 Mike McCune <mmccune@gmail.com> 0.5.31-1
- 486186 - Update spacewalk spec files to require cobbler >= 1.4.3

* Thu Mar 12 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.30-1
- fixed iprange delete URLs weren't being correctly rendered
- 480432 - fixed kickstart urls: .../rhn/kickstart/ks/cfg/org/1/org_default
- 489792 - fixing incorrect api return types
- 489775 - fixing listErrata api due to bad query
- 481180 - update KickstartFormatter to use StringUtils on --interpreter check

* Wed Mar 11 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.29-1
- 489760 - used cheetah's #errorCatcher Echo to handle escaping in ks files.
- 249459 - fixing issue where org trust page was busted
- 488137 - refer to cobbler_api instead of cobbler_api_rw to support cobbler >= 1.6
- update deprecated methods in ChannelSoftwareHandler to be more consistent
- 484463 - added more cobbler bits to the kickstart formatter that were missing
- 488830 - api - auth handler - remove the public doc for checkAuthToken
- apidoc generation now ignores an individual call using @xmlrpc.ignore
- added taskomatic task to regenerate deleted kickstart wizard files
- Fixed the ks-setup.py script to function correctly w.r.t space05 changes
- 481180 - do not include --interpreter in profile for scripts without scripting lang
- fix indentations to make it more readable
- Removed code that was getting ignored.
- 489577 - fixing issue that caused taskomatic tracebacks when talking to cobbler
- 489363 - add missing exception class...
- 489363 - api - system.createPackageProfile did not include pkg arch in profile
- 489426 - fixing cloning of kickstarts for regular and raw style
- 489347 - fixing "File Location" field on OS tab to show the --url param
- 483287 - Added ability to do a cobbler sync thru the UI
- adding missing param, for channel name to show up in header
- 483776 - fixing ISE (NPE) on clone errata page
- 462079 - fixed issue where an auto-scheduled errata had name of  "null - null"
- 467265 - fixing issue where errata list was sorting date incorrectly
- fixing package delete to delete from a couple more tables
- 489042 - api - org.setSystemEntitlements - supports setting base entitlements.
- added list of supported entitlements to the api doc
- 488999 - c.s.setUserSubscribable documented value as string while impl
- expected a primitive boolean as input instead of Boolean
- 488148 - test fixes related to bugzilla
- 488148 - use pre-existing system record if there is one.
- 489033 - correcting type of trustOrgId in org.trust.addTrust and removeTrust
- 488990 - api - remove addTrust, removeTrust, listTrusts apis from org handler.
- 488548 - api - org.migrateSystems - fix reactivationkeys, custom info and config
- 488348 - use channel org_id to prevent returning RH channels in addition to custom
- Fixed variable name typo.
 
* Fri Mar 06 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.28-1
- added ExcludeArch: ia64

* Thu Mar 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.27-1
- revert commit ba62c229
- changing MockConnection and MockXmlrpcInvoker to handle multiple entities
- 488723 - handling ise for channel packages listing
- 488379 - Syntax error in sql query causing ISE corrected
- 487317 - entitlement verbage change for error message
- 484284 - fixing create/updates messages for custom channel edit actions
- 488622 - api - kickstart.profile.addIpRange updated to validate input
- 487563 - switching take_snapshots to enable_snapshots
- 193788 - converting a few pages to java, so we can sort better
- adding check to looking up cobbler id if its null
- 466195 - apis - rename system.listBaseChannels and system.listChildChannels
- 488277 - remove rhn-highlight from href address
- 485313 - update string to remove extra space
- 484305 - Refactored to keep the package deletion heavy lifting in the DB, avoids OutOfMemoryErrors.
- 480012 - allow sharing org to see shared errata.
- 487234 - fix the query used by the system->software->upgrade page

* Mon Mar 02 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.26-1
- add bcel to BuildRequires

* Fri Feb 27 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.25-1
- Profile rename has been finally fixed
- 469921 - system.scheduleSyncPackagesWithSystems generated a NullPointerException
- fixing mistake in method name
- 485120 - fixed issue where changing org
- name or changing profile name breaks kickstarts (including raw).  Also moved kickstart file location

* Thu Feb 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.24-1
- removing listScripts, addScript, removeScript and downloadKickstart APIs from KickstartHandler
- 486749 - Add symlinks for jakarta-commons-collections and jta jars.
- 484942 - "Satellite" is in monitoring schema and have to be translated to product name

* Thu Feb 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.23-1
- modifying list tag to not clear set during a select all()
- fixing some issues with converting rhnset to implement set
- Fix to a cobbler rename profile issue...
- making edit command a bit more relaxed if there is no associated cobbler profile
- 486606 - Changed query and page to load/display arch for each package selected
- 487066 - change create link to be lowercase (create new key).
- 482879 - fixing compile error and syncing whenever we update a ksdata
- 482879 - make sure we add all the activation keys to the cobbler profile
- 486982 - fixed ise on software upgrade list
- 480191 - fix query used by systems->software->packages->install
- 487174 - fixing issue where clearing the filter, resulted in the page being submitted
- 241070 - select all on filtered list would select the entire list and not just what was filtered.
- 483555 - Ported to new list tag to get Select All functionality correct when a filter is active.

* Tue Feb 24 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.22-1
- fixing the repodata task queries to avoid tempspace issues
 
* Thu Feb 19 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.21-1
- 486502 - Changed order when list a group of systemIds so top result is highest.
- Fixing problem which broke unique documents in the lucene index.
- 486502 - Sort similar results by systemId with highest ID on the bottom
- SystemSearch change redirect behavior if only 1 result is found.

* Thu Feb 19 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.20-1
- 484768 - Basically fixed a query and DTO and a Translator to correctly 
- 486174 - Was using the incorrect key in the filterattr attribute on the
- kickstart session status where ks is syncing to a profile has an correc
- 456315 - refixing this bug, changing kickstart commands to be a Collect
- Changed the hard coded 500 value to BATCH size :)
- 444517 - Added snapshot hook to configuration channel subscription via 
- 485047 - adding back the Task_queries find_channel_in_task_queue query
- 437547, 485313 - Added exception message for when index files are missi
- Adding 'Errata' search to Tasks under YourRhn.do
- 483607 -  Adding documentation as an option to the search bar
- 219844 -  Add 'legend' for Errata Search
- Cleanup, removed commented out code

* Wed Feb 18 2009 Dave Parker <dparker@redhat.com> 0.5.19-1
- 486186 - Update spacewalk spec files to require cobbler >= 1.4.2

* Mon Feb 16 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.18-1
- yum repodata regen changes to taskomatic

* Mon Feb 16 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.16-1
- 458355 - show Monitoring tabs only if Monitoring Backend or Monitoring Scout is enabled
- 481766 - Corrected the text on Ks Distribution page to reflect the exact nature of the value to be
- 483796 - fixed bug where ip address would show up as 0
- 469957 - Updated getDetails to use first_name instead of first_names
- 485500 - fixed ISE when deleting errata
- 469957 - Added translation in XMLRPC API layer to accept first_name instead of "first_names"
- handler-manifest.xml used by xmlrpc api was pointing to wrong location for a class...:(
- 466295 - Added date format as description on the property
- Removing duplicate setKickstartTree API

* Thu Feb 12 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.13-1
- 484312 - more cleanup for kickstart AUTO virt type removal
- 484312 - massive cleanup of virt types.  getting rid of useless AUTO type.

* Thu Feb 12 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.12-1
- 484911 - fixed issue where taskomatic won't sync to cobbler newly sat-synced
- Moving SystemDetailsHandler.java and its junit test out of kickstart.profile
- 199560 - Fix epoch being returned as ' ' in channel.software.list_all_package
- 484262 - Updated documentation as per the bz
- 483815 - minor messaging change for custom channel pkg removal
- 452956 - Need to check to make sure the DMI actually contains data before at
- 484435 - needed parent_channel is null when selecting from rhnsharedchannelv
- 480674 - fixed query in Channel.hbm.xml to know about shared channels. Chang
- 485122 - api - kickstart.profile.system.getPartitioningScheme was incorrectl
- 485039 - apidoc - channel.software.removePackages - fix wording on return va
- remove + which hoses the urls in org trusts page

* Wed Feb 11 2009 Dave Parker <dparker@redhat.com> 0.5.11-1
- 484659 remove error messages due to incorrect startup sequences from sysv and from the rhn-satellite tool
* Thu Feb 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.10-1
- Properly run the status through the message bundle for i18n

* Thu Feb 05 2009 Mike McCune <mmccune@gmail.com> 0.5.9-1
- 481767 - be more forgiving of busted kickstart distros during a sync and also report errors in an email.
- 442601 - api - adding access to server lock/unlock
- Restructured to an inversion of control pattern to make it more clear that the mode/summary key are not meant to be attributes.
- 443718 - fixing a view mistage and having a query just use the view
- 483603 - Added details page for listing servers involved in a particular SSM operation
- update the header to 2009 and fix the very annoying whitespace after the *.
- fixing Action classes that have non-final member variables
- 251767 - api - channel.software.setSystemChannels - throw better exception when user passes multiple base channels as input
- 467063 - Added page decorator to allow variable amount of items to be shown
- 437872 - added multiorg messaging suggestion for entitlement warnings
- 483603 - First pass at display of async SSM operations in the UI
- 437563 - adding success message for sat admin toggles
- 479541, 483867 - replaced runuser with /sbin/runuser
- 483603 - Renamed query file; added ability to retrieve servers associated with an operation
- 481200 - api - fix minor issues in apidoc for activationkey apis
- 483689 - api doc updates for channel.software listAllPackages and listAllPackagesByDate apis
- 483806 - updating more iso country codes
- 482929 - fixing messaging with global channel subscriptions per user
- 480016 - adding ID to org details page for information (assist with migration scripts)
- 443718 - improving errata cache calcs when pushing a single errata

* Mon Feb  2 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.8-1
- 480126 - deactivate proxy different way
- 477532 - fixed issue where channels would dissappear after hiding the children

* Fri Jan 30 2009 Mike McCune <mmccune@gmail.com> 0.5.7-1
- removing requirement for spacewalk-branding-jar

* Fri Jan 30 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.6-1
- 483058 - subscribe to proxy channel if requested
- 482923 - splitting out the java branding jar file into its own subpackage
- 459085 - Added (and defaulted) option for Do Nothing
- 469984 - Restructuring to avoid DB hits entirely if there are no channels selected to either subscribe or unsubscribe.

* Wed Jan 28 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.5-1
- 468052 - throw exception if proxy do not has provisioning entitlement
- 481671 - improved the performance of a query
- 469984 - speeding up the bulk channel subscription changes
- 481778 - fix NPE when deleting an unpublished errata
- 480003 - minor grammar change for private channel access
- 428419 - always use the cobbler server when showing URLs for kickstarts
- added ks-setup.py script to add a profile, channel, distro and activation key ..

* Thu Jan 22 2009 Dennis Gilmore <dennis@ausil.us> 0.5.4-1
- update java and java-devel Requires and BuildRequires to 1.6.0

* Wed Jan 21 2009 Devan Goodwin <dgoodwin@redhat.com> 0.5.3-1
- Remove dependency on spacewalk-taskomatic and spacewalk-search.

* Wed Jan 21 2009 Michael Mraka <michael.mraka@redhat.com> 0.5.2-1
- fixed branding stuff

* Tue Jan 20 2009 Mike McCune <mmccune@gmail.com> 0.4.17-1
- 480636 - simplifying the commands vs options into one real collection 
  managed by hibernate vs 2 that both contained the same things

* Thu Jan 15 2009 jesus m. rodriguez <jesusr@redhat.com> 0.4.16-1
- 456467 - Fixed bug where the set of packages to remove was being cleared
- before scheduling

* Wed Jan 14 2009 Mike McCune <mmccune@gmail.com> 0.4.15-1
- 461162 - properly fetch guest name from form

* Tue Jan 13 2009 Mike McCune <mmccune@gmail.com> 0.4.14-1
- 461162 - adding org to system record name
- 461162 - unit test fixes.

* Mon Jan 12 2009 Mike McCune <mmccune@gmail.com> 0.4.12-1
- Boatload of changes from end of 0.4 set of bugs/features

* Tue Jan 06 2009 Mike McCune <mmccune@gmail.com> 0.4.11-1
- Latest spacewalk 0.4 changes.

* Tue Dec 23 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.10-1
- modified layout decorators

* Mon Dec 22 2008 Mike McCune <mmccune@gmail.com> 0.4.9-1
- Adding proper cobbler requirement with version

* Fri Dec 19 2008 Mike McCune <mmccune@gmail.com> 0.4.8-1
- latest changes

* Thu Dec 11 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.7-1
- resolved #471225 - moved rhn-sat-restart-silent to /usr/sbin

* Mon Dec  8 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.6-1
- fixed Obsoletes: rhns-* < 5.3.0

* Fri Dec  5 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.5-1
- removed rhn-oracle-jdbc

* Thu Nov 20 2008 Miroslav Suchy <msuchy@redhat.com> 0.4.2-1
- 472346 - Bump up API version and make the versioning independent on web.version

* Tue Nov  4 2008 Miroslav Suchy <msuchy@redhat.com>
- 461517 - password and db name are swapped

* Fri Oct 31 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.3.7-1
- 467945 - fixed issue where part of the ssm required you to be an org admin

* Thu Oct 23 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.3.6-1
- comment the logdriver statements again.
- Fixed some set related issues.
- Updated query to only count outranked channels if the channel
- contains the file.

* Wed Oct 22 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.3.5-1
- fix stringtree-spec Requires

* Wed Oct 22 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.3.4-1
- add stringtree-spec (Build)Requires

* Tue Oct 21 2008 Michael Mraka <michael.mraka@redhat.com> 0.3.3-1
- resolves #467717 - fixed sysvinit scripts
- resolves #467877 - use runuser instead of su

* Wed Sep 17 2008 Devan Goodwin <dgoodwin@redhat.com> 0.3.1-1
- Re-version for 0.3.x.
- Add BuildRequires: jsp for RHEL 4.

* Fri Sep  5 2008 Jan Pazdziora 0.2.7-1
- add BuildRequires: javamail, needed on RHEL 4.

* Tue Sep  2 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.6-1
- Rebuild to include new kickstart profile options.

* Fri Aug 29 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.2.5-1
- Remove dependency on jsch and ant-jsch.

* Fri Aug 29 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.4-1
- Remove dependency on bouncycastle and wsdl4j.

* Wed Aug 27 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.2-1
- Build fix for velocity.jar.

* Tue Aug 26 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.1-1
- Bumping to 0.2.0.

* Mon Aug 25 2008 Mike McCune 0.2-1
- remove ivy BuildRequires and adding jakarta-commons-cli

* Tue Aug 20 2008 Mike McCune <mmccune@redhat.com> 0.2-1
- more work on rename to spacewalk-java

* Tue Aug  5 2008 Miroslav Suchy <msuchy@redhat.com> 0.2-0
- Renamed to spacewalk-java
- cleanup spec

* Thu May 22 2008 Jan Pazdziora 5.2.0-5
- weaken hibernate3 version requirement

* Fri May 16 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-3
- fixed file ownership
- fixed optimizer settings for Oracle 10g

* Thu May 15 2008 Jan Pazdziora - 5.2.0-1
- spec updated for brew builds
