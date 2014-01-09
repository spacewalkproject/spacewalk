Name:           bootstrap
Version:        3.0.0
Release:        2%{?dist}
Summary:        Sleek, intuitive, and powerful mobile first front-end framework for faster and easier web development.

Group:          Applications/Internet
License:        Apache Software License v2
URL:            http://getbootstrap.com/
Source0:        https://github.com/twbs/bootstrap/archive/bootstrap-3.0.0.tar.gz
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:      noarch

%description
Bootstrap is sleek, intuitive, and powerful mobile first front-end framework for faster and easier web development.

Originally created by a designer and a developer at Twitter, Bootstrap has become one
of the most popular front-end frameworks and open source projects in the world.

%package less
Summary:        .less files for bootstrap framework customization.
Group:          Applications/Internet
Requires: %{name} = %{version}-%{release}

%description less
.less files for bootstrap framework customization.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{_var}/www/html/fonts
install -d -m 755 %{buildroot}%{_var}/www/html/javascript
install -d -m 755 %{buildroot}%{_datadir}/bootstrap
install -d -m 755 %{buildroot}%{_datadir}/bootstrap/less

for i in assets/js/jquery.js assets/js/less.js dist/js/bootstrap.js ; do
        install -m 644 $i %{buildroot}%{_var}/www/html/javascript/
done
for i in dist/fonts/* ; do
        install -m 644 $i %{buildroot}%{_var}/www/html/fonts/
done

for i in less/*.less ; do
        install -m 644 $i %{buildroot}%{_datadir}/bootstrap/less/
done


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{_var}/www/html/fonts/*
%{_var}/www/html/javascript/*

%files less
%defattr(-,root,root,-)
%{_datadir}/bootstrap/



%changelog
* Thu Jan 09 2014 Michael Mraka <michael.mraka@redhat.com> 3.0.0-2
- koji build needs Group specified

* Thu Jan 09 2014 Michael Mraka <michael.mraka@redhat.com> 3.0.0-1
- initial packaging of twitter bootstrap framework



