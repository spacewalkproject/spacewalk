Name:       dwr
Version:    3.0rc2
Release:    5%{?dist}
Summary:    Direct Web Remoting
Group:      Development/Libraries/Java
License:    Apache Software License v2
URL:        http://directwebremoting.org
# The Source0 is an svn checkout with some purged content
# rm -rf dwr-3.0rc2
# svn export --ignore-externals http://svn.directwebremoting.org/dwr/tags/Version_3_0_RC2_FINAL/ dwr-3.0rc2
# while read i ; do rm -f "dwr-3.0rc2/$i" ; done < dwr-purge-source-tree.list
# tar czf dwr-3.0rc2-lite.tar.gz dwr-3.0rc2/
Source0:    %{name}-%{version}-lite.tar.gz
Source1:    dwr-purge-source-tree.list
Patch0:     dwr-no-noncla-no-junit.patch
# The following two patches should address DWR-467 but they do not
Patch1:     dwr-r3974-merged.patch
Patch2:     dwr-r3975.patch
BuildArch:  noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

Requires:   java
BuildRequires:   java-devel >= 1.5.0
BuildRequires:   ant
%if 0%{?fedora} >= 20
BuildRequires: javapackages-tools
%endif

%description
DWR is a Java library that enables Java on the server and JavaScript
in a browser to interact and call each other as simply as possible.

%prep
%setup -q
%patch0 -p0
%patch1 -p1
%patch2 -p0

%build
LC_CTYPE=en_US.iso-8859-1 ant jar

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{_javadir}
install -m 644 ./target/ant/dwr.jar $RPM_BUILD_ROOT%{_javadir}/%{name}-%{version}.jar
(cd $RPM_BUILD_ROOT%{_javadir} && ln -sf %{name}-%{version}.jar %{name}.jar)

%files
%attr(0644,root,root) %{_javadir}/%{name}-%{version}.jar
%attr(0644,root,root) %{_javadir}/%{name}.jar


%changelog
* Wed Jan 08 2014 Tomas Lestach <tlestach@redhat.com> 3.0rc2-5
- let dwr buildrequire javapackages-tools on fc20

* Mon Apr 08 2013 Jan Pazdziora 3.0rc2-4
- patch for the "A server error has occurred" issue (DWR-467)

* Mon Apr 08 2013 Jan Pazdziora 3.0rc2-3
- build from sources

* Thu Nov 29 2012 Tomas Lestach <tlestach@redhat.com> 3.0rc2-2
- define NoTgzBuilder for dwr
- define BuildRoot for dwr.spec

* Thu Nov 29 2012 Tomas Lestach <tlestach@redhat.com> 3.0rc2-1
- initial dwr build


