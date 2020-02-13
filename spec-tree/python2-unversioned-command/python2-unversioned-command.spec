Name:		python2-unversioned-command
Version:	2.7.16.1
Release:	1%{?dist}
Summary:	The "python" command that runs Python 2

License:	Python
URL:		https://www.python.org/

%description
This package contains /usr/bin/python - the "python" command that runs Python 2.

%prep


%build


%install
mkdir -p %{buildroot}/usr/bin
ln -s python2 %{buildroot}/usr/bin/python

%files
/usr/bin/python



%changelog
* Mon Sep 23 2019 Michael Mraka <michael.mraka@redhat.com> - 2.7.16.1-1
- initial buld

