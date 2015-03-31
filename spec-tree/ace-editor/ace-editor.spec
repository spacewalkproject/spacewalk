#
# spec file for package ace-editor
#
# Copyright (c) 2013 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

%if 0%{?suse_version}
%global httpd apache2
%else
%global httpd httpd
%endif

Name:           ace-editor
Version:        1.1.3
Release:        2%{?dist}
License:        BSD-3-Clause
Summary:        High performance code editor for the web
Url:            http://ace.c9.io/
Group:          Development/Libraries/Other
Source0:        https://github.com/ajaxorg/ace-builds/archive/v%{version}.tar.gz#/ace-builds-%{version}.tar.gz
Source1:        ace-editor.conf
%if 0%{?suse_version}
BuildRequires:  fdupes
BuildRequires:  apache2
%endif
BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
TAce is an embeddable code editor written in JavaScript.
It matches the features and performance of native editors such as Sublime, Vim and TextMate.
It can be easily embedded in any web page and JavaScript application.
Ace is maintained as the primary editor for Cloud9 IDE and is the successor of the
Mozilla Skywriter (Bespin) project.

%prep
%setup -q -n ace-builds-%{version}

%build

%install
%{__mkdir_p} %{buildroot}%{_datadir}/ace-editor

cp -r src %{buildroot}%{_datadir}/ace-editor/src
cp -r src-min %{buildroot}%{_datadir}/ace-editor/src-min
cp -r src %{buildroot}%{_datadir}/ace-editor/src-noconflict
cp -r src-min %{buildroot}%{_datadir}/ace-editor/src-min-noconflict

%{__mkdir_p} %{buildroot}%{_sysconfdir}/%{httpd}/conf.d
%{__install} -m 644 %{SOURCE1} %{buildroot}%{_sysconfdir}/%{httpd}/conf.d/ace-editor.conf

%if 0%{?suse_version}
%fdupes %{buildroot}%{_datadir}/ace-editor
%endif

%files
%defattr(-,root,root)
%doc LICENSE ChangeLog.txt README.md
%{_datadir}/ace-editor
%config(noreplace) %{_sysconfdir}/%{httpd}/conf.d/*.conf

%changelog
* Fri Apr 25 2014 Michael Mraka <michael.mraka@redhat.com> 1.1.3-2
- missing dist in release

* Fri Apr 25 2014 Michael Mraka <michael.mraka@redhat.com> 1.1.3-1
- initial build of ace-editor



