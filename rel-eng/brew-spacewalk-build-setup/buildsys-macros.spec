
Name:		buildsys-macros
Summary:	Setup the dist tag in brew -build tag
Version:	0.9
Release:	2%(echo %dist | sed 's!\.sw$!!').sw
Group:		Development/Buildsystem
License:	GPLv2
BuildArch:	noarch

BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root

%prep

%build

%install

rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/etc/rpm/
echo '%%dist %dist' | sed 's!\(\.sw\)\?$!.sw!' > $RPM_BUILD_ROOT/etc/rpm/macros.spacewalk-disttag

%clean

rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
/etc/rpm/macros.spacewalk-disttag

%description 
We need to build git-sources packages of spacewalk in brew with
different NVR than those of Satellite, to avoid clashes between two
builds with exactly the same NVR. This package brings new file
/etc/rpm/macros.spacewalk-disttag with dist properly set.

%changelog
* Fri Jun 13 2008 Jan Pazdziora 0.9-2
- Initial release.

