%bcond_without ant

%global namedversion %{version}%{?namedreltag}

Name:           sitemesh
Version:        2.4.2
Release:        2.8%{?dist}
Epoch:          0
Summary:        Sitemesh
License:        ASL 1.1
URL:            http://www.sitemesh.org/
%if 0
/bin/rm -rf sitemesh-2.4.2.tar.xz sitemesh-2.4.2/ .gitignore
/usr/bin/svn -q export -r 446 https://svn.java.net/svn/sitemesh~svn/tags/SITEMESH_2-4-2/ sitemesh-2.4.2/
/bin/tar caf sitemesh-2.4.2.tar.xz sitemesh-2.4.2/
/usr/bin/rhpkg new-sources sitemesh-2.4.2.tar.xz
/usr/bin/rhpkg prep
%endif
Source0:        sitemesh-2.4.2.tar.xz
Source1:        http://central.maven.org/maven2/opensymphony/sitemesh/2.4.2/sitemesh-2.4.2.pom
Patch0:         0000-sitemesh-build.patch
Patch1:         0001-sitemesh-lexer_flex.patch
Patch2:         0002-sitemesh-tapestry-Title.patch
Patch3:         0003-sitemesh-tapestry-Property.patch
Patch4:         0004-sitemesh-tapestry-Util.patch
Patch5:         0005-sitemesh-tapestry-SiteMeshBase.patch
Patch6:         0006-sitemesh-velocity-VelocityDecoratorServlet.patch
Patch7:         0007-sitemesh-pom.patch
Patch8:         0008-sitemesh-package-html.patch
Patch9:         sitemesh-jflex-1.6.x-compatibility.patch
Requires(post): jpackage-utils
Requires(postun): jpackage-utils
Requires:       jpackage-utils
%if 0%{?fedora} >= 24
BuildRequires:  glibc-langpack-en
%endif
BuildRequires:  jpackage-utils
%if 0%{?fedora} || 0%{?rhel} >= 7
BuildRequires:  jboss-jsp-2.2-api >= 0:1.0.1
BuildRequires:  jboss-servlet-3.0-api >= 0:1.0.2
BuildRequires:  junit >= 0:4.11
BuildRequires:  velocity >= 0:1.7
%else
BuildRequires:  tomcat-jsp-2.2-api >= 0:1.0.1
BuildRequires:  tomcat6-servlet-2.5-api >= 0:1.0.2
BuildRequires:  junit >= 0:3.8.2
BuildRequires:  velocity >= 0:1.4
%endif
BuildRequires:  freemarker >= 0:2.3.19
BuildRequires:  velocity-tools >= 0:2.0
%if %with ant
BuildRequires:  ant
BuildRequires:  ant-junit
BuildRequires:  java-1.8.0-openjdk-devel
BuildRequires:  java_cup
BuildRequires:  jflex
%else
# XXX: 1.4.3-r1
BuildRequires:  maven-source-plugin >= 0:2.2.1
BuildRequires:  maven-jar-plugin >= 0:2.4
BuildRequires:  maven-surefire-plugin >= 0:2.16
BuildRequires:  maven-assembly-plugin >= 0:2.4
BuildRequires:  maven-compiler-plugin >= 0:3.1
BuildRequires:  maven-javadoc-plugin >= 0:2.9.1
BuildRequires:  maven-surefire-report-plugin >= 0:2.16
BuildRequires:  maven-pmd-plugin >= 0:3.0.1
BuildRequires:  maven-javadoc-plugin >= 0:2.9.1
#
BuildRequires:  maven-antrun-plugin >= 0:1.3
# XXX: 2.2-beta-2
BuildRequires:  maven-assembly-plugin >= 0:2.2
BuildRequires:  maven-clean-plugin >= 0:2.2
BuildRequires:  maven-dependency-plugin >= 0:2.0
BuildRequires:  maven-ear-plugin >= 0:2.3.1
BuildRequires:  maven-ejb-plugin >= 0:2.1
BuildRequires:  maven-plugin-plugin >= 0:2.4.3
BuildRequires:  maven-rar-plugin >= 0:2.2
# XXX: 2.0-beta-8
BuildRequires:  maven-release-plugin >= 0:2.0
# XXX: 2.1-alpha-2
BuildRequires:  maven-war-plugin >= 0:2.1
#
BuildRequires:  maven-compiler-plugin
BuildRequires:  maven-deploy-plugin
BuildRequires:  maven-install-plugin
BuildRequires:  maven-jar-plugin
BuildRequires:  maven-javadoc-plugin
BuildRequires:  maven-project-info-reports-plugin
BuildRequires:  maven-remote-resources-plugin
BuildRequires:  maven-resources-plugin
BuildRequires:  maven-site-plugin
BuildRequires:  maven-source-plugin
BuildRequires:  xmvn
%endif
BuildArch:      noarch

