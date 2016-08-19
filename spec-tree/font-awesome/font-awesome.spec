%if 0%{?suse_version}
%global apachedocroot /srv/www/htdocs
%else
%global apachedocroot %{_var}/www/html
%endif

Name:           font-awesome
Version:        4.0.3
Release:        2%{?dist}
Summary:        The iconic font designed for Bootstrap

Group:          Application/Internet
License:        OFL 1.1 and MIT
URL:            http://fontawesome.io/
Source0:        http://fontawesome.io/assets/font-awesome-4.0.3.zip
%if 0%{?suse_version}
BuildRequires:  unzip
%endif
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:      noarch

%description
Font Awesome gives you scalable vector icons that can instantly be customized — size,
color, drop shadow, and anything that can be done with the power of CSS.

%package devel
Summary:       Less and Scss files for Font Awesome development
Group:         Application/Development

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
%defattr(-,root,root,-)
%{apachedocroot}/fonts/font-awesome
%if 0%{?suse_version}
%dir %{apachedocroot}/fonts
%endif

%files devel
%defattr(-,root,root,-)
%{_datadir}/font-awesome


%changelog
* Tue May 10 2016 Grant Gainey 4.0.3-2
- font-awesome: build on openSUSE

* Fri Jan 17 2014 Michael Mraka <michael.mraka@redhat.com> 4.0.3-1
- initial build of font-awesome package


