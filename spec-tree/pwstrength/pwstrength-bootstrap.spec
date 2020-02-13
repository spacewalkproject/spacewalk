%if 0%{?suse_version}
%global apachedocroot /srv/www/htdocs
%else
%global apachedocroot %{_var}/www/html
%endif

Name:           pwstrength-bootstrap
Version:        1.0.2
Release:        6%{?dist}
License:        MIT or GPLv3
Summary:        Password quality Twitter Bootstrap Plugin
Url:            https://github.com/ablanco/jquery.pwstrength.bootstrap
Source0:        https://github.com/ablanco/jquery.pwstrength.bootstrap/archive/%{version}.tar.gz
Patch1:         pwstrength-bootstrap-%{version}.patch
BuildArch:      noarch

%description
The jQuery Password Strength Meter is a plugin for Twitter Bootstrap that provides rulesets for visualy displaying the quality of a users typed in password.

%prep
%setup -qn jquery.pwstrength.bootstrap-%{version}
%patch1

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{apachedocroot}/javascript
install -m 644 dist/pwstrength-bootstrap-%{version}.js %{buildroot}%{apachedocroot}/javascript

%clean
rm -rf %{buildroot}

%post

%postun

%files
%{apachedocroot}/javascript

%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 1.0.2-6
- removed %%%%defattr from specfile
- removed Group from specfile
- removed BuildRoot from specfiles

* Tue May 10 2016 Grant Gainey 1.0.2-5
- pwstrength-bootstrap: build on openSUSE

* Wed Nov 04 2015 Jan Dobes 1.0.2-4
- Fix license

* Tue Jan 28 2014 Matej Kollar <mkollar@redhat.com> 1.0.2-3
- Adding dist to the release to make build system happy(ier)

* Tue Jan 28 2014 Matej Kollar <mkollar@redhat.com> 1.0.2-2
- Un-bumping version number...

* Tue Jan 28 2014 Matej Kollar <mkollar@redhat.com> 1.0.3-1
- new package built with tito

* Tue Jan 28 2014 Maximilian Meister <mmeister@suse.de> 1.0.2-1
- initial packaging of pwstrength bootstrap plugin
