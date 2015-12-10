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

%define run_checkstyle  1

Name: spacewalk-java
Summary: Java web application files for Spacewalk
Group: Applications/Internet
License: GPLv2
Version: 2.5.26
Release: 1%{?dist}
URL:       https://fedorahosted.org/spacewalk
Source0:   https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz 
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
ExcludeArch: ia64

Requires: bcel
Requires: c3p0 >= 0.9.1
Requires: classpathx-mail
Requires: cobbler20
Requires: dojo
Requires: dwr >= 3
Requires: jakarta-commons-el
Requires: jakarta-commons-fileupload
Requires: jakarta-taglibs-standard
Requires: java >= 1:1.6.0
Requires: java-devel >= 1:1.6.0
Requires: jcommon
Requires: jdom
Requires: jpam
Requires: jta
Requires: log4j
Requires: oscache
Requires: redstone-xmlrpc
Requires: simple-core
Requires: simple-xml
Requires: sitemesh
Requires: spacewalk-branding
Requires: spacewalk-java-config
Requires: spacewalk-java-jdbc
Requires: spacewalk-java-lib
Requires: stringtree-json
Requires: susestudio-java-client
Requires: xalan-j2 >= 0:2.6.0
Requires: xerces-j2
%if 0%{?fedora}
Requires: classpathx-jaf
Requires: hibernate3 >= 3.6.10
Requires: hibernate3-c3p0 >= 3.6.10
Requires: hibernate3-ehcache >= 3.6.10
Requires: javassist
BuildRequires: ehcache-core
BuildRequires: hibernate3 >= 0:3.6.10
BuildRequires: hibernate3-c3p0 >= 3.6.10
BuildRequires: hibernate3-ehcache >= 3.6.10
BuildRequires: javassist
%else
Requires: hibernate3 = 0:3.2.4
BuildRequires: hibernate3 = 0:3.2.4
%endif
# EL5 = Struts 1.2 and Tomcat 5, EL6+/recent Fedoras = 1.3 and Tomcat 6
%if 0%{?fedora} || 0%{?rhel} >= 7
Requires: struts >= 0:1.3.0
Requires: tomcat >= 7
Requires: tomcat-lib >= 7
Requires: tomcat-servlet-3.0-api >= 7
BuildRequires: struts >= 0:1.3.0
BuildRequires: tomcat >= 7
BuildRequires: tomcat-lib >= 7
%else
Requires: struts >= 0:1.3.0
Requires: struts-taglib >= 0:1.3.0
Requires: tomcat6
Requires: tomcat6-lib
Requires: tomcat6-servlet-2.5-api
BuildRequires: struts >= 0:1.3.0
BuildRequires: struts-taglib >= 0:1.3.0
BuildRequires: tomcat6
BuildRequires: tomcat6-lib
%endif
%if 0%{?fedora} || 0%{?rhel} >=7
Requires:      apache-commons-cli
Requires:      apache-commons-codec
Requires:      apache-commons-discovery
Requires:      apache-commons-io
Requires:      apache-commons-lang
Requires:      apache-commons-logging
Requires:      javapackages-tools
BuildRequires: apache-commons-cli
BuildRequires: apache-commons-codec
BuildRequires: apache-commons-collections
BuildRequires: apache-commons-discovery
BuildRequires: apache-commons-io
BuildRequires: apache-commons-logging
BuildRequires: apache-commons-validator
# spelling checker is only for Fedoras (no aspell in RHEL6)
BuildRequires: aspell aspell-en libxslt
BuildRequires: javapackages-tools
BuildRequires: mvn(ant-contrib:ant-contrib)
%else
Requires:      jakarta-commons-cli
Requires:      jakarta-commons-codec
Requires:      jakarta-commons-discovery
Requires:      jakarta-commons-io
Requires:      jakarta-commons-lang >= 0:2.1
Requires:      jakarta-commons-logging
Requires:      jpackage-utils
BuildRequires: ant-contrib
BuildRequires: ant-nodeps
BuildRequires: jakarta-commons-cli
BuildRequires: jakarta-commons-codec
BuildRequires: jakarta-commons-collections
BuildRequires: jakarta-commons-discovery
BuildRequires: jakarta-commons-io
BuildRequires: jakarta-commons-logging
BuildRequires: jakarta-commons-validator
BuildRequires: jpackage-utils
%endif
# for RHEL6 we need to filter out several package versions
%if  0%{?rhel} && 0%{?rhel} >= 6
# cglib is not compatible with hibernate and asm from RHEL6
Requires: cglib < 0:2.2
%else
Requires: cglib
%endif

