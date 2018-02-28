%if 0%{?suse_version}
%global apachedocroot /srv/www/htdocs
%else
%global apachedocroot %{_var}/www/html
%endif

Name:           roboto
Version:        1.3
Release:        2%{?dist}
Summary:        Roboto font

License:        Apache Software License v2
URL:            http://developer.android.com/design/style/typography.html
Source0:        http://developer.android.com/downloads/design/roboto-1.3.tar.gz
%if 0%{?suse_version}
BuildRequires:  unzip
%endif
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
rm -f Roboto_v1.3/*/{Icon,.DS_Store}
cp -a Roboto_v1.3/Roboto Roboto_v1.3/RobotoCondensed %{buildroot}%{apachedocroot}/fonts/

%clean
rm -rf %{buildroot}


%files
%doc
%{apachedocroot}/fonts/Roboto
%if 0%{?suse_version}
%dir %{apachedocroot}/fonts
%endif

%files condensed
%{apachedocroot}/fonts/RobotoCondensed
%if 0%{?suse_version}
%dir %{apachedocroot}/fonts
%endif

%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 1.3-2
- removed %%%%defattr from specfile
- removed Group from specfile
- removed BuildRoot from specfiles

* Fri Jan 20 2017 Grant Gainey 1.3-1
- 1208421 - Update Roboto fonts

* Tue May 10 2016 Grant Gainey 1.2-3
- roboto: build on openSUSE

* Fri Jan 17 2014 Michael Mraka <michael.mraka@redhat.com> 1.2-2
- koji build needs Group specified

* Fri Jan 17 2014 Michael Mraka <michael.mraka@redhat.com> 1.2-1
- initial build of roboto package


