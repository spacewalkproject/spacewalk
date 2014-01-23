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
%if 0%{?fedora}
%define appdir          %{_localstatedir}/lib/tomcat/webapps
%define jardir          %{_localstatedir}/lib/tomcat/webapps/rhn/WEB-INF/lib
%else
%define appdir          %{_localstatedir}/lib/tomcat6/webapps
%define jardir          %{_localstatedir}/lib/tomcat6/webapps/rhn/WEB-INF/lib
%endif
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
Version: 2.1.127
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
Requires: c3p0 >= 0.9.1
Requires: dwr >= 3
%if 0%{?fedora}
Requires: hibernate3 >= 3.6.10
Requires: hibernate3-c3p0 >= 3.6.10
Requires: hibernate3-ehcache >= 3.6.10
Requires: javassist
%else
Requires: hibernate3 = 0:3.2.4
%endif
Requires: java >= 1:1.6.0
Requires: java-devel >= 1:1.6.0
Requires: jakarta-commons-lang >= 0:2.1
Requires: jakarta-commons-codec
Requires: jakarta-commons-discovery
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
%if 0%{?fedora}
Requires: tomcat >= 7
Requires: tomcat-lib >= 7
Requires: tomcat-servlet-3.0-api >= 7
Requires: struts >= 0:1.3.0
Requires: struts-taglib >= 0:1.3.0
%else
Requires: tomcat6
Requires: tomcat6-lib
Requires: tomcat6-servlet-2.5-api
Requires: struts >= 0:1.3.0
Requires: struts-taglib >= 0:1.3.0
%endif
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
%if 0%{?fedora} >= 20
BuildRequires: apache-commons-validator
BuildRequires: mvn(ant-contrib:ant-contrib)
BuildRequires: javapackages-tools
Requires:      javapackages-tools
%else
BuildRequires: jakarta-commons-validator
BuildRequires: ant-contrib
BuildRequires: ant-nodeps
BuildRequires: jpackage-utils
Requires:      jpackage-utils
%endif
Requires: cobbler >= 2.0.0
Requires: dojo
%if 0%{?fedora}
Requires:       apache-commons-io
BuildRequires:  apache-commons-logging
Requires:       apache-commons-logging
%else
Requires:       jakarta-commons-io
BuildRequires:  jakarta-commons-logging
Requires:       jakarta-commons-logging
%endif
BuildRequires: ant
BuildRequires: ant-apache-regexp
BuildRequires: java-devel >= 1:1.6.0
BuildRequires: ant-junit
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
%if ! 0%{?omit_tests} > 0
BuildRequires: translate-toolkit
%endif

# Sadly I need these to symlink the jars properly.
BuildRequires: bcel
BuildRequires: c3p0 >= 0.9.1
BuildRequires: concurrent
BuildRequires: cglib
BuildRequires: dom4j
BuildRequires: dwr >= 3
%if 0%{?fedora}
BuildRequires: hibernate3 >= 0:3.6.10
BuildRequires: hibernate3-c3p0 >= 3.6.10
BuildRequires: hibernate3-ehcache >= 3.6.10
BuildRequires: ehcache-core
BuildRequires: javassist
%else
BuildRequires: hibernate3 = 0:3.2.4
%endif
BuildRequires: jaf
BuildRequires: jakarta-commons-codec
BuildRequires: jakarta-commons-collections
BuildRequires: jakarta-commons-discovery
BuildRequires: jakarta-commons-el
BuildRequires: jakarta-commons-fileupload
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
%if 0%{?fedora}
BuildRequires: struts >= 0:1.3.0
BuildRequires: struts-taglib >= 0:1.3.0
BuildRequires: tomcat >= 7
BuildRequires: tomcat-lib >= 7
%else
BuildRequires: struts >= 0:1.3.0
BuildRequires: struts-taglib >= 0:1.3.0
BuildRequires: tomcat6
BuildRequires: tomcat6-lib
%endif
%endif
BuildRequires: sitemesh
BuildRequires: postgresql-jdbc
%if 0%{?fedora}
# spelling checker is only for Fedoras (no aspell in RHEL6)
BuildRequires: aspell aspell-en libxslt
Requires:      apache-commons-cli
BuildRequires: apache-commons-cli
BuildRequires: apache-commons-io
%else
Requires:      jakarta-commons-cli
BuildRequires: jakarta-commons-cli
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
Requires: /usr/bin/sudo

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
%if 0%{?fedora}
Requires: tomcat >= 7
%else
Requires: tomcat6
%endif
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
%if 0%{?fedora}
Requires: tomcat >= 7
%else
Requires: tomcat6
%endif
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
Requires: c3p0 >= 0.9.1
%if 0%{?fedora}
Requires: hibernate3 >= 3.6.10
Requires: hibernate3-c3p0 >= 3.6.10
Requires: hibernate3-ehcache >= 3.6.10
Requires: javassist
%else
Requires: hibernate3 >= 0:3.2.4
%endif
Requires: java >= 0:1.6.0
Requires: java-devel >= 0:1.6.0
Requires: jakarta-commons-lang >= 0:2.1
Requires: jakarta-commons-codec
Requires: jakarta-commons-dbcp
%if 0%{?fedora}
Requires: apache-commons-cli
Requires: apache-commons-logging
%else
Requires: jakarta-commons-cli
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

%if 0%{?fedora} && 0%{?fedora} >= 19
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

%install
rm -rf $RPM_BUILD_ROOT
%if 0%{?fedora} && 0%{?fedora} < 18
mkdir -p $RPM_BUILD_ROOT%{_javadir}/hibernate3
ln -s -f %{_javadir}/hibernate3/hibernate-core.jar $RPM_BUILD_ROOT%{_javadir}/hibernate3/hibernate-core-3.jar
ln -s -f %{_javadir}/hibernate3/hibernate-c3p0.jar $RPM_BUILD_ROOT%{_javadir}/hibernate3/hibernate-c3p0-3.jar
ln -s -f %{_javadir}/hibernate3/hibernate-ehcache.jar $RPM_BUILD_ROOT%{_javadir}/hibernate3/hibernate-ehcache-3.jar
%endif

# on Fedora 19 some jars are named differently
%if 0%{?fedora} && 0%{?fedora} > 18
mkdir -p $RPM_BUILD_ROOT%{_javadir}
%if 0%{?fedora} < 20
ln -s -f %{_javadir}/apache-commons-validator.jar $RPM_BUILD_ROOT%{_javadir}/commons-validator.jar
%endif
ln -s -f %{_javadir}/mchange-commons-java.jar $RPM_BUILD_ROOT%{_javadir}/mchange-commons.jar
ln -s -f %{_javadir}/jboss-logging/jboss-logging.jar $RPM_BUILD_ROOT%{_javadir}/jboss-logging.jar
%endif

%if  0%{?rhel} && 0%{?rhel} < 6
ant -Dprefix=$RPM_BUILD_ROOT install-tomcat5
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/tomcat5/Catalina/localhost/
install -m 755 conf/rhn.xml $RPM_BUILD_ROOT%{_sysconfdir}/tomcat5/Catalina/localhost/rhn.xml
%else
%if 0%{?fedora}
ant -Dprefix=$RPM_BUILD_ROOT install-tomcat7
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/tomcat/Catalina/localhost/
install -m 755 conf/rhn.xml $RPM_BUILD_ROOT%{_sysconfdir}/tomcat/Catalina/localhost/rhn.xml
%else
ant -Dprefix=$RPM_BUILD_ROOT install-tomcat6
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/tomcat6/Catalina/localhost/
install -m 755 conf/rhn.xml $RPM_BUILD_ROOT%{_sysconfdir}/tomcat6/Catalina/localhost/rhn.xml
%endif
%endif

