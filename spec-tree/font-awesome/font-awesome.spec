%if 0%{?suse_version}
%global apachedocroot /srv/www/htdocs
%else
%global apachedocroot %{_var}/www/html
%endif

Name:           font-awesome
Version:        4.7.0
Release:        1%{?dist}
Summary:        The iconic font designed for Bootstrap

License:        OFL 1.1 and MIT
URL:            https://fontawesome.com/
Source0:        https://fontawesome.com/v4.7.0/assets/font-awesome-4.7.0.zip
%if 0%{?suse_version}
BuildRequires:  unzip
%endif
BuildArch:      noarch

%description
Font Awesome gives you scalable vector icons that can instantly be customized — size,
color, drop shadow, and anything that can be done with the power of CSS.

%package devel
Summary:       Less and Scss files for Font Awesome development

%description devel
Less and Scss files for Font Awesome development.

%prep
%setup -q


%build


%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{apachedocroot}/fonts/font-awesome
install -d -m 755 %{buildroot}%{_datadir}/font-awesome

for dir in css fonts ; do
    install -d -m 755 %{buildroot}%{apachedocroot}/fonts/font-awesome/$dir
    for file in $dir/* ; do
         install -m 644 $file %{buildroot}%{apachedocroot}/fonts/font-awesome/$dir/
    done
done

for dir in less scss ; do
    install -d -m 755 %{buildroot}%{_datadir}/font-awesome/$dir
    for file in $dir/* ; do
         install -m 644 $file %{buildroot}%{_datadir}/font-awesome/$dir/
    done
done

%clean
rm -rf %{buildroot}


%files
%{apachedocroot}/fonts/font-awesome
%if 0%{?suse_version}
%dir %{apachedocroot}/fonts
%endif

%files devel
%{_datadir}/font-awesome


%changelog
* Wed Mar 11 2020 Stefan Bluhm <stefan.bluhm@clacee.eu> 4.7.0-1
- Updated font-awesome version to 4.7.0
- Updated URL and Source0 links

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 4.0.3-3
- removed %%%%defattr from specfile
- removed Group from specfile
- removed BuildRoot from specfiles

* Tue May 10 2016 Grant Gainey 4.0.3-2
- font-awesome: build on openSUSE

* Fri Jan 17 2014 Michael Mraka <michael.mraka@redhat.com> 4.0.3-1
- initial build of font-awesome package


