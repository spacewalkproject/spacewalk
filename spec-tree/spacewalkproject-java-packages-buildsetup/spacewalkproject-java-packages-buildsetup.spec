Name:           spacewalkproject-java-packages-buildsetup
Version:        2.7.13
Release:        1%{?dist}
Summary:        Dist override for spacewalkproject/java-packages copr buildroot.

License:        GPLv2
URL:            https://github.com/spacewalkproject/spacewalk
BuildArch:      noarch

%description
%{summary}

%package -n ant-mvn
Summary:        Adds missing maven dependencies for ant
Requires:       ant = 1.7.1
Provides:       mvn(org.apache.ant:ant) = 1.7.1

%description -n ant-mvn
%{summary}

%files -n ant-mvn

%package -n cglib-mvn
Summary:        Adds missing maven dependencies for cglib
Requires:       cglib = 2.2
Provides:       mvn(cglib:cglib) = 2.2

%description -n cglib-mvn
%{summary}

%files -n cglib-mvn

%package -n jakarta-commons-beanutils-mvn
Summary:        Adds missing maven dependencies for jakarta-commons-beanutils
Requires:       jakarta-commons-beanutils = 1.7.0
Provides:       mvn(commons-beanutils:commons-beanutils) = 1.7.0
Provides:       apache-commons-beanutils = 1.7.0

%description -n jakarta-commons-beanutils-mvn
%{summary}

%files -n jakarta-commons-beanutils-mvn
%{_javadir}/apache-commons-beanutils.jar

%package -n jakarta-commons-beanutils19
Summary:        Adds missing maven dependencies for jakarta-commons-beanutils
Requires:       apache-commons-beanutils = 1.9.2
Provides:       jakarta-commons-beanutils = 1.9.2
Obsoletes:      jakarta-commons-beanutils < 1.9

%description -n jakarta-commons-beanutils19
%{summary}

%files -n jakarta-commons-beanutils19

%package -n jakarta-commons-cli-mvn
Summary:        Adds missing maven dependencies for jakarta-commons-cli
Requires:       jakarta-commons-cli = 1.1
Provides:       mvn(commons-cli:commons-cli) = 1.1
Provides:       apache-commons-cli = 1.1

%description -n jakarta-commons-cli-mvn
%{summary}

%files -n jakarta-commons-cli-mvn

%package -n jakarta-commons-codec-mvn
Summary:        Adds missing maven dependencies for jakarta-commons-codec
Requires:       jakarta-commons-codec = 1.3
Provides:       mvn(commons-codec:commons-codec) = 1.3
Provides:       apache-commons-codec = 1.3

%description -n jakarta-commons-codec-mvn
%{summary}

%files -n jakarta-commons-codec-mvn

%package -n jakarta-commons-collections-mvn
Summary:        Adds missing maven dependencies for jakarta-commons-collections
Requires:       jakarta-commons-collections = 3.2.1
Provides:       mvn(commons-collections:commons-collections) = 3.2.1
Provides:       apache-commons-collections = 3.2.1

%description -n jakarta-commons-collections-mvn
%{summary}

%files -n jakarta-commons-collections-mvn
%{_javadir}/apache-commons-collections.jar

%package -n jakarta-commons-digester-mvn
Summary:        Adds missing maven dependencies for jakarta-commons-digester
Requires:       jakarta-commons-digester = 1.7
Provides:       mvn(commons-digester:commons-digester) = 1.7
Provides:       apache-commons-digester = 1.7

%description -n jakarta-commons-digester-mvn
%{summary}

%files -n jakarta-commons-digester-mvn

%package -n jakarta-commons-io-mvn
Summary:        Adds missing maven dependencies for jakarta-commons-io
Requires:       jakarta-commons-io = 1.4
Provides:       mvn(commons-io:commons-io) = 1.4
Provides:       apache-commons-io = 1.4

%description -n jakarta-commons-io-mvn
%{summary}

%files -n jakarta-commons-io-mvn

%package -n jakarta-commons-lang-mvn
Summary:        Adds missing maven dependencies for jakarta-commons-lang
Requires:       jakarta-commons-lang = 2.4
Provides:       mvn(commons-lang:commons-lang) = 2.4
Provides:       apache-commons-lang = 2.4

%description -n jakarta-commons-lang-mvn
%{summary}

%files -n jakarta-commons-lang-mvn

%package -n jakarta-commons-logging-mvn
Summary:        Adds missing maven dependencies for jakarta-commons-logging
Requires:       jakarta-commons-logging = 1.0.4
Provides:       mvn(commons-logging:commons-logging) = 1.0.4
Provides:       mvn(commons-logging:commons-logging-api) = 1.0.4
Provides:       apache-commons-logging = 1.0.4

