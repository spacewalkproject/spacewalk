%define cobprofdir      %{_localstatedir}/lib/rhn/kickstarts
%define cobprofdirup    %{_localstatedir}/lib/rhn/kickstarts/upload
%define cobprofdirwiz   %{_localstatedir}/lib/rhn/kickstarts/wizard
%define cobdirsnippets  %{_localstatedir}/lib/rhn/kickstarts/snippets
%define realcobsnippetsdir  %{_localstatedir}/lib/cobbler/snippets

%if 0%{?fedora} || 0%{?rhel} >= 7
%define appdir          %{_localstatedir}/lib/tomcat/webapps
%define jardir          %{_localstatedir}/lib/tomcat/webapps/rhn/WEB-INF/lib
%else
%define appdir          %{_localstatedir}/lib/tomcat6/webapps
%define jardir          %{_localstatedir}/lib/tomcat6/webapps/rhn/WEB-INF/lib
%endif

%if 0%{?rhel} || 0%{?fedora}
%define run_checkstyle  1
%endif

Name: spacewalk-java
Summary: Java web application files for Spacewalk
License: GPLv2
Version: 2.9.4
Release: 1%{?dist}
URL:       https://github.com/spacewalkproject/spacewalk
Source0:   https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch: noarch
ExcludeArch: ia64

Requires: apache-commons-fileupload
Requires: bcel
Requires: c3p0 >= 0.9.1
Requires: cglib
Requires: cobbler20
Requires: dwr >= 3.0.2
Requires: hibernate3 >= 3.6.10
Requires: hibernate3-c3p0 >= 3.6.10
Requires: hibernate3-ehcache >= 3.6.10
Requires: java-headless >= 1:1.8.0
Requires: javamail
Requires: jcommon
Requires: jdom
Requires: jpam
Requires: jta
Requires: log4j
Requires: redstone-xmlrpc
Requires: simple-core
Requires: simple-xml
Requires: sitemesh
Requires: spacewalk-branding
Requires: spacewalk-java-config
Requires: spacewalk-java-jdbc
Requires: spacewalk-java-lib
Requires: stringtree-json
Requires: struts >= 0:1.3.0
Requires: susestudio-java-client
Requires: tomcat-taglibs-standard
Requires: xalan-j2 >= 0:2.6.0
Requires: xerces-j2
%if 0%{?fedora} || 0%{?rhel} >= 7
Requires:      apache-commons-cli
Requires:      apache-commons-codec
Requires:      apache-commons-discovery
Requires:      apache-commons-el
Requires:      apache-commons-io
Requires:      apache-commons-lang
Requires:      apache-commons-logging
Requires:      javapackages-tools
Requires:      javassist
Requires:      mvn(org.slf4j:slf4j-log4j12)
Requires:      servlet >= 3.0
Requires:      tomcat >= 7
Requires:      tomcat-lib >= 7
# obsolete old jpackage rpms to make smooth upgrade
Obsoletes:     asm <= 1.5.3
Obsoletes:     classpathx-jaf <= 1.1.1
Obsoletes:     classpathx-mail <= 1.1.2
Obsoletes:     excalibur <= 1:1.0
Obsoletes:     excalibur-avalon-framework-api <= 1:4.3.1
Obsoletes:     excalibur-avalon-framework-impl <= 1:4.3.1
Obsoletes:     excalibur-avalon-logkit <= 1:2.2.1
Obsoletes:     geronimo-jaf-1.1-api <= 1.2
Obsoletes:     geronimo-jms-1.1-api <= 1.2
Obsoletes:     geronimo-jsp-2.1-api <= 1.2
Obsoletes:     geronimo-servlet-2.5-api <= 1.2
Obsoletes:     geronimo-specs-poms <= 1.2
Obsoletes:     glassfish-jaf <= 1.1.0
Obsoletes:     glassfish-javamail <= 1.4.0
Obsoletes:     jakarta-commons-el <= 1.0
Obsoletes:     jakarta-commons-collections <= 3.1
Obsoletes:     jython <= 2.2
Obsoletes:     oscache <= 2.4.1
Obsoletes:     saxpath <= 1.0
Obsoletes:     servletapi4 <= 4.0.4
Obsoletes:     sitemesh <= 2.4.1
Obsoletes:     spacewalk-jpp-workaround <= 2.3.5
Obsoletes:     tomcat5-jsp-2.0-api <= 5.5.27
Obsoletes:     tomcat5-servlet-2.4-api <= 5.5.27
Obsoletes:     tomcat6-servlet-2.5-api <= 6.0.18
Obsoletes:     tomcat6-el-1.0-api <= 6.0.18
Obsoletes:     velocity-dvsl <= 1.0
BuildRequires: apache-commons-codec
BuildRequires: apache-commons-discovery
BuildRequires: apache-commons-el
BuildRequires: apache-commons-io
BuildRequires: apache-commons-logging
# spelling checker is only for Fedoras (no aspell in RHEL6)
BuildRequires: aspell aspell-en libxslt
BuildRequires: ehcache-core
BuildRequires: javassist
BuildRequires: javapackages-tools
BuildRequires: mvn(ant-contrib:ant-contrib)
BuildRequires: mvn(org.slf4j:slf4j-log4j12)
BuildRequires: tomcat >= 7
BuildRequires: tomcat-lib >= 7
%else
Requires:      jakarta-commons-beanutils >= 1.9
Requires:      jakarta-commons-cli
Requires:      jakarta-commons-cli-mvn
Requires:      jakarta-commons-codec
Requires:      jakarta-commons-discovery
Requires:      jakarta-commons-el
Requires:      jakarta-commons-io
Requires:      jakarta-commons-lang
Requires:      jakarta-commons-logging < 1.1
Requires:      java-1.8.0-openjdk-devel
Requires:      jpackage-utils
Requires:      tomcat6
Requires:      tomcat6-lib
Requires:      tomcat6-servlet-2.5-api
BuildRequires: ant-contrib
BuildRequires: ant-nodeps
BuildRequires: jakarta-commons-codec
BuildRequires: jakarta-commons-discovery
BuildRequires: jakarta-commons-el
BuildRequires: jakarta-commons-io
BuildRequires: jakarta-commons-logging
BuildRequires: jpackage-utils
BuildRequires: tomcat6
BuildRequires: tomcat6-lib
# obsolete old jpackage rpms to make smooth upgrade
Obsoletes:     apache-portlet-1.0-api <= 1.0
Obsoletes:     asm <= 1.5.3
Obsoletes:     asm2 <= 2.2.3
Obsoletes:     classpathx-mail <= 1.1.2
Obsoletes:     easymock <= 1.2
Obsoletes:     easymock-classextension <= 1.2
Obsoletes:     excalibur <= 1:1.0
Obsoletes:     excalibur-avalon-framework-api <= 1:4.3.1
Obsoletes:     excalibur-avalon-framework-impl <= 1:4.3.1
Obsoletes:     excalibur-avalon-logkit <= 1:2.2.1
Obsoletes:     freemarker <= 2.3.15
Obsoletes:     geronimo-ejb-2.1-api <= 1.2
Obsoletes:     geronimo-j2ee-1.4-apis <= 1.2
Obsoletes:     geronimo-jta-1.1-api <= 1.2
Obsoletes:     geronimo-specs-poms <= 1.2
Obsoletes:     geronimo-stax-1.0-api <= 1.2
Obsoletes:     glassfish-jaf <= 1.1.0
Obsoletes:     glassfish-jaxb <= 2.1.4
Obsoletes:     gnu-regexp <= 1.1.4
Obsoletes:     groovy15 <= 1.5.6
Obsoletes:     hivemind <= 1.1.1
Obsoletes:     hivemind-lib <= 1.1.1
Obsoletes:     isorelax <= 0.1
Obsoletes:     jakarta-commons-chain <= 1.2
Obsoletes:     jakarta-commons-discovery <= 0.4
Obsoletes:     jakarta-commons-fileupload <= 1:1.2.1
Obsoletes:     jakarta-commons-transaction <= 1.1
Obsoletes:     jakarta-commons-validator <= 1.3.1
Obsoletes:     jakarta-slide-webdavclient <= 2.1
Obsoletes:     jarjar <= 0.9
Obsoletes:     java-cup <= 0.11
Obsoletes:     jaxen <= 1.1
Obsoletes:     jcommon <= 1.0.12
Obsoletes:     jettison <= 1.0.1
Obsoletes:     jetty5 <= 5.1.14
Obsoletes:     joda-time <= 1.5.2
Obsoletes:     mockobjects <= 0.09
Obsoletes:     msv-xsdlib <= 1.2
Obsoletes:     myfaces-core11-api <= 1.1.5
Obsoletes:     ognl <= 2.6.9
Obsoletes:     oscache <= 2.4.1
Obsoletes:     portals-pluto10-portlet-1.0-api <= 1.0.1
Obsoletes:     relaxngDatatype <= 1.0
Obsoletes:     saxpath <= 1.0
Obsoletes:     servletapi4 <= 4.0.4
Obsoletes:     spacewalk-jpp-workaround <= 2.3.5
Obsoletes:     spacewalk-slf4j <= 1.6.1
Obsoletes:     spring <= 1.2.9
Obsoletes:     spring-all <= 1.2.9
Obsoletes:     struts-taglib <= 1.3.8
Obsoletes:     struts-tiles <= 1.3.8
Obsoletes:     tapestry <= 4.0.2
Obsoletes:     tomcat5-jasper <= 5.5.27
Obsoletes:     tomcat5-jsp-2.0-api <= 5.5.27
Obsoletes:     tomcat5-servlet-2.4-api <= 5.5.27
Obsoletes:     velocity-dvsl <= 1.0
Obsoletes:     ws-jaxme <= 0.5.1
Obsoletes:     wstx <= 3.1.1
Obsoletes:     xml-commons-jaxp-1.2-apis <= 1.3.04
Obsoletes:     xml-im-exporter <= 1.1
Obsoletes:     xom <= 1.2.1
Obsoletes:     xpp2 <= 2.1.10
Obsoletes:     xstream <= 1.3.1
%endif

BuildRequires: /usr/bin/perl
BuildRequires: /usr/bin/xmllint
BuildRequires: ant
BuildRequires: ant-apache-regexp
BuildRequires: ant-junit
BuildRequires: antlr >= 0:2.7.6
BuildRequires: apache-commons-cli
BuildRequires: apache-commons-collections
BuildRequires: apache-commons-fileupload
BuildRequires: apache-commons-validator
BuildRequires: bcel
BuildRequires: c3p0 >= 0.9.1
BuildRequires: cglib
BuildRequires: concurrent
BuildRequires: dom4j
BuildRequires: dwr >= 3
BuildRequires: hibernate3 >= 0:3.6.10
BuildRequires: hibernate3-c3p0 >= 3.6.10
BuildRequires: hibernate3-ehcache >= 3.6.10
BuildRequires: java-1.8.0-openjdk-devel
BuildRequires: javamail
BuildRequires: jcommon
BuildRequires: jdom
BuildRequires: jpam
BuildRequires: jta
BuildRequires: postgresql-jdbc
BuildRequires: quartz < 2.0
BuildRequires: redstone-xmlrpc
BuildRequires: simple-core
BuildRequires: simple-xml
BuildRequires: sitemesh
BuildRequires: stringtree-json
BuildRequires: struts >= 0:1.3.0
BuildRequires: susestudio-java-client
BuildRequires: tanukiwrapper
BuildRequires: tomcat-taglibs-standard
%if 0%{?run_checkstyle}
BuildRequires: checkstyle
%if 0%{?fedora} || 0%{?rhel} >= 7
BuildRequires: apache-commons-beanutils >= 1.9
%else
BuildRequires: jakarta-commons-beanutils >= 1.9
%endif
BuildRequires: apache-commons-cli >= 1.3
BuildRequires: apache-commons-lang3 >= 3.4
%endif
%if ! 0%{?omit_tests} > 0
BuildRequires: translate-toolkit
%endif
Obsoletes: rhn-java < 5.3.0
Obsoletes: rhn-java-sat < 5.3.0
Obsoletes: rhn-oracle-jdbc-tomcat5 <= 1.0
Provides: rhn-java = %{version}-%{release}
Provides: rhn-java-sat = %{version}-%{release}
Provides: rhn-oracle-jdbc-tomcat5 = %{version}-%{release}

%description
This package contains the code for the Java version of the Spacewalk Web Site.

%package config
Summary: Configuration files for Spacewalk Java
Obsoletes: rhn-java-config < 5.3.0
Obsoletes: rhn-java-config-sat < 5.3.0
Provides: rhn-java-config = %{version}-%{release}
Provides: rhn-java-config-sat = %{version}-%{release}

%description config
This package contains the configuration files for the Spacewalk Java web
application and taskomatic process.

%package lib
Summary: Jar files for Spacewalk Java
Obsoletes: rhn-java-lib < 5.3.0
Obsoletes: rhn-java-lib-sat < 5.3.0
Provides: rhn-java-lib = %{version}-%{release}
Provides: rhn-java-lib-sat = %{version}-%{release}
Requires: /usr/bin/sudo

%description lib
This package contains the jar files for the Spacewalk Java web application
and taskomatic process.

%package oracle
Summary: Oracle database backend support files for Spacewalk Java
Requires: ojdbc14
%if 0%{?fedora} || 0%{?rhel} >= 7
Requires: tomcat >= 7
%else
Requires: tomcat6
%endif
Provides: spacewalk-java-jdbc = %{version}-%{release}

%description oracle
This package contains Oracle database backend files for the Spacewalk Java.

%package postgresql
Summary: PostgreSQL database backend support files for Spacewalk Java
Requires: postgresql-jdbc
%if 0%{?fedora} || 0%{?rhel} >=7
Requires: tomcat >= 7
%else
Requires: tomcat6
%endif
Provides: spacewalk-java-jdbc = %{version}-%{release}

%description postgresql
This package contains PostgreSQL database backend files for the Spacewalk Java.


%if ! 0%{?omit_tests} > 0
%package tests
Summary: Test Classes for testing spacewalk-java

BuildRequires:  jmock > 2.6
BuildRequires:  mvn(org.jmock:jmock-junit3) > 2.6
BuildRequires:  mvn(org.jmock:jmock-legacy) > 2.6
Requires: jmock > 2.6
Requires: mvn(org.jmock:jmock-junit3) > 2.6
Requires: mvn(org.jmock:jmock-legacy) > 2.6
Requires: ant-junit

%description tests
This package contains testing files of spacewalk-java.