%description 
SiteMesh is a web-page layout and decoration framework and web-application
integration framework to aid in creating large sites consisting of many pages
for which a consistent look/feel, navigation and layout scheme is required.

%package -n sitemesh-javadoc
Summary:        Javadoc for sitemesh
Requires:       jpackage-utils
BuildRequires:  jpackage-utils

%description -n sitemesh-javadoc
%{summary}.

%package -n sitemesh-site
Summary:        Site for sitemesh
Requires:       jpackage-utils
BuildRequires:  jpackage-utils
Requires:       sitemesh-javadoc = %{epoch}:%{version}-%{release}

%description -n sitemesh-site
%{summary}.

%prep
%setup -q -n sitemesh-%{namedversion}
%{_bindir}/find -type f -name '*.jar' | %{_bindir}/xargs -t %{__rm}
%{__cp} -p %{SOURCE1} pom.xml
%patch0 -p1 -b .0000~
%patch1 -p1 -b .0001~
%patch2 -p1 -b .0002~
%patch3 -p1 -b .0003~
%patch4 -p1 -b .0004~
%patch5 -p1 -b .0005~
%patch6 -p1 -b .0006~
%patch7 -p1 -b .0007~
%patch8 -p1 -b .0008~
%patch9 -p1 -b .jflex

%if %with ant
# XXX: missing tapestry-3.0.1.jar
%{__rm} -r src/java/com/opensymphony/module/sitemesh/tapestry

pushd lib
%{__ln_s} `%{_bindir}/build-classpath freemarker` freemarker.jar
%{__ln_s} `%{_bindir}/build-classpath java_cup` java_cup.jar
%{__ln_s} `%{_bindir}/build-classpath jflex` jflex.jar
%{__ln_s} `%{_bindir}/build-classpath junit` junit-3.8.1.jar
%if 0%{?fedora} || 0%{?rhel} >= 7
%{__ln_s} `%{_bindir}/build-classpath jboss-jsp-2.2-api` jsp.jar
%{__ln_s} `%{_bindir}/build-classpath jboss-servlet-3.0-api` servlet.jar
%else
%{__ln_s} `%{_bindir}/build-classpath tomcat-jsp-2.2-api` jsp.jar
%{__ln_s} `%{_bindir}/build-classpath tomcat6-servlet-2.5-api` servlet.jar
%endif
%{__ln_s} `%{_bindir}/build-classpath velocity` velocity-dep-1.3.1.jar
%{__ln_s} `%{_bindir}/build-classpath velocity-tools` velocity-tools-view-1.1.jar
popd
%endif

%build
%if %with ant
export OPT_JAR_LIST=`%{__cat} %{_sysconfdir}/ant.d/junit`
export CLASSPATH=
export LC_ALL=en_US.UTF-8
%{ant} -Dbuild.sysclasspath=first jflex dist
%else
export MAVEN_REPO_LOCAL=${PWD}/.m2/repository
export ALT_DEPLOYMENT_REPOSITORY=remote-repository::default::file://${PWD}/maven2-brew
export MAVEN_OPTS=
%{_bindir}/mvn-local -B -e -Dmaven.repo.local=${MAVEN_REPO_LOCAL} -DaltDeploymentRepository=${ALT_DEPLOYMENT_REPOSITORY} -DperformRelease deploy javadoc:aggregate
# FIXME: anything involving site and classpath seems to fail
%{_bindir}/mvn-local -B -e -Dmaven.repo.local=${MAVEN_REPO_LOCAL} -DaltDeploymentRepository=${ALT_DEPLOYMENT_REPOSITORY} -Dmaven.test.skip -Dcobertura.skip -Dfindbugs.skip site
%endif

%install
%{__rm} -rf %{buildroot}

# jars
%{__mkdir_p} %{buildroot}%{_javadir}
%if %with ant
%{__cp} -p dist/sitemesh-%{namedversion}.jar %{buildroot}%{_javadir}/sitemesh-%{namedversion}.jar
%else
%{__cp} -p maven2-brew/opensymphony/sitemesh/%{namedversion}/sitemesh-%{namedversion}.jar %{buildroot}%{_javadir}/sitemesh-%{namedversion}.jar
%{__cp} -p maven2-brew/opensymphony/sitemesh/%{namedversion}/sitemesh-%{namedversion}-javadoc.jar %{buildroot}%{_javadir}/sitemesh-%{namedversion}-javadoc.jar
%{__cp} -p maven2-brew/opensymphony/sitemesh/%{namedversion}/sitemesh-%{namedversion}-sources.jar %{buildroot}%{_javadir}/sitemesh-%{namedversion}-sources.jar
%endif
(cd %{buildroot}%{_javadir} && for jar in *-%{namedversion}*; do %{__ln_s} ${jar} `/bin/echo ${jar} | %{__sed} -e "s|-%{namedversion}||g"`; done)

