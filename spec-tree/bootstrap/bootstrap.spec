%if 0%{?suse_version}
%global apachedocroot /srv/www/htdocs
%global apacheconfd %{_sysconfdir}/apache2/conf.d
%else
%global apachedocroot %{_var}/www/html
%global apacheconfd %{_sysconfdir}/httpd/conf.d
%endif

Name:           bootstrap
Version:        3.0.0
Release:        8%{?dist}
Summary:        Sleek, intuitive, and powerful mobile first front-end framework for faster and easier web development.

License:        Apache Software License v2
URL:            http://getbootstrap.com/
Source0:        https://github.com/twbs/bootstrap/archive/v3.0.0.tar.gz
Source1:        httpd-bootstrap-less.conf
%if 0%{?suse_version}
Requires(pre):  apache2
%endif
BuildArch:      noarch

%description
Bootstrap is sleek, intuitive, and powerful mobile first front-end framework for faster and easier web development.

Originally created by a designer and a developer at Twitter, Bootstrap has become one
of the most popular front-end frameworks and open source projects in the world.

%package less
Summary:        .less files for bootstrap framework customization.
Requires: %{name} = %{version}-%{release}

%description less
.less files for bootstrap framework customization.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{apacheconfd}
install -d -m 755 %{buildroot}%{apachedocroot}/fonts
install -d -m 755 %{buildroot}%{apachedocroot}/javascript
install -d -m 755 %{buildroot}%{_datadir}/bootstrap
install -d -m 755 %{buildroot}%{_datadir}/bootstrap/less

install  -m 644 %{SOURCE1} %{buildroot}%{apacheconfd}/bootstrap-less.conf
for i in assets/js/jquery.js assets/js/less.js dist/js/bootstrap.js ; do
        install -m 644 $i %{buildroot}%{apachedocroot}/javascript/
done
for i in dist/fonts/* ; do
        install -m 644 $i %{buildroot}%{apachedocroot}/fonts/
done

for i in less/*.less ; do
        install -m 644 $i %{buildroot}%{_datadir}/bootstrap/less/
done


%clean
rm -rf %{buildroot}


%files
%{apachedocroot}/fonts/*
%{apachedocroot}/javascript/*
%if 0%{?suse_version}
%dir %{apachedocroot}/fonts
%dir %{apachedocroot}/javascript
%endif

%files less
%{apacheconfd}/bootstrap-less.conf
%{_datadir}/bootstrap



%changelog
* Wed Mar 11 2020 Stefan Bluhm <stefan.bluhm@clacee.eu> 3.0.0-8
- Updated bootstrap Source0 link.

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 3.0.0-7
- removed %%%%defattr from specfile
- removed Group from specfile
- removed BuildRoot from specfiles

* Tue May 10 2016 Grant Gainey 3.0.0-6
- 

* Tue May 10 2016 Grant Gainey 3.0.0-5
- bootstrap: build on openSUSE

* Thu Jan 16 2014 Michael Mraka <michael.mraka@redhat.com> 3.0.0-4
- Fix to use .less files in development mode (2)

* Mon Jan 13 2014 Michael Mraka <michael.mraka@redhat.com> 3.0.0-3
- allow to use .less files in development mode

* Thu Jan 09 2014 Michael Mraka <michael.mraka@redhat.com> 3.0.0-2
- koji build needs Group specified

* Thu Jan 09 2014 Michael Mraka <michael.mraka@redhat.com> 3.0.0-1
- initial packaging of twitter bootstrap framework



