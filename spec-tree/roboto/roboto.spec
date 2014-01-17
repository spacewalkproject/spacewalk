Name:           roboto
Version:        1.2
Release:        2%{?dist}
Summary:        Roboto font

Group:          Application/Internet
License:        Apache Software License v2
URL:            http://developer.android.com/design/style/typography.html
Source0:        http://developer.android.com/downloads/design/roboto-1.2.zip
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
install -d -m 755 %{buildroot}%{_var}/www/html/fonts/
rm -f Roboto_v1.2/*/{Icon,.DS_Store}
cp -a Roboto_v1.2/Roboto Roboto_v1.2/RobotoCondensed %{buildroot}%{_var}/www/html/fonts/

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%doc
%{_var}/www/html/fonts/Roboto

%files condensed
%defattr(-,root,root,-)
%{_var}/www/html/fonts/RobotoCondensed


%changelog
* Fri Jan 17 2014 Michael Mraka <michael.mraka@redhat.com> 1.2-2
- koji build needs Group specified

* Fri Jan 17 2014 Michael Mraka <michael.mraka@redhat.com> 1.2-1
- initial build of roboto package