%description -n jakarta-commons-logging-mvn
%{summary}

%files -n jakarta-commons-logging-mvn
%{_javadir}/apache-commons-logging.jar

%package -n jakarta-commons-net-mvn
Summary:        Adds missing maven dependencies for jakarta-commons-net
Requires:       jakarta-commons-net = 2.0
Provides:       mvn(commons-net:commons-net) = 2.0
Provides:       apache-commons-net = 2.0

%description -n jakarta-commons-net-mvn
%{summary}

%files -n jakarta-commons-net-mvn

%package -n jakarta-oro-mvn
Summary:        Adds missing maven dependencies for jakarta-oro
Requires:       jakarta-oro = 2.0.8
Provides:       mvn(oro:oro) = 2.0.8

%description -n jakarta-oro-mvn
%{summary}

%files -n jakarta-oro-mvn

%package -n jdom-mvn
Summary:        Adds missing maven dependencies for jdom
Requires:       jdom = 1.1.1
Provides:       mvn(jdom:jdom) = 1.1.1

%description -n jdom-mvn
%{summary}

%files -n jdom-mvn

%package -n javapackages-tools-mvn
Summary:        Adds missing maven dependencies for javapackages-tools
Requires:       javapackages-tools = 3.4.1
Provides:       mvn(com.sun:tools) = 3.4.1

%description -n javapackages-tools-mvn
%{summary}

%files -n javapackages-tools-mvn

%package -n junit-mvn
Summary:        Adds missing maven dependencies for junit
Requires:       junit = 3.8.2
Provides:       mvn(junit:junit) = 3.8.2

%description -n junit-mvn
%{summary}

%files -n junit-mvn

%package -n objectweb-asm-mvn
Summary:        Adds missing maven dependencies for objectweb-asm
Requires:       objectweb-asm = 3.2
Provides:       mvn(asm:asm) = 3.2

%description -n objectweb-asm-mvn
%{summary}

%files -n objectweb-asm-mvn

%package -n tomcat-servlet-3.0-api-mvn
Summary:        Adds missing maven dependencies for tomcat-servlet-3.0-api
Requires:       tomcat-servlet-3.0-api >= 7.0.78
Provides:       mvn(javax.servlet:javax.servlet-api) = 7.0.78

%description -n tomcat-servlet-3.0-api-mvn
%{summary}

%files -n tomcat-servlet-3.0-api-mvn

%package -n xalan-j2-mvn
Summary:        Adds missing maven dependencies for xalan-j2
Requires:       xalan-j2 = 2.7.0
Provides:       mvn(xalan:xalan) = 2.7.0

%description -n xalan-j2-mvn
%{summary}

%files -n xalan-j2-mvn

%package -n xerces-j2-mvn
Summary:        Adds missing maven dependencies for xerces-j2
Requires:       xerces-j2 = 2.7.1
Provides:       mvn(xerces:xercesImpl) = 2.7.1
Provides:       osgi(org.apache.xerces) = 2.7.1

%description -n xerces-j2-mvn
%{summary}

%files -n xerces-j2-mvn

%package -n xml-commons-resolver-mvn
Summary:        Adds missing maven dependencies for xml-commons-resolver
Requires:       xml-commons-resolver = 1.1
Provides:       mvn(xml-resolver:xml-resolver) = 1.1

%description -n xml-commons-resolver-mvn
%{summary}

%files -n xml-commons-resolver-mvn

%prep
# noop


%build
# noop


%install
for d in %{_prefix}/lib/rpm/macros.d %{_sysconfdir}/rpm ; do
  mkdir -p $RPM_BUILD_ROOT$d
  echo "%%dist .sw" >$RPM_BUILD_ROOT$d/macros.zz-dist-override
done
mkdir -p $RPM_BUILD_ROOT%{_javadir}
for i in apache-commons-beanutils \
         apache-commons-logging \
         apache-commons-collections ; do
  ln -s ${i/apache-/}.jar $RPM_BUILD_ROOT%{_javadir}/$i.jar
done

%files
%{_prefix}/lib/rpm/macros.d/macros.zz-dist-override
%{_sysconfdir}/rpm/macros.zz-dist-override


%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.7.13-1
- removed %%%%defattr from specfile
- removed Group from specfile

* Fri Jun 30 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.12-1
- tomcat in EPEL has been updated

* Fri Apr 28 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.11-1
- tomcat-servlet-3.0-api has been updated in epel

* Tue Apr 25 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.10-1
- setup copr @spacewalkproject/java-packages buildroot