# check spelling errors in all resources for English if aspell installed
[ -x "$(which aspell)" ] && scripts/spelling/check_java.sh .. en_US

%if 0%{?fedora}
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
install -d -m 755 $RPM_BUILD_ROOT%{cobprofdir}
install -d -m 755 $RPM_BUILD_ROOT%{cobprofdirup}
install -d -m 755 $RPM_BUILD_ROOT%{cobprofdirwiz}
install -d -m 755 $RPM_BUILD_ROOT%{cobdirsnippets}
install -d -m 755 $RPM_BUILD_ROOT%{_var}/spacewalk/systemlogs

install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d
%if 0%{?fedora}
echo "hibernate.cache.region.factory_class=net.sf.ehcache.hibernate.SingletonEhCacheRegionFactory" >> conf/default/rhn_hibernate.conf
echo "wrapper.java.classpath.49=/usr/share/java/hibernate3/hibernate-core-3.jar
wrapper.java.classpath.61=/usr/share/java/hibernate3/hibernate-ehcache-3.jar
wrapper.java.classpath.62=/usr/share/java/hibernate3/hibernate-c3p0-3.jar
wrapper.java.classpath.63=/usr/share/java/hibernate/hibernate-commons-annotations.jar
wrapper.java.classpath.64=/usr/share/java/slf4j/api.jar
wrapper.java.classpath.65=/usr/share/java/jboss-logging.jar
wrapper.java.classpath.66=/usr/share/java/javassist.jar
wrapper.java.classpath.67=/usr/share/java/ehcache-core.jar
wrapper.java.classpath.68=/usr/share/java/hibernate-jpa-2.0-api.jar" >> conf/default/rhn_taskomatic_daemon.conf
%else
echo "hibernate.cache.provider_class=org.hibernate.cache.OSCacheProvider" >> conf/default/rhn_hibernate.conf
echo "wrapper.java.classpath.49=/usr/share/java/hibernate3.jar" >> conf/default/rhn_taskomatic_daemon.conf
%endif
install -m 644 conf/default/rhn_hibernate.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_hibernate.conf
install -m 644 conf/default/rhn_taskomatic_daemon.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
install -m 644 conf/default/rhn_org_quartz.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_org_quartz.conf
install -m 644 conf/rhn_java.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults
install -m 755 conf/logrotate/rhn_web_api $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/rhn_web_api
%if 0%{?fedora}
install -m 755 scripts/taskomatic $RPM_BUILD_ROOT%{_sbindir}
install -m 755 scripts/taskomatic.service $RPM_BUILD_ROOT%{_unitdir}
%else
install -m 755 scripts/taskomatic $RPM_BUILD_ROOT%{_initrddir}
%endif
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
ln -s -f %{_javadir}/dwr.jar $RPM_BUILD_ROOT%{jardir}/dwr.jar
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
rm -rf $RPM_BUILD_ROOT%{jardir}/tomcat*.jar
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
%{jardir}/dwr.jar
%{jardir}/hibernate3*
%if 0%{?fedora}
%{jardir}/ehcache-core.jar
%{jardir}/*_hibernate-commons-annotations.jar
%{jardir}/hibernate-jpa-2.0-api.jar
%{jardir}/javassist.jar
%{jardir}/slf4j_api.jar
%{jardir}/slf4j_log4j12.jar
%endif
%if 0%{?fedora} && 0%{?fedora} < 18
%{_javadir}/hibernate3/hibernate-core-3.jar
%{_javadir}/hibernate3/hibernate-c3p0-3.jar
%{_javadir}/hibernate3/hibernate-ehcache-3.jar
%endif
%if 0%{?fedora} && 0%{?fedora} > 18
%if 0%{?fedora} < 20
%{_javadir}/commons-validator.jar
%endif
%{_javadir}/mchange-commons.jar
%{_javadir}/jboss-logging.jar
%{jardir}/jboss-loggingjboss-logging.jar
%endif
%if 0%{?fedora} && 0%{?fedora} < 19
%{jardir}/jboss-logging.jar
%endif
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
%if 0%{?fedora}
%config(noreplace) %{_sysconfdir}/tomcat/Catalina/localhost/rhn.xml
%else
%config(noreplace) %{_sysconfdir}/tomcat6/Catalina/localhost/rhn.xml
%endif
%endif
%{realcobsnippetsdir}/spacewalk
%dir %attr(755, tomcat, root) %{_var}/spacewalk/systemlogs
%ghost %attr(644, tomcat, root) %{_var}/spacewalk/systemlogs/audit-review.log

%files -n spacewalk-taskomatic
%if 0%{?fedora}
%attr(755, root, root) %{_sbindir}/taskomatic
%attr(755, root, root) %{_unitdir}/taskomatic.service
%else
%attr(755, root, root) %{_initrddir}/taskomatic
%endif
%{_bindir}/taskomaticd
%{_datadir}/rhn/lib/spacewalk-asm.jar


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

* Thu Jul 18 2013 Tomas Lestach <tlestach@redhat.com> 2.0.2-1
- 855845 - escaping system name on /rhn/systems/customdata/UpdateCustomKey.do
- 865595 - specify custom info searchability more precisely

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Wed Jul 17 2013 Tomas Lestach <tlestach@redhat.com> 1.10.138-1
- bump API version
- 910739 - let systemgroup.scheduleApplyErrataToActive API return action id
- 910739 - let system.scheduleSyncPackagesWithSystem API return action id
- 910739 - let system.scheduleReboot API return action id
- 857635 - API call setChildChannels should produce snapshot
- 857635 - take snapshot after change og base channel and not before

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.137-1
- updating copyright years

* Tue Jul 16 2013 Grant Gainey <ggainey@redhat.com> 1.10.136-1
- 985070 - Fix NPE when OSCAP results don't have associated files
- 857635 - changing of base channel via API should produce snapshot

* Tue Jul 16 2013 Tomas Lestach <tlestach@redhat.com> 1.10.135-1
- enable deleting servers via API

* Tue Jul 16 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.134-1
- fixing unit test to reflect dead code removal

* Tue Jul 16 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.133-1
- removing some dead code

* Tue Jul 16 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.132-1
- better to check if iterator hasNext() before we request next()

* Mon Jul 15 2013 Stephen Herr <sherr@redhat.com> 1.10.131-1
- 979402 - Fixing traceback in logs on warning page
- 910739 - let system.scheduleHardwareRefresh API return action id
- 910739 - checkstyle fixes
- using @@PRODUCT_NAME@@ macro in one more place
- 910739 let system.scheduleApplyErrata API return list of action ids
- 910739 let system.schedulePackageInstall API return action id

* Mon Jul 15 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.130-1
- 980482 - store part of SystemSearchResult into session that is not available
  via elaboration

* Fri Jul 12 2013 Tomas Lestach <tlestach@redhat.com> 1.10.129-1
- java changes for 1st user creation
- Adding the logging autentication to the XMLRPC API.
- Adding the logging invocations to the java WebUI stack.

* Fri Jul 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.128-1
- fixing checkstyle
- Fix indentation on user preferences page
- Don't commit chgs that only work with local configurations
- Tweaks to fix JUnits
- Fix hole identified by JUnit failure

* Thu Jul 11 2013 Grant Gainey <ggainey@redhat.com> 1.10.127-1
- 977878 - Fix struts-junit, add note to master-ca-cert field
- Generate pre flag into the metadata
- satysfying checkstyle

* Thu Jul 11 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.126-1
- adding missing bracelet

* Thu Jul 11 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.125-1
- reducing taskomatic_channel_repodata_workers to 1

* Tue Jul 09 2013 Tomas Lestach <tlestach@redhat.com> 1.10.124-1
- simplify managers and managers_edit jsps

* Mon Jul 08 2013 Grant Gainey <ggainey@redhat.com> 1.10.123-1
- 977878 - Need to be able to create masters in order to set cert and default
         - Fixed some broken JSPs (esp in the presence of errors)
         - Added error checking
         - Added/fixed I18N keys
- 977878 - Rename MapOrgs to EditMaster, and related changes
- 977878 - UI for master cfg-options

* Mon Jul 08 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.122-1
- don't require jboss-logging.jar on rhel(s)

* Mon Jul 08 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.121-1
- import forgotten java.io.Serializable

* Mon Jul 08 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.120-1
- stop spamming taskomatic log with ehcache using defaults message
- stop spamming catalina.out with ehcache using defaults message
- making ActionType seriazible to prevent ehcache exceptions
- crating symlinks for taskomatic to work on fedora 19

* Mon Jul 08 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.119-1
- creating symlinks for tomcat on Fedora 19

* Thu Jul 04 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.118-1
- skip xliff checks for fedora 19

* Thu Jul 04 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.117-1
- build spacewalk-java on fedora19

* Thu Jul 04 2013 Tomas Lestach <tlestach@redhat.com> 1.10.116-1
- Avoid relying on types returned by Hibernate

* Thu Jul 04 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.115-1
- make dirs if they don't exist yet

* Thu Jul 04 2013 Tomas Lestach <tlestach@redhat.com> 1.10.114-1
- rewrite /network/software/channels/managers.pxt page to java

* Thu Jul 04 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.113-1
- making spacewalk-java build-able on fedora19
- 977878 - Support for is_current and ca_cert, DTO/Serializer/Handler

* Tue Jul 02 2013 Grant Gainey 1.10.112-1
- 977878 - Keep some unit-tests from overlapping

* Tue Jul 02 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.111-1
- checkstyle fix

* Tue Jul 02 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.110-1
- updating strings to use @@PRODUCT_NAME@@ macro
- 834214 - do not validate input when it's not needed

* Fri Jun 28 2013 Tomas Lestach <tlestach@redhat.com> 1.10.109-1
- mark unfinished taskomatic runs as INTERRUPTED
- messages get displayed within layout_c.jsp

* Thu Jun 27 2013 Grant Gainey 1.10.108-1
- 977878 - Clean up maps on local-org-removal

* Thu Jun 27 2013 Jan Dobes 1.10.107-1
- 514223 - catching invalid ip to prevent ISE
- removing @Override annotation from methods that aren't overriden
- removing unnecessarily nested else clause
- removing unnecessarily nested else clause
- removing unnecessary casts
- 976136 - we need unentitle channels before we delete them
- 912931 - move taskomatic bunch logs to /var/log instead of /var/lib

* Tue Jun 25 2013 Grant Gainey 1.10.106-1
- Fix checkstyle issues

* Tue Jun 25 2013 Grant Gainey 1.10.105-1
Feature: Support channel-permissions on ISS
- ISS: Fix inappropriate cascade when deleting a Slave
- ISS: fix bad I18N key
- ISS: Add sync.slave.getSlaveByName API
- ISS: Missed slave.jsp centering
- ISS: Correctly center columns
- ISS: Correctly separate allow-all from allowed-org-list
- ISS: Fix navigation weirdness, add messaging and L10N
- ISS: Fix minor UI ordering weirdness
- ISS: Add num-orgs-allowed-to per slave on master.jsp
- ISS: Add IssSlave API calls      Fix slave-to-allowed-orgs mapping
- ISS: Naming nitpick: It's one IssMasterOrg, not several
- ISS: XMLRPC doesn't recognize Long      XMLRPC wants Map input, not Objects
  Set up serializers and register them      Fix Hibernate collection-mapping
  smeantics so they, like, work
- ISS: Add XMLRPC API for Master side of ISS
- ISS: Naming is important - clean ours up so it makes more sense
- ISS: Remove test-class that should never have been committed
- ISS: Tweaks to L10N strings
- ISS: Fix incorrect L10N strings
- ISS: I18N updates
- ISS: Fix rmv-master and cascades
- ISS: Map join-tables correctly so that delete works
- ISS master-to-slave org-mapping
- ISS: DRAFT #2: adelton's DB changes, affects on Java, slave-to-org-mapping
- ISS: DRAFT #2: adelton's DB changes, affects on Java, slave-to-org-mapping
- ISS: Fixes from review comments
- ISS: FIRST DRAFT: ISS Org-Sync UI work

* Tue Jun 25 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.104-1
- use real product name in strings instead of RHN
- 695638 - rewrite C style to java
- 973310 - adding last checkin field to Inactive systems
- minor branding cleanup
- 977301 - removing incorrect tag
- 687903 - fix of api doc
- 976371 - don't offer channels which system can't subscribe to

* Mon Jun 24 2013 Jan Dobes 1.10.103-1
- correcting ProfileHandlerTest to changed API
- 976722 - kickstart script name is required
- 976722 - creating exception for script name
- 976722 - adding eng resources

* Mon Jun 24 2013 Tomas Lestach <tlestach@redhat.com> 1.10.102-1
- 855845 - escaping system name for message.syncpackages message
- 855845 - escaping system name for
  /rhn/systems/details/packages/profiles/CompareSystems.do
- 855845 - escaping system name for
  /rhn/systems/details/configuration/DeployFileConfirm.do
- 855845 - escaping system name for /rhn/configuration/channel/TargetSystems.do
- 855845 - escaping system name on inactive-systems yourrhn pane
- fix (virt) system icons on system group pages

* Thu Jun 20 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.101-1
- Fix syntax. Sentences start with capital letter.
- 975083 - typo fix

* Tue Jun 18 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.100-1
- checkstyle fix

* Tue Jun 18 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.99-1
- patch to allow channel_admin to sync repos
- 968372 - changing virtualization compatibility check to work with api

* Tue Jun 18 2013 Dimitar Yordanov <dyordano@redhat.com> 1.10.98-1
- bz695638-Remove the proxy channels from the KS child channel

* Tue Jun 18 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.97-1
- 975232 - patch to add newline after writing kickstart_start var
- 974201 - marking label not required

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.96-1
- more branding cleanup
- rebranding few more strings

* Thu Jun 13 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.95-1
- 970072 - do not sort prepared data

* Wed Jun 12 2013 Jan Dobes 1.10.94-1
- 869247 - fixing elaborator

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.93-1
- rebranding RHN Proxy to Red Hat Proxy
- rebrading RHN Satellite to Red Hat Satellite

* Tue Jun 11 2013 Jan Dobes 1.10.92-1
- 970125 - adding unique value check
- 971828 - fixing wrong escaping of utf-8 strings

* Tue Jun 11 2013 Jan Dobes 1.10.91-1
- 913032 - we now remember sent errata email notifications to prevent multiple
  messages

* Mon Jun 10 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.90-1
- software crashes menu should be visible only for management entitled orgs
- 871276 - page for physical systems

* Mon Jun 03 2013 Jan Dobes 1.10.89-1
- checkstyle fix
- junit fixes
- fix more checkstyle issues in the java-create-page.pl
- minor changes to java-create-page.pl

* Thu May 30 2013 Tomas Lestach <tlestach@redhat.com> 1.10.88-1
- 855845 - escaping system name for
  /rhn/channel/ssm/ChildSubscriptionsConfirm.do
- 855845 - escaping system name for /rhn/channel/ssm/BaseChannelSubscribe.do

* Thu May 30 2013 Tomas Lestach <tlestach@redhat.com> 1.10.87-1
- 515003 - changing confirmprotected.jsp.confirmmsg.deux message
- making DataSourceParserTest work with PostgreSQL
- 516265 - sort parent channel pop-up menu by channel name
- 514288 - removing obsolete kickstart warning
- 512433 - grammatical typo

* Tue May 28 2013 Simon Lukasik <slukasik@redhat.com> 1.10.86-1
- SCAP file size limit shall be configurable through web interface
- Refactor: Rename variable: newLimit -> newCrashLimit

* Tue May 28 2013 Jan Dobes 1.10.85-1
- checkstyle fix

* Tue May 28 2013 Tomas Lestach <tlestach@redhat.com> 1.10.84-1
- 855845 - escaping system name for
  /rhn/systems/details/virtualization/VirtualGuestsList.do
- 855845 - escaping system name for
  /rhn/systems/entitlements/GuestLimitedHosts.do
- userlist.jsp isn't used for /users/SystemsAdmined.do page
- 855845 - escaping system name for /rhn/users/SystemsAdmined.do
- simplify the column message
- 855845 - escaping system name for /rhn/systems/details/audit/ScheduleXccdf.do
- junit tests postgresql fixes

* Tue May 28 2013 Tomas Lestach <tlestach@redhat.com> 1.10.83-1
- 967526 - on RHEL5 the (P)SQLException is wrapped into a RuntimeException

* Tue May 28 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.82-1
- 960885 - add list elaborator into session for CSV export

* Fri May 24 2013 Tomas Lestach <tlestach@redhat.com> 1.10.81-1
- 855845 - escaping system name for /rhn/systems/entitlements/FlexGuests.do
- 855845 - escaping system name for /rhn/systems/entitlements/PhysicalHosts.do
- 855845 - escaping system name for /rhn/systems/VirtualSystemsList.do
- 855845 - escaping system name for
  /rhn/systems/DuplicateSystemsDeleteConfirm.do
- 855845 - escaping system name for /rhn/systems/SystemCurrency.do
- 855845 - escaping system name for /rhn/systems/DuplicateIPList.do

* Fri May 24 2013 Tomas Lestach <tlestach@redhat.com> 1.10.80-1
- 855845 - escaping system name for
  /rhn/systems/details/configuration/DiffFileConfirm.do
- 855845 - escaping system name for
  /rhn/systems/details/configuration/DiffFile.do
- 855845 - escaping system name for
  /rhn/systems/details/configuration/addfiles/ImportFile.do
- 855845 - escaping system name for
  /rhn/systems/details/configuration/ViewModifySandboxPaths.do
- 855845 - escaping system name for
  /rhn/systems/details/configuration/ViewModifyCentralPaths.do
- 855845 - escaping system name for
  /rhn/systems/details/configuration/ConfigChannelList.do
- 855845 - escaping system name for
  /rhn/systems/details/packages/profiles/SyncSystems.do
- 855845 - escaping system name for /rhn/systems/details/packages/*.do pages
- 855845 - escaping system name for
  /rhn/systems/details/virtualization/ProvisionVirtualizationWizard.do
- 855845 - escaping system name for /rhn/monitoring/ProbeList.do
- 855845 - escaping system name for /rhn/systems/details/packages/Packages.do
- 855845 - escaping system name for /rhn/activationkeys/systems/List.do
- Open HTML Reports in a new window.
- Only non-HTML files shall be marked as an attachement.
- Exclude HTML file download from sitemesh.
- Downloaded files shall be logged in debug mode.
- Download of detailed SCAP result files.
- Godforsaken closing <tr> node.
- use xsd default message instead of custom one
- man pages branding cleanup + misc branding fixes

* Tue May 21 2013 Grant Gainey <ggainey@redhat.com> 1.10.79-1
- Provide way to build Eclipse .classpath even in the absence of required jars

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.78-1
- misc branding clean up
- branding clean-up of logrotate files
- 582510 - disable ks repos without available repodata
- form validation with xsd

* Mon May 20 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.77-1
- 959226 - too big value in system custom info should not cause ISE

* Fri May 17 2013 Tomas Lestach <tlestach@redhat.com> 1.10.76-1
- enhance (archived) actions deletion
- check for keywords length within the errataEditForm
- 580995 - enable reset of base channel for activation key via api
- 889633 - always set lastModifiedBy for custom infos
- removing trailing space

* Fri May 10 2013 Grant Gainey <ggainey@redhat.com> 1.10.75-1
- Save, *then* evict - Order Matters
- More user/org cleanup
- Compatible-channel rules chgd, chg the test. Also, cleanup user-creation
- For epoch, empty-string != null
- Call super first, not last
- 955590 - do not offer a symlink, if the user does not have acl for the target

* Tue May 07 2013 Tomas Lestach <tlestach@redhat.com> 1.10.74-1
- remove unused NoSuchPackageExceptionHandler
- do not throw xmlrpc exception within the WebUI context

* Mon May 06 2013 Tomas Lestach <tlestach@redhat.com> 1.10.73-1
- 924205 - enhance exception handling

* Sat May 04 2013 Grant Gainey <ggainey@redhat.com> 1.10.72-1
- A lot of JUnit cleanup
- Print stack trace in case of CSV failures.
- 958654 - Use different listSetName for the XccdfDetail page.
- Tweak create-page to know about StrutsDelegate
- logging pkg and errata search as INFO instead of WARN
- removing unnecessary cast

* Sat Apr 27 2013 Grant Gainey 1.10.71-1
- Abstract classes' names can't end in 'Test.java' or JUnit tries to execute
  them
- Checkstyle fixes
- Junit teting for errors that we don't even reach on Postgres
- Unit-test depends on specific contents of a jar.  It changed.  Sigh.
- Separate test from DB (and specifically from Oracle)
- With 07504b3d we stopped special-casing # in cfg-files - drop the tests

* Sat Apr 27 2013 Grant Gainey 1.10.70-1
- Fixing some minor query-data-type issues
- ActivationKeys cannot include both a base-channel and children of a
  different base
- Teach KickstartInstalltype that RHEL7 is coming
- Fixing a number of JUnit tests

* Fri Apr 26 2013 Tomas Lestach <tlestach@redhat.com> 1.10.69-1
- fix UserManagerTest.testGetTimeZoneDefault

* Fri Apr 26 2013 Grant Gainey 1.10.68-1
- Fix tests - adding a Network to test-servers has unintended consequences.
- commit flex conversions as they succeed

* Thu Apr 25 2013 Tomas Lestach <tlestach@redhat.com> 1.10.67-1
- fix bad bad debug remainder
- do not pass server list, if Long list is expected in
  ActionManagerTest.testScheduleSriptRun
- fix ListTagTest
- fix ScheduleRemovePackagesActionTest
- prevent NPE in SsmRemovePackagesAction
- we need a system in SSM for ChannelManagerTest.testListCompatibleBaseChannels
- let's make RestartData serializable

* Wed Apr 24 2013 Jan Dobes 1.10.66-1
- 952198 - added showing systems counts on cancel scheduled actions page
- removing dead code
- 952198 - changing action_list_elab to action_overview_elab to display counts
  of systems properly
- replace closing session with transaction rollback

* Wed Apr 24 2013 Tomas Lestach <tlestach@redhat.com> 1.10.65-1
- 956101 - removing extra semicolon
- drop useless order by
- commit channges, otherwise async UpdateErrataCacheActions won't find
  referenced objects in th DB
- every test server has one default network interface now
- switch MAC and IP args to match what's expected
- 928416 - display information message when filtering using older list tags
- update proxy.listAvailableProxyChannels API as we cannot transfer null via
  xmlrpc
- 955364 - remove caching for activation keys

* Mon Apr 22 2013 Tomas Lestach <tlestach@redhat.com> 1.10.64-1
- manually deregister drivers to prevent tomcat informing about possible memory
  leaks
- fix typo: RESRTICTED -> RESTRICTED
- let's make CachedStatement serializable

* Fri Apr 19 2013 Tomas Lestach <tlestach@redhat.com> 1.10.63-1
- remove unused method+query
- offer a null org channels for SSM servers with no base
- fix list of base channels for SSM where the systems have no base channel
- do not offer EUS channels for base channel change if a system is subscribed
  to a custom channel
- offer only base channels to change for SSM that are arch compatible
- offer only base channels to change for a system that are arch compatible
- better set null than empty string when creating a channel

* Thu Apr 18 2013 Jan Pazdziora 1.10.62-1
- In getLoggedInUser.getLoggedInUser and PxtSessionDelegate.getWebUserId, do
  not create (potentially anonymous) sessions unnecessarily.
- Drop pxtDelegate from the EnvironmentFilter where it does not seem to be
  used.
- Simplify the logic of deciding whether to authenticate.
- Avoid inserting record to PXTSessions to be immediately updated.

* Thu Apr 18 2013 Grant Gainey 1.10.61-1
- 953526 - Make cobbler/enable-menu match KS-Profile isActive()
- removing unnecessary cast
- make the select box for changing base channel as long as needed
- Revert "do not compile test cases within compile-all task"

* Thu Apr 18 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.60-1
- fixing possible errors/exceptions in list of virtual systems
- removing dead code
- containsDistributions should no longer cause exception of fedora

* Wed Apr 17 2013 Grant Gainey 1.10.59-1
- 953276 - Add warning to ActivationKey delete-confirm page.
  Also remove some dead code around CobblerSyncSystem (we have never
  actually done this...)

* Wed Apr 17 2013 Jan Dobes 1.10.58-1
- fixing channel/virtual systems list filtering and fake node handling

* Wed Apr 17 2013 Jan Pazdziora 1.10.57-1
- symlinking hibernate jars in the right way
- Redundant Math.abs()
- Salt generation corner case
- creating configDefault for java.taskomatic_channel_repodata_workers
- moving taskomatic.channel_repodata_workers config default from backend to
  java
- Switching to TransientScriptSessionManager to avoid POST
  /rhn/dwr/call/plaincall/__System.pageLoaded.dwr.

* Tue Apr 16 2013 Stephen Herr <sherr@redhat.com> 1.10.56-1
- 952839 - checkstyle fixes

* Tue Apr 16 2013 Stephen Herr <sherr@redhat.com> 1.10.55-1
- 952839 - adding erroronfail option for kickstart scripts

* Tue Apr 16 2013 Tomas Lestach <tlestach@redhat.com> 1.10.54-1
- fix base channel list offering when chaning base channel via SSM
- fix base channel list offering when chaning base channel
- Revert "removing unused string with trans-id
  'systems.details.virt.actions.scheduled'"
- removing WEB_ALLOW_PXT_PERSONALITIES
- removing unused methods
- using PxtCookieManager.createPxtCookie instead of
  RequestContext.createWebSessionCookie

* Tue Apr 16 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.53-1
- using hibernate from fedora repo on f17

* Tue Apr 16 2013 Matej Kollar <mkollar@redhat.com> 1.10.52-1
- Dead store removal (most of them)
- Speeding up c3p0 Connection testing.

* Fri Apr 12 2013 Jan Pazdziora 1.10.51-1
- 950833 - remove confusing 'delete user' and 'deactivate user' links

* Wed Apr 10 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.50-1
- on fedora 18 we are using hibernate3 from fedora repo

* Wed Apr 10 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.49-1
- check xliff files for most common localization errors
- moving system currency config defaults from separate file to rhn_java.conf
- Removing unnecessary else.

* Mon Apr 08 2013 Jan Dobes 1.10.48-1
- Fixed truncating of strings to work with UTF-8 characters properly.

* Mon Apr 08 2013 Tomas Lestach <tlestach@redhat.com> 1.10.47-1
- set emptykey for errata lists

* Mon Apr 08 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.46-1
- cleaned obsoleted trans-units

* Fri Apr 05 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.45-1
- reverted removal of localized entitlement strings

* Fri Apr 05 2013 Tomas Lestach <tlestach@redhat.com> 1.10.44-1
- 896566 - a channel may have multiple dcms: lookupDistChannelMap ->
  listDistChannelMaps
- 896566 - simplify Channel.isChannelRepodataRequired method
- link channel labels on /rhn/channels/manage/DistChannelMap.do page
- 948185 - fixing checkstyle
- 948185 - fix system.listSystemEvents on PG
- removing unnecessary cast
- removing unnecessarily nested else statement
- enhance /rhn/errata/AllErrata.do
- enhance /rhn/errata/RelevantErrata.do

* Thu Apr 04 2013 Grant Gainey 1.10.43-1
- 948605: checkstyle whitespace fixes.  Sigh.

* Thu Apr 04 2013 Grant Gainey 1.10.42-1
- 947205: Allow remote-cmd as part of SSM Package install/update/remove   *
  Refactored Ssm*PackageEvent/Action   * Corrected error-messaging when systems
  missing required capability/entitlement
- reuse existing static method
- 921312 - remove extra space before asterisk
- 839069 - display 'Updates' column on group system list pages

* Thu Apr 04 2013 Jan Dobes 1.10.41-1
- checkstyle fix
- 928198 - fixing URL detection to not contain dot or comma at the end.

* Wed Apr 03 2013 Stephen Herr <sherr@redhat.com> 1.10.40-1
- Display number of sockets in system details and spacewalk-reports

* Wed Apr 03 2013 Tomas Lestach <tlestach@redhat.com> 1.10.39-1
- 904072 - fix 'Configs' column on system groups related pages

* Wed Apr 03 2013 Jan Dobes 1.10.38-1
- indentation fix
- 918084 - added escaping for http request

* Wed Apr 03 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.37-1
- fixed checkstyle

* Wed Apr 03 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.36-1
- 820612 - implemented executor with paralled stdout and stderr reading
- looking for dtd files locally insted of redirecting for them

* Thu Mar 28 2013 Jan Pazdziora 1.10.35-1
- Fixing checkstyle.

* Thu Mar 28 2013 Jan Pazdziora 1.10.34-1
- Variable ctx not used, removing.
- The CATALINA_BASE seems to have logs/ symlink to proper place and we do not
  have to depend on CATALINA_HOME being exported.
- adding dwr to ivy list
- 681453 - throw exception instead of ISE if bad paramter is given
- updating c3p0 version in ivy
- Making the ARM soft./hard. FP channel archs localizable.

* Wed Mar 27 2013 Tomas Lestach <tlestach@redhat.com> 1.10.33-1
- we need at least c3p0 v.0.9.1 to support ConnectionCustomizer

* Wed Mar 27 2013 Tomas Lestach <tlestach@redhat.com> 1.10.32-1
- introduce RhnConnectionCustomizer

* Tue Mar 26 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.31-1
- downloading packages for kickstart via java
- correct capitalization
- abrt: display component in crash overview

* Tue Mar 26 2013 Jan Pazdziora 1.10.30-1
- Fixing checktyle.

* Tue Mar 26 2013 Jan Pazdziora 1.10.29-1
- Use to_timestamp instead of to_date which should bring the second precision
  to PostgreSQL.

* Mon Mar 25 2013 Stephen Herr <sherr@redhat.com> 1.10.28-1
- Client tools able to pass up socket info
- add python and java xmlrpc handlers for cpu socket info

* Mon Mar 25 2013 Jan Dobes <jdobes@redhat.com> 1.10.27-1
- Adding sudo Requires for spacewalk-java-lib

* Mon Mar 25 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.26-1
- abrt: new api: getCrashesByUuid
- abrt: new api: getCrashOverview

* Fri Mar 22 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.25-1
- abrt: webui for list of systems / details where a specific crash occurred
- abrt: properly export csv columns for crash overview
- abrt: add filter to software crashes overview page

* Thu Mar 21 2013 Stephen Herr <sherr@redhat.com> 1.10.24-1
- 924487 - Display warning if user might clobber their LUN with kickstart

* Thu Mar 21 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.23-1
- abrt: software crash overview, grouped by uuid

* Thu Mar 21 2013 Jan Pazdziora 1.10.22-1
- if token does not exist in DB better use it instead of new one

* Wed Mar 20 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.21-1
- returning empty string instead of null when null is given
- removing @Override annotation from method that isn't overriden

* Wed Mar 20 2013 Jan Dobes <jdobes@redhat.com> 1.10.20-1
- abrt: store crash uuid
- abrt api createCrashNote - subject is required
- visual fix for crash details
- checkstyle fix
- removing class="(fisrt|last)-column" from *.jsp(f)

* Tue Mar 19 2013 Grant Gainey <ggainey@redhat.com> 1.10.19-1
- 922928: Make duplicate-hostname search case-insensitive

* Mon Mar 18 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.18-1
- abrt - crash note api
- add is_uploaded flag to listSystemCrashFiles() return
- adding link for description of java regular expression
- removing broken link from apidoc
- use the server timezone as the default for the first user
- do not compile test cases within compile-all task

* Mon Mar 18 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.17-1
- link jmock only when it's installed

* Fri Mar 15 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.16-1
- abrt webui: separate tabs for details, files and notes

* Fri Mar 15 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.15-1
- detect objectweb-asm properly

* Fri Mar 15 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.14-1
- fix configuration for jboss hibernate
- Update copyright year shown on the WebUI.

* Thu Mar 14 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.13-1
- let's hibernate pull correct asm dependency itself
- rhn-iecompat.css is never used - delete it
- Fix the java doc
- correct the message context

* Wed Mar 13 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.12-1
- removing unused styles and refactoring blue-nav-top.css and adjacent files
- abrt: merge 3 original calls into one

* Tue Mar 12 2013 Stephen Herr <sherr@redhat.com> 1.10.11-1
- 920813 - update to latest tree, not alphabetically last tree
- apidoc fixes

* Tue Mar 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.10-1
- clean up of rhn-special-styles.css and adjacent files

* Tue Mar 12 2013 Jan Pazdziora 1.10.9-1
- 920489 - no longer allow change of the type of the key bu the action expects
  it, hidden helps.
- sorting crashes and crash files by default
- 920292 - In GpgCryptoKey, isGPG better be true.

* Mon Mar 11 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.8-1
- removing another bunch of styleclass="(first|last)-column" from *.jsp(f)
- typo fix
- fix lengths and names of identifiers
- removing styleclass="(first|last)-column" from *.jsp(f)

* Sat Mar 09 2013 Tomas Lestach <tlestach@redhat.com> 1.10.7-1
- set note rather to null than to an empty string
- display nice crash file modified date on the
  /rhn/systems/details/SoftwareCrashDetail.do page
- fix captions on the /rhn/systems/details/SoftwareCrashDetail.do page
- enable CrashNote sorting according to the modified date

* Sat Mar 09 2013 Tomas Lestach <tlestach@redhat.com> 1.10.6-1
- crash note related strings
- list CrashNotes on the /rhn/systems/details/SoftwareCrashDetail.do page
- allow CrashNote create/edit
- create CrashNote class and hibernate mapping

* Fri Mar 08 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.5-1
- abrt: API for org-wide crash reporting settings
- abrt: org-wide settings for crash reporting and crash file uploading
- Move org configuration to a separate table

* Wed Mar 06 2013 Tomas Lestach <tlestach@redhat.com> 1.10.4-1
- fix column styleclass in guestunlimited.jsp
- fix column styleclass in physicalhosts.jsp
- fix column styleclass in guestlimited.jsp
- fix column styleclass in syncsystem.jsp
- fix column styleclass in syncprofile.jsp
- fix column styleclass in missingpkgs.jsp
- fix column styleclass in comparesystems.jsp
- fix column styleclass in compareprofiles.jsp
- fix column styleclass in crashdetail.jsp
- fix column styleclass in packagelist.jsp
- fix column styleclass in list.jsp
- fix column styleclass in organizations.jsp
- fix column styleclass in orglist.jsp
- fix column styleclass in packageprofiles.jsp
- fix column styleclass in affectedsystems.jsp
- fix column styleclass in subscribeconfirm.jsp
- fix column styleclass in deployconfirm.jsp
- fix column styleclass in copy2systems.jsp
- fix column styleclass in confirmnewbasechannels.jsp
- fix column styleclass in confirmprotected.jsp
- fix column styleclass in confirmprivate.jsp
- fix column styleclass in channelrepos.jsp
- fix column styleclass in adderrataredhat.jsp
- fix column styleclass in addcustomerrata.jsp
- fix column styleclass in xccdfdiffsubmit.jsp
- fix column styleclass in schedules.jsp
- fix column styleclass in softwareentitlementdetails.jsp
- fix column styleclass in orgtrustconfirm.jsp
- fix column styleclass in organizations.jsp
- fix column styleclass in entitlementorgs.jsp
- fix column styleclass in affectedsystems.jsp
- fix column styleclass in bunchDetail.jsp
- fix column styleclass in subscribe.jsp
- fix column styleclass in ruledetails.jsp
- fix column styleclass in scap-list.jspf
- fix column styleclass in rule-common-columns.jspf
- fix column styleclass in xccdf-easy-list.jspf

* Wed Mar 06 2013 Tomas Lestach <tlestach@redhat.com> 1.10.3-1
- checkstyle issues

* Wed Mar 06 2013 Tomas Lestach <tlestach@redhat.com> 1.10.2-1
- enhance /rhn/channels/manage/repos/RepoEdit.do page
- introduce SslContentSource class

* Tue Mar 05 2013 Jan Pazdziora 1.10.1-1
- Polish a webui message
- To match backend processing of the config files, do not strip comments from
  values.

* Mon Mar 04 2013 Stephen Herr <sherr@redhat.com> 1.9.83-1
- dwr is required for building now
- fixing typo in build-props.xml

* Fri Mar 01 2013 Stephen Herr <sherr@redhat.com> 1.9.82-1
- Updating API versions for release

* Fri Mar 01 2013 Tomas Lestach <tlestach@redhat.com> 1.9.81-1
- start using crash logo
- remove thin-column sign

* Fri Mar 01 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.80-1
- abrt: display download link only for files that are available

* Thu Feb 28 2013 Tomas Lestach <tlestach@redhat.com> 1.9.79-1
- fix system crash file CVS export column translation
- delete multiple software crashes by selecting them on webui
- fix deleting a system crash
- fix crash select on the SoftwareCrashes page
- add PackageManager.buildPackageNevra java doc
- fix checkstyle issues
- add package nevra for crash pages
- abrt: add missing colons
- abrt: show full storage path for a crash
- abrt: add links to crash detail page
- webui: <p/> instead of <br/>
- adding system headers for the crash pages
- adding crash files on the crash detail page
- introducing crash delete page
- introducing crash details page
- introducing crash list page
- abrt: webui to set crashfile upload size
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Wed Feb 27 2013 Jan Pazdziora 1.9.78-1
- API doc build fix.
- abrt: fix exception number
- abrt: return default string instead of null
- abrt: api calls for crash file downloading

* Wed Feb 27 2013 Tomas Kasparek <tkasparek@redhat.com> 1.9.77-1
- 915770 - fix in sql query
- abrt: api to get/set org-wide crash file size limit

* Tue Feb 26 2013 Jan Pazdziora 1.9.76-1
- 915158 - correcting copyright dates
- Comment fix
- abrt: delete crash: remove content from filer

* Mon Feb 25 2013 Tomas Kasparek <tkasparek@redhat.com> 1.9.75-1
- API for setting primary network interface

* Mon Feb 25 2013 Tomas Kasparek <tkasparek@redhat.com> 1.9.74-1
- selecting of primary network interface should behave corectly with
  --nohardware
- checkstyle fix

* Mon Feb 25 2013 Stephen Herr <sherr@redhat.com> 1.9.73-1
- 915158 - Allow kickstart profile to update to latest available tree
- abrt: deleteCrash xml-rpc api call
- abrt: listSystemCrashFiles api call
- abrt: listSystemCrashes() api call returns crash package info

* Sat Feb 23 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.72-1
- Fix 'SystemCrashHandler' compile error
- Fix cobbler login errors

* Fri Feb 22 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.71-1
- abrt: listSystemCrashes api call
- fixed API doc for system.listLatestUpgradablePackages and
  system.listLatestInstallablePackages API calls
- Fix nasty typo throughout translation files
- abrt: xml-rpc api for crash count information

* Wed Feb 20 2013 Tomas Kasparek <tkasparek@redhat.com> 1.9.70-1
- Revert "aa"
- aa

* Wed Feb 20 2013 Tomas Kasparek <tkasparek@redhat.com> 1.9.69-1
- Java code for setting primary network interface

* Tue Feb 19 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.68-1
- abrt: total & unique crash count info in webui
- fix ChannelSoftwareHandlerTest test
- add throws clause to setBuildTime

* Tue Feb 19 2013 Tomas Lestach <tlestach@redhat.com> 1.9.67-1
- 911741 - completed kickstarts still show up on 'currently kickstarting' list

* Fri Feb 15 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.66-1
- check for zypp-plugin-spacewalk if testing autoinstall capability

* Fri Feb 15 2013 Tomas Lestach <tlestach@redhat.com> 1.9.65-1
- fixing checkstyle issues
- Only package build times should be converted to GMT

* Fri Feb 15 2013 Tomas Lestach <tlestach@redhat.com> 1.9.64-1
- return whole log in case more bytes are requested than the current file size
- removing unused imports
- RhnJavaJob: Do not ignore the exit code for external programs.
- Do not silence catched exceptions. Debugging can be hard.
- FileNotFoundException inherits IOException so no need for a separate catch
  block if the catch code is the same (none).

* Thu Feb 14 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.63-1
- fixed systemd services description

* Thu Feb 14 2013 Tomas Lestach <tlestach@redhat.com> 1.9.62-1
- 906399 - list also channel packages not associated with already cloned errata
- 906399 - fix WebUI's errata sync
- prevent rpmbuild warning: File listed twice: /var/spacewalk/systemlogs/audit-
  review.log

* Tue Feb 12 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.61-1
- link channels on /rhn/channels/ChannelDetail.do page
- cleanup old accidentaly commited eclipse project files

* Wed Feb 06 2013 Jan Pazdziora 1.9.60-1
- Make images of type 'kvm' show up on the UI

* Wed Feb 06 2013 Tomas Lestach <tlestach@redhat.com> 1.9.59-1
- 908346 - unify available package list for all systems
- 908346 - unify package list for all systems
- 908346 - unify upgradable package list for all systems

* Tue Feb 05 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.58-1
- updated rhn-search path in messages
- added systemd service for taskomatic

* Mon Feb 04 2013 Jan Pazdziora 1.9.57-1
- Redirect to landing.pxt to flush out the blue messages, then go to Index.do.
- Replace /network/systems/ssm/misc/index.pxt redirect with
  /rhn/systems/ssm/misc/Index.do.
- The gpg_info.pxt is only referenced from channel_gpg_key, only used by rhn-
  channel-gpg-key in this page, removing.

* Mon Feb 04 2013 Tomas Lestach <tlestach@redhat.com> 1.9.56-1
- 903718 - give the user url to request or generate a new certificate
- 903557 - fix queries for extra packages
- 906345 - reuse the ssm.server.delete.operationname message

* Thu Jan 31 2013 Tomas Lestach <tlestach@redhat.com> 1.9.55-1
- 906345 - undo delete 'Server Delete' string
- 906345 - localize operation descriptions
- 896015 - we need to set elaboration params anyway
- correct the case

* Mon Jan 28 2013 Tomas Lestach <tlestach@redhat.com> 1.9.54-1
- 905055 - prevent executing both LoginAction and LoginSetupAction when re-
  logging after successful logout
- 889263 - whitelist more actions for the restricted period

* Thu Jan 24 2013 Tomas Lestach <tlestach@redhat.com> 1.9.53-1
- do not allow changing type of an existing crypto key on CryptoKeyEdit.do page
- simplify CryptoKey isSSL() and isGPG() methods
- introducing SslCryptoKey and GpgCryptoKey

* Wed Jan 23 2013 Tomas Lestach <tlestach@redhat.com> 1.9.52-1
- add extra space to error message
- 902673 - tell the user about restricted period, when notifying about
  certificate expiration
- 902671 - unify restricted period length information at WebUI banner and
  notification e-mail
- 889263 - change wording for the restricted period related messages
- 889263 - check for restricted POSTS even if CSRF check is bypassed
- 889263 - enable paging on Software Channel Entitlements page

* Wed Jan 23 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.51-1
- use path compatible with slf4j >= 1.6

* Tue Jan 22 2013 Tomas Lestach <tlestach@redhat.com> 1.9.50-1
- removing unused PageControl parameter
- 896015 - dissociate duplicate system set from SSM

* Mon Jan 21 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.48-1
- specify permission on /var/lib/tomcat*/webapps