BuildRequires: /usr/bin/perl
BuildRequires: /usr/bin/xmllint
BuildRequires: ant
BuildRequires: ant-apache-regexp
BuildRequires: ant-junit
BuildRequires: antlr >= 0:2.7.6
BuildRequires: bcel
BuildRequires: c3p0 >= 0.9.1
BuildRequires: cglib
BuildRequires: classpathx-mail
BuildRequires: concurrent
BuildRequires: dom4j
BuildRequires: dwr >= 3
BuildRequires: jaf
BuildRequires: jakarta-commons-el
BuildRequires: jakarta-commons-fileupload
BuildRequires: jakarta-taglibs-standard
BuildRequires: java-devel >= 1:1.6.0
BuildRequires: jcommon
BuildRequires: jdom
BuildRequires: jpam
BuildRequires: jta
BuildRequires: oscache
BuildRequires: postgresql-jdbc
BuildRequires: quartz
BuildRequires: redstone-xmlrpc
BuildRequires: simple-core
BuildRequires: simple-xml
BuildRequires: sitemesh
BuildRequires: stringtree-json
BuildRequires: susestudio-java-client
BuildRequires: tanukiwrapper
%if 0%{?run_checkstyle}
BuildRequires: checkstyle
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
Group: Applications/Internet
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
Group:  Applications/Internet

BuildRequires:  jmock < 2.0
Requires: jmock < 2.0
Requires: ant-junit

%description tests
This package contains testing files of spacewalk-java.  

%files tests
%defattr(644,root,root,775)
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
%else
Requires: cglib
%endif

Requires: bcel
Requires: c3p0 >= 0.9.1
Requires: cobbler20
Requires: concurrent
Requires: jakarta-taglibs-standard
Requires: java >= 0:1.6.0
Requires: java-devel >= 0:1.6.0
Requires: jcommon
Requires: jpam
Requires: log4j
Requires: oscache
Requires: quartz < 2.0
Requires: simple-core
Requires: spacewalk-java-config
Requires: spacewalk-java-jdbc
Requires: spacewalk-java-lib
Requires: tanukiwrapper
Requires: xalan-j2 >= 0:2.6.0
Requires: xerces-j2
%if 0%{?fedora}
Requires: hibernate3 >= 3.6.10
Requires: hibernate3-c3p0 >= 3.6.10
Requires: hibernate3-ehcache >= 3.6.10
Requires: javassist
%else
Requires: hibernate3 >= 0:3.2.4
%endif
%if 0%{?fedora} || 0%{?rhel} >= 7
Requires: apache-commons-cli
Requires: apache-commons-codec
Requires: apache-commons-dbcp
Requires: apache-commons-lang
Requires: apache-commons-logging
%else
Requires: jakarta-commons-cli
Requires: jakarta-commons-codec
Requires: jakarta-commons-dbcp
Requires: jakarta-commons-lang >= 0:2.1
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

%install
rm -rf $RPM_BUILD_ROOT

# on Fedora 19 some jars are named differently
%if 0%{?fedora}
mkdir -p $RPM_BUILD_ROOT%{_javadir}
[[ -f %{_javadir}/mchange-commons-java.jar ]] && ln -s -f %{_javadir}/mchange-commons-java.jar $RPM_BUILD_ROOT%{_javadir}/mchange-commons.jar
[[ -f %{_javadir}/mchange-commons/mchange-commons-java.jar ]] && ln -s -f %{_javadir}/mchange-commons/mchange-commons-java.jar $RPM_BUILD_ROOT%{_javadir}/mchange-commons.jar
ln -s -f %{_javadir}/jboss-logging/jboss-logging.jar $RPM_BUILD_ROOT%{_javadir}/jboss-logging.jar
# create missing symlinks on fedora21
%if 0%{?fedora} >= 21
 ln -s -f %{_javadir}/hibernate-jpa-2.0-api/hibernate-jpa-2.0-api.jar $RPM_BUILD_ROOT%{_javadir}/hibernate-jpa-2.0-api.jar
 ln -s -f %{_javadir}/c3p0/c3p0.jar $RPM_BUILD_ROOT%{_javadir}/c3p0.jar
 ln -s -f %{_javadir}/concurrent/concurrent.jar $RPM_BUILD_ROOT%{_javadir}/concurrent.jar
%endif

%endif