# poms
%{__mkdir_p} %{buildroot}%{_mavenpomdir}
%if %with ant
%{__cp} -p pom.xml %{buildroot}%{_mavenpomdir}/JPP-sitemesh.pom
%else
%{__cp} -p maven2-brew/opensymphony/sitemesh/%{namedversion}/sitemesh-%{namedversion}.pom %{buildroot}%{_mavenpomdir}/JPP-sitemesh.pom
%endif

# javadoc
%{__mkdir_p} %{buildroot}%{_javadocdir}/sitemesh-%{namedversion}
%if %with ant
%{__cp} -pr dist/docs/api/* %{buildroot}%{_javadocdir}/sitemesh-%{namedversion}
%else
%{__cp} -pr target/site/apidocs/* %{buildroot}%{_javadocdir}/sitemesh-%{namedversion}
%endif
%{__ln_s} sitemesh-%{namedversion} %{buildroot}%{_javadocdir}/sitemesh

# site
%{__mkdir_p} %{buildroot}%{_docdir}/sitemesh
%if %without ant
%{__cp} -pr target/site/* %{buildroot}%{_docdir}/sitemesh
%{__rm} -r %{buildroot}%{_docdir}/sitemesh/apidocs
%endif
%{__ln_s} %{_javadocdir}/sitemesh %{buildroot}%{_docdir}/sitemesh/apidocs

%clean
%{__rm} -rf %{buildroot}

%files -n sitemesh
%doc CHANGES.txt LICENSE.txt README.txt docs
%{_javadir}/sitemesh-%{namedversion}.jar
%{_javadir}/sitemesh.jar
%if %without ant
%{_javadir}/sitemesh-%{namedversion}-javadoc.jar
%{_javadir}/sitemesh-javadoc.jar
%{_javadir}/sitemesh-%{namedversion}-sources.jar
%{_javadir}/sitemesh-sources.jar
%endif
%{_mavenpomdir}/JPP-sitemesh.pom

%files -n sitemesh-javadoc
%{_javadocdir}/sitemesh-%{namedversion}
%{_javadocdir}/sitemesh

%files -n sitemesh-site
%{_docdir}/sitemesh

%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.4.2-2.8
- removed %%%%defattr from specfile
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 2.4.2-2.7
- recompile all packages with the same (latest) version of java

* Wed Mar 29 2017 Michael Mraka <michael.mraka@redhat.com> 2.4.2-2.6
- let sitemesh build on RHEL6

* Mon Mar 20 2017 Michael Mraka <michael.mraka@redhat.com> 2.4.2-2.5
- relax dependencies on Fedora 23

* Wed Mar 15 2017 Michael Mraka <michael.mraka@redhat.com> 2.4.2-2.4
- require  en (UTF8) locales

* Wed Mar 15 2017 Michael Mraka <michael.mraka@redhat.com> 2.4.2-2.3
- explicitly require javac
- link proper jar from Requires:

* Tue Mar 14 2017 Michael Mraka <michael.mraka@redhat.com> 2.4.2-2.2
- update to jflex 1.6.1

* Tue Mar 14 2017 Michael Mraka <michael.mraka@redhat.com> 2.4.2-2.1
- rebuild sitemesh locally without jpackage dependencies

* Fri Aug 23 2013 David Walluck <dwalluck@redhat.com> 0:2.4.2-1
- release

* Thu Sep 27 2012 David Walluck <dwalluck@redhat.com> 0:2.4.2-1
- 2.4.2
- re-diff all patches
- add sitemesh-velocity-VelocityDecoratorServlet.patch
- fix Requires
- fix docs
- don't mark javadoc as %doc
- remove tapestry

* Sat Jan 22 2011 Ralph Apel <r.apel at r-apel.de> 0:2.4.1-2
- Adapt to JPP-6

* Fri Apr 03 2009 Ralph Apel <r.apel at r-apel.de> 0:2.4.1-1.jpp5
- Upgrade to 2.4.1

* Fri Jul 20 2007 Ralph Apel <r.apel at r-apel.de> 0:2.3-1jpp
- Upgrade to 2.3
- Add pom and depmap frag

* Tue May 08 2007 Ralph Apel <r.apel at r-apel.de> 0:2.2.1-2jpp
- Fix Copyright year
- Fix aot build
- Fix Vendor, Distribution

* Thu Oct 05 2006 Ralph Apel <r.apel at r-apel.de> 0:2.2.1-1jpp
- Upgrade to 2.2.1
- Add ant and jflex BRs
- Add post/postun Requires for javadoc
- Add gcj_suppport option

* Fri Mar 10 2006 Ralph Apel <r.apel at r-apel.de> 0:2.1-1jpp
- First JPackage release

* Thu Aug 12 2004 Chip Turner <cturner@redhat.com> 2.1-1
- Initial build