* Fri Jan 18 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.47-1
- New API: system.getCrashCount()

* Fri Jan 18 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.46-1
- checkstyle fix

* Fri Jan 18 2013 Jan Pazdziora 1.9.45-1
- abrt: display crash count in system overview

* Thu Jan 17 2013 Jan Pazdziora 1.9.44-1
- Checkstyle fix.

* Thu Jan 17 2013 Jan Pazdziora 1.9.43-1
- Checkstyle fixes.

* Thu Jan 17 2013 Jan Pazdziora 1.9.42-1
- For RHN-ORG-TRUSTED-SSL-CERT, inform that it will be copied over to new orgs.
- Copy RHN-ORG-TRUSTED-SSL-CERT if it exists, not a random SSL key.
- display abrt summary only if spacewalk-abrt is installed
- abrt: correct webui message
- The isUserManaged does not seem to be used anywhere, removing.

* Mon Jan 14 2013 Tomas Lestach <tlestach@redhat.com> 1.9.41-1
- 863123 - the query works much better when it uses existing columns

* Fri Jan 11 2013 Tomas Lestach <tlestach@redhat.com> 1.9.40-1
- introduce new synchronous system.deleteSystem API
- fix typos
- make the system.deleteSystems API doc more precise

* Wed Jan 09 2013 Tomas Lestach <tlestach@redhat.com> 1.9.39-1
- 868884 - fix the 'Replace Existing Subscriptions' SSM config channel option
- 868884 - subscribe only to selected config channels via SSM
- 890897 - prevent NPE when package description might be null