%files tests
%defattr(644,root,root,775)
%{_datadir}/rhn/lib/rhn-test.jar
%{_datadir}/rhn/unit-tests/*
%{_datadir}/rhn/unittest.xml
%attr(644, tomcat, tomcat) %{jardir}/commons-lang3.jar
%attr(644, tomcat, tomcat) %{jardir}/mockobjects*.jar
%attr(644, tomcat, tomcat) %{jardir}/strutstest*.jar
%endif

%package -n spacewalk-taskomatic
Summary: Java version of taskomatic

Requires: bcel
Requires: c3p0 >= 0.9.1
Requires: cglib
Requires: cobbler20
Requires: concurrent >= 1.3.4-21
Requires: hibernate3 >= 3.6.10
Requires: hibernate3-c3p0 >= 3.6.10
Requires: hibernate3-ehcache >= 3.6.10
Requires: java-headless >= 1:1.8.0
Requires: jcommon
Requires: jpam
Requires: log4j
Requires: quartz < 2.0
Requires: simple-core
Requires: spacewalk-java-config
Requires: spacewalk-java-jdbc
Requires: spacewalk-java-lib
Requires: tanukiwrapper
Requires: tomcat-taglibs-standard
Requires: xalan-j2 >= 0:2.6.0
Requires: xerces-j2
%if 0%{?fedora} || 0%{?rhel} >= 7
Requires: apache-commons-cli
Requires: apache-commons-codec
Requires: apache-commons-dbcp
Requires: apache-commons-lang
Requires: apache-commons-logging
Requires: javassist
%else
Requires: jakarta-commons-cli
Requires: jakarta-commons-codec
Requires: jakarta-commons-dbcp
Requires: jakarta-commons-lang
Requires: jakarta-commons-logging
%endif
Conflicts: quartz >= 2.0
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

%if 0%{?fedora}
%define skip_xliff  1
%endif

%if ! 0%{?omit_tests} > 0 && ! 0%{?skip_xliff}
find . -name 'StringResource_*.xml' |      while read i ;
    do echo $i
    # check for common localizations issues
    ln -s $(basename $i) $i.xliff
    CONTENT=$(pofilter --progress=none --nofuzzy --gnome \
                       --excludefilter=untranslated \
                       --excludefilter=purepunc \
                       $i.xliff 2>&1)
    if [ -n "$CONTENT" ]; then
        echo ERROR - pofilter errors: "$CONTENT"
        exit 1
    fi
    rm -f $i.xliff

    #check duplicate message keys in StringResource_*.xml files
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
export ADDITIONAL_OPTIONS="-Djavadoc.method.scope=public \
-Djavadoc.type.scope=package \
-Djavadoc.var.scope=package \
-Dcheckstyle.cache.file=build/checkstyle.cache.src \
-Djavadoc.lazy=false \
-Dcheckstyle.header.file=buildconf/LICENSE.txt"
find . -name *.java | grep -vE '(/test/|/jsp/|/playpen/)' | \
xargs checkstyle -c buildconf/checkstyle.xml

echo "Running checkstyle on java test sources"
export ADDITIONAL_OPTIONS="-Djavadoc.method.scope=nothing \
-Djavadoc.type.scope=nothing \
-Djavadoc.var.scope=nothing \
-Dcheckstyle.cache.file=build/checkstyle.cache.test \
-Djavadoc.lazy=false \
-Dcheckstyle.header.file=buildconf/LICENSE.txt"
find . -name *.java | grep -E '/test/' | grep -vE '(/jsp/|/playpen/)' | \
xargs checkstyle -c buildconf/checkstyle.xml
%endif

# catch macro name errors
find . -type f -name '*.xml' | xargs perl -CSAD -lne '
          for (grep { $_ ne "PRODUCT_NAME" } /\@\@(\w+)\@\@/g) {
              print;
              $exit = 1;
          }
          @r = /((..)?PRODUCT_NAME(..)?)/g ;
          while (@r) {
              $s = shift(@r); $f = shift(@r); $l = shift(@r);
              if ($f ne "@@" or $l ne "@@") {
                  print $s;
                  $exit = 1;
              }
          }
          END { exit $exit }'

# disable crash dumps in IBM java (OpenJDK have them off by default)
if java -version 2>&1 | grep -q IBM ; then
    sed -i '/#wrapper\.java\.additional\.[0-9]=-Xdump:none/ { s/^#//; }' \
        conf/default/rhn_taskomatic_daemon.conf
fi

%install

# on Fedora 19 some jars are named differently
%if 0%{?fedora} || 0%{?rhel} >= 7
ant -Dprefix=$RPM_BUILD_ROOT install-tomcat
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/tomcat/Catalina/localhost/

# Need to use 2 versions of rhn.xml, Tomcat 8 changed syntax
%if 0%{?fedora} >= 23
install -m 644 conf/rhn-tomcat8.xml $RPM_BUILD_ROOT%{_sysconfdir}/tomcat/Catalina/localhost/rhn.xml
%else
install -m 644 conf/rhn-tomcat5.xml $RPM_BUILD_ROOT%{_sysconfdir}/tomcat/Catalina/localhost/rhn.xml
%endif

%else
ant -Dprefix=$RPM_BUILD_ROOT install-tomcat6
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/tomcat6/Catalina/localhost/
install -m 644 conf/rhn-tomcat5.xml $RPM_BUILD_ROOT%{_sysconfdir}/tomcat6/Catalina/localhost/rhn.xml
%endif

# check spelling errors in all resources for English if aspell installed
[ -x "$(which aspell)" ] && scripts/spelling/check_java.sh .. en_US

%if 0%{?fedora} || 0%{?rhel} >= 7
install -d -m 755 $RPM_BUILD_ROOT%{_sbindir}
install -d -m 755 $RPM_BUILD_ROOT%{_unitdir}
%else
install -d -m 755 $RPM_BUILD_ROOT%{_initrddir}
%endif
install -d -m 755 $RPM_BUILD_ROOT%{_bindir}
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/rhn
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/unit-tests
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/lib
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/classes
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/search
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/search/lib
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/spacewalk/taskomatic
install -d -m 755 $RPM_BUILD_ROOT%{cobprofdir}
install -d -m 755 $RPM_BUILD_ROOT%{cobprofdirup}
install -d -m 755 $RPM_BUILD_ROOT%{cobprofdirwiz}
install -d -m 755 $RPM_BUILD_ROOT%{cobdirsnippets}
install -d -m 755 $RPM_BUILD_ROOT%{_var}/spacewalk/systemlogs

install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d

echo "hibernate.cache.region.factory_class=net.sf.ehcache.hibernate.SingletonEhCacheRegionFactory" >> conf/default/rhn_hibernate.conf

install -m 644 conf/default/rhn_hibernate.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_hibernate.conf
install -m 644 conf/default/rhn_taskomatic_daemon.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
install -m 644 conf/default/rhn_org_quartz.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_org_quartz.conf
install -m 644 conf/rhn_java.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults
install -m 644 conf/logrotate/rhn_web_api $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/rhn_web_api
%if 0%{?fedora} || 0%{?rhel} >= 7
# LOGROTATE >= 3.8 requires extra permission config
sed -i 's/#LOGROTATE-3.8#//' $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/rhn_web_api
install -m 755 scripts/taskomatic $RPM_BUILD_ROOT%{_sbindir}
install -m 644 scripts/taskomatic.service $RPM_BUILD_ROOT%{_unitdir}
%else
install -m 755 scripts/taskomatic $RPM_BUILD_ROOT%{_initrddir}
%endif
install -m 644 scripts/unittest.xml $RPM_BUILD_ROOT/%{_datadir}/rhn/
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
ln -s -f %{_javadir}/dwr.jar $RPM_BUILD_ROOT%{jardir}/dwr.jar
install -d -m 755 $RPM_BUILD_ROOT%{realcobsnippetsdir}
ln -s -f  %{cobdirsnippets} $RPM_BUILD_ROOT%{realcobsnippetsdir}/spacewalk
touch $RPM_BUILD_ROOT%{_var}/spacewalk/systemlogs/audit-review.log

# special links for taskomatic
TASKOMATIC_BUILD_DIR=%{_prefix}/share/spacewalk/taskomatic
ln -s -f %{_javadir}/ojdbc14.jar $RPM_BUILD_ROOT$TASKOMATIC_BUILD_DIR/ojdbc14.jar
ln -s -f %{_javadir}/quartz-oracle.jar $RPM_BUILD_ROOT$TASKOMATIC_BUILD_DIR/quartz-oracle.jar
rm -f $RPM_BUILD_ROOT$TASKOMATIC_BUILD_DIR/slf4j*nop.jar
rm -f $RPM_BUILD_ROOT$TASKOMATIC_BUILD_DIR/slf4j*simple.jar

# special links for rhn-search
RHN_SEARCH_BUILD_DIR=%{_prefix}/share/rhn/search/lib
ln -s -f %{_javadir}/ojdbc14.jar $RPM_BUILD_ROOT$RHN_SEARCH_BUILD_DIR/ojdbc14.jar
ln -s -f %{_javadir}/postgresql-jdbc.jar $RPM_BUILD_ROOT$RHN_SEARCH_BUILD_DIR/postgresql-jdbc.jar

# delete JARs which must not be deployed
rm -rf $RPM_BUILD_ROOT%{jardir}/jspapi.jar
rm -rf $RPM_BUILD_ROOT%{jardir}/jasper5-compiler.jar
rm -rf $RPM_BUILD_ROOT%{jardir}/jasper5-runtime.jar
rm -rf $RPM_BUILD_ROOT%{jardir}/tomcat*api.jar
rm -rf $RPM_BUILD_ROOT%{jardir}/tomcat[_a-z6]*.jar
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

%pre
rm -f %{realcobsnippetsdir}/spacewalk

%post -n spacewalk-taskomatic
if [ -f /etc/init.d/taskomatic ]; then
   # This adds the proper /etc/rc*.d links for the script
   /sbin/chkconfig --add taskomatic
fi

%preun -n spacewalk-taskomatic
if [ $1 = 0 ] ; then
   if [ -f /etc/init.d/taskomatic ]; then
      /sbin/service taskomatic stop >/dev/null 2>&1
      /sbin/chkconfig --del taskomatic
   fi
fi

%files
%defattr(644,tomcat,tomcat,775)
%attr(775, root, tomcat) %dir %{appdir}
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
%{appdir}/rhn/errors/
%{appdir}/rhn/*.jsp
%{appdir}/rhn/WEB-INF/classes
%{appdir}/rhn/WEB-INF/decorators
%{appdir}/rhn/WEB-INF/includes
%{appdir}/rhn/WEB-INF/nav
%{appdir}/rhn/WEB-INF/pages
%{appdir}/rhn/WEB-INF/*.xml
# list of all jar symlinks without any version numbers
# and wildcards (except non-symlink velocity)
%{jardir}/antlr.jar
%{jardir}/bcel.jar
%{jardir}/c3p0*.jar
%if 0%{?fedora} >= 25
%{jardir}/cglib_cglib.jar
%else
%{jardir}/cglib.jar
%endif
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
%{jardir}/*commons-validator.jar
%{jardir}/concurrent*.jar
%{jardir}/dom4j.jar
%{jardir}/dwr.jar
%{jardir}/hibernate3*
%{jardir}/ehcache-core.jar
%{jardir}/*_hibernate-commons-annotations.jar
%{jardir}/hibernate-jpa-2.0-api*.jar
%{jardir}/javassist.jar
%{jardir}/mchange-commons*.jar
%{jardir}/slf4j_api.jar
%{jardir}/slf4j_log4j12*.jar
%{jardir}/*jboss-logging.jar
%{jardir}/tomcat-taglibs-standard_taglibs-build-tools.jar
%{jardir}/tomcat-taglibs-standard_taglibs-standard-compat.jar
%{jardir}/tomcat-taglibs-standard_taglibs-standard-impl.jar
%{jardir}/tomcat-taglibs-standard_taglibs-standard-jstlel.jar
%{jardir}/tomcat-taglibs-standard_taglibs-standard-spec.jar

%{jardir}/javamail_javax.mail.jar
%{jardir}/jcommon*.jar
%{jardir}/jdom.jar
%{jardir}/jpam.jar
%{jardir}/jta.jar
%{jardir}/log4j*.jar
%{jardir}/objectweb-asm_asm.jar
%{jardir}/oro.jar
%{jardir}/quartz.jar
%{jardir}/redstone-xmlrpc-client.jar
%{jardir}/redstone-xmlrpc.jar
%{jardir}/rhn.jar
%{jardir}/simple-core.jar
%{jardir}/simple-xml.jar
%{jardir}/sitemesh.jar
%{jardir}/stringtree-json.jar
%{jardir}/susestudio-java-client.jar
%{jardir}/tanukiwrapper.jar
%{jardir}/velocity-*.jar
%{jardir}/xalan-j2.jar
%{jardir}/xerces-j2.jar
%{jardir}/xml-commons-apis.jar

%{jardir}/struts*.jar
%{jardir}/commons-chain.jar

%dir %{cobprofdir}
%dir %{cobprofdirup}
%dir %{cobprofdirwiz}
%dir %{cobdirsnippets}
%config %{cobdirsnippets}/default_motd
%config %{cobdirsnippets}/keep_system_id
%config %{cobdirsnippets}/post_reactivation_key
%config %{cobdirsnippets}/post_delete_system
%config %{cobdirsnippets}/redhat_register
%if 0%{?fedora} || 0%{?rhel} >= 7
%config(noreplace) %{_sysconfdir}/tomcat/Catalina/localhost/rhn.xml
%else
%config(noreplace) %{_sysconfdir}/tomcat6/Catalina/localhost/rhn.xml
%endif
%{realcobsnippetsdir}/spacewalk
%dir %attr(755, tomcat, root) %{_var}/spacewalk/systemlogs
%ghost %attr(644, tomcat, root) %{_var}/spacewalk/systemlogs/audit-review.log

%files -n spacewalk-taskomatic
%defattr(644,root,root,775)
%if 0%{?fedora} || 0%{?rhel} >= 7
%attr(755, root, root) %{_sbindir}/taskomatic
%attr(644, root, root) %{_unitdir}/taskomatic.service
%else
%attr(755, root, root) %{_initrddir}/taskomatic
%endif
%{_bindir}/taskomaticd
%{_datarootdir}/spacewalk/taskomatic


%files config
%defattr(644,root,root,775)
%{_prefix}/share/rhn/config-defaults/rhn_hibernate.conf
%{_prefix}/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
%{_prefix}/share/rhn/config-defaults/rhn_org_quartz.conf
%{_prefix}/share/rhn/config-defaults/rhn_java.conf
%config %{_sysconfdir}/logrotate.d/rhn_web_api

%files lib
%defattr(644,root,root,775)
%{_datadir}/rhn/classes/log4j.properties
%{_datadir}/rhn/lib/rhn.jar

%files oracle
%defattr(644,root,root,775)
%attr(644, tomcat, tomcat) %{jardir}/ojdbc14.jar
%{_prefix}/share/rhn/search/lib/ojdbc14.jar
%{_prefix}/share/spacewalk/taskomatic/ojdbc14.jar
%{_prefix}/share/spacewalk/taskomatic/quartz-oracle.jar

%files postgresql
%defattr(644,root,root,775)
%attr(644, tomcat, tomcat) %{jardir}/postgresql-jdbc.jar
%{_prefix}/share/rhn/search/lib/postgresql-jdbc.jar

%changelog
* Thu Apr 05 2018 Jiri Dostal <jdostal@redhat.com> 2.9.4-1
- 1544350 - Add possibility to manage errata severity via API/WebUI

* Wed Apr 04 2018 Tomas Kasparek <tkasparek@redhat.com> 2.9.3-1
- don't offer cloning of channel when there's no avaialable to clone from

* Tue Apr 03 2018 Jiri Dostal <jdostal@redhat.com> 2.9.2-1
- 1544350 - Add possibility to manage errata severity via API/WebUI

* Tue Apr 03 2018 Jiri Dostal <jdostal@redhat.com> 2.9.1-1
- 1558684 - don't allow to clone channels without subscribable parent
- Bumping package versions for 2.9.

* Mon Mar 26 2018 Jiri Dostal <jdostal@redhat.com> 2.8.76-1
- Fix: rename JSP method
- Fix: hide non-org event details
- Fix channel <-> advisory field inversion on the ErrataChannelIntersection
  page

* Fri Mar 23 2018 Jiri Dostal <jdostal@redhat.com> 2.8.75-1
- 1542556 - Prevent deletion of last SW admin if disabled.

* Fri Mar 23 2018 Jiri Dostal <jdostal@redhat.com> 2.8.74-1
- 1544350 - Add possibility to manage errata severity via API/WebUI
- Java should require new dwr, old doesn't work anymore
- Update dwr to 3.0.2

* Wed Mar 21 2018 Jiri Dostal <jdostal@redhat.com> 2.8.73-1
- Bump Java API version
- Updating copyright years for 2018
- Merging frontend L10N from Zanata

* Fri Mar 02 2018 Jiri Dostal <jdostal@redhat.com> 2.8.72-1
- 1187053 - package search do not search through ppc64le packages by default

* Tue Feb 27 2018 Jiri Dostal <jdostal@redhat.com> 2.8.71-1
- Fix building java, silly mistake

* Tue Feb 27 2018 Jiri Dostal <jdostal@redhat.com> 2.8.70-1
- Allow fetching jars from different install-root

* Mon Feb 19 2018 Grant Gainey 2.8.69-1
- 1020318 - Check description for max-len when updating

* Fri Feb 16 2018 Grant Gainey 2.8.68-1
- 1020318 - Fix refactored to take more, multiple, errors into account

* Mon Feb 12 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.67-1
- there might not be repo metadata we're looking for

* Fri Feb 09 2018 Grant Gainey 2.8.66-1
- 1481329 - Lost an <rhn-tab-directory> tab in previous commit for this BZ

* Fri Feb 09 2018 Jiri Dostal <jdostal@redhat.com> 2.8.65-1
- Add proper errata severity editing/creating to WebUI
- Add severity handling to API calls

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.64-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Thu Feb 08 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.63-1
- write modules information during repodata generation
- support downloading of modules.yaml files via java stack
- make module information part of channel just like comps
- provide a way how to handle different repo metadata files in Java

* Tue Feb 06 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.62-1
- removed unused dependency on dojo

* Mon Feb 05 2018 Jiri Dostal <jdostal@redhat.com> 2.8.61-1
- 1541955 - Clone of an erratum doesn't have original erratum's severity

* Tue Jan 30 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.60-1
- Adapt other errata sites to colors
- update checkstyle license to 2018

* Thu Jan 25 2018 Jiri Dostal <jdostal@redhat.com> 2.8.59-1
- 1537108 - Colorful icons for differet errata severities
- Automatic commit of package [spacewalk-java] release [2.8.58-1].

* Mon Jan 22 2018 Jiri Dostal <jdostal@redhat.com> 2.8.58-1
- Unify icons/style with other services

* Wed Jan 17 2018 Jiri Dostal <jdostal@redhat.com> 2.8.57-1
- 1052292 - Task that is already picked up by the client can be cancelled via
  API

* Fri Jan 12 2018 Grant Gainey 2.8.56-1
- 1534021 - Fix sorting on systems/SystemGroupList; clean up systems/Overview

* Fri Jan 12 2018 Grant Gainey 2.8.55-1
- 1491501 - Some cleanup, add alphabar/filtering to SSMManageSystemGroups

* Fri Jan 12 2018 Grant Gainey 2.8.54-1
- 1491501 - fix ssm/groups/Manage and its Confirm

* Fri Jan 05 2018 Jiri Dostal <jdostal@redhat.com> 2.8.52-1
- 1523632 - missing margin in organization trust detail page data
- 1523634 - popularity drop-down menu strangely positioned and seems too big,
  code format

* Wed Jan 03 2018 Jiri Dostal <jdostal@redhat.com> 2.8.51-1
- 1524211 - Internal Server Error When Setting Kickstart Package List via
  Spacewalk API

* Wed Jan 03 2018 Jiri Dostal <jdostal@redhat.com> 2.8.50-1
- 1523597 - labels for OS editing in kickstart profile are vertically centered,
  making the form bit hard to understand

* Mon Dec 18 2017 Jiri Dostal <jdostal@redhat.com> 2.8.49-1
- 1020318 - creation of custom info key with long key label fails with ISE

* Thu Dec 07 2017 Jiri Dostal <jdostal@redhat.com> 2.8.48-1
- 1520664 - Internal server error changing kickstart script order

* Wed Dec 06 2017 Eric Herget <eherget@redhat.com> 2.8.47-1
- 1515278 - list of systems on Virtual Systems page is not synchronized with
  SSM

* Fri Dec 01 2017 Grant Gainey 2.8.46-1
- 1466006 - Previous fix breaks RHEL6-EUS logic :(
- 1466006 - more RHEL7EUS version heuristics

* Fri Dec 01 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.45-1
- Unify heading for "Recently Registered Systems"
- Use correct header string for system groups

* Thu Nov 30 2017 Eric Herget <eherget@redhat.com> 2.8.44-1
- Update ant setup to add xalan-j2 to build-lib.  Also update apidoc generation
  steps.

* Wed Nov 29 2017 Jiri Dostal <jdostal@redhat.com> 2.8.43-1
- 1514020 - Unhandled internal exception when trying to cancel child scheduled
  event

* Wed Nov 29 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.42-1
- 1482501 - update docs for system.listSystemEvents API method

* Wed Nov 22 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.41-1
- Improve messaging for "Compare Packages"

* Mon Nov 20 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.40-1
- 1461705 - do not clear SSM during VirtualSystems loading.

* Tue Nov 14 2017 Eric Herget <eherget@redhat.com> 2.8.39-1
- Fix javadoc generation errors

* Thu Nov 09 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.38-1
- 1511347 - improve SQL query for selecting uncloned Errata.

* Wed Nov 08 2017 Jan Dobes 2.8.37-1
- there is no virtEntitlement required
- don't display info about guests on virtual host if it's not accessible (in
  different org)
- System_queries: virtual_servers query formatted for clarity
- Virtual Systems list: if a host is in a different Org, only list its name (no
  link)
- Virtual Systems list: show virtual hosts from different Orgs

* Wed Nov 08 2017 Jan Dobes 2.8.36-1
- Revert "1461705 - enable checkboxes for systems are in SSM"

* Tue Nov 07 2017 Jan Dobes 2.8.35-1
- 1510511 - update debuginfo unavailable message
- 1510511 - display known debugsource package

* Wed Nov 01 2017 Jan Dobes 2.8.34-1
- 1457226 - remove link to third party page

* Wed Nov 01 2017 Jan Dobes 2.8.33-1
- 1507491 - make sure distribution is updated in generated kickstart file

* Wed Nov 01 2017 Jiri Dostal <jdostal@redhat.com> 2.8.32-1
- 1471120 - Advanced search for systems with installed packages is not working
  correctly for java packages

* Fri Oct 27 2017 Jan Dobes <jdobes@redhat.com> 2.8.31-1
- reverting condition

* Thu Oct 26 2017 Jan Dobes <jdobes@redhat.com> 2.8.30-1
- 1492572 - display action without prerequisites first
- 1492572 - hide select box when it's disabled
- 1492572 - action is selectable if it's without prerequisites

* Tue Oct 17 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.29-1
- remove no longer needed imports
- use inline variables when possible
- return as last statement in void function is pointless
- continue doesn't make sense as last command in loop
- don't use ternary operator where it's not necessary
- .equals already returns boolean value
- simplify if (true) { return true; } else { return false; } expressions
- use .equals instead of ==
- get rid of empty if blocks
- fix javadoc comment with correct method signature
- call methods from ConfigDefaults to ensure default value is used instead of 0
- ConfigDefaults - simplify return statement
- ConfigDefaults - make publically not used attributes private
- Config - use foreach loop where it makes sense
- Config - make publically not used attributes private
- ClientCertificate - use foreach loop
- ClientCertificate - make not publically used methods/attributes private
- super() class exception is already thrown
- simplify if (true) { return true; } else { return false; } expressions
- return is not needed in void functions
- expression can be written without ternary operator

* Mon Oct 16 2017 Jan Dobes 2.8.28-1
- do not forcibly include @ Base pkg group into package list
- remove unused variable
- making snippets compatible with Python 3
- these packages are necessary on Fedora too
- fixing typo

* Mon Oct 16 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.27-1
- 1445254 - fix error message
- 1445254 - support removal of packages which are not in database via API
- bring LineLength max to 120 to be on par with max-line-length in pylint
- use correct argument name in javadoc

* Thu Oct 12 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.26-1
- 1460960 - set correct ListTagHelper.PARENT_URL attribute for ProxyClients
  page.

* Mon Oct 09 2017 Christian Lanig <clanig@suse.com>
- PR 577 - Harmonize presentation of patch information

* Fri Oct 06 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.24-1
- add help for new options

* Wed Oct 04 2017 Jiri Dostal <jdostal@redhat.com> 2.8.23-1
- 1477728 - Upgrade to Sat 5.8 caused url change in kickstarts, have to edit
  and republish by hand to correct url

* Wed Oct 04 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.22-1
- 1460960 - change ProxyClients page due to problem with passing acls.

* Mon Oct 02 2017 Grant Gainey 2.8.21-1
- 1481329 - Repoint references to Reference Guide to Getting Started - th
  Reference Guide is no longer updated

* Fri Sep 29 2017 Jiri Dostal <jdostal@redhat.com> 2.8.20-1
- Get rid of unused code
- Display message after deleting custom key

* Mon Sep 25 2017 Jan Dobes 2.8.19-1
- 1455791 - don't rename all profiles, it takes too much time

* Thu Sep 21 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.18-1
- 1483503 - disable ibm java coredumps in tanukiwrapper

* Thu Sep 21 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.17-1
- 1493143 - keep errata in the original channel for
  channel.software.mergeErrata

* Fri Sep 15 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.16-1
- Initialize prefix property in build.xml for install-tomcat target

* Fri Sep 08 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.15-1
- Disable YaST self update for new autoinstallation trees for SLE
- Added a script that performs post-processing on DocBook XML output.

* Thu Sep 07 2017 Grant Gainey 2.8.14-1
- 1469011 - Fix two typos in about.jsp language

* Wed Sep 06 2017 Jiri Dostal <jdostal@redhat.com> 2.8.13-1
- Show custom error message in the UI on exception
- Remove unused parameter
- Activate ErrorStatusFilter via dispatcher in case of error
- Drop messages from the session in case of error page

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.12-1
- purged changelog entries for Spacewalk 2.0 and older

* Tue Sep 05 2017 Jiri Dostal <jdostal@redhat.com> 2.8.11-1
- SSM software refresh page: do not right-align button

* Tue Sep 05 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.10-1
- 1486190 - take organization into account when looking up for an erratum

* Tue Aug 29 2017 Grant Gainey 2.8.9-1
- 1466006 - Fix 'available EUS channels' for RHEL7 systems

* Fri Aug 25 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.8-1
- Fix typo hisotry -> history

* Thu Aug 24 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.7-1
- 1460208 - organization name allows XSS

* Thu Aug 24 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.6-1
- 1460208 - organization name allows XSS

* Wed Aug 23 2017 Grant Gainey 2.8.5-1
- Revert "1475067 - Fix SSM update-status icons"

* Wed Aug 23 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.4-1
- 1460208 - organization name allows XSS

* Mon Aug 21 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.3-1
- 1461816 - in case of less items than we're expecting start with no pagination
- remove debugging message

* Fri Aug 18 2017 Grant Gainey 2.8.2-1
- 1469011 - updating about.jsp to bear some resemblance to current reality

* Fri Aug 18 2017 Jan Dobes 2.8.1-1
- workaround struts 1.3.10 ExceptionHandler call of isCommited method - not
  implemented in old mockobjects lib (MockHttpServletResponse class)
- Bumping package versions for 2.8.

* Thu Aug 17 2017 Jiri Dostal <jdostal@redhat.com> 2.7.115-1
- 1458712 - "Update Organization" button placed that way it is not clear that
  it updates "Allow Organization Admin to manage Organization Configuration"
  setting as well

* Wed Aug 16 2017 Eric Herget <eherget@redhat.com> 2.7.114-1
- SW 2.7 Release prep - update copyright year (3rd pass)

* Tue Aug 15 2017 Grant Gainey 2.7.113-1
- 1461898 - Fix SelectableChannel for other users of channel_selector.jspf

* Tue Aug 15 2017 Jan Dobes 2.7.112-1
- KickstartDownloadActionTest is useless

* Mon Aug 14 2017 Jan Dobes 2.7.111-1
- use LinkedHashSet same as in get method and as on web UI counterpart, TreeSet
  evaluates all KickstartCommand instances as equal (because of compareTo
  method)
- fixing NoCobblerTokenException: We had an error trying to login.
- this test doesn't make much sense - it lists also null-org errata and it
  randomly passes/fails depending on synced content

* Fri Aug 11 2017 Jan Dobes 2.7.110-1
- assert is wrong - inverted TEST_CONFIG_BOOLEAN value is not saved when
  required fields are missing in form
- fixing various ClassNotFoundException in tests - add hamcrest to classpath
- update struts libs, they are now in /usr/share/java/struts/, add only tiles
  lib, others should be linked from tomcat lib dir
- ChannelFactory.listAllBaseChannels lists also null-org channels, fix test
- fix table name for set, hibernate is looking for
  'rhnaction_rhnactionconfigchannel' and 'rhnaction_rhnactionconfigfilename'
  tables in ConfigUploadActionTest and ConfigUploadMtimeActionTest

* Fri Aug 11 2017 Jiri Dostal <jdostal@redhat.com> 2.7.109-1
- 1471018 - Allow cancel event that was picked up from queue by WebUI

* Thu Aug 10 2017 Jan Dobes 2.7.108-1
- 'if not exists' is unsupported in PG 8.4, catch exception in Java code
  instead
- TEST_CONF_LOCATION path is still used in spacewalk-java-tests RPM, use it as
  fallback when any config file is not found locally

* Mon Aug 07 2017 Eric Herget <eherget@redhat.com> 2.7.107-1
- another pass to update copyright year

* Thu Aug 03 2017 Jan Dobes 2.7.106-1
- 1455791 - rename cobbler profile names containing org's name

* Thu Aug 03 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.105-1
- 1477508 - fix query for Oracle databases

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.104-1
- bump java.apiversion
- update copyright year

* Fri Jul 28 2017 Grant Gainey 2.7.103-1
- 1475067 - Fix SSM update-status icons

* Fri Jul 28 2017 Jiri Dostal <jdostal@redhat.com> 2.7.102-1
- 1455887 - allow to fail Picked Up action as well

* Tue Jul 25 2017 Gennadii Altukhov <grinrag@gmail.com> 2.7.101-1
- 1461705 - enable checkboxes for systems are in SSM

* Thu Jul 20 2017 Grant Gainey 2.7.100-1
- 1461898 - fix pulldown for 'Manage Software Repositories' page  * Use call
  that returns correctly-sorted channel-hierarchy  * Fix JSP to stop using
  <optgroup> in ways that are bad for display  * Remove HQL listCustomChannels
  that doesn't do what we thought it did

* Thu Jul 20 2017 Jiri Dostal <jdostal@redhat.com> 2.7.99-1
- 1455887 - schedule.failSystemAction API overwrites system events history

* Thu Jul 20 2017 Jiri Dostal <jdostal@redhat.com> 2.7.98-1
- 1455880 - failSystemAction does not check system action id

* Tue Jul 18 2017 Eric Herget <eherget@redhat.com> 2.7.97-1
- PR 476 - Fix child nav items not being shown as active

* Tue Jul 18 2017 Grant Gainey 2.7.96-1
- 1458722 - Only make org-changes, if the org is allowed to be changed

* Mon Jul 17 2017 Jan Dobes 2.7.95-1
- Merging frontend L10N from Zanata

* Wed Jul 12 2017 Jiri Dostal <jdostal@redhat.com> 2.7.94-1
- 1320469 - "channel.software.mergePackages" does not create a repodata if a
  clone channel is created using the API

* Fri Jun 30 2017 Eric Herget <eherget@redhat.com> 2.7.93-1
- PR 500 - correcting email address in change log.  Not able/willing to change
  email addresses in individual commits, however.
- Duplicate Systems: correct language not to mention 'profiles' (bsc1035728)

* Tue Jun 27 2017 Marc Dahlhaus <ossdev@dahlhaus.it>
- Fix logging of errors to be at error level, not debug.  Also remove
  milliseconds from metadata stale check to match non-debian stale check
- PR 500 - fix copy and paste mistake
- PR 500 - use the already imported and used equalsIgnoreCase
- PR 500 - Add epoch information for deb packages

* Tue Jun 27 2017 Jiri Dostal <jdostal@redhat.com> 2.7.91-1
- 1460208 - organization name allows XSS
- Revert "1460208 - organization name allows XSS"

* Tue Jun 27 2017 Gennadii Altukhov <grinrag@gmail.com> 2.7.90-1
- 1460960 - show 'Proxy' tab only if a system is proxy

* Fri Jun 23 2017 Jiri Dostal <jdostal@redhat.com> 2.7.89-1
- 1460208 - organization name allows XSS

* Thu Jun 22 2017 Grant Gainey 2.7.88-1
- request repodata regeneration even if an erratum without new packages is
  published

* Mon Jun 19 2017 Gennadii Altukhov <grinrag@gmail.com> 2.7.87-1
- 1418746 - checkbox should be selected if proxy client is in a SSM

* Thu Jun 15 2017 Grant Gainey 2.7.86-1
- Increment 'earliest' date by a millisecond between chain actions

* Thu Jun 15 2017 Grant Gainey 2.7.85-1
- Add a link to action details in single errata schedule notification
- Add a link to system pending events in errata schedule notification for a
  single system

* Thu Jun 15 2017 Grant Gainey 2.7.84-1
- Fix sort directions when the sort column is changed
- Allow sorting on avisory name in errata lists
- Reformat relevant-errata-list.jspf

* Wed Jun 14 2017 Grant Gainey 2.7.83-1
- Checkstyle is a harsh mistress

* Tue Jun 13 2017 Grant Gainey 2.7.82-1
- Test create assertions only in the create test, refactor helper method so
  that it can be used in other tests
- Refactor: extract Tree operations tests to multiple classes, extract the
  common helper method to a base class

* Tue Jun 13 2017 Grant Gainey 2.7.81-1
- extend package testing methods for more control

* Tue Jun 13 2017 Grant Gainey 2.7.80-1
- Teach NavNodeTest that not-found-l10n strings are already escaped
- Teach NavTest to rely on different pages for its test
- Fix KickstartUrlHelperTest that has never been correct
- Teach SystemManagerTest correct way to say Integer to Hibernate
- Removed UserManagerTest's fragile dependency on ordering of rhntimezone table
- SystemHandlerTest relied on changing a readonly Hibernate entity - look it up
  instead
- ToolbarTagCloneTest relied on headers whose strings are no longer lowercase
- VirtualSystemsListActionTest relied on a page that has been renamed
- SessionSwapTest has always said 'DO NOT COMMIT THIS' - we should have
  listened...
- Teach JarFinderTest to not rely on packages that live in more than one jar
- Teach AdvDataSourceTest to work even if test-table already exists
- Update StrutsTestCase to version that supports Struts 1.3

* Fri Jun 09 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.79-1
- fixed checkstyle errors on Fedora 26
- Remove more fedorahosted links

* Thu Jun 01 2017 Michael Calmer <mc@suse.de>
- PR 519 - make country, state/province and city searchable for system location

* Wed May 31 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.77-1
- 1444047 - display alternative archs only from the same org
- Update system group details page

* Wed May 24 2017 Jan Dobes 2.7.76-1
- 1441219 - channel admin should be able to set org user restrictions for null-
  org channels
- 1441219 - fixing exploit - user permission is not checked
- 1446310 - remove not existing links

* Tue May 23 2017 Grant Gainey 2.7.75-1
- 1368438 - Teach ListPackagesAction and list.jsp about packageChannels

* Tue May 23 2017 Grant Gainey 2.7.74-1
- 1005783 - I18N the 'NOT MAPPED' string of ISS
- 1324737 - polish API description

* Tue May 23 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.73-1
- java devel package is needed even in runtime (on RHEL6)

* Mon May 22 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.72-1
- fixed java developer setup (mainly ivy config)
- slf4j-log4j12 is in slf4j's subpackage on Fedora 25

* Fri May 19 2017 Grant Gainey 2.7.71-1
- 1452080 - Escape failure-text of failed-actions

* Tue May 16 2017 Grant Gainey 2.7.70-1
- 1067601 - Rename org-specific channel-family when org-name changes

* Fri May 12 2017 Laurence Rochfort <laurence.rochfort@oracle.com>
- 1436634 - PR 527 - Used StringBuilder correctly without '+' operator.
- 1436634 - PR 527 - Fix KS Default Download Location appending URL verbatim.

* Wed May 10 2017 Jan Dobes 2.7.68-1
- 1414406. Fix schedulePackage{Install,Remove}ByNevra arguments description.

* Tue May 09 2017 Grant Gainey 2.7.67-1
- 1445868 - Handle attempting to create ISS Master/Slave with existing FQDN
  more gracefully
- 1440696 , fix updateRepoSsl description

* Mon May 08 2017 Can Bulut Bayburt <cbbayburt@suse.com>
- PR 472 - Add 'Latest' back to button labels to make clear the latest version
  will be copied - Eric Herget <eherget@redhat.com>
- PR 472 - Update 'view/modify file' action buttons text

* Mon May 08 2017 Grant Gainey 2.7.65-1
- 1381857 - Teach Postgres to correctly-unique-ify rhnConfigInfo rows

* Mon May 08 2017 Silvio Moioli <smoioli@suse.de>
- PR 485 - Leave System Set Manager page title as-is - Eric Herget <eherget@redhat.com>
- PR 485 - SSM Task Log: make title coherent with menu item
- PR 485 - ssm_status.xml: format XML
- PR 485 - SSM Task Log page: put default as first tab
- PR 485 - Rename SSM page titles for consistency (bsc#979623)

* Mon May 08 2017 Eric Herget <eherget@redhat.com> 2.7.66-1
- PR 476 - Change to support java version < 1.8
- PR 476 - SidenavRenderer: do not ouput empty class
- PR 476 - Use different symbols for collapsible sidebar items

* Fri May 05 2017 Grant Gainey 2.7.62-1
- 1448342 - Fix config-deploy success message

* Thu May 04 2017 Can Bulut Bayburt <cbbayburt@suse.com>
- PR 483 - Hides 'Save/Clear' buttons when no changes are present in action
  chain lists
- PR 483 - Fix plus/minus buttons in action chain list

* Thu May 04 2017 Gennadii Altukhov <galt@redhat.com> 2.7.60-1
- 1436746 - remove 'Add Selected to SSM' button, because now WebUI requires
  enabled JavaScript

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.59-1
- recompile all packages with the same (latest) version of java
- point ivy to local jars installed from rpms
- fixed ant compile warning

* Wed May 03 2017 Jiri Dostal <jdostal@redhat.com> 2.7.58-1
- 1409537 Remove unused packages from KS > Rhel4

* Fri Apr 28 2017 Eric Herget <eherget@redhat.com> 2.7.57-1
- PR478 - Fix notification order for Create Organization page - Silvio Moioli <smoioli@suse.de>
- Remove unused imports.

* Thu Apr 27 2017 Grant Gainey 2.7.56-1
- 1445225 - Don't link a package if it doesn't have an id

* Thu Apr 27 2017 Grant Gainey 2.7.55-1
- 1445711 - Fix incorrect reference for id/name in JSP
- bz1441213. installation->removal in schedulePackageRemove,
  remove->removal(for consistency), nerva->nevra

* Tue Apr 25 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.54-1
- use newer version of commons-digester on RHEL6
- newer version of commons-beanutils is needed on RHEL6
- some java packages has been built with java 1.8.0

* Mon Apr 24 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.53-1
- fixing upgrade on Fedora 24
- no more special jar handling is needed
- simplify mchange-commons setup

* Fri Apr 21 2017 Jan Dobes 2.7.52-1
- 1414454 - adding test
- 1414454 - adding channel.listManageableChannels API and changing select to
  provide all expected fields for serializer

* Fri Apr 21 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.51-1
- resolving dependencies during upgrade on RHEL6
- resolving file conflicts on RHEL6 installation
- obsolete jpackage remnants on RHEL7
- 1441213 - fix description of api call

* Tue Apr 11 2017 Jan Dobes 2.7.50-1
- 1441219 - channel admin role shouldn't allow user to work with null-org
  channels

* Tue Apr 11 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.49-1
- use fedora (not jpackage) version of concurrent
- unify file ownership across subpackages

* Mon Apr 10 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.48-1
- updated RHEL6 (Build)Requires according to new java packages

* Mon Apr 10 2017 Jan Dobes 2.7.47-1
- obsolete some more packages for successfull upgrade on rhel 7

* Thu Apr 06 2017 Jiri Dostal <jdostal@redhat.com> 2.7.46-1
- 1380311 - API client.channel.software.createRepo() in 5.8.0 allows "yum" repo
  type only, 5.7.0 used "YUM"

* Tue Apr 04 2017 Gennadii Altukhov <galt@redhat.com> 2.7.45-1
- 1436746 - reverted commit 64d3df3b783c96548d53f31601c0e8322c23d8bc

* Thu Mar 30 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.44-1
- simplify rhn-search jar list

* Wed Mar 29 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.43-1
- fix perrmissions on /usr/share/spacewalk/taskomatic/*.jar

* Tue Mar 28 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.42-1
- run checkstyle on Fedora again
- fixed new checkstyle errors
- newer checkstyle requires commons-lang3
- use same requires on Fedora and RHEL7

* Mon Mar 27 2017 Gennadii Altukhov <galt@redhat.com> 2.7.41-1
- 1421115 - set number of bytes instead of length of java string for 'Content-
  Length' HTTP-header

* Fri Mar 24 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.40-1
- simplified taskomatic jar dependencies by linking them into a single
  directory

* Tue Mar 21 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.39-1
- include slf4j logger binding

* Mon Mar 20 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.38-1
- obsolete old jpackage rpms to make smooth upgrade

* Thu Mar 16 2017 Gennadii Altukhov <galt@redhat.com> 2.7.37-1
- 1408167 - add link to proxy system details page

* Wed Mar 15 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.36-1
- new cglib on Fedora 25 has different path

* Wed Mar 15 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.35-1
- jmock-junit3 and jmock-legacy has been split into different packages

* Wed Mar 15 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.34-1
- ProxyHandler: dead code removed
- struts-taglib is part of struts on Fedora / EPEL7
- hibernate on Fedora uses ehcache

* Mon Mar 13 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.33-1
- we need quartz v1 for build
- use standard objectweb-asm and cglib on all platforms
- use standard javamail on Fedora
- merged Requires/BuildRequires into a single ifdef (cleanup)
- jaf is a part of standard openjdk for a long time

* Fri Mar 10 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.32-1
- use standard apache-commons-fileupload on Fedora
- use standard apache-commons-el on Fedora
- use standard tomcat-taglibs-standard on Fedora

* Fri Mar 10 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.31-1
- Migrate to jMock2

* Fri Mar 03 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.30-1
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub
- Fix SSM reboot action success messages
- Fix checkbox icon align
- Get rid of remaining <noscript> elements as general noscript error is
  displayed for each page
- Display warning when JavaScript is disabled on all pages (bsc#987579)

* Wed Feb 22 2017 Ondrej Gajdusek <ogajduse@redhat.com> 2.7.29-1
- 1384093 - action now store its completion time

* Mon Feb 20 2017 Jan Dobes 2.7.28-1
- 1414459 - unschedule task only if exists

* Fri Feb 10 2017 Jan Dobes 2.7.27-1
- Fix JSP logic and readability
- Fix issue with checkboxes not being checked
- Fix broken merge (bsc#987864)

* Thu Feb 09 2017 Jan Dobes 2.7.26-1
- 1401497 - changing BaseRepoCommand to abstract class and some checkstyle
  fixes
- 1401497 - updating serializers
- 1401497 - updating repo create/edit API calls
- 1401497 - updating repo create/edit page
- 1401497 - update command to support multiple ssl sets per repository
- 1401497 - updating hibernate mapping

* Thu Feb 09 2017 Gennadii Altukhov <galt@redhat.com> 2.7.25-1
- 1418746 - add possibility to add systems to SSM from ProxyClients page

* Fri Feb 03 2017 Gennadii Altukhov <galt@redhat.com> 2.7.24-1
- 1408167 - escape XML in name of a system in Proxy list

* Fri Feb 03 2017 Gennadii Altukhov <galt@redhat.com> 2.7.23-1
- fixup
- fixup
- 1414421 - fix unhandled internal exception: null
- 1416810 - change the name of logfile
- fixing year

* Wed Jan 25 2017 Eric Herget <eherget@redhat.com> 2.7.22-1
- 1394299 - fix regression with virt system status display

* Wed Jan 25 2017 Jiri Dostal <jdostal@redhat.com> 2.7.21-1
- 1332805 - The problematic editing of kickstart profile - custom options

* Mon Jan 23 2017 Jan Dobes 2.7.20-1
- Use human-parseable dates for server notes (bsc#969564) (#863)

* Thu Jan 19 2017 Jiri Dostal <jdostal@redhat.com> 2.7.19-1
- 1324737 - [RFE] API call to get list of Systems Requiring Reboot

* Fri Jan 13 2017 Grant Gainey 2.7.18-1
- 1412555 - order all kickstart-tree-queries by label

* Thu Jan 12 2017 Gennadii Altukhov <galt@redhat.com> 2.7.17-1
- 1412177 - fix ISE when Kickstart File contains only newlines

* Wed Jan 11 2017 Gennadii Altukhov <galt@redhat.com> 2.7.16-1
- 1408167 - add links to systems in JSP

* Tue Jan 10 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.15-1
- update year in copyright

* Fri Jan 06 2017 Gennadii Altukhov <galt@redhat.com> 2.7.14-1
- 1410754 - fix Internal Server Error when kickstart file is empty
- re-implement createMonitoringScout API for backward compatibility

* Wed Dec 21 2016 Tomas Lestach <tlestach@redhat.com> 2.7.13-1
- bz1389349 change taskomatic uuid task to writemode vs callable

* Wed Dec 21 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.7.12-1
- edit method description
- fixing checkstyle - long line
- keep satellite.isMonitoringEnabled API for backward compatibility

* Tue Dec 20 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.7.11-1
- 1384093 - new API call failSystemAction

* Wed Dec 14 2016 Jiri Dostal <jdostal@redhat.com> 2.7.10-1
- Fix: remove double and useless check

* Wed Dec 07 2016 Eric Herget <eherget@redhat.com> 2.7.9-1
- 1402522 - Cancelling schedule action on Oracle fails when number of systems
  greater than 1000

* Wed Dec 07 2016 Jiri Dostal <jdostal@redhat.com> 2.7.8-1
- 1399841 - Remote command execution allows integers outside 32 bit range

* Fri Dec 02 2016 Jiri Dostal <jdostal@redhat.com> 2.7.7-1
- 1250572 - Text description missing for remote command by API and spacecmd

* Wed Nov 30 2016 Grant Gainey 2.7.6-1
- 1385099 - delete activation-keys using mode-query instead of hibernate

* Tue Nov 22 2016 Eric Herget <eherget@redhat.com> 2.7.5-1
- 1394299 - clean up system id inclusion in virt systems csv download

* Tue Nov 22 2016 Jiri Dostal <jdostal@redhat.com> 2.7.4-1
- Removing unused method. Last use removed by BZ 1388073
- 1388073 - unable to PXE provision: http://<fqdn>/rhn/kickstart/

* Mon Nov 21 2016 Gennadii Altukhov <galt@redhat.com> 2.7.3-1
- scheduleDetail.jsp: clarify button label

* Thu Nov 17 2016 Eric Herget <eherget@redhat.com> 2.7.2-1
- 1394299 - Add missing CSV labels to strings and add a space to separate xml
  attributes in listtag
- 1394299 - Remove the temporary old virt systems page
- 1394299 - Add CSV download to virt sys page that is now converted to new list
  tag
- 1394299 - Switch virt sys page to new list tag leaving old virt sys page
  temporarily
- 1394299 - Add support for postFilter processing of filtered data to support
  conversion to new list tag
- 1394299 - tidy up commit for work on Download CSV option on Virt Systems page

* Wed Nov 16 2016 Jan Dobes 2.7.1-1
- 1394245 - fill label and id on error page
- 1394245 - content type can change too, handle it
- 1394245 - set variable in case of errors
- Bumping package versions for 2.7.

* Mon Nov 14 2016 Gennadii Altukhov <galt@redhat.com> 2.6.48-1
- remove Solaris from strings
- don't test removed solaris architectures

* Tue Nov 08 2016 Gennadii Altukhov <galt@redhat.com> 2.6.47-1
- Bump API Version
- Merging frontend L10N from Zanata

* Fri Nov 04 2016 Grant Gainey 2.6.46-1
- 1385811 - log login/out and failures, update log4j defaults

* Thu Nov 03 2016 Tomas Lestach <tlestach@redhat.com> 2.6.45-1
- 1251252 - removing use of 'Satellite' in kickstart.* (API)doc

* Wed Oct 26 2016 Jan Dobes 2.6.44-1
- 1240597 - fixing null pointer exception when we call updateLogPaths()
  multiple times
- 1240597 - catch HibernateException on commit when touched data in database
  were modified during task execution by someone else

* Thu Oct 20 2016 Jan Dobes 2.6.43-1
- fixing hibernate mapping
- fixing occurences in code
- Ensure no stray config channels are listed for ranking (bsc#979630)

* Mon Oct 17 2016 Gennadii Altukhov <galt@redhat.com> 2.6.42-1
- fill KickstartData when select kickstart profile.
- add small fix for Kickstart profile update.

* Fri Oct 14 2016 Grant Gainey 2.6.41-1
- Updated specfile - RHN -> Spacewalk
- Checkstyle: remove redundant modifiers
- add missing string

* Wed Oct 05 2016 Eric Herget <eherget@redhat.com> 2.6.40-1
- 1377841 - return empty DataResult when querying with empty inClause and query
  has in clause substitution
- Revert "1380304 - API client.channel.software.createRepo() should not
  advertise it supports "uln""

* Mon Oct 03 2016 Eric Herget <eherget@redhat.com> 2.6.39-1
- 1377841 - csv download all items, not remainder of dividing total items by
  500

* Mon Oct 03 2016 Jiri Dostal <jdostal@redhat.com> 2.6.38-1
- 1380304 - API client.channel.software.createRepo() should not advertise it
  supports "uln"

* Fri Sep 30 2016 Eric Herget <eherget@redhat.com> 2.6.37-1
- 1365410 - remove updateinfo.xml.gz if last errata associated with channel is
  deleted

* Fri Sep 30 2016 Jiri Dostal <jdostal@redhat.com> 2.6.36-1
- 1380311 - API client.channel.software.createRepo() in 5.8.0 allows "yum" repo
  type only

* Tue Sep 27 2016 Jiri Dostal <jdostal@redhat.com> 2.6.35-1
- 1378879 - The API system.upgradeEntitlement does not work

* Mon Sep 26 2016 Jan Dobes 2.6.34-1
- support initiating RHEL kickstart with dnf-plugin-spacewalk installed

* Thu Sep 22 2016 Jan Dobes 2.6.33-1
- partially fixing reposync progress bar

* Tue Sep 20 2016 Eric Herget <eherget@redhat.com> 2.6.32-1
- 1377839 - fix a few tiny issues and update eclipse code formatter settings

* Tue Sep 20 2016 Jiri Dostal <jdostal@redhat.com> 2.6.31-1
- 1368490 - RFE: add 'Create new Repository' link on the channel repositories
  page

* Mon Sep 12 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.6.30-1
- Added completed column to audit CSV download

* Tue Sep 06 2016 Jiri Dostal <jdostal@redhat.com> 2.6.29-1
- 1356173 - kickstart.profile.set_advanced_options does not update kickstart
  file

* Fri Sep 02 2016 Grant Gainey 2.6.28-1
- Make heading match navigation: "Managed Systems"

* Fri Sep 02 2016 Grant Gainey 2.6.27-1
- Redirect user to a meaningful page after requesting details of non-existing
  Action Chain

* Mon Aug 29 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.6.26-1
- removed unwanted chars and lines from previous commit
- Changed from 'RHN' to 'Satellite' in API doc.
- Revert "1282838 - Fix extremely slow channel.software.syncErrata API"

* Wed Aug 10 2016 Jiri Dostal <jdostal@redhat.com> 2.6.25-1
- 1357824 - Kickstart advanced options accept required options without argument
- Kickstart AdvancedOptions ISE without URL

* Wed Aug 10 2016 Eric Herget <eherget@redhat.com> 2.6.24-1
- 1365530 - add system data to downloaded csv on Advanced Search page

* Thu Aug 04 2016 Grant Gainey 2.6.23-1
- 1351785 - getInputStream() reached from multiple places

* Wed Aug 03 2016 Jiri Dostal <jdostal@redhat.com> 2.6.22-1
- 1332805 - The problematic editing of kickstart profile

* Wed Aug 03 2016 Jiri Dostal <jdostal@redhat.com> 2.6.21-1
- 1332805 - The problematic editing of kickstart profile

* Wed Aug 03 2016 Jiri Dostal <jdostal@redhat.com> 2.6.20-1
- 1332805 - The problematic editing of kickstart profile

* Tue Aug 02 2016 Jan Dobes 2.6.19-1
- 1192879 - refresh list on click
- 1192879 - use radio box instead of checkbox
- Fixing typo "with the past year" > "within the past year""

* Wed Jul 27 2016 Jiri Dostal <jdostal@redhat.com> 2.6.18-1
- 1356173 - kickstart.profile.set_advanced_options does not update kickstart
  file

* Tue Jul 19 2016 Grant Gainey 2.6.17-1
- 1226329 - sense support for debian packages

* Tue Jul 19 2016 Jiri Dostal <jdostal@redhat.com> 2.6.16-1
- ISE kickstart AdvancedOptions with "url" field checked but not set

* Mon Jul 11 2016 Jiri Dostal <jdostal@redhat.com> 2.6.15-1
- 1324737 - API call to get list of Systems Requiring Reboot

* Thu Jul 07 2016 Gennadii Altukhov <galt@redhat.com> 2.6.14-1
- 1353210 - use Oracle and PostgreSQL compatible 'REGEXP_REPLACE' function
  instead of 'SUBSTRING'

* Tue Jul 05 2016 Grant Gainey 2.6.13-1
- 1351695 - Traceback: comparison method violates its general contract Cleanup
  of a few more suboptimal compare() methods

* Tue Jul 05 2016 Grant Gainey 2.6.12-1
- 1351695 - Fix SystemSearchHelper score-comparator This should fix the TimSort
  issue, in addition to fixing a variety of broken edge-case behavior in this
  comparator. Also adds a Junit for
  SystemSearchHelper.SearchResultScoreComparator

* Wed Jun 29 2016 Tomas Lestach <tlestach@redhat.com> 2.6.11-1
- 1124809 - fix system sorting by last checkin

* Tue Jun 21 2016 Gennadii Altukhov <galt@redhat.com> 2.6.10-1
- 1348522 - add sha512 support for password encryption in kickstart profile

* Tue Jun 21 2016 Jan Dobes 2.6.9-1
- fixing api documentation
- adding exception for invalid repo type
- rewriting code to use lookup by label only
- redundant statement
- need to have lookup by label method because of API

* Mon Jun 20 2016 Jiri Dostal <jdostal@redhat.com> 2.6.8-1
- 1332880 - Updating of network properties does not work without HW profile

* Fri Jun 17 2016 Jan Dobes 2.6.7-1
- make possible to select content type for repo

* Fri Jun 10 2016 Jan Dobes 2.6.6-1
- fix rhnContentSourceSsl -> rhnContentSsl in code

* Thu Jun 09 2016 Grant Gainey 2.6.5-1
- 1322710 - <c:out> is your friend

* Fri Jun 03 2016 Jiri Precechtel <jprecech@redhat.com> 2.6.4-1
- 1288818 - added API method actionchain.addErrataUpdate()

* Fri May 27 2016 Jan Dobes 2.6.3-1
- removing couple of execute permissions in spacewalk-java
- control taskomatic by systemd on rhel 7

* Fri May 27 2016 Jiri Precechtel <jprecech@redhat.com> 2.6.2-1
- 1116426 - "Delete Group" and "Work With Group" buttons are not be displayed
  on the Delete Group confirmation page now

* Fri May 27 2016 Jiri Precechtel <jprecech@redhat.com> 2.6.1-1
- 1304093 - remove migrated systems from SSM if they are selected
- Bumping package versions for 2.6.

* Thu May 26 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.99-1
- bumping java.apiversion for 2.5

* Thu May 26 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.98-1
- fix checkstyle

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.97-1
- call 'queue channel change' only once per channel change
- removing unused code
- updating copyright years
- Merging frontend L10N from Zanata

* Fri May 20 2016 Grant Gainey 2.5.96-1
- Don't modify request map when rendering alphabar, since it may fail depending
  on the implementation of ServletRequest

* Thu May 19 2016 Jiri Precechtel <jprecech@redhat.com> 2.5.95-1
- 1302323 - listVirtualGuests(): returned structures contain virtual system Id
  in "id" key now

* Wed May 18 2016 Grant Gainey 2.5.94-1
- 1291031 - Tweaks for the tree-structures on the Duplicate*.do pages

* Tue May 17 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.93-1
- don't rely on postgresql service

* Mon May 16 2016 Tomas Lestach <tlestach@redhat.com> 2.5.92-1
- 1330610 - fix repodata regeneration after errata removal

* Thu May 12 2016 Grant Gainey 2.5.91-1
- 1334296 - Limit filter-by to a slightly less-ridiculous number of characters

* Thu May 12 2016 Grant Gainey 2.5.90-1
- 1334308 - better error/oid/org handling

* Thu May 12 2016 Grant Gainey 2.5.89-1
- 1333443 - Added note to explain potential discrepancy between Total and num-
  clients

* Wed May 11 2016 Tomas Lestach <tlestach@redhat.com> 2.5.88-1
- 1335104 - fix user filtering on /rhn/groups/AdminList.do page
- Exit if there are exceptions on startup to let tanuki restart taskomatic
- Revert addition of tomcat as requirement for taskomatic systemd service.
- Remove pointless check for tomcat being up.
- log to the service wrapper so that we can see the messages during onStartUp()
- Under high load, the service wrapper may incorrectly interpret the inability
  to get a response in time from taskomatic and kill it (bsc#962253).

* Wed Apr 27 2016 Grant Gainey 2.5.87-1
- 1291031 - Remove OldTag junits (which weren't very useful to begin with)
- 1291031 - Refactor errata-mgt pages to use NewListTag  * Collapse actions to
  one each for List/Remove  * Rework JSPs for new tag  * Tweak nav.xml to match
  action-changes
- make checkstyle on Fedora22 happy

* Tue Apr 19 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.86-1
- TaskomaticApi refactoring: method code formatted
- TaskomaticApi refactoring: method code formatted
- RepoSyncTask refactoring: spacing and comments
- ChannelFactory.getChannelIds refactoring: never return null

* Mon Apr 18 2016 Jan Dobes 2.5.85-1
- 1192879 - support basic listing of source packages with API
- 1192879 - support remove source package with API

* Fri Apr 15 2016 Jan Dobes 2.5.84-1
- clean unused pages
- acl fixes
- update strings
- remove proxy.jsp, action and struts config
- add proxy version info to proxyclients page
- change details->proxy tab to point to proxyclients

* Wed Apr 13 2016 Jiri Precechtel <jprecech@redhat.com> 2.5.83-1
- Added switch to show Systems with Managed cfg files only

* Mon Apr 11 2016 Jan Dobes 2.5.82-1
- 1192879 - updating confirm page
- 1192879 - adding delete queries for database and filesystem
- 1192879 - adding queries for listing source package ids in set
- 1192879 - make possible to list source packages + other minor fixes on page
- 1192879 - adding checkbox for listing source packages
- 1192879 - adding queries for listing source packages
- 1192879 - cannot automatically delete source package as other packages may
  still use it

* Fri Apr 08 2016 Tomas Lestach <tlestach@redhat.com> 2.5.81-1
- Fix the string representation of PackageEvr

* Wed Apr 06 2016 Jiri Precechtel <jprecech@redhat.com> 2.5.80-1
- 1274484 - changed name of key in ConfigRevision structure + updated API doc +
  configchannel.py

* Tue Apr 05 2016 Jan Dobes 2.5.79-1
- improving apidoc appearance

* Fri Apr 01 2016 Gennadii Altukhov <galt@redhat.com> 2.5.78-1
- 1323126 - Fix getting MD5 for file
- fix scheduling an action chain
- Fix: 'Systems > Advanced Search' title and description consistency
- fix splitting kernel options

* Thu Mar 31 2016 Gennadii Altukhov <galt@redhat.com> 2.5.77-1
- 1322890 - Fix Content-Length in HTTP-header of response

* Wed Mar 30 2016 Grant Gainey 2.5.76-1
- 1320452 - Cleaning up some remaining Tag/Group XSS issues

* Wed Mar 30 2016 Jiri Precechtel <jprecech@redhat.com> 2.5.75-1
- 1158981 - Warning "Unservable packages" is not shown when such packages don't
  exist now

* Tue Mar 29 2016 Grant Gainey 2.5.74-1
- 1320444 - typo slipped past. Ugh.

* Tue Mar 29 2016 Grant Gainey 2.5.73-1
- 1320444 - Bad bean-message ids and navbar-vars can lead to XSS issues

* Tue Mar 29 2016 Grant Gainey 2.5.72-1
- 1313517 - AlphaBar had an 'interesting' XSS exploit available
- Whitespace fixes

* Mon Mar 28 2016 Grant Gainey 2.5.71-1
- 1291031 - Fix SelectAll in the presence of filtering

* Mon Mar 28 2016 Grant Gainey 2.5.70-1
- 1320452 - <c:out> is your friend

* Mon Mar 28 2016 Grant Gainey 2.5.69-1
- 1313515 - found/fixed another in BunchDetails. QE++

* Thu Mar 24 2016 Jiri Precechtel <jprecech@redhat.com> 2.5.68-1
- 1063839 - added comment to deleteCustomValues API method's "returns" section

* Thu Mar 24 2016 Gennadii Altukhov <galt@redhat.com> 2.5.67-1
- 1320236 - Change mechanism of selecting compatible systems

* Wed Mar 23 2016 Jan Dobes 2.5.66-1
- Fix: add a missing url mapping for kickstart/tree/EditVariables
- Whitespace fix

* Mon Mar 21 2016 Jan Dobes 2.5.65-1
- Make read-only entitlements show up aligned in the UI

* Sun Mar 20 2016 Jan Dobes 2.5.64-1
- Disable changing Managers for Vendor Channels

* Fri Mar 18 2016 Jan Dobes 2.5.63-1
- Fix case statements to correctly check for NULL

* Thu Mar 17 2016 Tomas Lestach <tlestach@redhat.com> 2.5.62-1
- remove redundant line
- add missing string

* Fri Mar 11 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.61-1
- add missing string (UUID cleanup description)

* Wed Mar 09 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.60-1
- move uuid cleanup logic into taskomatic

* Mon Mar 07 2016 Grant Gainey 2.5.59-1
- 1313515 - add unittest for id in hidden fields
- 1313515 - hidden taglib provide id field if given

* Fri Mar 04 2016 Grant Gainey 2.5.58-1
- 1313515 - adding fn:escapeXml to <bean:message arg="${}"/> issues in JSPF
- 1313515 - adding fn:escapeXml to a number of <bean:message arg="${}"/> issues
  in JSPs

* Tue Mar 01 2016 Grant Gainey 2.5.57-1
- 1313515 - value=<c:out may have worked for <input>, but not for rhn:hidden
- 1313515 - cobbler-variables.jspf has a 'special' use of <input type='hidden'>

* Tue Mar 01 2016 Grant Gainey 2.5.56-1
- 1313515 - <input...> is ok, <rhn:hidden > is not - close your tags!

* Tue Mar 01 2016 Grant Gainey 2.5.55-1
- 1313515 - checkstyle is a Harsh Mistress

* Tue Mar 01 2016 Grant Gainey 2.5.54-1
- 1313515 - action-chain CSS wants a dynamic attribute-name - revert to 'stock'
  <input type='hidden'
- 1313515 - we use 'id' in some of out hidden-inputs
- 1313515 - 'value' is (apparently) optional for some of our hidden-tag-use
- 1313515 - One more jspf to teach rhn:hidden
- 1313515 - Teach many JSPs to use rhn:hidden instead of <input type='hidden'>
- 1313515 - Add new rhn:hidden tag and its test
- 1313517 - Teach ListTagHelper to be less trusting of filter-values
- remove monitoring from the help text

* Fri Feb 19 2016 Grant Gainey 2.5.53-1
- Tweaked TZ-ordering - goes E-to-W starting with GMT. Also cleaned up the
  associated junit
- order is assertEquals(expected, actual)
- use generics
- Sort timezones: GMT first and then east to west
- UserManagerTest: use the proper assert methods in order to get useful
  information on failures
- add Chile to the list of timezones (bsc#959055)
- Add junit for 2f19c70e, clean up StringUtilTest.java * Doesn't need the
  extras of RhnBaseTestCase * Cleaned up generics-warnings
- Fix: prevent return null on merging path slices
- 1244512 - deprecating useless method

* Fri Feb 19 2016 Grant Gainey 2.5.52-1
- 1309892 - on cancel, only delete actions that haven't been picked up yet

* Fri Feb 19 2016 Jan Dobes 2.5.51-1
- Fix option names to correspond with rhn_server.conf

* Thu Feb 18 2016 Grant Gainey 2.5.50-1
- 1304863 - previous overzealous fix, 'fixed' one query too many

* Thu Feb 04 2016 Grant Gainey 2.5.49-1
- 1304863 - add scheduled-by to SSM action-history-list

* Thu Feb 04 2016 Grant Gainey 2.5.48-1
- 1122974 - ISE in case no system is selected

* Wed Feb 03 2016 Tomas Lestach <tlestach@redhat.com> 2.5.47-1
- for Channel.packageByFileName query prefer packages from the actual channel,
  sort the rest accoring to build_time

* Tue Feb 02 2016 Jiri Dostal <jdostal@redhat.com> 2.5.46-1
- 1250572 - Text description missing for remote command by API -> function
  scheduleLabelScriptRun()

* Fri Jan 29 2016 Gennadii Altukhov <galt@redhat.com> 2.5.45-1
- 1302996 Added/changed API-methods to work with package installation/removing
  using it's nevra
- 1302996 Added additional information to package metadata, returned by
  serializer

* Wed Jan 27 2016 Tomas Lestach <tlestach@redhat.com> 2.5.44-1
- additionaly sort results according to build_time, when searching for packages
  by filename
- 1287829 - reverting original changes

* Mon Jan 25 2016 Grant Gainey 2.5.43-1
- Make it compile against servlet API < 3.0
- Avoid the diamond operator
- Render nav menu by either request or page context
- Create RenderUtils as a helper for rendering menus

* Sun Jan 24 2016 Grant Gainey 2.5.42-1
- Fix: sort channel list by name

* Sun Jan 24 2016 Grant Gainey 2.5.41-1
- Remove unused import
- Share logic to setup unit tests
- Rewrite RhnJmockBaseTestCase to support setUp() as well

* Sun Jan 24 2016 Grant Gainey 2.5.40-1
- SystemHandler: fix JDK7 compatibility
- Entitlement refactory: remove unused isSatelliteEntitlement() method and fix
  BaseHandler.validateEntitlements() to check for isPermanent() instead
- SystemHandler: throw exception when permanent/nonSatellite entitlements are
  changed via API

* Sun Jan 24 2016 Grant Gainey 2.5.39-1
- Set HTTP status code for error pages
- Allow error pages to be requested via HTTP
- Add error pages to UNPROTECTED_URIS

* Sat Jan 23 2016 Grant Gainey 2.5.38-1
- MessageQueue/ActionExecutor: use generics

* Sat Jan 23 2016 Grant Gainey 2.5.37-1
- log error instead of printStackTrace()

* Tue Jan 19 2016 Gennadii Altukhov <galt@redhat.com> 2.5.36-1
- 1287246 - Added fixes to API methods

* Mon Jan 18 2016 Gennadii Altukhov <galt@redhat.com> 2.5.35-1
- 1287246 - Added new API methods to add new repository with SSL certificates
  or update existing one
- BugFix: fixed comparison with null pointer

* Thu Jan 07 2016 Jan Dobes 2.5.34-1
- Tomcat 8 requires different syntax of rhn.xml
- change dependency to match Tomcat 8 Servlet API 3.1

* Thu Jan 07 2016 Jan Dobes 2.5.33-1
- start to compile with Java 1.7 because Jasper in Tomcat 8 generates 1.5
  incompatible code
- disable checkstyle on Fedora 23 for now due to regression
- implement methods needed by Tomcat 8 Servlet API 3.1

* Wed Jan 06 2016 Grant Gainey 2.5.32-1
- 1296234 - Fix edge-case in kickstart-profile-gen-ordering and
  post_install_network_config
- we have new year

* Mon Jan 04 2016 Grant Gainey 2.5.31-1
- 1282474 - checkstyle fixes

* Mon Jan 04 2016 Grant Gainey 2.5.30-1
- 1282474 - Add hack to deal with RHEL7's differing redhat-release-protocol

* Fri Dec 18 2015 Tomas Lestach <tlestach@redhat.com> 2.5.29-1
- 1287829 - make sure we can find the child channel
- fix checkstyle issue

* Thu Dec 17 2015 Jan Dobes 2.5.28-1
- moving non_expirable_package_urls parameter to java
- moving download_url_lifetime parameter to java
- removing unused force_unentitlement configuration parameter

* Wed Dec 16 2015 Jan Dobes 2.5.27-1
- get the default organization before we create any

* Thu Dec 10 2015 Jan Dobes 2.5.26-1
- 1274282 - Teach CobblerSyncProfile that profiles might disappear in mid-run

* Wed Dec 09 2015 Jan Dobes 2.5.25-1
- moving smtp_server parameter to java
- making chat icon visible and better placed
- moving chat_enabled parameter to java
- moving actions_display_limit parameter to java
- moving base_domain and base_port parameters to java
- compile jspf files differently to avoid problems with Tomcat 8
- fix jar versions on fedora23

* Mon Dec 07 2015 Jan Dobes 2.5.24-1
- cleanup create user page since we don't create first user there anymore

* Mon Dec 07 2015 Jan Dobes 2.5.23-1
- better set logging user earlier
- removing entitlements info

* Mon Dec 07 2015 Jan Dobes 2.5.22-1
- adding setup for first organization
- fixing select with null
- redirecting jsp files to create first org instead of user

* Fri Dec 04 2015 Tomas Lestach <tlestach@redhat.com> 2.5.21-1
- 1287829 - make sure package from a right child channel is provided for
  kickstart

* Fri Dec 04 2015 Jan Dobes 2.5.20-1
- when installing insert default SSL crypto key with null org

* Thu Dec 03 2015 Jan Dobes 2.5.19-1
- fixing confusing name and making difference between create first user form
  and create normal user form
- restyle page for creating users
- remove RHEL 5 related things - we don't build on el5 anymore
- remove remnants of old Fedora/RHEL versions
- remove unused macro
- removing unused code

* Fri Nov 27 2015 Tomas Lestach <tlestach@redhat.com> 2.5.18-1
- BugFix: skip similar tasks only if task is 'single threaded'
- 1076490 - prefer the package from the given channel

* Thu Nov 26 2015 Jan Dobes 2.5.17-1
- removing link to removed page
- ActionChainHandler: javadoc fixes
- replace html:select with simple select to fix plain text printing

* Wed Nov 25 2015 Tomas Kasparek <tkasparek@redhat.com> 2.5.16-1
- BZ-1284101 Incorrect query parameters cause unique constraint violations when
  cloning errata

* Tue Nov 24 2015 Jan Dobes 2.5.15-1
- SystemEntitlementsSetupActionTest: stale comment removed
- java: remove unused imports
- drop usage of rhnOrgEntitlements and rhnOrgEntitlementsType tables
- drop OrgFactory.lookupEntitlementByLabel() and references
- drop getEntitlementEnterprise() and references
- drop getEntitlementVirtualization() and references
- drop use of org_entitlements() acl checks from jsps
- drop use of org_entitlements() acls from navigation
- java: fix entitlement-testing cases
- java: remove repoll parameter from
  rhn_entitlements.remove_server_entitlement()
- i18n: unused strings removed
- OrgHandler: remove unused constants
- SystemEntitlementsSetupAction: remove useless check
- ChannelFamilyFactoryTest: unused method removed
- ChannelFamilyFactoryTest: fix checkstyle issue
- LoginSetupActionTest: remove tests that are not relevant anymore
- OrgFactoryTest: drop test, does not make sense anymore
- SystemDetailsEditActionTest.testAddonEntitlemntsList: fix
- SystemEntitlementsSetupActionTest: fix
- SystemHandler: remove comment leftover
- ChannelFamilyFactoryTest: remove entitlement leftovers
- SystemManagerTest: remove test, it does not make sense in the end
- SystemGroupOvervirew: remove unused code
- ServerGroupTest: dead code removal
- SummaryPopulation Taskomatic task: assume all orgs always have enterprise
  entitlements
- SystemHandler.listGroups: visible system groups have no max members, simplify
  query
- EntitlementServerGroup: remove references to max_members from the class and
  test code
- i18n: unused strings removed
- EntitlementServerGroupSerializer: unused, removed
- i18n: unused strings removed
- EntitlementManager: remove dead code
- SystemManager: don't check entitlement counts when changing a system's
  entitlements
- SystemEntitlementsSubmitAction: remove dead code - available entitlement
  count is not shown anymore
- System Details page: don't show entitlement counts
- UpdateOrgSystemEntitlementsCommand: drop unused code
- OrgHandler: drop setSystemEntitlements API endpoint
- OrgHandler/OrgManager: dead code removed
- OrgHandler: drop listSystemEntitlements API endpoint
- OrgHandler: drop listSystemEntitlements API endpoint
- SystemEntitlementsDto: drop unused class
- EntitlementManager: dead code removed
- OrgHandler: drop listSystemEntitlements API endpoint
- SystemEntitlementsAction: page dropped
- SystemEntitlementDetailsAction: page dropped
- SystemEntitlementOrgsAction: page dropped
- OrgEntitlementDto: dead code removed
- OrgHandler: drop listSystemEntitlementsForOrg API endpoint
- OrgSystemSubscriptionsAction: page dropped
- EntitledServerGroup: unused code removed
- NotEnoughEntitlementsException: unused exception removed
- SystemHandler.upgradeEntitlement: remove entitlement count check
- SystemEntitlementsSetupAction: assume all entitlements are unlimited
- ConfigureCertificateCommand: unused, dropped
- CertificateConfig.do: page dropped
- editlangs.sh: generalize a bit for non-jsp files
- i18n: unused strings removed
- SatelliteCertificateExpiredException: unused, dropped
- SatelliteCertificate: unused, dropped
- SatelliteFactory: unused, dropped
- CertificateFactory: unused, dropped
- SatelliteHandler: getCertificateExpirationDate() dropped
- CertificateManager: unused, dropped
- sat-cert-check Taskomatic task dropped
- LoginExpiredTest: dropped
- LoginSetupAction, LoginAction: don't restrict access if the certificate is
  expired
- java: XMLRPC restricted whitelist dead code removal
- BaseHandler: don't restrict XMLRPC APIs if the certificate is expired
- java: restricted whitelist dead code removal
- AuthFilter: don't restrict page visits if the certificate is expired
- ActivationKeyHandlerTest: avoid Java 7 constructs
- i18n: Remove system.entitle.alreadyvirt
- i18n: Remove virtualization_host_platform
- i18n: Remove
  system_entitlement_details.access_grant_desc.virtualization_host_platform
- i18n: Remove sys_entitlements.virtualization_host_platform
- i18n: Remove system_entitlements.virtualization_host_platform.success
- i18n: Remove system_entitlements.virtualization_host_platform.removed.success
- i18n: Remove system_entitlements.virtualization_host_platform.notEnoughSlots
- i18n: Remove system_entitlements.virtualization_host_platform.noManagement
- i18n: Remove
  system_entitlements.virtualization_host_platform.noSolarisSupport
- java: remove references to rhnVirtSubLevel which is not used anymore
- java: delete class and methods not used anymore
- java: remove test code referencing rhnVirtSublevel
- SystemChannelsActionTest: remove commented out dead test
- SystemManager: unused import removed
- Removed dead localization key (virt_plat_tip)
- Remove Virtualization Platform from hibernate
- Remove Virtualization Platform from CommonConstants and tests
- Remove Virtualization Platform from some tests
- Remove Virtualization Platform checking when adding entitlement to an
  activation key, adjust the test
- Drop EntitlementManager.VIRTUALIZATION_PLATFORM ent and
  EntitlementManager.VIRTUALIZATION_PLATFORM_ENTITLED and their usages
- Remove Virtualization Platform test from EntitlementManagerTest
- Remove Virtualization Platform from Server and ServerTest
- api: Remove Virtualization Platform from SystemHandler, remove Virtualization
  Platform and Virtualization exclusivity check, adjust the test
- api(doc): Remove Virtualization Platform from ServerSerializer
- api: Remove Virtualization Platform from OrgHandlerTest
- api(doc): Remove Virtualization Platform from OrgHandler
- api: Remove Virtualization Platform from ActivationKeyHandlerTest
- api(doc): Remove Virtualization Platform from documentation of
  ActivationKeyHandler
- api: Remove checking for Virtualization Platform and Virtualization
  entitlements exclusivity from the API validation
- Remove Virtualization Platform from SystemManagerTest, cleaned up unused
  methods.
- Remove handling Virtualization Platform when entitling a server in
  SystemManager
- Remove unused methods from tests
- Remove checking for Virtualization Platform when checking and updating server
  entitlements in SystemDetailsEditAction
- Remove Virtualization Platform from Overview -> Subscription Management ->
  System Entitlements view
- Remove Virtualization Platform from Admin -> Organizations view
- translation strings: remove unused non-linux entitlement string
- java: remove update entitlement references from test code
- Org: remove unused fake update org entitlement
- SearchAction: don't check for update org entitlement
- EntitlementManager: remove references to update entitlements
- translation strings: remove unused references
- translation strings: remove reference to update entitlements
- SystemDetailsEditAction: don't show update entitlement counts
- SystemDetailsEditAction: don't filter update entitlements
- ServerConstants: remove unused method getServerGroupTypeUpdateEntitled
- System entitlements page: don't handle update entitlements
- SystemEntitlementsAction: don't check for update entitlements
- SystemHandler: update entitlement removed from documentation
- ServerSerializer: update entitlement removed from documentation
- java: more unused imports removed
- java: fix checkstyle warnings
- Task_queries: remove provisioning entitlement
- EnableListAction: don't show provisioning entitlement
- Unused translation strings removed
- navigation menus: remove rhn_provisioning ACL checks
- jsps: remove rhn_provisioning ACL checks
- struts-config.xml: removed all rhn_provisioning references
- PackageAclHandler: fix javadoc
- OrgFactory: remove unused method
- BaseHandler: remove unused method
- Drop provisioning entitlement code from Java test classes
- SystemDetailsEditAction: don't expect provisioning parameter
- ConfigList actions: don't require provisioning entitlement
- CustomValueSetAction: don't require provisioning for custom data setting
- SystemManager: don't require provisioning in rollback to tag
- ActivationKeyManager: don't handle special provisioning entitlement case
- ServerConstants: getServerGroupTypeProvisioningEntitled dropped
- ProvisioningEntitlement: dropped
- EntitlementManager: don't expect provisioning entitlement
- EnableConfigHelper: don't add provisioning entitlement
- ActionManager: don't require provisioning entitlement to run scripts
- SystemEntitlementsSubmitAction: don't expect provisioning entitlement in form
  data
- ProvisioningRemoteCommand: don't require provisioning for remote command
- BaseSystemPackagesConfirmAction: don't require provisioning for rollback
- KickstartScheduleCommand: avoid adding provisioning entitlement to activation
  key
- ActivationKeyDetailsAction: remove provisioning entitlement check
- SystemHandler: drop provisioning entitlement checks
- SystemHandler: drop provisioning entitlement from documentation
- OrgHandler: drop provisioning entitlement from documentation
- ActivationKeyHandler: drop provisioning entitlement checks
- ActivationKeyHandler: drop provisioning entitlement from documentation
- ServerSerializer: remove provisioning entitlement documentation
- Drop Activation Key checks on config file deployments on provisioning
  entitlement
- ActivationKeyAclHandler: drop
- Activation Key page: remove check on provisioning entitlement
- System Details page: don't show provisioning entitlement
- ProxyHandler: require enterprise entitlement instead of provisioning
- System Entitlement Counts page: removal of the provisioning entitlement
- Allow system tagging actions even without the provisioning entitlement in UI
- Allow power management actions even without the provisioning entitlement in
  UI
- Drop provisioning-related Python tests
- Unused translation strings removed: monitoring entitlement
- Remove references to rhn_config_macro from Java code
- Remove 'monitoring_entitled' from Python tests
- refactor: Rename monitoring package
- branding: remove unused css classes and their dead references
- java: ServerFactoryTest imports organized
- java: context references to removed page removed
- Unused translation removed
- Unused translation removed
- java: remove unused constant and import
- java: remove unused class SnapshotRollbackException
- java: context references to removed page removed
- Unused translation removed
- Unused translation removed
- java: remove HostAndGuestCountView and related methods
- Unused translation removed
- java: fixed context in StringResource
- Unused translation removed
- Unused translation removed
- Unused translation removed
- java: remove ChannelFamilySystem
- Unused translation removed
- java: remove ChannelFamilySystemGroup
- java python tests: remove tests for dropped API setSoftwareEntitlements
- java: remove example script which uses obsolete satellite.listEntitlements
  API
- java python tests: remove tests for dropped APIs
- java: remove MultiOrgEntitlementsDto
- Unused translation removed
- java: remove page from authentication service whitelist
- Unused translation removed
- java: remove SoftwareEntitlementDto
- Unused translation removed
- java: remove SoftwareEntitlement StringResources
- java: remove unused members from ChannelOverview
- java: remove OrgChannelFamily
- java: remove OrgChannelFamilySerializer
- java: remove ChannelOverviewSerializer
- java: remove is_fve from system_channel_subscriptions query
- VirtualInstanceFactory: imports organized
- java: remove maxMembers, currentMembers, maxFlex and currentFlex from
  PrivateChannelFamily
- java: removed unused package_search query files
- java: modify insert_family_perms - not set members explicitly
- java: remove unused methods listFlexGuests and runFlexGuestsQuery
- java: remove channel_entitlement and channel_entitlement_for_all_orgs queries
- SnapshotHandler: imports organized
- SatelliteHandlerTest: imports organized
- SatelliteHandler: imports organized
- SnapshotRollbackAction: imports organized
- java: remove handling for channel_family_no_subscriptions exception
- java: remove entitlements() and getEntitlement() from ChannelManager
- java: change ChannelFamily product URL
- java: remove ChannelFamilyTree page
- java XMLRPC: remove listEntitlements from SatelliteHandler
- remove current_members and available_members from rhnAvailableChannels view
- ChannelManagerTest: imports organized
- SsmManager: imports organized
- ChannelManager: imports organized
- ChildChannelDto: checkstyle fixes
- ChildChannelConfirmAction: checkstyle fixes
- java: remove SystemManager.isServerIdFveEligible()
- java: remove ChannelManager.isChannelFreeForSubscription()
- java: remove all getAvailableFveEntitlements() methods and
  ChannelEntitlementCounter
- java: remove getAvailableEntitlements() methods
- java: remove SsmManager.verifyChildEntitlements()
- java: remove SystemManager.canServerSubscribeToChannel()
- java: cleanup ChildChanneDto; remove available(Fve)Subscriptions and
  isFreeForGuest
- java XMLRPC: remove ChannelSoftwareHandler.availableEntitlements()
- java: remove OrgSoftwareEntitlementDto
- java: remove unused assign_software_entitlements query
- java: remove unused VirtualInstanceFactory.listEligibleFlexGuests() method
- java: remove unused UpdateOrgSoftwareEntitlementsCommand and test
- java: SystemHandler imports organized
- java: remove unused VirtualizationEntitlementsManager class and tests
- java: remove GuetsLimitedHosts StringResources
- java: remove GuestLimitedHosts page
- java: remove GuestUnlimitedHosts StringResources
- java: remove GuestUnlimitedHosts page
- java: update NavTest not to rely on removed page
- java: remove PhysicalHosts StringResources
- java: remove PhysicalHosts page
- java: remove unused methods VirtEntManager listFlexGuests,
  listEligibleFlexGuests
- java: remove unused convertToFlex method
- java XMLRPC: remove SystemHandler.listEligibleFlexGuests()
- java XMLRPC: remove SystemHandler.listFlexGuests()
- java XMLRPC: remove SystemHandler.convertToFlexEntitlement()
- java: remove softwareentitlements from StringResource
- java: remove SoftwareEntitlements from PxtAuth
- java: remove an unused SoftwareEntitlementSubscriptions StringResource
- java: remove SoftwareEntitlementSubscriptions from PxtAuth
- java: remove unused SystemManager.getEntitledSystems() method
- java: remove link to dropped software entitlemet page
- java: remove software Entitlements pages
- java: remove EntitledSystems StringResources
- java: remove EntitledSystems page
- java: remove EligibleFlexGuests StringResources
- java: remove EligibleFlexGuests page
- java: remove FlexGuest from StringResources
- java: remove FlexGuest page
- OrgHandlerTest: imports organized
- ChannelManager: imports organized
- OrgHandler: imports organized
- java: remove unused software entitlement backend methods
- java XMLRPC: remove SoftwareEntitlement functions
- java: remove OrgSoftwareSubscription StringResources
- java: remove OrgSoftwareSubscriptions page
- java: remove SoftwareEntitlements page
- java: remove SoftwareEntitlementDetails StringResources
- java: remove SoftwareEntitlementDetails page
- java: remove softwareEntitlementSubscriptions StringResources
- java: remove SoftwareEntitlementSubscriptions page
- Revert "added ability to filter out only synchronised channels when adding
  entitlements to org in multi org satellite"

* Thu Nov 19 2015 Jan Dobes 2.5.14-1
- BugFix: remove inconsistency and make more general the action description for
  package page title and tab-title in Schedule

* Thu Nov 19 2015 Jan Dobes 2.5.13-1
- better log than nothing
- Use non-immediate errata cache rebuilding on channel unsubscription

* Tue Nov 17 2015 Grant Gainey 2.5.12-1
- 1282855 - publishToChannel optimization
- 1282838 - Fix extremely slow channel.software.syncErrata API
- Fix typo and remove from whitelist

* Mon Nov 02 2015 Tomas Lestach <tlestach@redhat.com> 2.5.11-1
- removing unused code

* Fri Oct 30 2015 Tomas Kasparek <tkasparek@redhat.com> 2.5.10-1
- use xmlrpc_visible_to_user instead of visible_to_user query for searchByName

* Thu Oct 29 2015 Jiri Dostal <jdostal@redhat.com> 2.5.9-1
- added ability to filter out only synchronised channels when adding
  entitlements to org in multi org satellite

* Mon Oct 26 2015 Jan Dobes 2.5.8-1
- 1257281 - optimize queries

* Fri Oct 23 2015 Tomas Lestach <tlestach@redhat.com> 2.5.7-1
- 1154548 - allowing RHEL7 kickstart repositories

* Thu Oct 22 2015 Jan Dobes 2.5.6-1
- adding useful comment

* Wed Oct 21 2015 Jan Dobes 2.5.5-1
- support listing errata by last_modified date

* Thu Oct 15 2015 Tomas Lestach <tlestach@redhat.com> 2.5.4-1
- Make the betaMarker string accessors private
- rename ChannelProduct#beta to ChannelProduct#betaMarker

* Tue Oct 13 2015 Tomas Kasparek <tkasparek@redhat.com> 2.5.3-1
- extend session lifetime after API call
- removing @Override annotations for methods that aren't overriden

* Mon Oct 05 2015 Grant Gainey 2.5.2-1
- 608355 - change token-gen to use random UUID rather than a guessable salt

* Mon Oct 05 2015 Jan Dobes 2.5.1-1
- 1199214 - split only on first occurrence of '='
- Bumping package versions for 2.5.

* Thu Sep 24 2015 Jan Dobes 2.4.78-1
- Bumping copyright year.

* Thu Sep 24 2015 Jan Dobes 2.4.77-1
- support more frontend languages
- Merging updated frontend translations from Zanata.

* Mon Sep 21 2015 Grant Gainey 2.4.76-1
- 1253793 - Fix ks-snippets-view and catalin.out view under IE8

* Fri Sep 18 2015 Jan Dobes 2.4.75-1
- update api version

* Thu Sep 17 2015 Jan Dobes 2.4.74-1
- Make pagination attributes more consistent by putting them into enum
- Unify paging parameter values
- Remove unused pagination parameters checking

* Thu Sep 17 2015 Jan Dobes 2.4.73-1
- removing orphan_packages_for_channel query

* Wed Sep 16 2015 Grant Gainey 2.4.72-1
- 608355 - updated user-creation email template

* Wed Sep 16 2015 Grant Gainey 2.4.71-1
- 608355 - More checkstyle happiness
- 608355 - Fix some Junit
- 608355 - checkstyle
- 608355 - Refactor reset-pwd path to not log user in until pwd-chg accepted
- 608355 - Add min-password-length to user_attribute_sizes.jspf
- 608355 - Teach ResetPasswordFactory about errors
- 608355 - Make validatePassword into its own method in UserEditActionHelper
- 608355 - First draft, UI workflow
- 608355 - teach model about isExpired
- 608355 - ResetPassword domain-model/mode-queries/access/Junit

* Wed Sep 16 2015 Jan Dobes 2.4.70-1
- 1250351 - kickstartable trees should not be cacheable

* Mon Sep 14 2015 Jan Dobes 2.4.69-1
- removing old-styled icon from
  /rhn/systems/details/virtualization/ProvisionVirtualizationWizard
- show virtual machine status instead of name

* Thu Sep 10 2015 Jan Dobes 2.4.68-1
- render the right icon in system details header

* Wed Sep 09 2015 Jan Dobes 2.4.67-1
- displaying the content once is enough
- 1205818 - fixing NullPointerException

* Wed Sep 09 2015 Jiri Dostal <jdostal@redhat.com> 2.4.66-1
- 1181152 - WebUI -> Admin -> Users XSS

* Tue Sep 08 2015 Jan Dobes 2.4.65-1
- 1040871 - remove not existing system name reference

* Mon Sep 07 2015 Jan Dobes 2.4.64-1
- allow to use action chaining as SSM equivalent can

* Mon Sep 07 2015 Jan Dobes 2.4.63-1
- 1259445 - do not overwrite selected date and time

* Thu Sep 03 2015 Jan Dobes 2.4.62-1
- add missing string

* Thu Sep 03 2015 Jan Dobes 2.4.61-1
- 1252166 - removing duplicate setting
- 1252166 - fixing texts and links on system event page

* Wed Sep 02 2015 Jan Dobes 2.4.60-1
- removing redundant space

* Thu Aug 27 2015 Jan Dobes 2.4.59-1
- 1000415 - add icon for compliance status
- 1000415 - show diff icon in separate column
- 1000415 - change icon for empty diff
- making confirm page readable
- Organization users page: fix typo

* Wed Aug 26 2015 Jan Dobes 2.4.58-1
- correct message
- this is not a toolbar
- shift this menu to right
- vim version tags removed
- java unit tests: fixes after 1229427
- ChannelSoftwareHandler documentation: checksum is required now

* Thu Aug 20 2015 Jan Dobes 2.4.57-1
- 1229427 - support checksum change when cloning as in WebUI
- 1229427 - channels without checksum are no longer supported
- bump year in all languages

* Wed Aug 19 2015 Jan Dobes 2.4.56-1
- removing duplicate button
- bump year

* Wed Aug 19 2015 Jan Dobes 2.4.55-1
- 1250067 - unschedule actions only on single system

* Mon Aug 17 2015 Jan Dobes 2.4.54-1
- 1252166 - remove results of rescheduled remote script actions immediately

* Fri Aug 14 2015 Grant Gainey 2.4.53-1
- 1253793 - Fixing IE8 display issues  * Add respond.js/html5-shim for IE8  *
  Block editarea.js, which breaks respond.js under IE8, from    executing under
  IE8

* Fri Aug 14 2015 Tomas Lestach <tlestach@redhat.com> 2.4.52-1
- 1253495 - Improve configchannel.channelExists API efficiency

* Fri Aug 14 2015 Tomas Lestach <tlestach@redhat.com> 2.4.51-1
- 1228589 - need to query rhnOrgDistChannelMap that is per organization
- 1228589 - prevent NullPointerException when chaning base channels via SSM

* Wed Aug 12 2015 Jan Dobes 2.4.50-1
- 1252166 - simplify logic
- 1252166 - delete status of previous action run
- 1252166 - check if failed only this server action
- 1252166 - reschedule only relevant server action

* Tue Aug 11 2015 Jiri Dostal <jdostal@redhat.com> 2.4.49-1
- [RFE] 1167999 - Osa ping for API, check sendOsaPing/getOsaPing methods

* Fri Aug 07 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.48-1
- reremove unsused SetDecl
- don't cleanup set when adding packages to a channel

* Tue Aug 04 2015 Jiri Dostal <jdostal@redhat.com> 2.4.47-1
- 1241945 - Fixed - search field only allows 40 characters

* Tue Aug 04 2015 Jiri Dostal <jdostal@redhat.com> 2.4.46-1
- [RFE] 1097634 - Added option to schedule sync with latest packages

* Mon Aug 03 2015 Tomas Lestach <tlestach@redhat.com> 2.4.45-1
- 1219140 - skip errata clone events, where channel or erratum aren't available
  anymore (were deleted in the meantime)
- 1219140 - let errata.cloneAsync process the cloning process async

* Fri Jul 31 2015 Tomas Lestach <tlestach@redhat.com> 2.4.44-1
- 1179479 - add last boot and registration date to
  systemgroup.listSystemsMinimal API

* Fri Jul 31 2015 Tomas Lestach <tlestach@redhat.com> 2.4.43-1
- detect removed packages during repo generation
- sort the channels for rego generation task
- set the policy for blocked execution (concurrent settings)
- unmark channel in progress for failed repomd tasks
- mark ChannelRepodataWorker failed, when exception is thrown
- removing unused loadErrata() from ErrataQueueWorker
- modified will be set by the rhnRepoRegenQueue update trigger

* Fri Jul 24 2015 Jan Dobes 2.4.42-1
- adding link to reposync logs
- adding progress bar showing sync status
- disable sync button and show message if reposync is in progress
- Sort api list
- Remove test handler from API

* Fri Jul 24 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.41-1
- require cobbler20 - Spacewalk is not working with upstream cobbler anyway

* Wed Jul 22 2015 Jiri Dostal <jdostal@redhat.com> 2.4.40-1
- 1181152 - XSS when altering user details and going somewhere where you are
  choosing user         - Escaped tags in real names
- Make RhnServletListenerTest not extend RhnBaseTestCase

* Tue Jul 21 2015 Tomas Lestach <tlestach@redhat.com> 2.4.39-1
- introduce org.setErrataEmailNotifsForOrg and org.isErrataEmailNotifsForOrg
  API calls

* Mon Jul 20 2015 Tomas Lestach <tlestach@redhat.com> 2.4.38-1
- introduce org.setOrgConfigManagedByOrgAdmin and
  org.isOrgConfigManagedByOrgAdmin API calls

* Mon Jul 20 2015 Tomas Lestach <tlestach@redhat.com> 2.4.37-1
- update organization configuration description
- spacewalk/satellite admin may allow org admin to manage org configuration
- re-use same org config jsp code
- introduce errata_emails_enabled per org
- make the Organization Configuration pages available also to org amin
- Fix docs

* Wed Jul 15 2015 Jan Dobes 2.4.36-1
- prevent ISE if taskomatic is not running
- get files only for correct channel

* Tue Jul 14 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.35-1
- allow to change 1st organization name

* Mon Jul 13 2015 Jan Dobes 2.4.34-1
- properly close 'a' tag
- removing dead code
- do not try to translate certain messages several times

* Mon Jul 13 2015 Matej Kollar <mkollar@redhat.com> 2.4.33-1
- Grammar fix

* Fri Jul 10 2015 Tomas Lestach <tlestach@redhat.com> 2.4.32-1
- 1235955 - fix detection of systems requiring reboot

* Thu Jul 09 2015 Jiri Dostal <jdostal@redhat.com> 2.4.31-1
- Bug 1098804 - fixed broken link, labels

* Thu Jul 09 2015 Tomas Lestach <tlestach@redhat.com> 2.4.30-1
- log debug messages only if debug is enabled
- Fix queue size: consider possible remainders from last run
- Log message when finished errata cache for a server or channel
- Remove some duplicated empty lines
- Remove unused return value that was always null
- Remove unused parameter to TaskQueue.run()
- Log the current queue size before every job run (DEBUG)
- Fix log message when finished with server

* Fri Jul 03 2015 Jan Dobes 2.4.29-1
- removing dead code
- fixing system.listUngroupedSystems API

* Fri Jul 03 2015 Jan Dobes 2.4.28-1
- removing obsolete file
- configure ivy resolver

* Fri Jul 03 2015 Matej Kollar <mkollar@redhat.com> 2.4.27-1
- Unify profile creation/update with one submit button instead of two.
- Fix file input control alignment issue with form-control (bsc#873203)

* Mon Jun 29 2015 Jan Dobes 2.4.26-1
- checksum type None is no longer available
- Make arch x86_64 the default when creating new channels.
- Remove checksum type None. It prevents metadata generation.
- do not recreate the option tags, just change visibility
- New Channel: Fix setting the default architecture/checksum when selecting
  back Parent: None

* Fri Jun 26 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.25-1
- Avoid deadlock in CompareConfigFilesTask when a
  rhn_channel.update_needed_cache is in progress
- Server.listConfigDiffEnabledSystems: fix indentation
- Recommend cobbler20 with all packages requiring cobbler on Fedora 22

* Fri Jun 12 2015 Jan Dobes 2.4.24-1
- 1227700 - add missing country code
- 1227700 - removing invalid title
- TaskoXmlRpcHandler: dead code removed

* Tue Jun 09 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.23-1
- Fix adding roles: make sure that ORG admin is last
- Fix javadoc and remove some superfluous newlines
- Simplify getCandidates() to return a list of task objects
- Remove unused Date variable
- Do not remove tasks from DB during getCandidates() (bsc#932052)
- Verify forward path and query ignoring the order of parameters

* Fri May 29 2015 Jan Dobes 2.4.22-1
- Get rid of IE7 compatibility mode enforcement
- ErrataManager: fix stack update case
- fixing message
- removing unused import
- KickstartScheduleCommand: always use activation key data
- KickstartScheduleCommand: dead code removed

* Thu May 28 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.21-1
- remove redundant abstract modifier
- fix checkstyle issues on Fedora 22
- ErrataManagerTest: correct assertion message

* Fri May 22 2015 Tomas Lestach <tlestach@redhat.com> 2.4.20-1
- expect a Number instead of an Integer

* Fri May 22 2015 Jan Dobes 2.4.19-1
- 1201719 - wait for current transaction end
- SystemHandler cleanup
- fix checkstyle issue
- Extract utility method in HibernateFactory
- ErrataManagerTest: correct comment to agree with code

* Mon May 18 2015 Tomas Lestach <tlestach@redhat.com> 2.4.18-1
- enhance task creation logging
- removing @Override annotation for method that isn't overriden

* Mon May 18 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.17-1
- 1221224 - display schema upgrade required message on CreateFirstUser page

* Thu May 14 2015 Stephen Herr <sherr@redhat.com> 2.4.16-1
- Kickstart: install the latest available koan package, not first found

* Thu May 14 2015 Grant Gainey 2.4.15-1
- 1221739 - EXISTS is an Oracle keyword, don't use it casually

* Wed May 13 2015 Stephen Herr <sherr@redhat.com> 2.4.14-1
- Change Activation Key Child Channels from multiple select to checkboxes

* Tue May 12 2015 Stephen Herr <sherr@redhat.com> 2.4.13-1
- hasPreflag(): improve documentation about which rpm flags are evaluated
- fix generating pre-equires (pre="1" in metadata)

* Thu May 07 2015 Jan Dobes <jdobes@redhat.com> 2.4.12-1
- make checkstyle compatible with newer versions and enable on fedora

* Wed May 06 2015 Tomas Lestach <tlestach@redhat.com> 2.4.11-1
- 1218705 - allow read-only user to call find* APIs

* Thu Apr 30 2015 Stephen Herr <sherr@redhat.com> 2.4.10-1
- 1215271 - Scheduling remote command for large system sets is slow

* Wed Apr 29 2015 Stephen Herr <sherr@redhat.com> 2.4.9-1
- 1215671 - move auto-errata updates into separate taskomatic task
- 1215671 - Magic strings should only be defined in one place
- ErrataCacheDriverTest: make condition robust to pre-existing Tasks

* Fri Apr 24 2015 Stephen Herr <sherr@redhat.com> 2.4.8-1
- 1207816 - You should be able to clone channels shared from other orgs

* Wed Apr 22 2015 Stephen Herr <sherr@redhat.com> 2.4.7-1
- 1214437 - improve system overview list performance

* Tue Apr 21 2015 Stephen Herr <sherr@redhat.com> 2.4.6-1
- 1214034 - Implement a "default" kickstart script name for edit link

* Wed Apr 15 2015 Jan Dobes 2.4.5-1
- 1096263 - force taskomatic to use UTF-8

* Wed Apr 15 2015 Jan Dobes 2.4.4-1
- fixing alphabar and pagination rendering on some pages
- 1202233 - include missing taglib

* Thu Apr 02 2015 Jan Dobes 2.4.3-1
- remove query errata_list_in_set as it is not used anymore
- use another method as lookupErrataListFromSet does not exist anymore
- change method to get selected errata relevant to system set

* Thu Apr 02 2015 Stephen Herr <sherr@redhat.com> 2.4.2-1
- 1204246 - re-deleting the commit lines after commit 0a54057de3 re-added them

* Wed Apr 01 2015 Jan Dobes 2.4.1-1
- 1205328 - do not ignore errata with same package version
- allow only Red Hat, Inc. and SUSE LLC in the checkstyle preferences
- Copyright texts updated to SUSE LLC
- to create .project file for eclipse, 'ant make-eclipse-project' should be run
- Bumping package versions for 2.4.

* Fri Mar 27 2015 Grant Gainey 2.3.178-1
- Copyrights 2015, redux

* Fri Mar 27 2015 Tomas Lestach <tlestach@redhat.com> 2.3.177-1
- change evr parsing for repodata primary.xml dependencies
- expand checkstyle copyright regexp
- Add a test for getCandidates() in ErrataCacheDriver
- Fix parameter names for "insert_into_task_queue"
- Create only one errata cache worker per server
- Add type parameters throughout getCandidates()

* Thu Mar 26 2015 Jan Dobes 2.3.176-1
- 1200162 - reduce number of system lookups
- 1188954 - also get errata scheduling out of cycle to make stackUpdates sense
- 1188954 - schedule only one errata action for each errata

* Wed Mar 25 2015 Grant Gainey 2.3.175-1
- Updating copyright info for 2015

* Wed Mar 25 2015 Tomas Lestach <tlestach@redhat.com> 2.3.174-1
- 1205108 - extend getHistoryDetails() method by the User argument and unify
  this interface

* Tue Mar 24 2015 Tomas Lestach <tlestach@redhat.com> 2.3.173-1
- set kickstart timezone according to the user locale, who creates it

* Mon Mar 23 2015 Grant Gainey 2.3.172-1
- 1204246 - close auto errata update timing hole
- Forward to "raw mode" edit page in case of uploaded profiles
- checkstyle fixes
- Fix: kickstart wizard step 2 and 3 => removed unnecessary BR and empty DIV
  from both files.
- Fix: step 3 kickstart wizard => added the missing class form-horizontal in
  the form tag. removed the class list-group from a div since its a class for
  Ul tags. added the form-control class to the inputs.
- Fix: Step 2 kickstart wizard => removed the class list-group from a div (this
  class is only for UL). Properly formated the html of the radio buttons with
  their labels and classes. Changed the disposition of the labels to make it
  more clear that its 1 property with 2 different options, since before it
  looked like 2 different properties.
- FIX: error from last 2 commits where the icons were included in a wrong place
  inside the buttons of the wizard
- Fix: Step 3: Create Kickstart Profile => the panel didnt have a panel-body
  and that is now fixed. The group lists were inside a UL (without list inside)
  and it was replaced for a div. The buttons to submit or go back were inserted
  into the panel-footer
- Fix: Step 2: Create Kickstart Profile => the panel didnt have a panel-body
  and that is now fixed. The group lists were inside a UL (without list inside)
  and it was replaced for a div. The buttons to submit or go back were inserted
  into the panel-footer
- Fix: Step 1: Create Kickstart Profile => the buttons sending the form are
  included inside the panel-footer in order to follow the 3 steps process,
  where in the following steps there will be a Prev button as well
- address tag: fix extra p and testcase to latest changes
- form inserted into panel and button moved to the buttom of the form to make
  it more obvious it is the button that submits the whole form and not just one
  input
- Fix button style on locale settings
- wrap information in panel and show with alert class
- hr to separate the form and the table
- message inserted inside an alert.
- buton changed to primary
- duplicated title removed
- sw entitlements page: hr tag addded to separate the pagination and the tips
- row with no margin
- xcddf search: radio and checkbox inputs formated with bootstrap
- popular channels page: elements vertically aligned
- button position fix
- user preferences: use the new input with inline class
- address tag: removed unnecessary p tag
- user details page: fix column sizes and panel title
- fix column sizes in the edit address form
- button class changed from primary to default
- col size, labels, checkboxes and radio buttons fixed
- buttons fix

* Thu Mar 19 2015 Grant Gainey 2.3.171-1
- Update api version
- Updated copyright year missed in 2013
- Updating copyright info for 2015

* Thu Mar 19 2015 Tomas Lestach <tlestach@redhat.com> 2.3.170-1
- pass reposync params as List
- adding java .project to git

* Wed Mar 18 2015 Grant Gainey 2.3.169-1
- Cleanup of L10N files

* Wed Mar 18 2015 Grant Gainey 2.3.168-1
- zanata doesn't like < or >, even in context-tags
- Zanata doesn't like empty ids

* Tue Mar 17 2015 Tomas Kasparek <tkasparek@redhat.com> 2.3.167-1
- properly set taskomatic wrapper.java.classpath.4 option
- fix Documentation link

* Mon Mar 16 2015 Tomas Lestach <tlestach@redhat.com> 2.3.166-1
- fixing typo: sync-kickstars -> sync-kickstart
- we do not need jfreechart anymore

* Thu Mar 12 2015 Tomas Lestach <tlestach@redhat.com> 2.3.165-1
- removing unused rhn_web.conf options
- simplify getDefaultDownloadLocation() method

* Thu Mar 12 2015 Tomas Lestach <tlestach@redhat.com> 2.3.164-1
- java-map-hibernate-table.pl should not be part of RHN::DB::Package

* Wed Mar 11 2015 Jan Dobes 2.3.163-1
- fixing weird path

* Mon Mar 09 2015 Tomas Lestach <tlestach@redhat.com> 2.3.162-1
- use /help/index.do for Documentaton
- removing spacewalk-sniglets as they are not needed any more

* Fri Mar 06 2015 Tomas Lestach <tlestach@redhat.com> 2.3.161-1
- 1086354 - update properly necessary cobbler fields when changing ks tree
- host as parameter of KickstartableTree.getDefaultDownloadLocation() isn't
  used
- DataSourceParserTest: generalize so that both Postgres 8 and 9 drivers work

* Thu Mar 05 2015 Grant Gainey 2.3.160-1
- 1196329 - IE11/WinServer2008/CompatMode fix

* Thu Mar 05 2015 Jan Dobes 2.3.159-1
- fix old branding icon
- remove unused Perl code
- Remove a couple of directory references in nav xml to perl directories

* Tue Mar 03 2015 Tomas Lestach <tlestach@redhat.com> 2.3.158-1
- we use /rhn/help/index.do instead of /help/about.pxt

* Tue Mar 03 2015 Tomas Kasparek <tkasparek@redhat.com> 2.3.157-1
- create globallySubscribeable default value
- adapt 404.jsp
- do not decorate java error pages
- removing html taglib from error jsp pages as it isn't used
- make the error pages accessible from apache
- removing nosuchpkg.jsp as it's not referenced any more

* Tue Mar 03 2015 Tomas Kasparek <tkasparek@redhat.com> 2.3.156-1
- 1128989 - allow users to set taskomatic mail preferences - change query of
  user emails
- 1128989 - allow users to set taskomatic mail preferences - allow setting of
  tasko_notify flag
- 1128989 - allow users to set taskomatic mail preferences - updated User clasS

* Mon Mar 02 2015 Stephen Herr <sherr@redhat.com> 2.3.155-1
- Finish porting SSM Group pages to java
- Moving SSM Group Create to its own jsp to fix changing nav contexts when form
  doesn't validate
- Port SSM Group Create page to java TODO: port ssm group landing /
  confirmation page, update links
- Add back in SSM Groups tab that was accidentally deleted in 93b7d1a9

* Fri Feb 27 2015 Tomas Lestach <tlestach@redhat.com> 2.3.154-1
- removing system_list/out_of_date.pxt as it isn't referenced anymore
- removing system_list/visible_to_user.pxt as it isn't referenced anymore

* Fri Feb 27 2015 Tomas Lestach <tlestach@redhat.com> 2.3.153-1
- rewriting raw_script_output.txt to java
- Refresh errata cache asynchronously when subscribing server to channel

* Thu Feb 26 2015 Tomas Lestach <tlestach@redhat.com> 2.3.152-1
- Catch NumberFormatException and send error to the client instead

* Wed Feb 25 2015 Tomas Lestach <tlestach@redhat.com> 2.3.151-1
- removing system details edit.pxt as it was ported to java

* Tue Feb 24 2015 Grant Gainey 2.3.150-1
- Make checkstyle happy

* Tue Feb 24 2015 Grant Gainey 2.3.149-1
- CloneErrataActionTest: missing query added
- RhnSetDeclTest: use a decl with correct cleanup operation
- UserExternalHandlerTest: monitoring entitlement was removed, update counters
- ActivationKeyHandlerTest: virtualization host entitlement was removed, update
  counters
- ServerTest: don't count monitoring entitlement any more
- CloneErrataActionTest: adapt to new behavior in ChannelRepodataDriver, remove
  stale code
- ErrataHandler.create: restore backwards-compatible method signature and fix
  tests
- Server Hibernate mapping: don't use {S.*} notation as it will generate
  incorrect SQL with joined-subclass
- ServerFactoryTest: create a 32-byte secret to play nice with
  ClientCertificate
- PxtAuthenticationServiceTest: adjust expectations to updated code
- KickstartPartitionActionTest: expect warning message as well
- UserImpl: keep local collection in sync (fixes RoleTest failure)
- KickstartDataTest: do not fail by using correct constant
- KickstartBuilderTest: update to post-SHA256 code
- Fedora KS install type is 'fedora18' now, adapt code accordingly
- sitenav.xml: use full sign in URL to make NavTest happy
- UserTest: use SHA1 instead of MD5
- UserTest: save Role before use, a non-null id is required
- UserEditSetupActionTest: number of roles has diminished by one with removal
  of monitoring
- AccessTest: ftr_kickstart should be present in provisioning entitled servers
- ChannelFactoryTest: channel labels always need to be lower case
- TestFactoryWrapperTest: use a different query, table does not exist anymore

* Tue Feb 24 2015 Tomas Lestach <tlestach@redhat.com> 2.3.148-1
- removing unused iso download jsp

* Tue Feb 24 2015 Tomas Kasparek <tkasparek@redhat.com> 2.3.147-1
- fix malformed @@PRODUCT_NAME@@ macro

* Mon Feb 23 2015 Stephen Herr <sherr@redhat.com> 2.3.146-1
- 1191071 - fix java acls for ProxyClients.do

* Mon Feb 23 2015 Tomas Kasparek <tkasparek@redhat.com> 2.3.145-1
- update translation strings

* Fri Feb 20 2015 Tomas Lestach <tlestach@redhat.com> 2.3.144-1
- enable 'Remove Errata' button on the
  /rhn/channels/manage/errata/ListRemove.do page
- fix ISE on /rhn/channels/manage/errata/ListRemove.do page

* Thu Feb 19 2015 Grant Gainey 2.3.143-1
- 1194418 - API call channel.software.clone does not work as expected for child
  channels.

* Wed Feb 18 2015 Stephen Herr <sherr@redhat.com> 2.3.142-1
- 1191071 - Fix Connection.do and Proxy.do acls after perl-> java migration

* Wed Feb 18 2015 Tomas Lestach <tlestach@redhat.com> 2.3.141-1
- issue a warning in case sortAttribute is invalid

* Mon Feb 16 2015 Tomas Lestach <tlestach@redhat.com> 2.3.140-1
- log AJP_REMOTE_USER_GROUP 'iterator' instead of AJP_REMOTE_USER_GROUPS
  attribute

* Thu Feb 05 2015 Stephen Herr <sherr@redhat.com> 2.3.139-1
- 1173731 - ErrataQueue shouldn't fail if server is subscribed to other org's
  channel
- New fast java errata clones need to enqueue notifications for taskomaitc
  Without it things like auto-errata-updates never get scheduled
- 1174652 - Don't dereference things that might be null, in SQL

* Wed Feb 04 2015 Tomas Lestach <tlestach@redhat.com> 2.3.138-1
- linking real files works much better
- Documentation changes - fix name and refer to RFC.
- Package_queries.xml system_available_packages: one more whitespace fix
- Package_queries.xml system_available_packages: use comprehensible subquery
  names
- Package_queries.xml system_available_packages: use JOIN for join conditions,
  WHERE for others
- Package_queries.xml system_available_packages: normalize AS use
- Package_queries.xml system_available_packages: fix indentation and spacing
- Package_queries.xml system_available_packages: fix case

* Fri Jan 30 2015 Stephen Herr <sherr@redhat.com> 2.3.137-1
- 1173260 - avoid deadlock if you call mergePackages after mergeErrata
- Make first letter uppercase as in rest of the UI
- This is how button is called now

* Wed Jan 28 2015 Tomas Lestach <tlestach@redhat.com> 2.3.136-1
- fix wrong spec condition

* Wed Jan 28 2015 Tomas Lestach <tlestach@redhat.com> 2.3.135-1
- 1186355 - fixing typo
- create missing jar symlinks (mainly for taskomatic)
- let taskomatic link log4j-1.jar on fc21
- Setting ts=4 is wrong

* Wed Jan 28 2015 Tomas Lestach <tlestach@redhat.com> 2.3.134-1
- fix mchange-commons issue on fc21

* Tue Jan 27 2015 Tomas Lestach <tlestach@redhat.com> 2.3.133-1
- fedora21 packages install the jars to custom directories
- unify fedora specific files
- fedora21 uses only the log4j-1 compatibility package

* Mon Jan 26 2015 Stephen Herr <sherr@redhat.com> 2.3.132-1
- 1180581 - make config file upload on FileDetails work

* Mon Jan 26 2015 Tomas Lestach <tlestach@redhat.com> 2.3.131-1
- remove nonlinux (solaris) entitlement
- prevent NPE on activationkeys/Edit.do page
- removing @Override annotations for methods that aren't overriden

* Fri Jan 23 2015 Stephen Herr <sherr@redhat.com> 2.3.130-1
- Fix "Select All" buttons display on rhn:list, make consistent with new
  rl:list
- Fix missing submit parameter for "Select All"
- Sort filelist in configfile.compare event history alphabetically
- add getSSMPowerSettingsUpdateCommand() to keep the values on empty form data
- fix setting powermanagement values
- Add missing dash to docbook apidoc macro
- Update the example scripts section for docbook output
- Update the title page for docbook output
- Fix xmlrpc.doc for the "system" namespace
- Fix grammar and typos in API code example descriptions
- Set cobbler hostname variable when calling system.createSystemRecord
- parseDistUrl needs to return null if it can't parse the url
- Fix NPE on GET /rhn/common/DownloadFile.do
- Avoid NumberFormatException in case of invalid URL
- Lookup kickstart tree only when org is found
- Avoid ArrayIndexOutOfBoundsException with invalid URLs

* Fri Jan 23 2015 Tomas Lestach <tlestach@redhat.com> 2.3.129-1
- link log4j-1.jar if available (for fc12)
- removing duplicate Summary and Group
- 1179765 - directories and symlinks cannot be binary

* Wed Jan 21 2015 Stephen Herr <sherr@redhat.com> 2.3.128-1
- Port Errata Clone page from perl -> java Make nav link to java channel clone
  and errata clone pages Also make various clone errata jsps share common list

* Wed Jan 21 2015 Stephen Herr <sherr@redhat.com> 2.3.127-1
- fixing error '...requires that an attribute name is preceded by whitespace'

* Wed Jan 21 2015 Tomas Lestach <tlestach@redhat.com> 2.3.126-1
- fixing checkstyle issue

* Tue Jan 20 2015 Stephen Herr <sherr@redhat.com> 2.3.125-1
- Fix ISE when cloning a channel that is not globally subscribable
- Fix ISE if creating a channel that is not globally subscribable

* Mon Jan 19 2015 Grant Gainey 2.3.124-1
- 1156299, CVE-2014-7811 - Fixed reported XSS issues  *
  /rhn/systems/details/Overview.do?sid= , Description  *
  /rhn/groups/GroupDetail.do?sgid= , Name, Description  *
  /rhn/users/UserList.do, /rhn/users/DisabledList.do - first/last name  *
  /rhn/systems/details/history/Event.do?sid= , SCAP param/action

* Fri Jan 16 2015 Grant Gainey 2.3.123-1
- bnc#901927: Remove custom file size calculation
- Need to wrap the InputStream in order to support mark/reset so the binary
  upload won't crash anymore

* Fri Jan 16 2015 Tomas Lestach <tlestach@redhat.com> 2.3.122-1
- Remove "Select All" button from system currency report

* Fri Jan 16 2015 Matej Kollar <mkollar@redhat.com> 2.3.121-1
- Remove "Add Selected to SSM" from SSM system overview page
- Remove "Add Selected to SSM" from system overview page

* Thu Jan 15 2015 Tomas Lestach <tlestach@redhat.com> 2.3.120-1
- 1158806 - fix menu structure for
  /rhn/systems/details/history/snapshots/TagCreate.do page
- 1158806 - fix menu structure for /rhn/systems/details/history/Event.do page

* Wed Jan 14 2015 Stephen Herr <sherr@redhat.com> 2.3.119-1
- checkstyle fixes

* Wed Jan 14 2015 Stephen Herr <sherr@redhat.com> 2.3.118-1
- migrate clone channel page from perl -> java
- Use Hibernate-friendly equals() and hashCode() in Org

* Mon Jan 12 2015 Matej Kollar <mkollar@redhat.com> 2.3.117-1
- Getting rid of trailing spaces in translations
- Getting rid of trailing spaces in XML
- Getting rid of Tabs and trailing spaces in Python
- Getting rid of trailing spaces in Perl
- Getting rid of Tabs in Java JSPF
- Getting rid of Tabs in Java JSP
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files
- allow Copyright 2015
- clean up some type safety warnings
- Whitespace fixes

* Tue Dec 23 2014 Stephen Herr <sherr@redhat.com> 2.3.116-1
- checkstyle fix
- Clean up some static references to pxt pages in nav tests
- port errata_channel_intersection.pxt to java

* Mon Dec 22 2014 Stephen Herr <sherr@redhat.com> 2.3.115-1
- Checkstyle fix and translation with old url update

* Mon Dec 22 2014 Stephen Herr <sherr@redhat.com> 2.3.114-1
- Port Channel Subscriber pages to java
- minor style fix for virt-guest advanced options kickstart page
- Port of the advanced kickstart options to TB3.
- ErrataManager.applyErrata: raise exception even when there is no relevant
  errata
- Improve applyErrata algorithm to apply only relevant erratas. Testcase
  included.
- hasKeyword and containsKeyword are the same, but one crashes on null
- 1176435 - make displaying package actions with multiple packages faster

* Fri Dec 19 2014 Stephen Herr <sherr@redhat.com> 2.3.113-1
- migrate sdc Reactivation page to java
- migrate sdc clients through proxy page to java
- migrate sdc Proxy page to java

* Thu Dec 18 2014 Stephen Herr <sherr@redhat.com> 2.3.112-1
- don't add sync-probe taskomatic task, but handle upgrades that have it

* Wed Dec 17 2014 Stephen Herr <sherr@redhat.com> 2.3.111-1
- Adding copyright statements where they were missing

* Wed Dec 17 2014 Stephen Herr <sherr@redhat.com> 2.3.110-1
- fix checkstyle problems
- Migrate sdc Connection page to java
- remove old references to perl pages in ssm.xml that no longer exist
- and one more reference
- migrate SSM Misc System Preferences Confirm page to java
- Revert "updating the test sitenav.xml with more recent content" I should make
  sure this doesn't break test first
- updating the test sitenav.xml with more recent content
- migrate SSM Rollback page to java
- Migrate SSM Tag Systems page to java
- use c:out instead of bare references to avoid potential xss problems
- removing references to perl restart pages that no longer exist
- Migrating SSM Custom Value pages to java
- a few more old pxt references to clean up
- random cleanups, mostly getting rid of references to pxt pages
- migrate about help page to java
- updating old references to pxt pages from StringResources
- make config column be correct for Installed Systems and Target Systems pages
- Fix checkstyle errors
- port package details Target Systems pages to java
- fixing a couple of hard-to-track-down xml errors
- Migrating 'systems with installed package' page to java
- Port package 'new versions' page to java
- Package maps are only a solaris feature, remove
- Porting package file list page to java
- Removing solaris support from spacewalk-java
- drop monitoring code and monitoring schema
- plus one more reference
- A more complete removal of monitoring from spacewalk-java
- take a giant ax to monitoring in spacewalk-java. work in progress

* Tue Dec 16 2014 Tomas Lestach <tlestach@redhat.com> 2.3.109-1
- 1174627 - make sure columns are named according to the dto attributes
- Revert "don't show packages tab if activation key hasn't provisioning
  entitlement"

* Fri Dec 12 2014 Stephen Herr <sherr@redhat.com> 2.3.108-1
- 1168328 - fix failures due to uninitialized log it
- style java.custom_header, java.custom_footer, java.login_banner,
  java.legal_note parameters

* Fri Dec 12 2014 Tomas Lestach <tlestach@redhat.com> 2.3.107-1
- remove empty trans-unit elements

* Wed Dec 10 2014 Tomas Lestach <tlestach@redhat.com> 2.3.106-1
- 1069155 - let system set manager csv contain add-on entitlements
- extra space

* Tue Dec 09 2014 Tomas Lestach <tlestach@redhat.com> 2.3.105-1
- 1170704 - allow filtering RHEL7 errata
- add some missing strings

* Mon Dec 08 2014 Tomas Lestach <tlestach@redhat.com> 2.3.104-1
- 1151931 - fix broken xml

* Mon Dec 08 2014 Jan Dobes 2.3.103-1
- slightly improve hideable menu

* Mon Dec 08 2014 Tomas Lestach <tlestach@redhat.com> 2.3.102-1
- 1169278 - fix typo: Occurence -> Occurrence
- 1169345 - returning back removed file preservation related messages
- 1151931 - returning back removed config related messages

* Fri Dec 05 2014 Stephen Herr <sherr@redhat.com> 2.3.101-1
- Fixing merge problem in test

* Fri Dec 05 2014 Stephen Herr <sherr@redhat.com> 2.3.100-1
- Explain snapshot/rollback behavior better (bsc#808947)
- Fix documentation search
- New API call to list kickstartable tree channels + test
- Don't commit when XMLRPCExceptions are thrown
- XmlRpcServletTest: ensure a new Hibernate session is used in each test

* Fri Dec 05 2014 Tomas Lestach <tlestach@redhat.com> 2.3.99-1
- 1169741 - allow removing Cobbler System Profile on  the power management page
- 1169752 - allow also blank power management settings
- 1169741 - add csrf check for the power management page
- Made text more clear for package profile sync

* Thu Dec 04 2014 Jan Dobes 2.3.98-1
- style /rhn/systems/details/kickstart/SessionStatus page

* Tue Dec 02 2014 Tomas Lestach <tlestach@redhat.com> 2.3.97-1
- remove WebList as it isn't referenced any more
- remove SelectableWebList as it isn't referenced any more
- remove WebRhnSet as it isn't referenced any more
- remove WebSessionSet as it isn't referenced any more
- adapt ListRemoveGroupsAction to the rewritten groups.jspf
- adapt groups.jspf to the rewritten AddGroupsAction
- rewrite AddGroupsAction
- 1169480 - No ISE on provisioning page when no base channel

* Mon Dec 01 2014 Jan Dobes 2.3.96-1
- too big space
- there is no need to block enter key
- Cobbler variables page ported to Bootstrap

* Fri Nov 28 2014 Tomas Lestach <tlestach@redhat.com> 2.3.95-1
- fix hibernate.NonUniqueObjectException on errata cloning
- Download CSV button does not export all columns ("Base Channel" missing)
  (bnc#896238)
- Fix install type detection on SUSE systems

* Thu Nov 27 2014 Jan Dobes 2.3.94-1
- style /rhn/channels/manage/errata/ConfirmErrataAdd page

* Thu Nov 27 2014 Tomas Lestach <tlestach@redhat.com> 2.3.93-1
- paginate before elaboration
- remove duplicated line

* Wed Nov 26 2014 Stephen Herr <sherr@redhat.com> 2.3.92-1
- 1168328 - Make the base channel ssm action asynchronous
- 1168292 - Commit after each system deletion to avoid deadlocks

* Tue Nov 25 2014 Tomas Lestach <tlestach@redhat.com> 2.3.91-1
- 1081124 - let system advanced search return common package nvrea
- remove @Override annotation

* Tue Nov 25 2014 Tomas Lestach <tlestach@redhat.com> 2.3.90-1
- 1167753 - apidoc generator does not know #array("something")
- 1009396 - fix js injection on /rhn/systems/Search.do page

* Mon Nov 24 2014 Stephen Herr <sherr@redhat.com> 2.3.89-1
- 920603 - fixing javascript errors
- 1162862 - Config file url should update when you create new revision

* Mon Nov 24 2014 Tomas Lestach <tlestach@redhat.com> 2.3.88-1
- prevent ISE, when firstname a/o lastname weren't passed from IPA server

* Fri Nov 21 2014 Jan Dobes 2.3.87-1
- fix button alignment
- impove style of Software Crash pages

* Thu Nov 20 2014 Tomas Lestach <tlestach@redhat.com> 2.3.86-1
- 1001018 - xml escape scripting language on
  /rhn/kickstart/KickstartScriptDelete.do page

* Thu Nov 20 2014 Tomas Lestach <tlestach@redhat.com> 2.3.85-1
- 1001018 - xml escape script language on /rhn/kickstart/Scripts.do page

* Wed Nov 19 2014 Jan Dobes 2.3.84-1
- do not show expanded menu on small screens on default
- remove redundant navbar-collapse-1 class
- hide items on smaller screens

* Wed Nov 19 2014 Tomas Lestach <tlestach@redhat.com> 2.3.83-1
- 1024090 - user does not need to be a channel admin to manage a channel
- Channel package compare will fail if checking two unrelated channels when ch1
  or ch2 is NULL.

* Fri Nov 14 2014 Tomas Lestach <tlestach@redhat.com> 2.3.82-1
- 801965 - checkstuyle fix

* Fri Nov 14 2014 Tomas Lestach <tlestach@redhat.com> 2.3.81-1
- 801965 - config admin role required for the kickstart.profile.*Repositories
  API calls
- 801965 - introduce kickstart.profile.getAvailableRepositories API
- 801965 - rename kickstart.profile.getAvailableRepositories to
  kickstart.profile.getRepositories
- 801965 - we cannot return 'null' in API
- 801965 - remove redundant code

* Thu Nov 13 2014 Grant Gainey 2.3.80-1
- 1093669 - Fixed typo in column-names

* Thu Nov 13 2014 Stephen Herr <sherr@redhat.com> 2.3.79-1
- 796434 - refreshing should not clone activation key again
- 1156337 - use conf channel label instead of name
- 1136491 - listActivationKeys should return empty list if no keys visible
- 1037974 - make API listing system events by type work
- cannot select code from disabled textarea in Firefox, use readonly editor

* Wed Nov 12 2014 Stephen Herr <sherr@redhat.com> 2.3.78-1
- 1151183 - clean up remnants of prototype.js, convert to jQuery
- Fix tests broken by fix to 1134879, PackageName objects should be saved
  explicitly

* Wed Nov 12 2014 Grant Gainey 2.3.77-1
- 1152984 - Fix entitled_systems.jsp num-per-page ISE

* Tue Nov 11 2014 Stephen Herr <sherr@redhat.com> 2.3.76-1
- 1162862 - we should consider if text <> binary has changed for config files
- 1162840 - all API methods should be able to find shared channels
- ActionChainSaveActionTest: missing override annotation added
- ActionChainHelperTest fix: use correct chain ordering
- SsmErrataAction: correct logger usage
- CreateChannelCommand imports organized
- CreateChannelCommand imports organized

* Tue Nov 11 2014 Tomas Lestach <tlestach@redhat.com> 2.3.75-1
- remove @Override annotation from method that isn't overriden
- remove unnecessarily nested 'else' statement
- remove unnecessarily nested 'else' statement
- remove unnecessarily nested 'else' statement
- 1153010 - move verifyOrgExists method to BaseHandler as it is being called
  from more handlers
- Fix ActionChainSaveActionTest after Action Chains creator patch
- 1065998 - adapt the page to adding/cloning errata
- fix alignment and apply style class on /rhn/users/CreateUser page

* Mon Nov 10 2014 Grant Gainey 2.3.74-1
- 116206 - Removed remaining (?) support for context-sensitive-help
- Commit 877f3308 should fix tasko OOM problems, so setting max mem to 1GB
  and increaseing repodata workers back to 2
- 1158750 - minor UI text updates

* Fri Nov 07 2014 Tomas Lestach <tlestach@redhat.com> 2.3.73-1
- 1134879 - we do not want to use cascade for evr and name attributes of
  PackageActionDetails

* Thu Nov 06 2014 Jan Dobes 2.3.72-1
- Fix pxt page link to point to the ported version of that page
- style /rhn/kickstart/KickstartScript(Create|Edit) page
- change position of tip
- remove closing button and change class of box

* Tue Nov 04 2014 Grant Gainey 2.3.71-1
- 1159070 - Fix GPG_URL_REGEX

* Fri Oct 31 2014 Grant Gainey 2.3.70-1
- 1158639 - checkstyle fixes

* Fri Oct 31 2014 Grant Gainey 2.3.69-1
- 1158639 - AccessChains belong to their creator, only

* Fri Oct 31 2014 Tomas Lestach <tlestach@redhat.com> 2.3.68-1
- 1009396 - fix javascript injection on the /rhn/groups/ProbesList.do page
- 1009396 - fix javascript injection on the
  /rhn/monitoring/config/ProbeSuiteSystems.do page
- 1156456 - fix Portuguese message.channeldeleted translation

* Thu Oct 30 2014 Stephen Herr <sherr@redhat.com> 2.3.67-1
- 1159053 - Fix two XSS flaws in Kickstart Snippets and List Attributes
- uppercase the toolbar stuff

* Thu Oct 30 2014 Tomas Lestach <tlestach@redhat.com> 2.3.66-1
- let the links open in a new window/tab
- 1003565 - extend packages.getPackage API documentation
- Test fixes after rewording
- fix typo in api doc
- add csv export for /rhn/errata/manage/PublishedErrata.do
- add csv output for /rhn/systems/details/packages/profiles/CompareSystems.do
- minor updates to strings / wording

* Fri Oct 24 2014 Tomas Lestach <tlestach@redhat.com> 2.3.65-1
- do not allow to cancel the kickstart once completed
- 796434 - [RFE] Add clone action to activation keys

* Thu Oct 23 2014 Jan Dobes 2.3.64-1
- remove invalid div
- Style tweak to fix /rhn/configuration/channel/ChannelSystems
- Correct style-issue due to empty old-list-tag in /rhn/configuration/Overview
- Correct style-issue due to empty old-list-tag in
  /rhn/configuration/file/LocalConfigFileList
- Correct style-issue due to empty old-list-tag in
  /rhn/configuration/GlobalConfigFileList
- style /rhn/configuration/file/DeleteFile
- style /rhn/configuration/file/DeleteRevision

* Mon Oct 20 2014 Stephen Herr <sherr@redhat.com> 2.3.63-1
- 1151005 - add package id to query results so webui can generate link
- 1024118 - Remove bogus help-url/rhn-help/helpUrl links from all pages
- do not re-init the exception cause with the same

* Fri Oct 17 2014 Stephen Herr <sherr@redhat.com> 2.3.62-1
- 1154175 - Show ppc64le profiles to ppc systems
- fix spelling error

* Fri Oct 17 2014 Jan Dobes 2.3.61-1
- another list items count and selected items count texts style
- improve style of navigation sub menu
- separate list items count and selected items count texts
- use fontawesome icon instead of image

* Thu Oct 16 2014 Stephen Herr <sherr@redhat.com> 2.3.60-1
- 1153793 - set default kernel and initrd locations for ppc64le distros
- 1153789 - prevent infinite loop when scheduling kickstart

* Thu Oct 16 2014 Tomas Lestach <tlestach@redhat.com> 2.3.59-1
- 1153651 - actually a File.separator should work better
- 1153651 - slash needed when building paths

* Thu Oct 16 2014 Tomas Lestach <tlestach@redhat.com> 2.3.58-1
- accept lowercase gpg channel information
- let javascript do the uppercase of gpg fields for the user
- 1008677 - fix system.schedulePackageInstall APIdoc

* Tue Oct 14 2014 Jan Dobes 2.3.57-1
- style /rhn/kickstart/SystemDetailsEdit page
- remove header of always empty section

* Tue Oct 14 2014 Tomas Lestach <tlestach@redhat.com> 2.3.56-1
- fix javascript injection on /rhn/systems/details/kickstart/ScheduleWizard.do
  page
- 1150980 - add read_only and errata_notification to user.getDetails APIdoc
- 1013672 - add id to errata.getDetails APIdoc
- fixing javascript injection on /rhn/kickstart/KickstartOverview.do page
- close forgotten div in lists

* Mon Oct 13 2014 Stephen Herr <sherr@redhat.com> 2.3.55-1
- 1132398 - fix debian repo generation and unused code cleanup
- 1150980 - extend user.getDetails API

* Fri Oct 10 2014 Tomas Lestach <tlestach@redhat.com> 2.3.54-1
- fixing javascript injection on
  /rhn/systems/details/configuration/addfiles/ImportFileConfirm.do page
- fixing javascript injection on /rhn/errata/details/SystemsAffected.do page
- 1020414 - Removed bogus label-limit from SDC Remote Cmd pg

* Thu Oct 09 2014 Jan Dobes 2.3.53-1
- improve look of /rhn/channels/manage/repos/RepoDelete page

* Wed Oct 08 2014 Jan Dobes 2.3.52-1
- style /rhn/systems/details/configuration/Overview page
- remove redundant symbol

* Wed Oct 08 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.51-1
- 1150275 - fixed pt_BR translation
- style /rhn/systems/ssm/provisioning/RemoteCommand page
- 'Erratum' is singular, 'Errata' is plural, 'Erratas' is nothing

* Mon Oct 06 2014 Grant Gainey 2.3.50-1
- 1148836 - DOn't schedule a remote-cmd if the system can't execute it
- fix used icon
- add some space under button
- fix button indentation

* Fri Oct 03 2014 Jan Dobes 2.3.49-1
- style lot of buttons
- making Channel.equals(SelectableChannel) symmetric
- broken checkbox layout in /rhn/channels/manage/Sync.do?cid=xxx

* Wed Oct 01 2014 Jan Dobes 2.3.48-1
- 1136492 - check if user can see activation key

* Wed Oct 01 2014 Jan Dobes 2.3.47-1
- 1093045 - schedule configuration actions asynchronously
- fixed missing boostrap design
- missing bootstrap class

* Mon Sep 29 2014 Stephen Herr <sherr@redhat.com> 2.3.46-1
- 481001 - throw sensible error to user if multiple channels containing rhncfg

* Fri Sep 26 2014 Stephen Herr <sherr@redhat.com> 2.3.45-1
- 1084522 - make parsing repo filters more robust

* Fri Sep 26 2014 Tomas Lestach <tlestach@redhat.com> 2.3.44-1
- return empty string instead of null, when a required completion_time of a
  rhnServerAction isn't set
- set a completion time, when marking an actin as failed

* Fri Sep 26 2014 Tomas Kasparek <tkasparek@redhat.com> 2.3.43-1
- checkstyle fix
- patternfly: css files order fixed because of spacewalk specific icons
- patternfly: fixing footer position
- Integrating patternfly for more awesomeness...
- packageNamesByCapabilityAndChannel: dead code removed
- packageNamesByCapability: dead code removed

* Thu Sep 25 2014 Tomas Lestach <tlestach@redhat.com> 2.3.42-1
- allow selecting users on the /rhn/users/DisabledList.do page
- 1145478 - enhance Org.numOfOrgAdmins sql-query
- 1145478 - change readOnly hbm type to yes_no
- 1145478 - behave differently when the user was a readonly one before the
  change
- 1145186 - fix api.getApiCallList not to return 'struct' as the 1st parameter

* Wed Sep 24 2014 Tomas Lestach <tlestach@redhat.com> 2.3.41-1
- do not offer errata to add to the channel that are already in there
- Use IconTag

* Mon Sep 22 2014 Stephen Herr <sherr@redhat.com> 2.3.40-1
- 1028308 - suppress ks-tree-copy warning in ks-rhn-post.log

* Thu Sep 18 2014 Stephen Herr <sherr@redhat.com> 2.3.39-1
- 990998 - package details page should not list channels we can't see
- 698241 - suppress unnecessary warnings in ks snippet
- 1133634 - fix file descriptor leak in system.crash.getCrashFile

* Wed Sep 17 2014 Stephen Herr <sherr@redhat.com> 2.3.38-1
- 1138708, 1142110 - make child channel architecture check universal
- fix typo
- specify usage of java.config_file_edit_size option
- 1142133 - throw LookupException instead of NoSuchCrashException

* Mon Sep 15 2014 Stephen Herr <sherr@redhat.com> 2.3.37-1
- 1126305 - add more documentation to Power Management page
- 1126297 - power management - make system identifier clearable

* Fri Sep 12 2014 Tomas Lestach <tlestach@redhat.com> 2.3.36-1
- do not offer the channel itself within the channel list to add packages from
- do not offer channel itself among the channel list to clone errata from
- 1065998 - do not clone custom errata when merging

* Fri Sep 12 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.35-1
- 1057638 - check, whether referenced kickstart profice and crypto keys are
  available

* Fri Sep 12 2014 Tomas Lestach <tlestach@redhat.com> 2.3.34-1
- display error messages in red
- 1126303 - catch cobbler exception 'Invalid characters found in input'

* Thu Sep 11 2014 Stephen Herr <sherr@redhat.com> 2.3.33-1
- 1140859 - html-encode tomcat log to prevent cross-site scripting
- 959567 - use sha256 checksums for config files instead of md5
- 1140180 - re-set number of config file diffs correctly
- remove unused variable assignement
- remove unnecessary casts

* Fri Sep 05 2014 Stephen Herr <sherr@redhat.com> 2.3.32-1
- Checkstyle fixes

* Fri Sep 05 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.31-1
- 1138326 - improved ja translation of help menu

* Thu Sep 04 2014 Stephen Herr <sherr@redhat.com> 2.3.30-1
- 1138451 - add aarch64 provisioning support

* Tue Sep 02 2014 Stephen Herr <sherr@redhat.com> 2.3.29-1
- 1136526 - Fix installabe package list in system details

* Tue Sep 02 2014 Jan Dobes 2.3.28-1
- 1120847 - improving 'All Custom Channels' queries

* Fri Aug 29 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.27-1
- 1119447 - show package link if package is in database

* Fri Aug 29 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.26-1
- 1128825 - AKey package names separated by spaces.

* Thu Aug 28 2014 Stephen Herr <sherr@redhat.com> 2.3.25-1
- 1135073, 1132398 - repomd generation memory increases with channel size

* Wed Aug 27 2014 Tomas Lestach <tlestach@redhat.com> 2.3.24-1
- remove jasper2 validateXml attribute as it's causing troubles
- improve spacing between UI elements
- 1063808 - Custom info empty value added (java/api)

* Mon Aug 25 2014 Jan Dobes 2.3.23-1
- 1127730 - check if action chain with same name already exists

* Fri Aug 22 2014 Stephen Herr <sherr@redhat.com> 2.3.22-1
- Fix SELinux denials in fedora

* Wed Aug 20 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.21-1
- struts-taglib is no more needed
- use tomcat 7 on RHEL7

* Tue Aug 19 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.20-1
- added missing PPC64LE localization string
- Don't swallow exceptions (try...finally should be considered harmful)

* Mon Aug 18 2014 Tomas Lestach <tlestach@redhat.com> 2.3.19-1
- introduce system.transitionDataForSystem API
- expression of type SystemsPerChannelDto is already an instance of type
  SystemsPerChannelDto
- Eclipse code formatter settings: use checkstyle compatible spacing for array
  initializers

* Fri Aug 08 2014 Jan Dobes 2.3.18-1
- 1127750 - ISE when activation key has no description.

* Wed Aug 06 2014 Tomas Kasparek <tkasparek@redhat.com> 2.3.17-1
- remove wrong @Override annotations
- remove unused import
- remove unused import
- remove unused import
- move unnecessarily nested else clause
- move unnecessarily nested else clause
- move unnecessarily nested else clause
- move unnecessarily nested else clause
- move unnecessarily nested else clause
- move unnecessarily nested else clause
- move unnecessarily nested else clause
- move unnecessarily nested else clause
- remove unnecessary casts
- introduce system.unentile API call
- unify and move validation of client certificate to BaseHandler

* Fri Aug 01 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.16-1
- make lineIterator() prototype unambiguous

* Fri Aug 01 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.15-1
- add Korea to the list of timezones

* Fri Aug 01 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.14-1
- Use text mode and set editor to read only
- Add test for getTailOfFile()
- Read and display only a limited number of logfile lines

* Wed Jul 30 2014 Stephen Herr <sherr@redhat.com> 2.3.13-1
- 1066432 - auto errata updates have to wait for errataCache to finish

* Tue Jul 29 2014 Jan Dobes 2.3.12-1
- update linking and delete old page
- create /software/packages/Dependencies page in Java
- refactor packages code
- add queries for weak package dependencies to Java

* Thu Jul 24 2014 Jan Dobes 2.3.11-1
- fix NullPointerException

* Wed Jul 23 2014 Tomas Lestach <tlestach@redhat.com> 2.3.10-1
- fixing java.lang.NullPointerException

* Wed Jul 23 2014 Tomas Lestach <tlestach@redhat.com> 2.3.9-1
- escape external group names on /admin/multiorg/ExtAuthRoleMapping.do and
  /users/ExtAuthSgMapping.do pages

* Tue Jul 22 2014 Stephen Herr <sherr@redhat.com> 2.3.8-1
- fix junit test by setting a password in test ks profile
- 1121659 - ssm config actions should show details for specific system in
  history

* Tue Jul 22 2014 Tomas Kasparek <tkasparek@redhat.com> 2.3.7-1
- better initialization of array

* Mon Jul 21 2014 Stephen Herr <sherr@redhat.com> 2.3.6-1
- fixing junit tests after cd0a7132d6fe8a1b24f6078bd079e9757db1f2bc

* Fri Jul 18 2014 Stephen Herr <sherr@redhat.com> 2.3.5-1
- 1121215 - ISE comparing config files in SSM
- 1121245 - history events should show script results for this system only
- 1121252 - config revision not found when following history link

* Thu Jul 17 2014 Stephen Herr <sherr@redhat.com> 2.3.4-1
- 1120814 - fix broken links to old perl events page
- api for setting/getting kickstart virtualization profiles

* Tue Jul 15 2014 Stephen Herr <sherr@redhat.com> 2.3.3-1
- 1114044 - checkstyle fix

* Tue Jul 15 2014 Stephen Herr <sherr@redhat.com> 2.3.2-1
- 1114044 - fix to support custom kickstart distributions

* Tue Jul 15 2014 Tomas Kasparek <tkasparek@redhat.com> 2.3.1-1
- API for deployment of certain config file to all system from its config
  channel
- add api for setting OS repositories in kickstart profiles
- allow setting errata mailer preferences via API
- Bumping package versions for 2.3.

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.120-1
- bump api version
- fix copyright years
- Fix ISE when tag name is left empty

* Thu Jul 10 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.119-1
- make channel family consumtion columns sortable
- add schedulePackageInstall api for array of servers

* Thu Jul 10 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.118-1
- add api for setting kickstart/software properties
- fix api call paramater in api documentation

* Mon Jul 07 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.117-1
- call rhn-config-satellite.pl only if anything has changed

* Fri Jul 04 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.116-1
- SET is a Oracle reserved word
- TokenPackageFactoryTest: avoid NPE on incomplete existing packages

* Tue Jul 01 2014 Stephen Herr <sherr@redhat.com> 2.2.115-1
- 1109276 - checkstyle fix

* Tue Jul 01 2014 Stephen Herr <sherr@redhat.com> 2.2.114-1
- 1109276 - Fix Distro syncing in CobblerSyncTask, force one sync to fix arch
- don't show packages tab if activation key hasn't provisioning entitlement
- fix column header for package profile difference
- add csv export for package profile comparison
- handle NestedNullException while creating csv
- allow users to set size of config files to be editable in webUI

* Mon Jun 30 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.113-1
- add missing string resource
- don't use obsolete hibernate namespace

* Fri Jun 27 2014 Stephen Herr <sherr@redhat.com> 2.2.112-1
- Some final polish on power management feature.
- Power Management: indentation corrected
- Power Management: use rhn:toolbar

* Fri Jun 27 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.111-1
- checkstyle fix

* Fri Jun 27 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.110-1
- don't offer read-only flag in the initial user creation page

* Fri Jun 27 2014 Tomas Lestach <tlestach@redhat.com> 2.2.109-1
- package (apache-)commons-validator.jar
- on fc19 we shall link apache-commons-validator instead of commons-validator

* Thu Jun 26 2014 Stephen Herr <sherr@redhat.com> 2.2.108-1
- Fixing missing headers

* Thu Jun 26 2014 Stephen Herr <sherr@redhat.com> 2.2.107-1
- Fixing merge problem and checkstyle for power management merge

* Thu Jun 26 2014 Stephen Herr <sherr@redhat.com> 2.2.106-1
- Guest Provisioning was broken because of refactoring
- Update to build on newer source
- $ tags removed as suggested by mkollar
- SSM power management operation page test
- SSM power management operation page added
- SSM power management configuration page test
- SSM power management configuration page added
- rhnSsmOperationServer: note column tests
- rhnSsmOperationServer: note column added
- ServerTestUtils: add a server group parameter to createTestSystem
- Single-system power management page tests
- Single-system power management page added
- Configuration options added
- SystemRecord: power status support tests
- SystemRecord: power status support added
- CobblerPowerCommand tests
- CobblerPowerCommand added
- CobblerPowerSettingsUpdateCommand tests
- CobblerPowerSettingsUpdateCommand added
- Refactoring: make getCobblerSystemRecordName() callable from other classes
- Do not assume a Cobbler system record always has a profile attached
- Cobbler image support tests
- Cobbler image support added
- SystemRecord: power management support tests
- SystemRecord: power management support added
- make requires sorted
- moved common requires before conditional ones
- reduced number of if-else-endif blocks
- return also org_name in user.getDetails api

* Wed Jun 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.105-1
- fixed apache-commons-* vs. jakarta-commons-* conflicts
- return whether staging content is enabled for org in org.getDetails api
- add csv report for relevant erratas in system groups

* Wed Jun 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.104-1
- fixed apache vs. jakarta  -commons-{codec,lang} conflict

* Tue Jun 24 2014 Stephen Herr <sherr@redhat.com> 2.2.103-1
- 1109276 - checkstyle fix

* Tue Jun 24 2014 Stephen Herr <sherr@redhat.com> 2.2.102-1
- 1112633 - Prevent CobblerSync from failing from removed ks trees
- 1109276 - Correctly set cobbler arch

* Tue Jun 24 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.101-1
- correctly retrieve user name for logging purposes
- fix channel link
- check for read_only flag when checking for active (Sat|Org)Admins
- better logging of post process exceptions
- ErrataHandlerTest: avoid accidental end-of-string chars in test strings

* Mon Jun 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.100-1
- don't render a link for non-existent base channel

* Mon Jun 23 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.99-1
- use javapackages-tools instead of jpackage-utils on RHEL7

* Mon Jun 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.98-1
- removed unused import

* Fri Jun 20 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.97-1
- ensure an Iterator<String> is passed instead of an Iterator<Object>

* Fri Jun 20 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.96-1
- syntax fix

* Thu Jun 19 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.95-1
- explicitly convert errata keywords to String
- allow filtering of events based on event type for listSystemEvents api
- specify 'None' repository checksum type usage
- style add/remove system to system group buttons
- add white space after 'in'
- style publish button

* Tue Jun 17 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.94-1
- 1012643 - display count of errata in channel not packages with errata
- disable last org/sat admin become read-only
- add csv report to errata pages
- fix dead links
- 803040 - API for snapshot rollback
- hibernate mapping for snapshots associated to a snapshot tag
- don't execute sessionKey -> User translation for AuthHandler
- simplify expression a bit
- fix typo in class name

* Fri Jun 13 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.93-1
- checkstyle fix

* Fri Jun 13 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.92-1
- We are testing CryptoKeyDeleteAction here
- CryptoKeyDelete needs the "contents_edit" parameter now

* Fri Jun 13 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.91-1
- compare_packages_to_snapshot: performance fix
- compare_packages_to_snapshot: avoid failure on NULL evr on Oracle
- start using User as parameter instead of sessionKey in ScheduleHandler
- OrgHandler: unused private methods removed
- 1011935 - add missing localization string
- 1012643 - display errata count in channels/All.do
- 1063342 - create error message if passwords doesn't match

* Wed Jun 11 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.90-1
- 1086256 - style submit buttons
- page for viewing channels repo is associated to
- API for setting read-only user flag
- allow read-only user flag to be set in webUI
- remove unused class
- using User as parameter in API instead of sessionKey
- authenticate user before invoking API methods
- check method name in order to distinguish read only api calls
- disable read-only users to log in
- allow user to be created as read only
- hibernate mapping for read only user
- checkstyle fix
- Fix datepicker time at xx:xx PM pre-filled with xx:xx AM inducing user to
  enter the wrong time. (bnc#880936)
- SystemRemoteCommandAction: avoid exception swallowing[1]
- 574974 - RFE: Add option of pasting key into textarea
- remove dead variable
- make array initialized from constants static final
- remove redundant .LongValue() call on Long object
- finalize variables which should be final
- use serialVersionUID
- remove unused method
- use StringBuilder instead of StringBuffer for local variables
- remove link to the dead page
- Fix human dates now() staying unmodified (bnc#880081)

* Thu Jun 05 2014 Stephen Herr <sherr@redhat.com> 2.2.89-1
- 594455 - group by db fix for elaborator
- apidoc fix: remove extraneous #array from function prototypes

* Thu Jun 05 2014 Stephen Herr <sherr@redhat.com> 2.2.88-1
- 594455 - Fix db grouping error

* Wed Jun 04 2014 Stephen Herr <sherr@redhat.com> 2.2.87-1
- Hibernate does not like overloaded setters

* Tue Jun 03 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.86-1
- lookupByIds(): fix handling of a minimal case
- System Event History page: fix link to pending events on Oracle databases

* Mon Jun 02 2014 Stephen Herr <sherr@redhat.com> 2.2.85-1
- 1103822 - Provide faster systemgroup.listSystemsMinimal
- Escape package name to prevent from script injection
- Allow for null evr and archs on event history detail

* Mon Jun 02 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.84-1
- rewrite rollback_by_tag_conf.pxt to java RollbackToTag.do

* Fri May 30 2014 Stephen Herr <sherr@redhat.com> 2.2.83-1
- A few hundred more warning fixes

* Fri May 30 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.82-1
- Remove assert statements from setUp() method
- Fix and improve unit tests involving kickstartable channels
- New query to determine kickstartable channels
- create named query for snapshotTag lookup by name
- CloneErrataAction: spacing fix
- provide information about unservable packages to Rollback.do page
- rewrite unservable_packages.pxt page to java

* Thu May 29 2014 Stephen Herr <sherr@redhat.com> 2.2.81-1
- 1102831 - make BaseEvent null-safe
- 1102831 - fix 'can't read the_log_id' errors in async events

* Thu May 29 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.80-1
- checkstyle fixes

* Thu May 29 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.79-1
- add_snapshot_tag.pxt has been replaced by SnapshotTagCreate.do
- fixed links to new java pages
- ChannelManager.ownedChannelsTree test added
- ActionChainHandlerTest fixes
- Fix refreshing of Autoinstallable Tree forms (bnc#874144)
- BaseTreeEditOperation: avoid NPE in unexpected exception handling
- Delete system: button styled
- System/Software/Packages/Non Compliant: button styled
- System/Software/Packages/Profiles: button styled
- System/Software/Packages/Upgrade: button styled
- System/Software/Packages/List: button styled
- System/Software/Packages/Install: button styled
- Missing translation string added (bnc#877547)

* Tue May 27 2014 Stephen Herr <sherr@redhat.com> 2.2.78-1
- Can't infer class is Long because there's no zero argument constructor

* Tue May 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.77-1
- rewrite system snapshot to java: Rollback.do
- call removeServerFromGroup() with ids not objects

* Fri May 23 2014 Stephen Herr <sherr@redhat.com> 2.2.76-1
- Checkstyle fixes
- Disable caching of Locale between page loads; might have changed
- fix test: we ow pass the Date object to the JSP so it can be null   - test
  that is the same as the user attribute
- userdetails.jsp also uses EditUserSetupAction, so handle also the null case
- even if most of it is Javascript, add simple unit test to FormatDateTag HTML
  output
- lastLoggedIn is a String, not a Date, and can be null
- make use of humanize dates for package lists
- make use of humanize dates for system lists
- humanize dates for user pages. created in 'calendar' mode and last login in
  'time ago' mode
- show the system overview with human dates

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.75-1
- format the date in ISO format using javax.xml.bind.DatatypeConverter
- 1044527 - EL7 Vhost warning about missing VT chann
- use proxy host for kickstarting virtual guest if available
- new system snapshot pages in java

* Thu May 22 2014 Stephen Herr <sherr@redhat.com> 2.2.74-1
- fix JSP variable names
- SQL query fix
- refactor snapshot details code a bit
- rewrite Snapshots - Config Channels page to Java

* Thu May 22 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.73-1
- system groups & snapshots page: converted from pxt to java
- fix the date format (month vs minutes)

* Wed May 21 2014 Stephen Herr <sherr@redhat.com> 2.2.72-1
- A couple of mode queries didn't quite fit into ChannelTreeNode objects.
- 1099938 - add spacewalk-report for systems with extra packages
- 1099938 - improve performance of Systems with Extra Packages query
- remove redundant formvars
- queries to compare snapshot to system packages / config channels
- move code for snapshot name generation to more appropriate place

* Wed May 21 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.71-1
- insert ss_id parameter into navigation links if needed
- checkstyle fix
- queries to compare snapshot to system groups/channels
- Event history: format script text and output correctly
- Fix indentation
- Fix exception in tomcat logs due to missing server object
- SystemHandlerTest: check edit date correctly
- Hibernate Package definition: fix table name

* Wed May 21 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.70-1
- More schedule action unification
- 1098800 - link to event to be cancelled is broken
- KickstartSession.markFailed: use correct parameter order

* Tue May 20 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.69-1
- Systems in a channel family: converted from pxt to java
- 1098805 - event cancel confirm botton label.

* Tue May 20 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.68-1
- navigation links to new pages (Tags.do)
- rewrite snapshots/rollback.pxt?sid=${sid}&ss_id=${ss_id} page to java
- rewrite snapshot tag deletion to java
- rewrite system_tags.pxt?sid=${sid} page to java
- introduce snapshot tag filter
- rewrite add_system_tag.pxt?sid=${sid} page to java
- rewrite add_system_tag.pxt?sid=${sid} page to java
- strings for snapshot tags pages rewrite

* Mon May 19 2014 Stephen Herr <sherr@redhat.com> 2.2.67-1
- Squashing a thousand more type warnings by doing param maps correctly
- Squash a few hundred type safety warnings
- 1098316 - don't let code diverge; everyone should use new method
- add request scope to the remote command via SSM action
- 1098313 - cleanup unused method
- changed autoinstallation -> kickstart
- testListPackagesFromChannel: update after changes to
  SystemManager.packagesFromChannel
- apidoc: reflect changes in createChain() return type
- Action Chaining API: remove superfluous annotation
- Action Chaining API: fail if trying to add multiple chains with the same
  label
- Fix: Action Chain XML-RPC API doc
- Bugfix: API crashes, if label is null.
- checkstyle: line length should be <= 92 characters
- fix configchannel.createOrUpdatePath API issue that stored new revision
  contents as null characters
- autoinstallation -> kickstart
- Added kickstart syntax rules box to advanced edit page
- Added warning message about kickstart syntax rules

* Fri May 16 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.66-1
- Fix javadoc. 1-11 makes no sense, and the old picker did 1-12 for am/pm time.
- Fix bug converting pm times to am when using locales in 24 hour format.
- If value parameter expression is null, evaluate the page. Fixes a crash when
  using the tag inside rhn:list and ${current} is not yet set.
- Do not force the timezone name with daylight=false. (eg. showing EST for EDT)
- Set milliseconds to 0 before comparing dates (bnc#814292)
- Added a test for CloneErrataAction
- Trigger repo metadata generation after cloning patches (bnc#814292)

* Thu May 15 2014 Stephen Herr <sherr@redhat.com> 2.2.65-1
- 1098316 - ssm child channel subscription page was slow
- 1098313 - SDC was unnecessarily slow if the system had many guests

* Thu May 15 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.64-1
- deduplicate rhn_server.remove_action() calls
- typo fix

* Wed May 14 2014 Stephen Herr <sherr@redhat.com> 2.2.63-1
- 1075127 - continue to use md5 for rhel 5 and lower kickstarts
- Form names are only available as name attributes now, not ids.
- 1075161 - set autopart options correctly
- Typo fix

* Mon May 12 2014 Stephen Herr <sherr@redhat.com> 2.2.62-1
- 1075127 - Kickstart profiles use sha-256 everywhere you can set root pw

* Fri May 09 2014 Stephen Herr <sherr@redhat.com> 2.2.61-1
- Checkstyle Fix
- 594455 - checkstyle fix

* Fri May 09 2014 Stephen Herr <sherr@redhat.com> 2.2.60-1
- 594455 - SSM package upgrades should apply correctly across diverse system
  sets
- remove semicolon in query
- use the request object and not the pagecontext directly to store whether we
  already included javascript
- 1082694 - The "Delete Key" link should not appear if there is no key to
  delete

* Tue May 06 2014 Stephen Herr <sherr@redhat.com> 2.2.59-1
- 1074083 - API package search should not require a provider

* Tue May 06 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.58-1
- rewrite pending events page from perl to java

* Mon May 05 2014 Stephen Herr <sherr@redhat.com> 2.2.57-1
- 1094364 - add default arch heuristic for kickstart package installs

* Mon May 05 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.56-1
- use getInt instead of getInteger so we can read default value
- Action Chain: for every action, create its own ScriptActionDetails
  (bnc#870207)
- fixed broken links introduced by 178ee339
- CryptoKeyCreateActionTest: fix after 35b0296
- MigrationManagerTest: Oracle could still fail in some cases, fix in more
  comprehensive way
- add localization string
- add localization string
- RebootActionClenup: documentation fix

* Mon Apr 28 2014 Tomas Lestach <tlestach@redhat.com> 2.2.55-1
- MigrationManagerTest: add explicit flushing before assertions (needed by
  Oracle, not needed in production code)
- scheduleCertificateUpdate: update api doc

* Fri Apr 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.54-1
- correctly display certificate update action in webui
- Replace editarea with ACE (http://ace.c9.io/) editor.

* Thu Apr 24 2014 Stephen Herr <sherr@redhat.com> 2.2.53-1
- 973848 - ISE in case no file specified when crating key.
- 973848 - Check if the key is not empty file when editing.
- 1090989 - Uneditable field is marked as required.
- fix typo
- MigrationManagerTest: fix Hibernate problem that prevented the test to run
  correctly
- MigrationManagerTest: remove unnecessary set up code
- SystemManager refactoring: move query in it's own method and remove
  duplication
- Enable DWR exception stack trace logging by default

* Wed Apr 23 2014 Stephen Herr <sherr@redhat.com> 2.2.52-1
- 1084522 - [RFE] filters per repository on WebUI
- checkstyle fixes, documentation updates, making method names consistant
- xmlrpc spec includes bool values, any library should be able to handle them
- fix unclosed javadoc tags
- Fixed typo
- - split method that fix the order gaps - implement a helper method to remove
  and fix the ordering of an entry   from a chain - use that method in the
  handler - tests
- Fixed Javadoc and XML-RPC doc
- Adjusting tests for the refactoring of the XML-RPC API
- Refactoring of XML-RPC API handler
- Added translations for the Action Chain XML-RPC API exception
- Added exception type for Action Chain XML-RPC API
- Fixes during review
- Removed timeout limitation for the script schedule
- Removed unused code, made for 'convenience' methods
- Checkstyle, missing javadoc tags, unused imports.
- Added tests for Action Chain rename XML-RPC API, adjusted tests for config
  deployment API call
- Added Action Chain rename XML-RPC API, unified config deployment API call
- Added missing javadoc
- Renamed 'name' to 'label'
- Added tests for configuration deployment XML-RPC API of the Action Chain
- Added configuration deployment XML-RPC API for the Action Chain call
- Change tests for referring to the Action Chain entries by ID
- Referring to the Action Chain entries by ID
- Added more tests for XML-RPC API calls
- Added exceptions, minor refactoring
- Added XML-RPC API for scheduling the Action Chain for exec
- Added missing method javadoc
- Added tests for chain removal XML-RPC API calls with the authorization
- Added security for chain removal XML-RPC API calls
- Adjusted tests for Action Chain handler throwin exceptions
- Change Action Chain handler to throw exceptions on failures
- Reviewed test assertions and added more tests to the XML-RPC API Action
  Chains
- Removed 'convenient' methods
- Removed unused imports
- Throw an exception if server is not found
- Rename action chain 'name' to 'label' in tests
- Added a test for creating Action Chain method XML-RPC API call.
- Checkstyle fixes
- Added XML-RPC API call to explicitly create an Action Chain
- Removed previously introduced cleanup paradigm as Action Chain explicitly
  created. Removed validation check in favor of exceptions.
- Rename action chain 'name' to 'label'
- Various unit test fixes
- Added more tests for the Action Chain XML-RPC API
- Refactored cleanup for Action Chain XML-RPC handler
- Add resolve packages by ID to ActionChain XML-RPC handler
- Added more tests
- Minor bugfixes to the Action Chain XML-RPC handler
- Added tests for the standard XML-RPC API for the Action Chaining.
- Adding missing cleanup action on failed input
- Added XML-RPC API unit tests: chain list, chain actions
- Removed accidentally added external files
- Added package installation and removal tests for the XML-RPC ActionChain API
- Query should return same column names
- Bugfix: pkg keys missing underscore
- Added two tests of XML-RPC API for Action Chaining
- Code refactoring, improved documentation
- Changed namespace name for ActionChain RPC API
- Added Remote command script API to Action Chaining XML-RPC API
- Documentation fixes
- Checkstyle fixes
- Added more APIs taking IDs
- Adapt to changed APIs in ActionChainManager
- Added System reboot, added more API by ID
- Added package install by ID
- API is now accepts real server attributes - IP and name
- XML-RPC API: Action Chain initial implementation
- Added Action Chain listing and Action details API
- Added single system update/install/remove/verify pkg by name
- ActionChainHandler: XML-RPC API for Action Chaining

* Tue Apr 22 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.51-1
- rewrite system snapshot to java: fixed nav menu hiding
- rewrite system snapshot to java: Packages.do
- rewrite system event page from perl to java

* Thu Apr 17 2014 Stephen Herr <sherr@redhat.com> 2.2.50-1
- More API methods for IPA integration

* Wed Apr 16 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.49-1
- rewrite system snapshot to java: implement nav menu hiding
- rewrite system snapshot to java: Index.do
- Fixing junit tests for external user management APIs

* Mon Apr 14 2014 Stephen Herr <sherr@redhat.com> 2.2.48-1
- Adding new API methods for external user management

* Mon Apr 14 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.47-1
- limit actions displayed on schedule/*actions pages
- 1086256 - Submit buttons are incorrectly labelled.
- 1084703 - Removing repo filters ISE.

* Fri Apr 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.46-1
- 1086161 - PM page incorrectly labelled buttons.

* Fri Apr 11 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.45-1
- dwr.xml file reformatted
- Refactoring: utility method makeAjaxCallback renamed
- DWR rendering infrastructure: allow throwing custom exceptions

* Fri Apr 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.44-1
- Add support to ConfigureSatelliteCommand to remove keys

* Fri Apr 11 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.43-1
- rewrite channel compare pages to java

* Thu Apr 10 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.42-1
- New API: system.scheduleCertificateUpdate()

* Wed Apr 09 2014 Stephen Herr <sherr@redhat.com> 2.2.41-1
- 1051160 - correctly set cobbler distro os_version

* Tue Apr 08 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.40-1
- remote command webui: don't scrub the script body

* Mon Apr 07 2014 Stephen Herr <sherr@redhat.com> 2.2.39-1
- fixes 2 action chain strings for consistency
- SSM Action Chain configuration Deploy: missing strings added
- Action Chain: bootstrap form groups fixed

* Fri Apr 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.38-1
- converted tabs to spaces
- rewrite listPackagesFromChannel logic into database select

* Fri Apr 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.37-1
- 903068 - checkstyle fixes

* Fri Apr 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.36-1
- 903068 - fixed debian repo generation

* Thu Apr 03 2014 Jan Dobes 2.2.35-1
- 1083975 - fix logrotate insecure permission
- Eclipse Checkstyle settings updated
- Eclipse cleanup preferences file added
- Eclipse code templates: remove old version tag
- Eclipse code templates: move file header to comments
- Eclipse code templates: update to current version
- Eclipse formatter: allow assignment line wrapping
- Eclipse formatter: update maximum line length
- Eclipse RHN formatter settings: update to current version
- 1076864 - [RFE] params for sw-repo-sync UI/API.

* Wed Apr 02 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.34-1
- explicitly initialize MessageDigest object instance

* Wed Apr 02 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.33-1
- add missing bracket

* Wed Apr 02 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.32-1
- Ability to validate SHA-256 client certificate

* Mon Mar 31 2014 Stephen Herr <sherr@redhat.com> 2.2.31-1
- checkstyle fixes
- checkstyle fixes
- fixed typo in action chain jsp and js
- Action Chaining: list page columns changed as suggested
- ActionChainManager: refactorings and Javadoc cleanup
- SSM remote command: use proper user messages
- SSM remote command: allow queuing to Action Chains
- SSM reboot: allow queuing to Action Chains
- SSM configuration file deploy: allow queuing to Action Chains
- SSM errata apply: use proper user message
- SSM errata apply: allow queuing to Action Chains
- SSM package verify: allow queuing to Action Chains
- SSM package actions: allow queuing to Action Chains
- Remove functionality to add remote command before a package action in SSM, it
  is superseded by Action Chains
- Action Chain Edit page tests
- Action Chain Edit page added
- Action Chain List page added
- Reboot: use proper user messages
- Reboot: allow queuing to Action Chains
- Deploy Configuration: use proper user message
- Deploy Configuration: allow queuing to Action Chains
- Remote Command: use proper user message
- Remote Command: allow queuing to Action Chains
- Errata actions: use proper user message
- Errata actions: allow queuing to Action Chains
- Remove functionality to add remote command before a package action, it is
  superseded by Action Chains
- Single system package actions: use proper user message
- Single system package actions: allow queuing to Action Chains
- Controller helper tests added
- Controller helper class added
- ORM class tests added
- ORM classes for new tables added
- Front-end code for action chain creation/selection added
- ActionFormatter: utility methods tests
- ActionFormatter: add utility methods
- Refactoring: use a fragment for scheduling options on supported operations
- Implement task to invalidate reboot actions
- SSM Configuration Deploy: missing strings added

* Fri Mar 28 2014 Stephen Herr <sherr@redhat.com> 2.2.30-1
- 1082020 - taskomatic heap size of 1G is not sufficient for large channels
- Redirect instead of forwarding to overview page after a reboot

* Fri Mar 28 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.29-1
- Fail if rhnPackage.path is NULL
- Use rhnPackage.path as rhnErrataFile.filename like Perl does
- Base channel update: no-op if new channel equals old one
- ChannelManager.findCompatibleChildren: propose cloned children as compatible
- ChannelManager.findCompatibleChildren: propose children correctly if old and
  new are equal
- length of rhnServer.secret has been extended to 64
- Check the SHA-256 password first, MD-5 second.

* Tue Mar 25 2014 Stephen Herr <sherr@redhat.com> 2.2.28-1
- 1075127 - another checkstyle fix

* Tue Mar 25 2014 Stephen Herr <sherr@redhat.com> 2.2.27-1
- 1075127 - checkstyle fix

* Tue Mar 25 2014 Stephen Herr <sherr@redhat.com> 2.2.26-1
- 1075127 - use sha256 for kickstart password instead of md5. Also for fips.
- 1075161 - use default lvm partitioning for RHEL 7 kickstarts

* Tue Mar 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.25-1
- fixing broken tomcat detection in build-webapp.xml

* Fri Mar 21 2014 Stephen Herr <sherr@redhat.com> 2.2.24-1
- Rewrite code for bootstrap usage
- Rewrite code for bootstrap usage
- 1074083 - small performance improvement
- 1074083 - package.search API returns only one match per package name

* Fri Mar 21 2014 Tomas Lestach <tlestach@redhat.com> 2.2.23-1
- allow deleting temporary org admins
- delete all the temporary roles across the whole satellite
- assign the server group permissions acroding to the mappings
- add form validation
- rename UserExtGroup.hbm.xml to ExtGroup.hbm.xml
-  introduce /rhn/users/ExtAuthSgDelete.do page
- introduce /rhn/users/ExtAuthSgDetails.do page
- introduce the External Group to Roles Mapping page

* Thu Mar 20 2014 Stephen Herr <sherr@redhat.com> 2.2.22-1
- Updating ant task definitions to work better on new OS's:
- fix finding of the right API method to call

* Tue Mar 18 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.21-1
- SHA-256 to be used for creating session key

* Mon Mar 17 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.20-1
- User passwords will be encrypted with SHA-256

* Fri Mar 14 2014 Stephen Herr <sherr@redhat.com> 2.2.19-1
- Merge pull request #9 from dyordano/1071657
- 1071657 - Adding Custom Errata offers RH Erratas.

* Fri Mar 14 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.18-1
- make the task list responsive and do not use the image bullet
- FileDetails.do style and responsiveness.
- fix menu highlight

* Thu Mar 13 2014 Tomas Lestach <tlestach@redhat.com> 2.2.17-1
- create user default system group for the user
- introduce new /users/SystemGroupConfig.do page
- adapt class and mapping for createDefaultSg attribute
- introduce abstract class ExtGroup
- introduce OrgUserExtGroup and hibernate mapping

* Wed Mar 12 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.16-1
- new utility class to create SHA-256 encrypted user passwords
- one defaultsort per list must be enough for everybody

* Tue Mar 11 2014 Tomas Lestach <tlestach@redhat.com> 2.2.15-1
- 1064403 - fix filtering on the /rhn/channels/Managers.do page
- tidy (re-format) the hardware.jsp
- 1074540 - put the </div>s on the right place
- fix javadoc: remove extraneous function parameter description
- comment polish & removal

* Mon Mar 10 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.14-1
- java: extend length of web_contact.password to 110

* Fri Mar 07 2014 Stephen Herr <sherr@redhat.com> 2.2.13-1
- 1073652 - channel.software.syncErrata clones too many packages

* Fri Mar 07 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.12-1
- 1021558 - if buildTime is null don't parse it
- fix element nesting
- add Create First User page title to string resources
- update title of create first user page

* Thu Mar 06 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.11-1
- moved duplicated code to function
- removed old / simplified fedora requirements
- include both jboss-logging.jar and jboss-loggingjboss-logging.jar
- java pages do not use on-click and node-id attributes

* Wed Mar 05 2014 Jan Dobes 2.2.10-1
- hide search form together with other UI changes
- RecurringDatePicker sets HOUR_OF_DAY, however DatePicker design is kind of
  broken and it internally uses HOUR or HOUR_OF_DAY depending of the isLatin()
  flag. This does not make much sense as in Calendar itself HOUR, HOUR_OF_DAY
  and AM_PM are all interconnected.

* Tue Mar 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.9-1
- make taskomatic and rhn-search configuration overrideable via rhn.conf

* Mon Mar 03 2014 Stephen Herr <sherr@redhat.com> 2.2.8-1
- 1072073 - ChannelSerializer should display arch label too
- Compare objects using equals
- Add overrides
- Compare objects with equals
- Add overrides
- Make code more strightforward

* Mon Mar 03 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.7-1
- cryptokeydeleteconfirm.jsp port
- kickstartablesystems.jsp, fix layout
- unneeded offset and button alignment with columns
- typo in class, unneeded offset, button was aligned with columns (use text-
  right)
- fixing checkstyle
- Use String.equals instead of ==, this works only because we are lucky to get
  the constants as input.
- Revamp the recurring picker fragment to use the datepicker time component.
  For this the RecurringDatePicker bean now is composed of DatePicker beans to
  reuse functionality. With some Javascript, the repeat-task-picker disables
  the cron frequencies that are not being used.
- - if the datepicker date is disabled, disable the date part of the widget. -
  always generate the hidden fields. StrutsDelegate::readDatePicker will
  reset _all_ your date to now() if any field is missing.
- allow to disable date selection in addition to time
- syncrepos: format the page
- use buttons instead of inputs
- syncrepos: remove line break
- make the setup of the date picker more declarative using data- attributes in
  order to be able to share this setup with other parts of the code that will
  need a slightly different picker like the recurrent selector. It also saves
  us from outputing one <script> tag in the jsp tag implementation.

* Sat Mar 01 2014 Tomas Lestach <tlestach@redhat.com> 2.2.6-1
- replace tabs with spaces

* Fri Feb 28 2014 Stephen Herr <sherr@redhat.com> 2.2.5-1
- 1071482 - Add errata type selection to ssm page
- Check for deprecation annotation vs. javadoc consistency
- Removing trailing whitespace
- Added @Deprecation annotations

* Fri Feb 28 2014 Tomas Lestach <tlestach@redhat.com> 2.2.4-1
- delete outdated repo-sync schedules
- filter out channels that are not assigned to a server

* Wed Feb 26 2014 Jan Dobes 2.2.3-1
- 1068815 - update API documentation
- 1068815 - deal with deleted users
- Commit  04d9dccaedf8aa2998125e93969262ab73e58126 makes the form look broken.

* Tue Feb 25 2014 Tomas Lestach <tlestach@redhat.com> 2.2.2-1
- initialize temporaryRoles within CreateUserCommand
- remove unnecessarily nested else statement

* Tue Feb 25 2014 Tomas Lestach <tlestach@redhat.com> 2.2.1-1
- store the bounce_url back in the login page form
- rename label
- introduce Login401
- introduce keep_roles option
- list temporary roles on WebUI
- rework checkOrgAdmin to checkPermanentOrgAdmin
- rename addRole and removeRole to addPermanentRole and removePermanentRole
- start using temporary roles
- introduce UserGroupMembers class and mapping
- do not update user details if empty
- Bumping package versions for 2.2.

* Sat Feb 22 2014 Grant Gainey 2.1.163-1
- Remove unused import

* Sat Feb 22 2014 Grant Gainey 2.1.162-1
- We rmvd DESIRED_PASS/CONFIRM params from UserEditSetupAction - rmv from
  expected in test
- Testing createFirstUser() now looks to be forbidden
- verifyForward() and redirects-w/params do not like each other
- Tweaking some tag Junits to work
- Make checkstyle happy

* Thu Feb 20 2014 Jan Dobes 2.1.161-1
- fixing ISE in create repo form

* Thu Feb 20 2014 Tomas Kasparek <tkasparek@redhat.com> 2.1.160-1
- Styling unstyled submit buttons.
- styling buttons. LocalizedSubmitTag can't access styleClass attribute. It is
  set as private in the parent class.

* Thu Feb 20 2014 Matej Kollar <mkollar@redhat.com> 2.1.159-1
- fix checkstyle

* Thu Feb 20 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.158-1
- improved performance of system.listLatestUpgradeablePackages and
  UpgradableList.do

* Thu Feb 20 2014 Matej Kollar <mkollar@redhat.com> 2.1.157-1
- Use enhanced for loop
- Use generics
- Privatization of getLoggedInUser

* Wed Feb 19 2014 Matej Kollar <mkollar@redhat.com> 2.1.156-1
- 1009396 - escaping system name for
  /rhn/monitoring/config/ProbeSuiteSystemsEdit.do
- 1009396 - escaping system name for
  /rhn/systems/ssm/provisioning/RemoteCommand.do

* Tue Feb 18 2014 Matej Kollar <mkollar@redhat.com> 2.1.155-1
- correct grammar
- Fixing unclosed hr
- Fixing unclosed br
- Fixing unclosed meta
- Simple attempt to find problematic things in jsps
- don't add &amp; twice to the parameters of the url

* Mon Feb 17 2014 Matej Kollar <mkollar@redhat.com> 2.1.154-1
- 1064573 - make sidenav html valid

* Mon Feb 17 2014 Matej Kollar <mkollar@redhat.com> 2.1.153-1
- Remove unused context store
- Use .toHashCode
- removing unnecessary overriding attribute
- removing unnecessary overriding attribute
- removing unnecessary overriding attribute
- removing unnecessary overriding attribute
- removing unnecessary overriding attribute
- remove unnecessary cast
- remove unnecessary cast
- remove unnecessary else statement
- remove unnecessary else statement

* Fri Feb 14 2014 Stephen Herr <sherr@redhat.com> 2.1.152-1
- 1065483 - SSM package upgrades should not install packages if not an upgrade
- Proper TB3 column class

* Fri Feb 14 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.151-1
- fixed errors in date/time format conversions
- Introduce a date-time picker.
- Make the HtmlTag HTML5 compliant
- Added tool to manipulate localization files (format, del, sed).
- remove unused localization string
- Schedule action unification
- Separate datepicker and its label

* Wed Feb 12 2014 Stephen Herr <sherr@redhat.com> 2.1.150-1
- 1061425 - make package search faster
- Non-existent icon
- Forgotten internationalization...

* Wed Feb 12 2014 Tomas Kasparek <tkasparek@redhat.com> 2.1.149-1
- fix spanish translation for selected systems (string does not take a
  parameter anymore)
- Revert "fix spanish translation for selected systems (string does not take a
  parameter anymore)"
- Add missing GMT+3 timezone as Saudi Arabia
- style CreateUser page so it resembles old look
- /rhn/systems/details/configuration/addfiles/CreateFile.do?sid=... too much
  space between radios due to wrong usage of form-group.
- use help-block for help text in form
- /rhn/systems/ssm/MigrateSystems.do popup menu (aka select) after 'Target
  Orgenization' is not styled
- Unstyled elements in /rhn/errata/manage/AddPackages.do?eid=...
- panel inside a panel in rhn/configuration/Overview.do, just give a title to
  the list, which is already a panel.
- /rhn/admin/config/MonitoringConfig.do help texts ((e.g. 'redhat.com' for
  myemail@…)) should be bellow input bars (see
  /rhn/activationkeys/Edit.do?tid=1 how it should look like)
- fix unclosed that broke the top pagination selected count for example
  /rhn/systems/DuplicateIPList.do
- fix spanish translation for selected systems (string does not take a
  parameter anymore)

* Tue Feb 11 2014 Grant Gainey <ggainey@redhat.com> 2.1.148-1
- 1063915, CVE-2013-4415 - Fix XSS flaws in Spacewalk-search
- 1063915, CVE-2013-4415 - Fix XSS in new-list-tag by escaping _LABEL_SELECTED
- 1063915, CVE-2013-1871, Fix XSS in edit-address JSPs
- 1063915, CVE-2013-1869, close header-injection hole
- 1063915, CVE-2010-2236, Cleanse backticks from monitoring-probes where
  appropriate
- 1063915, CVE-2013-1869, Only follow internal return_urls
- 1063915, CVE-2012-6149, Fix XSS in notes.jsp
- Fix an ISE that could happen after clearing cookies (elaborator not bound)
- Removed duplicate colons
- Unified space before slash in void tags
- Datepicker UI unification: Errata pages
- use normal checkbox

* Mon Feb 10 2014 Tomas Kasparek <tkasparek@redhat.com> 2.1.147-1
- style ProbeEdit page
- updating susestudio-java-client to 1.4
- remove <meta name="page-decorator" content="none" />
- remove html formatting in other languages
- remove html formatting from StringResources
- fix checkstyle

* Thu Feb 06 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.146-1
- patch to handle systems registered with the --nohardware flag
- Patch code to build against susestudio-java-client version 0.1.4
- render <thead> and <tr> in UnpagedListDisplayTag

* Wed Feb 05 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.145-1
- page layout fixes
- Generalized code so it can be used both with and without selectable column
- Generification of Listable

* Tue Feb 04 2014 Stephen Herr <sherr@redhat.com> 2.1.144-1
- 1061425 - Improve package search performance
- 1061425 - query performance improvement for package search
- Fixed typo
- Use prepared confirm page
- Add confirmation page to ssm/ListPatches
- Needed elaborable return of ErrataManager.lookupErrataListFromSet
- Whitespace fix
- Remove unnecessary code after extraction
- Extracted "list systems in ssm related to errata" into separate action
- Change misleading variable name
- Extract actual handling of action into separate method
- Use some idioms to improve code readability
- Replace explicit iterator with enhanced for

* Tue Feb 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.143-1
- restored Monitoring Scout label
- removed unnecessary spacing and restored left side labels
- unify probe detail page look

* Tue Feb 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.142-1
- swapping struts tag with input html to allow the use of the placeholder
- perform password validation within the java class
- removing obsolete code related to PLACEHOLDER_PASSWORD

* Mon Feb 03 2014 Tomas Lestach <tlestach@redhat.com> 2.1.141-1
- enable creating externally authenticated users in organization according to
  REMOTE_USER_ORGUNIT
- do not close last row of tables with two </tr> tags
- make search work when search form is submitted by enter
- make ExpansionDecorator work again
- new icon for item edit

* Fri Jan 31 2014 Tomas Lestach <tlestach@redhat.com> 2.1.140-1
- allow deleting disabled users
- return default string even if input string is null
- move shared methods to loginhelper
- introduce LoginHelper
- add externally authenticated user roles according to the external group to
  roles mapping
- externally authenticated user does not have to be in the default org
- add external group delete page
- add external group edit page
- add external group to role mapping list page

* Fri Jan 31 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.139-1
- add special class to help links
- use consistent set of icons for system status

* Fri Jan 31 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.138-1
- reuse IconTag for help links, item search and pagination icons
- re-style kickstart creation wizard, 1st form

* Thu Jan 30 2014 Stephen Herr <sherr@redhat.com> 2.1.137-1
- 1059910 - create api for channel errata syncing, have clone-by-date call it
- fix style on kickstart profile creation wizard + use rhn:toolbar
- use rhn:toolbar for page headers
- update copyright year in page footer in java
- Removing unaesthetic spaces around dots in IPv4 address
- Small code cleanup

* Thu Jan 30 2014 Matej Kollar <mkollar@redhat.com> 2.1.136-1
- Fixed ssm reboot scheduling.
- Sometimes we don't want "add to ssm" option...
- add message about system lock/unlock into ssm index
- use icon for locked system
- 1009396 - escape system name for ssm lock/unlock page
- add defaultsort for extra packages page
- add defaultSort for packages list/remove
- add defaultSort to package list

* Tue Jan 28 2014 Stephen Herr <sherr@redhat.com> 2.1.135-1
- 1058761 - Update RHEL 7 VM memory requirements to 1024 MB
- rendering the password strength meter

* Tue Jan 28 2014 Jan Dobes 2.1.134-1
- remove old message
- Datepicker UI unification: Systems/Software/Packages/List-Remove
- Datepicker UI unification: SSM/Configuration/Enable
- Datepicker UI unification: SSM/Packages/Upgrade
- Datepicker UI unification: SSM/Packages/Verify
- Datepicker UI unification: SSM/Packages/Install
- Datepicker UI unification: SSM/Packages/Remove
- add javadoc comment
- removing @Override annotation from method that isn't overriden
- remove unnecessary cast

* Mon Jan 27 2014 Matej Kollar <mkollar@redhat.com> 2.1.133-1
- Unstyled Systems/Software/Channels
- Fixed unstyled form for XCCDF scaner on SSM and single system
- Fixed scattered form for Systems/Conf/AddFiles/CreateFile
- Fixed unstyled form: Systems/Software/Pkgs/Profiles/CreateNewProfile
- give search button an id
- Make sure that all form fields are correctly aligned
- Panels added in the html of ipranges.jspf
- re-organized the HTML to display the in-range inputs correctly

* Mon Jan 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.132-1
- Implement rhn:formatDate that uses moment.js on the client side. It supports
  also most of fmt:formatDate options.

* Mon Jan 27 2014 Tomas Lestach <tlestach@redhat.com> 2.1.131-1
- renumber taskomatic classpath entries

* Mon Jan 27 2014 Tomas Lestach <tlestach@redhat.com> 2.1.130-1
- enhance taskomatic link path to link hibernate-commons-annotations.jar on
  fc20

* Fri Jan 24 2014 Jan Dobes 2.1.129-1
- porting system group monitoring probes page to java

* Fri Jan 24 2014 Simon Lukasik <slukasik@redhat.com> 2.1.128-1
- 1057294 - Wrap choise by <c:choose>
- fix exceptions when user is deleted

* Thu Jan 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.127-1
- javadoc fix

* Wed Jan 22 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.126-1
- Removed an unused line that broke compilation

* Wed Jan 22 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.125-1
- checkstyle fix

* Wed Jan 22 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.124-1
- 1053591 - fix deadlock when cloning using spacewalk-clone-by-date

* Wed Jan 22 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.123-1
- Bugfix: ISE when cobbler components are missing (not installed)
- port reboot_confirm.pxt from perl to java
- SUSE Studio API will stop working via unencrypted HTTP
- Inconsistency in build vs. eclipse checkstyle.

* Wed Jan 22 2014 Tomas Lestach <tlestach@redhat.com> 2.1.122-1
- let taskomatic link commons-io
- fix CVE URL in updateinfo references
- 1009396 - escape system name for SystemRemoteCommand page

* Fri Jan 17 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.121-1
- increase column length for CVE ids

* Fri Jan 17 2014 Tomas Lestach <tlestach@redhat.com> 2.1.120-1
- fix checkstyle

* Thu Jan 16 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.119-1
- checkstyle fixes
- avoid reassigning parameters in StringUtil

* Thu Jan 16 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.118-1
- %%attr() mode not applicaple to symlink
- fixed conflict with apache-commons-validator
- resolve conflict between {apache,jakarta}-commons-cli on Fedora 20

* Thu Jan 16 2014 Tomas Lestach <tlestach@redhat.com> 2.1.117-1
- remove unused method
- create external authentication page
- removed unused import

* Wed Jan 15 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.116-1
- removed unused methods
- selectable doesn't work properly with ListRhnSetHelper
- select all / unselect all should not submit changes

* Wed Jan 15 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.115-1
- reuse BaseListAction for AdminListAction
- fixed added/removed keys logic
- select all / unselect all should not submit changes

* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.114-1
- bump java API version
- update LICENSE, allow Copyright (c) to start in 2013
- removing @Override annotation from method that isn't overriden
- KickstartDetailsEdit.do formatting broken since dac19190
- Updating the copyright years info
- fix LoginSetupActionTest
- add missing strings + clean old one

* Fri Jan 10 2014 Tomas Lestach <tlestach@redhat.com> 2.1.113-1
- fix PxtAuthenticationServiceTest
- Protected field in final class makes no sense
- Avoiding instantiating Boolean objects
- Eliminate unused private fields

* Fri Jan 10 2014 Tomas Lestach <tlestach@redhat.com> 2.1.112-1
- 1013712 - return server action message within schedule.listInProgressSystems
  and schedule.listCompletedSystems API calls
- fix linking of hibernate-commons-annotations
- ant-nodpes is buildrequired on rhels
- differentiate between apache- and jakarta- buildrequires on fedora and rhel
- buildrequire mvn(ant-contrib:ant-contrib) on fc20
- build/require javapackages-tools on fc20

* Fri Jan 10 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.111-1
- 1051230 - fixed icon name
- String.indexOf(char) is faster than String.indexOf(String).
- fix RequestContextTest.testGetLoggedInUser unit test
- fix LoginActionTest.testPerformValidUsername unit test
- Rewrite groups/systems_affected_by_errata.pxt to java

* Tue Jan 07 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.110-1
- .project file was not accidentally committed
- there's not ant-nodeps on fc20

* Mon Jan 06 2014 Tomas Lestach <tlestach@redhat.com> 2.1.109-1
- 1048090 - Revert "add package ID to array returned by system.listPackages API
  call"

* Fri Jan 03 2014 Tomas Lestach <tlestach@redhat.com> 2.1.108-1
- store url_bounce and request_method to session and re-use common login parts
- support logins using Kerberos ticket
- 1044547 - adding newlines as needed

* Mon Dec 23 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.107-1
- Remove extraneous character from query
- Fix action type
- fix icon name
- Use new rhn:icon internationalization/localization
- Perform localization inside rhn:icon tag

* Thu Dec 19 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.106-1
- updated references to new java WorkWithGroup page
- work_with_group.pxt rewritten to java
- change order of system ok/warn/crit in legends
- rewrite system event history page to java
- give icons title in rhn:toolbar tag

* Wed Dec 18 2013 Stephen Herr <sherr@redhat.com> 2.1.105-1
- 1044547 - kickstarts to RHEL 7 don't work because of missing rpms

* Wed Dec 18 2013 Stephen Herr <sherr@redhat.com> 2.1.104-1
- 1039193 - fix checkstyle

* Wed Dec 18 2013 Stephen Herr <sherr@redhat.com> 2.1.103-1
- 1039193 - fixing null pointer exception
- fix package according to the fs path
- fix CSVTag so it uses IconTag
- fix ListDisplayTag so it uses IconTag
- removing dead code, exception is thrown within lookupAndBindServerGroup
- removing dead code, exception is thrown within lookupAndBindServerGroup

* Tue Dec 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.102-1
- delete ConfigSystemTag as these things are easily handled in jsp
- Local variables need not to be synchronized

* Tue Dec 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.101-1
- updated links to system group delete page
- converted system group > delete page from pxt to java
- bootstrap tuning: fixed icons
- rework logic of ConfigFileTag so it uses icons instead of gifs and cool stuff
- fixing references to SSM errata page

* Mon Dec 16 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.100-1
- more icon fixes
- Rewrite of errata_list.pxt to Java
- call ssm check on system - software crashes, notes, migrate and hardware pages
- bootstrap fixes

* Fri Dec 13 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.99-1
- replaced icons with icon tag
- simplify logic in cfg:channel tag

* Thu Dec 12 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.98-1
- replaced icons with icon tag
- system group edit properties - linking + cleanup
- alter system group create page to do editing
- use rhn:toolbar tag instead of creating html inside .jsp + unify icons
- fix icons on config file details page
- icon for file download
- unify configuration management icons

* Wed Dec 11 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.97-1
- use new icon aliases in more places

* Wed Dec 11 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.96-1
- allow channel administrator to view Channel > Managers page

* Wed Dec 11 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.95-1
- 1040540 - have package search return all matching results
- use rhn:toolbar in 'Show Tomcat Logs' page

* Wed Dec 11 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.94-1
- use new icon aliases in rhn:toolbar tag
- adding new icon definitions
- adding rhn taglib as it's needed by rhn:icon
- use rhn:icon tag for creating icons in rhn:toolbar

* Tue Dec 10 2013 Stephen Herr <sherr@redhat.com> 2.1.93-1
- 1039193 - Increase default ram to 768 for RHEL 7

* Tue Dec 10 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.92-1
- bootstrap tuning: use new icon tag
- use static code for icons map in IconTag + typo and documentation fix
- System Group / Admins - updated links and removed old page
- ported System Group / Admins to java
- bootstrap tuning: icon tag for simpler icon inserting

* Mon Dec 09 2013 Jan Dobes 2.1.91-1
- system group details - linking + cleanup
- converting system group details page to java
- LoginExpiredTest fixed
- VirtualizationEntitlementTestCase: dead code removed
- LoginExpiredSatTestCase: rename to respect test convention
- removed trailing whitespaces from jsp{,f} sources

* Wed Dec 04 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.90-1
- bootstrap tuning

* Wed Dec 04 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.89-1
- bootstrap tuning

* Tue Dec 03 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.88-1
- bootstrap tuning
- Optionally show a legal note on login/relogin

* Tue Dec 03 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.87-1
- bootstrap tuning
- enable setting nobase and ignoremissing for
  kickstart.profile.setAdvancedOptions API

* Tue Dec 03 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.86-1
- bootstrap tuning
- Add a missing translation string: system.entitle.guestcantvirt

* Fri Nov 29 2013 Tomas Lestach <tlestach@redhat.com> 2.1.85-1
- 1034851 - fix SSM child channel membership changes

* Fri Nov 29 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.84-1
- Allow UTF-8 in config file
- Reformat so less unnecessary whitespace gets to output

* Fri Nov 29 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.83-1
- 1035429 - make package search of a specific architecture faster
- HTML 5 does allow "_new" as a valid target

* Thu Nov 28 2013 Tomas Lestach <tlestach@redhat.com> 2.1.82-1
- 1010205 - fix displaying of reposync log on WebUI
- bootstrap tuning: make non-link text in header more visible
- bootstrap tuning - add value parameter to make certain list actions work
- bootstrap tuning - use same icon for 'no updates' as in legend and other
  places

* Wed Nov 27 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.81-1
- bootstrap tuning - organization in head is not a link
- bootstrap tuning - use bootstrap style for "locked" icon
- bootstrap tuning - color icons in SystemList like mentioned in legend

* Thu Nov 21 2013 Jan Dobes 2.1.80-1
- 1009875 - changing order of operations
- 1021923 - allow deletion link on
  /rhn/systems/provisioning/preservation/PreservationListEdit.do
- replace UTF-8 space with normal space

* Tue Nov 19 2013 Tomas Lestach <tlestach@redhat.com> 2.1.79-1
- 1001018 - escape kickstart script name on
  /rhn/kickstart/KickstartScriptDelete.do page

* Tue Nov 19 2013 Tomas Lestach <tlestach@redhat.com> 2.1.78-1
- 1001018 - escape kickstart script name on /rhn/kickstart/Scripts.do page
- 1020497 - one /kickstart/Scripts action path is enough

* Tue Nov 19 2013 Tomas Lestach <tlestach@redhat.com> 2.1.77-1
-  replace Red Hat Satellite with @@PRODUCT_NAME@@
- 1021934 - do not save duplicate filenames
- 1030546 - throw an exception in case there are no systems or errata specified
- 1030546 - throw an exception in case there are no packages to remove
- 1030546 - throw an exception in case there are no packages to install
- 1030628 - fix ISE, when sorting according to the 'Registered by' column

* Mon Nov 18 2013 Tomas Lestach <tlestach@redhat.com> 2.1.76-1
- replace 'Channel Managemet Guide' docs with 'User Guide' and 'Getting Started
  Guide'

* Fri Nov 15 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.75-1
- polishing changelog

* Fri Nov 15 2013 Matej Kollar <mkollar@redhat.com> 2.1.74-1
- Fix ISE when deleting a non persistent custom info value
- Replaced deprecated Priority.WARN with suggested Level.WARN
- Removing deprecated and unused classes
- Removing use of now deprecated CharacterMap
- Explicitly marking as deprecated

* Thu Nov 14 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.73-1
- Bootstrap 3.0 changes, brand new WebUI look

* Tue Nov 12 2013 Tomas Lestach <tlestach@redhat.com> 2.1.72-1
- CVE-2013-4480 - restrict user creation to org_admin only
- CVE-2013-4480 - restrict first user creation with need_first_user acl

* Tue Nov 12 2013 Tomas Lestach <tlestach@redhat.com> 2.1.71-1
- 1029066 - enhance Package.listOrphans query
- TestFactoryWrapperTest: avoid adding TestImpl.hbm.xml twice
- RhnServletListener: do not break subsequent testcases

* Mon Nov 11 2013 Tomas Lestach <tlestach@redhat.com> 2.1.70-1
- fix $Serializer macro expansion in API doc

* Mon Nov 11 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.69-1
- reuse rhnServerNeededCache for errataqueue_find_autoupdate_servers
- reuse rhnServerNeededCache content for ErrataMailer
- removed redundant insertNeededPackageCache()
- Prevent [available] deprecation message
- 1021552 - point to channel architecture listing API in
  channel.software.create APIs

* Thu Nov 07 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.68-1
- 1027050 - optimized system_config_files_with_diffs eleborator for PostgreSQL
- 1027454 - fix ISE, when renaming channel to channel name already in use

* Wed Nov 06 2013 Tomas Lestach <tlestach@redhat.com> 2.1.67-1
- ConfigTest: do not rely on hardcoded paths, preexisting files
- Use kickstart icon on the snippets page

* Wed Nov 06 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.66-1
- 1024395 - modified query to work better with PostgreSQL 8.4 optimizer
- Reorder snippet tabs
- Broken link in SSM index fixed
- 1025626 - Prevent NPE with system.getDetails() API call for virtual systems
  with no virtualization type

* Mon Nov 04 2013 Tomas Lestach <tlestach@redhat.com> 2.1.65-1
- 1023482 - spped up /rhn/channels/manage/errata/AddRedHatErrata.do page
- Fix navigation for the default snippets page
- removing unnecessary casts

* Mon Nov 04 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.64-1
- 1022279 - modified query to work better with PostgreSQL 8.4 optimizer
- 1022279 - added hints for PostgreSQL 8.4 optimizer

* Thu Oct 31 2013 Matej Kollar <mkollar@redhat.com> 2.1.63-1
- 1020952 - Single db root cert + option name change
- Checkstyle fix, follow JSL for method modifiers
- 1007521 - synchronize repo entries creation

* Thu Oct 24 2013 Tomas Lestach <tlestach@redhat.com> 2.1.62-1
- 1011856 - detect max lengths at repo creation
- 1020952 - SSL for Postgresql: Java (WebUI, Tascomatic)
- Removed redundant code from SchedulerKernel
- Removed redundant code from ConnectionManager
- Put JDBC connect string creation into ConfigDefaults
- Removed unchecked conversion
- 1013672 - let errata.getDetails API return errata id

* Thu Oct 24 2013 Jan Dobes 2.1.61-1
- 1015747 - resources
- 1015747 - page handling
- 1015747 - new jsp page + nav stuff

* Wed Oct 23 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.60-1
- added messages for SystemRemoteCommandAction.java
- reformated xliff file using xmllint
- using @@PRODUCT_NAME@@ instead of Spacewalk
- api doc fix

* Tue Oct 22 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.59-1
- add support for enhances rpm weak dependency (java) (bnc#846436)

* Fri Oct 18 2013 Stephen Herr <sherr@redhat.com> 2.1.58-1
- 1020497 - fixing a bug and adding a unit test for ordering kickstarts
- Cobbler tests: added missing return
- Update ScriptSetupActionTest for new attribute name

* Thu Oct 17 2013 Stephen Herr <sherr@redhat.com> 2.1.57-1
- 1020497 - re-applying fix from 122418187 that got missed in the merge in
  c821c7ee2

* Thu Oct 17 2013 Stephen Herr <sherr@redhat.com> 2.1.56-1
- 1020497 - provide a way to order kickstart scripts

* Thu Oct 17 2013 Tomas Lestach <tlestach@redhat.com> 2.1.55-1
- 676828 - distinguish bash interpreter in ks non-chroot post scripts

* Mon Oct 14 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.54-1
- cleaning up old svn Ids

* Mon Oct 07 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.53-1
- 1012951 - Revert "removing unused string with trans-id 'file_lists.added'"
- 1012951 - Revert "removing unused string with trans-id 'file_lists.removed'"
- 1006127 - Make Search button translatable
- 1006182 - Make ISS Master and Slave tabs less confusing

* Wed Oct 02 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.52-1
- 1002590 - unified way how we call rhn-search cleanindex
- Serializers for Taskomatic: log serialization errors
- Added an Ivy dependency needed for tests

* Tue Oct 01 2013 Grant Gainey <ggainey@redhat.com> 2.1.51-1
- Refactoring that lets us log serialization errors * Added
  RhnXmlRpcCustomSerializer base class * Refactored all Serializers to extend
  from RhnXmlRpcCustomSerializer * Refactored SerializerFactory to be
  less...clever

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.50-1
- removed trailing whitespaces

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.49-1
- UserManagerTest: fix new timezone ordering
- Orphaned class PushDispatcher removed
- DataSourceParserTest: fix Oracle case-depentent tests
- UserFactory: fix time zone ordering
- 1012660 - somehow I missed one

* Thu Sep 26 2013 Stephen Herr <sherr@redhat.com> 2.1.48-1
- 1012660 - move links for Channel Management Guide to correct places
- Add exception stack trace logging in Taskomatic

* Mon Sep 23 2013 Tomas Lestach <tlestach@redhat.com> 2.1.47-1
- fixing checkstyle

* Mon Sep 23 2013 Tomas Lestach <tlestach@redhat.com> 2.1.46-1
- 711373 - provide ftp link only for RHEL5 packages

* Thu Sep 19 2013 Simon Lukasik <slukasik@redhat.com> 2.1.45-1
- 1009652 - Render empty SCAP results correctly
- Fixing spelling mistakes
- 1009396 -  escaping server name for software crashes with identical UUID

* Wed Sep 18 2013 Tomas Lestach <tlestach@redhat.com> 2.1.44-1
- updated UI strings pulled from zanata
- 1007998 - fix activation key selection
- 1009019 - mentioning entitlement labels in apidoc
- 820225 - remove and recount entitlements before we remove guest associations
- 910739 - fix systemgroup.scheduleApplyErrataToActive API doc

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.43-1
- Grammar error occurred
- 1008687 - Fixing unlocalized strings in Manage Software Channels tab
- 1006630 - Making "Update" button translated
- 1008649 - Fixing unlocalized words
- 1008631 - fixing untranslatable strings

* Mon Sep 16 2013 Tomas Lestach <tlestach@redhat.com> 2.1.42-1
- Workaround bug in MockHttpServletRequest - asking for a param that doesn't
  exist shouldn't assert()
- VirtualGuestsActionTest: do not rely ontranslation messages
- ProvisionVirtualizationWizardActionTest:preconditions
- SystemEntitlementsSetupActionTest: do not assume Org has virtualization
  entitlement
- Add support for uploaded files in mockedrequests, fix
  CryptoKeyCreateActionTest
- OrgSoftwareSubscriptionsActionTest: always create test channel families
- MethodsSetupActionTest: do not assume that method command exists
- KickstartScriptActionTest: missingparameters added
- junit tests: some logging cleanups
- Make taskomatic maxmemory configurable in rhn.conf
- TestUtils: use the same temporaryfilename for the same file
- junit tests: do not rely on Cobbler
- VirtualGuestsActionTest: do not rely on query string parameter ordering
- OrgHandlerTest: don't depend on a channel family with free entitlement slots
- ActivationKeyHandlerTest: expect correct exceptions
- AuthFilterTest: mocked request object updated
- MasterHandlerTest: handlegetDefaultMaster exceptions
- DownloadActionTest: do not assume file tobe downloaded exists
- Frontend monitoring tests: ensure aMonitoring Scout exists
- RequestContext.buildPageLink: forceparameter ordering
- 580995 - typo fix + clarify meaning
- Cleaning up more Junits

* Tue Sep 10 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.41-1
- 580995 - updating api doc

* Tue Sep 10 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.40-1
- updated UI strings pulled from zanata
- 1006157 - translate submit button
- 1005771 - fixed macro name
- 1005771 - improved build time check for @@PRODUCT_NAME@@ macro

* Tue Sep 10 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.39-1
- Teach XmlRpcServletTest about setting up for logging
- Remove unnecessary commit from ProfileManagerTest
- VirtualizationEntitlementsManagerTest fixes
- rhn.manager tests: do not assume an Orgadmin exists
- Remove QuartzTest
- UserManagerTest: don't rely on hardcodeddefault time zone
- ConfigureSatelliteCommandTest: do not rely on HashMap key ordering
- MonitoringManagerTest: missingsuper.setUp() call added
- UpdateErrataCacheCommand: log an error when orgId is incorrect
- AdvDataSourceTest: do not rely on testexecution order
- ChannelTest: do not assume a proxy channel family exists
- More JUnit cleanup
- Missed a file for preceding patch
- Fix more tests to not rely on data already being in the DB when executed
- Always call super.setUp()
- If countServersInQueue() is passed a null-org, don't blow up please
- Remove empty tests, and disable test that takes ~8min alone but ~120ms
  running directly
- At Junit setUp(), if there's a xaction error, try rolling back previous
  xaction and retrying
- Fix bugs in a few junits
- Avoid a possible issue on concurrent updates to an RhnSet

* Fri Sep 06 2013 Tomas Lestach <tlestach@redhat.com> 2.1.38-1
- 973848 - store a key only if a file to upload is specified
- 973848 - file upload isn't required on /rhn/keys/CryptoKeyEdit.do page
- 973848 - correct an error message
- 973848 - define "type" string
- 973848 - fix error messaging for GPG nad SSL key creation/edit
- fix channel.software.setDetails APIdoc
- fix channel.software.listErrata APIdoc

* Fri Sep 06 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.37-1
- updated UI strings
- 1003896 - setup the form even in case of validation failure
- 998951 - fix configchannel.getEncodedFileRevision API doc

* Wed Sep 04 2013 Grant Gainey <ggainey@redhat.com> 2.1.36-1
- 1004547 - fixed API doc for some ISS calls
- 1003565 - packages.getPackage returns a binary object, not a base64 encoded
  package
- making OrgChannelFamily serializable

* Tue Sep 03 2013 Jan Dobes 2.1.35-1
- 976136 - unsubsribe from all channels before migration
- Unnecessary fully qualified names.
- 1001922 - set correct menu for reboot_confirm.pxt
- fix Remote Command page acl
- display 'Remote Command' menu item only if the system has the
  ftr_remote_command capability
- Broken null check

* Mon Sep 02 2013 Tomas Lestach <tlestach@redhat.com> 2.1.34-1
- 822289 - do not offer compatible child channel if not unique (when changing
  base channel)

* Mon Sep 02 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.33-1
- common.db.datasource tests: get database username from configuration file
- 906315 - Links in API documentation
- 1002912 - fix Systems Subscribed column on the
  /rhn/channels/software/Entitlements.do page
- fix checkstyle issue
- 1002590 - fix advice how to regenerate search index

* Fri Aug 30 2013 Tomas Lestach <tlestach@redhat.com> 2.1.32-1
- 1002316 - Cloning API generates ISE if no summary

* Thu Aug 29 2013 Tomas Lestach <tlestach@redhat.com> 2.1.31-1
- 855845 - escaping server name for ssm package verify
- 855845 - escaping server name for ssm package upgrade
- 855845 - escaping server name for ssm package removal
- 855845 - escaping server name for ssm package list
- 855845 - escaping server name for
  /rhn/systems/details/packages/profiles/ShowProfiles.do
- 1001826 - fix the API error msg
- Using Map instead of HashMap where possible

* Thu Aug 29 2013 Tomas Lestach <tlestach@redhat.com> 2.1.30-1
- 1002183 - allow trusted orgs to list out subscribed systems to shared
  channels
- 1002308 - Cloning a channel via API fails
- UserFactoryTest: avoid failure if there are no users

* Wed Aug 28 2013 Tomas Lestach <tlestach@redhat.com> 2.1.29-1
- add additional check for cases, when pam is disabled
- Fix javascript "Uncaught TypeError"
- 1001826 - fixing the java code as well
- 1001551 - fix kickstart repositories selection
- 998944 - fix package removal via ssm
- removing @Override annotation from methods that aren't overriden
- removing @Override annotation from method that isn't overriden
- remove unnecessary cast

* Fri Aug 23 2013 Tomas Lestach <tlestach@redhat.com> 2.1.28-1
- 989275 - fix ISE when changing base channel with korean locale prefs
- 993047 - adding missing space after dot in translation strings
- 993047 - throw correct exception if activation key already exists

* Fri Aug 23 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.27-1
- Perl to JSP port: Single system Remote Command

* Fri Aug 23 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.26-1
- removing redundant call
- Perl to JSP port: SSM/Errata
- 999948 - fix broken equals method

* Thu Aug 22 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.25-1
- removing @Override annotation from method that isn't overriden
- SSM/Misc/Reboot: Standard system list, optimized action
- Allow Hibernate to distinguish packages with identical name,
- 998961 - do not touch the DB after a hibernate exception but correctly close
  the session

* Wed Aug 21 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.24-1
- updating links to new java page
- removing @Override annotation from method that isn't overriden
- fix checkstyle, C style for loop and ISE with no base channel
- Perl to JSP port: SSM/Misc/Reboot
- add arch to package listings on /rhn/errata/manage/AddPackages.do page
- fix checkstyle
- Avoid testing callMethod on multiple qualifying methods

* Tue Aug 20 2013 Tomas Lestach <tlestach@redhat.com> 2.1.23-1
- Allow users to change the CSV separator

* Tue Aug 20 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.22-1
- simplify activation key management
- provide a link to real run remote command page in ssm

* Tue Aug 20 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.21-1
- link to java page instead of perl one
- removing obsolete method and some trailing whitespaces
- Perl to JSP port: SSM/Provisioning/RemoteCommand
- Consintency {less,more}\ than semantics.
- Fix ABRT API documentation
- 998052 - evaluation of localizing strings in jsp works in an another way
- 997868 - fix sync.master.addToMaster APIdoc inconsistency

* Mon Aug 19 2013 Tomas Lestach <tlestach@redhat.com> 2.1.20-1
- 711373 - navigate to missing debuginfo package
- 997809 - make unavailable packages non-clickable
- 713684 - fix localization of jsp parameters
- 996924 - Throw an appropriate error if kickstart script name is too long
- Revert "Make callMethod() and invokeStaticMethod() deterministic when
  multiple methods qualify for calling"
- do not limit channel packages by signature in WebUI
- do not print name twice for unlocked systems

* Thu Aug 15 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.19-1
- fix legend and image title on new ssm lock/unlock page
- Ported from Perl to JPS locking and unlocking page, combining to one.
- Accept SUSE copyright.
- LocalizationServiceTest: run on JDKs without fix for bug 6609737

* Wed Aug 14 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.18-1
- Make callMethod() and invokeStaticMethod() deterministic when multiple
  methods qualify for calling

* Wed Aug 14 2013 Dimitar Yordanov <dyordano@redhat.com> 2.1.17-1
- Add API call listPhysicalSystems

* Mon Aug 12 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.16-1
- serializable classes should contain serializable fields

* Thu Aug 08 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.15-1
- adding java.io.Seriazible to monitoring.Command class

* Wed Aug 07 2013 Tomas Lestach <tlestach@redhat.com> 2.1.14-1
- 993249 - fix org.org.listSystemEntitlements API doc
- fix typo
- removing unnecessarily nested else clause
- removing unnecessary cast

* Tue Aug 06 2013 Tomas Lestach <tlestach@redhat.com> 2.1.13-1
- Fix HTML not being escaped in package information
- 982354 - Show Scan's ID (xid) on scan's details page.
- Refactor: Use static-final instead of magic constant.
- 982354 - enable easy comparison between various SCAP scans.

* Mon Aug 05 2013 Grant Gainey <ggainey@redhat.com> 2.1.12-1
- 993419 - L10N fix, 'RHN Tools' isn't a product-name

* Mon Aug 05 2013 Simon Lukasik <slukasik@redhat.com> 2.1.11-1
- Trim line longer than 92 characters.

* Mon Aug 05 2013 Simon Lukasik <slukasik@redhat.com> 2.1.10-1
- Introduce API: org.setPolicyForScapResultDeletion()
- Introduce API: org.setPolicyForScapFileUpload()
- Introduce API: org.getPolicyForScapResultDeletion()
- Introduce API: org.getPolicyForScapFileUpload()
- Introduce API: system.scap.deleteXccdfScan()
- Export the 'deletable' property of TestResult through API.
- Branding clean-up of proxy stuff in java dir

* Wed Jul 31 2013 Simon Lukasik <slukasik@redhat.com> 2.1.9-1
- Refactor common columns to a fragment file.
- Handle non-existent files properly.
- Remove commented-out code, commited by accident.
- Do not delete content of the directory which you cannot list
- Make sure to not iterate through null.
- Reconcile the set of scans with existing scans after deletion
- Allow deletion of a single scan from its details page
- Use the red tint if none has been deleted.
- Allow XccdfTestResult objects to be deleted.
- Deletion of multiple XCCDF Scans.
- Allow for scans at the System's scans listing page to be selected
- Prepare model for deletion of a SCAP Result
- Indent organization configuration dialog to clarify semantics of checkboxes.
- Allow for scap_retention_period to be set through webui.
- Close table cell more properly.
- Correct typo in documentation.

* Mon Jul 29 2013 Stephen Herr <sherr@redhat.com> 2.1.8-1
- 989630 - Allow user to hackisly add their own keys during the kickstart

* Thu Jul 25 2013 Grant Gainey <ggainey@redhat.com> 2.1.7-1
- 987977 - Fix there-can-be-solaris issue and make Upgrade behave like
  everything else

* Wed Jul 24 2013 Grant Gainey <ggainey@redhat.com> 2.1.6-1
- Make checkstyle happy
- 987977 - Fix chaining of pkg-scheduling in SSM

* Tue Jul 23 2013 Dimitar Yordanov <dyordano@redhat.com> 2.1.5-1
- new api call updateRepoLabel(key, label, new_label

* Mon Jul 22 2013 Tomas Lestach <tlestach@redhat.com> 2.1.4-1
- 986527 - removing extra semicolon

* Mon Jul 22 2013 Jan Dobes 2.1.3-1
- prevent ISE when UUID and host ID is null
- ISS: Return LookupException to getDefaultMaster() if there isn't one

* Fri Jul 19 2013 Stephen Herr <sherr@redhat.com> 2.1.2-1
- 986335 - explicitly require libxml2 for kickstarts to avoid error
- 986299 - use empty_message_key instead of empty_message

* Thu Jul 18 2013 Grant Gainey 2.1.1-1
- JUnit fixes
- Bumping package versions for 2.1.

