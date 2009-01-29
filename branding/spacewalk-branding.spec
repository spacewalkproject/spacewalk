Name:       spacewalk-branding
Version:    0.5.3
Release:    1%{?dist}
Summary:    Spacewalk branding data

Group:      Applications/Internet
License:    GPLv2
URL:        https://fedorahosted.org/spacewalk/
Source0:    %{name}-%{version}.tar.gz
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:  noarch

Requires:   spacewalk-html
BuildRequires: java-devel >= 1.5.0


%description
Spacewalk specific branding, CSS, and images.

%package jar
Group:      Applications/Internet
Summary: Jar file containing l10n strings for Java

%description jar
This package contains the branding-java.jar file used to contain product specific strings.

%prep
%setup -q

%build

javac java/code/src/com/redhat/rhn/branding/strings/StringPackage.java
rm -f java/code/src/com/redhat/rhn/branding/strings/StringPackage.java
jar -cf java-branding.jar -C java/code/src com

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}/%{_var}/www/html
install -d -m 755 %{buildroot}/%{_var}/www/html/nav
install -d -m 755 %{buildroot}%{_datadir}/spacewalk
install -d -m 755 %{buildroot}%{_datadir}/rhn/lib/
install -d -m 755 %{buildroot}%{_var}/lib/tomcat5/webapps/rhn/WEB-INF/lib/
cp -R css %{buildroot}/%{_var}/www/html/
cp -R img %{buildroot}/%{_var}/www/html/
cp -R templates %{buildroot}/%{_var}/www/html/
cp -R styles %{buildroot}/%{_var}/www/html/nav/
cp -R setup  %{buildroot}%{_datadir}/spacewalk/
cp -R java-branding.jar %{buildroot}%{_datadir}/rhn/lib/
ln -s %{_datadir}/rhn/lib/java-branding.jar %{buildroot}%{_var}/lib/tomcat5/webapps/rhn/WEB-INF/lib/java-branding.jar

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%dir /%{_var}/www/html/css
/%{_var}/www/html/css/*
%dir /%{_var}/www/html/img
/%{_var}/www/html/img/*
%dir /%{_var}/www/html/templates
/%{_var}/www/html/templates/*
/%{_var}/www/html/templates/.htaccess
%dir /%{_var}/www/html/nav/styles
/%{_var}/www/html/nav/styles/*
%{_datadir}/spacewalk/

%files jar
%{_datadir}/rhn/lib/java-branding.jar
%{_var}/lib/tomcat5/webapps/rhn/WEB-INF/lib/java-branding.jar


%changelog
* Wed Jan 28 2009 Mike McCune <mmccune@gmail.com> 0.5.3-1
- split out branding jar into its own subpackage.

* Wed Jan 21 2009 Michael Mraka <michael.mraka@redhat.com> 0.5.1-1
- modified branding according to jsp layout changes

* Mon Dec 22 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.1-1
- added spacewalk-public.cert and spacewalk-cert.conf

* Thu Oct 23 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.1.6-1
- fix square corner on left tab.

* Fri Aug 29 2008 Jesus M. Rodriguez <jesusr@redhat.com> 0.1.5-1
- bz: 460313  css fix for search bar in top right header.

* Tue Aug 12 2008 Devan Goodwin 0.1.4-0
- Adding nav styles.

* Thu Aug 07 2008 Devan Goodwin 0.1.3-0
- Adding templates.

* Wed Aug  6 2008 Jan Pazdziora 0.1.2-0
- decrease version to 0.1.*
- tag for rebuild

* Mon Aug 04 2008  Miroslav Suchy <msuchy@redhat.com>
- fix dependecies, requires spacewalk-html
- bump version

* Wed Jul 30 2008  Devan Goodwin <dgoodwin@redhat.com> 0.2-2
- Adding images.

* Tue Jul 29 2008  Devan Goodwin <dgoodwin@redhat.com> 0.2-1
- Initial packaging.