* Tue Jan 08 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.38-1
- 863123 - improved query
- 885760 - add virtualization guest info to the ServerSerializer
- 890897 - prevent NPE when package description is null
- 891681 - added email field to user list csv
- 892020 - Must set correct list name for user CSV list to work

* Fri Jan 04 2013 Tomas Lestach <tlestach@redhat.com> 1.9.37-1
- fix ChannelSoftwareHandlerTest unit test

* Wed Jan 02 2013 Stephen Herr <sherr@redhat.com> 1.9.36-1
- 890344 - fixing dependency list in taskomatic SysV script

* Wed Jan 02 2013 Jan Pazdziora 1.9.35-1
- No need to specify debug when it is not used.
- change year copyright preferencies for newly created java files using eclipse
- checkstyle: allow Copyright 2013

* Wed Jan 02 2013 Tomas Lestach <tlestach@redhat.com> 1.9.34-1
- use null as default value instead of an empty string for bug url
- adding previosly deleted strings
- 889263 - restrict API functionality when satellite certificate expires
- 889263 - allow displaying action messages on the webui login page
- 889263 - restrict WebUI functionality when satelllite certificate expires

* Tue Jan 01 2013 Jan Pazdziora 1.9.33-1
- set child channel checksum type to parent's
- 889463 - correct olson name for Australia Western timezone

