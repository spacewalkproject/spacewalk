Name:       ycssmin
Version:    1.0.1
Release:    4%{?dist}
Summary:    CSS minification tool
License:    BSD
URL:        https://github.com/yui/ycssmin
Source0:    http://registry.npmjs.org/%{name}/-/%{name}-%{version}.tgz
BuildArch:  noarch

BuildRequires:  nodejs-devel

%description
ycssmin is a CSS minification tool.

It was originally based on the css minification tool used inside of YUI 
Compressor, based on code from Stoyan Stefanov and Isaac Schlueter.

%prep
%setup -q -n package

#drop spurious executable bit
chmod 0644 package.json cssmin.js

%build
#nothing to do

%install
mkdir -p %{buildroot}%{nodejs_sitelib}/%{name}
cp -pr bin cssmin.js package.json %{buildroot}%{nodejs_sitelib}/%{name}

mkdir -p %{buildroot}%{_bindir}
ln -sf ../lib/node_modules/%{name}/bin/cssmin %{buildroot}%{_bindir}/cssmin

%nodejs_symlink_deps

# yet another test framework that's not packaged yet :-(
#%%check
#istanbul cover --print both -- vows --spec ./tests/*.js

%files
%defattr(-,root,root,-)
%{nodejs_sitelib}/%{name}
%{_bindir}/cssmin
%doc README.md LICENSE

%changelog
* Tue Jun 24 2014 Michael Mraka <michael.mraka@redhat.com> 1.0.1-4
- ycssmin rebuilt for spacewalk

* Mon May 06 2013 T.C. Hollingsworth <tchollingsworth@gmail.com> - 1.0.1-3
- improve description
- drop spurious executable permissions
- drop EL5isms

* Fri Mar 15 2013 T.C. Hollingsworth <tchollingsworth@gmail.com> - 1.0.1-2
- typo fix

* Thu Mar 14 2013 T.C. Hollingsworth <tchollingsworth@gmail.com> - 1.0.1-1
- initial package
