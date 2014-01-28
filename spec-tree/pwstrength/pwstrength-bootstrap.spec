Name:           pwstrength-bootstrap
Version:        1.0.2
Release:        3%{?dist}
License:        MIT and GPLv3
Summary:        Password quality Twitter Bootstrap Plugin
Url:            https://github.com/ablanco/jquery.pwstrength.bootstrap
Group:          Applications/Internet
Source0:        https://github.com/ablanco/jquery.pwstrength.bootstrap/archive/%{version}.tar.gz
Patch1:         pwstrength-bootstrap-%{version}.patch
BuildArch:      noarch
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

%description
The jQuery Password Strength Meter is a plugin for Twitter Bootstrap that provides rulesets for visualy displaying the quality of a users typed in password.

%prep
%setup -qn jquery.pwstrength.bootstrap-%{version}
%patch1

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{_var}/www/html/javascript
install -m 644 dist/pwstrength-bootstrap-%{version}.js %{buildroot}%{_var}/www/html/javascript

%clean
rm -rf %{buildroot}

%post

%postun

%files
%defattr(-,root,root,-)
%{_var}/www/html/javascript
%{_var}/www/html/javascript/*

%changelog
* Tue Jan 28 2014 Matej Kollar <mkollar@redhat.com> 1.0.2-3
- Adding dist to the release to make build system happy(ier)

* Tue Jan 28 2014 Matej Kollar <mkollar@redhat.com> 1.0.2-2
- Un-bumping version number...

* Tue Jan 28 2014 Matej Kollar <mkollar@redhat.com> 1.0.3-1
- new package built with tito

* Tue Jan 28 2014 Maximilian Meister <mmeister@suse.de> 1.0.2-1
- initial packaging of pwstrength bootstrap plugin