%if 0%{?fedora} || 0%{?rhel} >= 7
ant -Dprefix=$RPM_BUILD_ROOT install-tomcat7
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/tomcat/Catalina/localhost/
install -m 755 conf/rhn.xml $RPM_BUILD_ROOT%{_sysconfdir}/tomcat/Catalina/localhost/rhn.xml
%else
ant -Dprefix=$RPM_BUILD_ROOT install-tomcat6
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/tomcat6/Catalina/localhost/
install -m 755 conf/rhn.xml $RPM_BUILD_ROOT%{_sysconfdir}/tomcat6/Catalina/localhost/rhn.xml
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
%endif
%if 0%{?fedora} && 0%{?fedora} >= 21
echo "wrapper.java.classpath.28=/usr/share/java/log4j-1.jar" >> conf/default/rhn_taskomatic_daemon.conf
%else
echo "wrapper.java.classpath.28=/usr/share/java/log4j.jar" >> conf/default/rhn_taskomatic_daemon.conf
%endif
%if 0%{?fedora}
echo "wrapper.java.classpath.49=/usr/share/java/hibernate3/hibernate-core-3.jar
wrapper.java.classpath.61=/usr/share/java/hibernate-jpa-2.0-api.jar
wrapper.java.classpath.62=/usr/share/java/hibernate3/hibernate-ehcache-3.jar
wrapper.java.classpath.63=/usr/share/java/hibernate3/hibernate-c3p0-3.jar
wrapper.java.classpath.64=/usr/share/java/hibernate*/hibernate-commons-annotations.jar
wrapper.java.classpath.65=/usr/share/java/slf4j/api.jar
wrapper.java.classpath.66=/usr/share/java/jboss-logging.jar
wrapper.java.classpath.67=/usr/share/java/javassist.jar
wrapper.java.classpath.68=/usr/share/java/ehcache-core.jar" >> conf/default/rhn_taskomatic_daemon.conf
%else
echo "hibernate.cache.provider_class=org.hibernate.cache.OSCacheProvider" >> conf/default/rhn_hibernate.conf
echo "wrapper.java.classpath.49=/usr/share/java/hibernate3.jar" >> conf/default/rhn_taskomatic_daemon.conf
%endif
install -m 644 conf/default/rhn_hibernate.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_hibernate.conf
install -m 644 conf/default/rhn_taskomatic_daemon.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
install -m 644 conf/default/rhn_org_quartz.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_org_quartz.conf
install -m 644 conf/rhn_java.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults
install -m 755 conf/logrotate/rhn_web_api $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/rhn_web_api
# LOGROTATE >= 3.8 requires extra permission config
%if 0%{?fedora} || 0%{?rhel} > 6
sed -i 's/#LOGROTATE-3.8#//' $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/rhn_web_api
%endif
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
%if 0%{?fedora}
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
%{jardir}/*commons-validator.jar
%{jardir}/concurrent*.jar
%{jardir}/dom4j.jar
%{jardir}/dwr.jar
%{jardir}/hibernate3*
%if 0%{?fedora}
%{jardir}/ehcache-core.jar
%{jardir}/*_hibernate-commons-annotations.jar
%{jardir}/hibernate-jpa-2.0-api*.jar
%{jardir}/javassist.jar
%{jardir}/slf4j_api.jar
%{jardir}/slf4j_log4j12*.jar
%{jardir}/mchange-commons.jar
%{_javadir}/mchange-commons.jar
%{_javadir}/jboss-logging.jar
%{jardir}/*jboss-logging.jar

%if 0%{?fedora} >= 21
%{_javadir}/c3p0.jar
%{_javadir}/concurrent.jar
%{_javadir}/hibernate-jpa-2.0-api.jar
%endif

%endif
%{jardir}/jaf.jar
%{jardir}/javamail.jar
%{jardir}/jcommon*.jar
%{jardir}/jdom.jar
%{jardir}/jpam.jar
%{jardir}/jta.jar
%{jardir}/log4j*.jar
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

%{jardir}/asm_asm.jar

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
%if 0%{?fedora}
%attr(755, root, root) %{_sbindir}/taskomatic
%attr(755, root, root) %{_unitdir}/taskomatic.service
%else
%attr(755, root, root) %{_initrddir}/taskomatic
%endif
%{_bindir}/taskomaticd
%{_datadir}/rhn/lib/spacewalk-asm.jar


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
%defattr(644, tomcat, tomcat)
%{jardir}/ojdbc14.jar

%files postgresql
%defattr(644, tomcat, tomcat)
%{jardir}/postgresql-jdbc.jar

%changelog
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
- removing unneeded insmod on kickstart %%pre script, since they are already
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
- 639999 - adding %%end tags to generated kickstart files if os is fedora or
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
- fixing kickstart %%post script logging to actually work and not break
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
  to fail in the %%post section resulting in the system not being registered at
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
- fixing un-escaped dollar sign in %%post script that deals with rewriting
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