* Fri Dec 21 2012 Jan Pazdziora 1.9.32-1
- 889247 - support for Australia EST/EDT timezones
- update dwr dependencies since we expect dwr3

* Tue Dec 18 2012 Tomas Lestach <tlestach@redhat.com> 1.9.31-1
- remove strange unused code

* Mon Dec 17 2012 Jan Pazdziora 1.9.30-1
- Do not use <select>'s with the same names on one form.

* Fri Dec 14 2012 Michael Mraka <michael.mraka@redhat.com> 1.9.29-1
- determining tomcat version when building webapp instead hardcode tomcat5

* Fri Dec 07 2012 Jan Pazdziora 1.9.28-1
- 883546 - reworking how repodata xml gets built to avoid "snapshot too old"
  errors
- Revert "883546 - repodata inconsistency due to concurrent modification"

* Wed Dec 05 2012 Tomas Lestach <tlestach@redhat.com> 1.9.27-1
- update catalina.out path for tomcat7
- KickstartFileSyncTaskTest should no longer fail
- 883546 - repodata inconsistency due to concurrent modification
- use dwr30.dtd insted of dwr20.dtd

* Tue Dec 04 2012 Jan Pazdziora 1.9.26-1
- Do not package tomcat 7 stuff from buildroot.
- On Fedoras, start to use tomcat >= 7.
- KickstartDataTest should no longer fail
- 881830 - create /var/lib/rhn/kickstarts/wizard/*.cfg files if missing by the
  KickstartFileSyncTask
- PackageHelperTest should no more fail at testPackageToMap
- ActionFormatterTest should no more fail at testErrataFormatter

* Fri Nov 30 2012 Tomas Lestach <tlestach@redhat.com> 1.9.25-1
- do not include engine.js twice
- remove embedded dwr from spacewalk-java and start using dwr package

* Fri Nov 30 2012 Jan Pazdziora 1.9.24-1
- Do not use Java keywords.
- 851942 - copy GPG information from the original channel within
  channel.software.clone API, when the user omits it
- OrgSoftwareSubscribtions CSV export
- removing @Override annotation from methods that aren't overriden

* Thu Nov 29 2012 Tomas Lestach <tlestach@redhat.com> 1.9.23-1
- fix checkstyle issue
- Some more type-safety / checkstyle fixes
- Fixing a bunch of type-safety and checkstyle warnings

* Wed Nov 28 2012 Tomas Lestach <tlestach@redhat.com> 1.9.22-1
- typo fix
- 519472 - suggest deleting custom packages after a channel is deleted
- 880346 - deleting an org should remove cobbler profiles too
- Revert "880346 - delete cobbler profiles when deleting an org"
- add a null check
- 470463 - fixing xmllint issue
- put a newline before pre_install_network_config snippet
- 880346 - delete cobbler profiles when deleting an org
- 675193 - removing the confising tip

* Mon Nov 26 2012 Jan Pazdziora 1.9.21-1
- 864037 - fixing typo.

* Mon Nov 26 2012 Tomas Lestach <tlestach@redhat.com> 1.9.20-1
- 879332 - checkstyle issue

* Mon Nov 26 2012 Jan Pazdziora 1.9.19-1
- 864037 - we need to POST to /cobbler_api.

* Mon Nov 26 2012 Tomas Lestach <tlestach@redhat.com> 1.9.18-1
- 879332 - introduce 'md5_crypt_rootpw' option for
  kickstart.profile.setAdvancedOptions API

* Fri Nov 23 2012 Tomas Lestach <tlestach@redhat.com> 1.9.17-1
- 879443 - preserve product name when cloning channels using API
- Implement new API call system.listAllInstallablePackages
- Fix query for API call system.listLatestInstallablePackages
- 798571 - Moscow time is GMT+4.

* Thu Nov 22 2012 Jan Pazdziora 1.9.16-1
- Fixing checkstyle.

* Thu Nov 22 2012 Jan Pazdziora 1.9.15-1
- 864037 - no hardcoding URLs.
- 879006 - Use default cobbler user id if not overriden
- Fix errors with unrequired field 'Prefix'

* Wed Nov 21 2012 Jan Pazdziora 1.9.14-1
- decrease distChannelMap release minimal length
- No need to put empty lines to rhn_taskomatic_daemon.log.

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
- Fixed a pagination issue that occurred on first page load (paji@redhat.com)
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
- Fixed an accidental compile error that occurred due to a previous commit
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

