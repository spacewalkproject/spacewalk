%if 0%{?suse_version}
%global apachedocroot /srv/www/htdocs
%else
%global apachedocroot %{_var}/www/html
%endif

Name:           roboto
Version:        1.2
Release:        3%{?dist}
Summary:        Roboto font

Group:          Application/Internet
License:        Apache Software License v2
URL:            http://developer.android.com/design/style/typography.html
Source0:        http://developer.android.com/downloads/design/roboto-1.2.zip
%if 0%{?suse_version}
BuildRequires:  unzip
%endif
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:      noarch

%description
Roboto has a dual nature. It has a mechanical skeleton and the forms are largely
geometric. At the same time, the font features friendly and open curves. While some
grotesks distort their letterforms to force a rigid rhythm, Roboto doesn’t
compromise, allowing letters to be settle in to their natural width. This makes for a
more natural reading rhythm more commonly found in humanist and serif types.

This is the normal family, which can be used alongside the Roboto Condensed family
and the Roboto Slab family.

%package condensed
Summary:        Roboto Condensed font
Group:          Application/Internet

%description condensed
Roboto has a dual nature. It has a mechanical skeleton and the forms are largely
geometric. At the same time, the font features friendly and open curves. While some
grotesks distort their letterforms to force a rigid rhythm, Roboto doesn’t
compromise, allowing letters to be settle in to their natural width. This makes for a
more natural reading rhythm more commonly found in humanist and serif types.

This is the normal family, which can be used alongside the Roboto Condensed family
and the Roboto Slab family.


%prep
%setup -q -c

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{apachedocroot}/fonts/
rm -f Roboto_v1.2/*/{Icon,.DS_Store}
cp -a Roboto_v1.2/Roboto Roboto_v1.2/RobotoCondensed %{buildroot}%{apachedocroot}/fonts/

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%doc
%{apachedocroot}/fonts/Roboto
%if 0%{?suse_version}
%dir %{apachedocroot}/fonts
%endif

%files condensed
%defattr(-,root,root,-)
%{apachedocroot}/fonts/RobotoCondensed
%if 0%{?suse_version}
%dir %{apachedocroot}/fonts
%endif

%changelog
* Tue May 10 2016 Grant Gainey 1.2-3
- roboto: build on openSUSE

* Fri Jan 17 2014 Michael Mraka <michael.mraka@redhat.com> 1.2-2
- koji build needs Group specified

* Fri Jan 17 2014 Michael Mraka <michael.mraka@redhat.com> 1.2-1
- initial build of roboto package


