%define rhnroot %{_datadir}/rhn

Name:        spacecmd
Version:     0.4.1
Release:     1%{?dist}
Summary:     Command-line interface to Spacewalk and Satellite servers

Group:       Applications/System
License:     GPL
URL:         http://github.com/aparsons/spacecmd
Source:      %{name}-%{version}.tar.gz
BuildRoot:   %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:   noarch

Requires:    python >= 2.4

%description
spacecmd is a command-line interface to Spacewalk and Satellite servers

%prep
%setup -q

%build
# nothing to build

%install
rm -rf %{buildroot}

mkdir -p %{buildroot}/%{_bindir}
install -m0755 src/bin/spacecmd %{buildroot}/%{_bindir}/

mkdir -p %{buildroot}/%{_sysconfdir}/bash_completion.d
install -m0644 src/misc/spacecmd-bash-completion %{buildroot}/%{_sysconfdir}/bash_completion.d/spacecmd

mkdir -p %{buildroot}/%{rhnroot}/spacecmd
install -m0644 src/lib/*.py %{buildroot}/%{rhnroot}/spacecmd/

mkdir -p %{buildroot}/%{_mandir}/man1
gzip -c src/doc/spacecmd.1 > %{buildroot}/%{_mandir}/man1/spacecmd.1.gz

touch %{buildroot}/%{rhnroot}/spacecmd/__init__.py
chmod 0644 %{buildroot}/%{rhnroot}/spacecmd/__init__.py

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_bindir}/spacecmd
%dir %{rhnroot}/spacecmd
%{rhnroot}/spacecmd/*
%{_sysconfdir}/bash_completion.d/spacecmd
%doc doc/README doc/COPYING
%doc %{_mandir}/man1/spacecmd.1.gz

%changelog
* Wed Jul 07 2010 aparsons <aron@redhat.com> 0.4.1-1
- new package built with tito

* Tue Jul 06 2010 Paul Morgan <pmorgan@redhat.com> - 0.4.1-1
- ADD: support for builds via tito
- CHANGE: x.y.z versioning (better for tito)
- tagged man page as doc 

* Thu Jul 01 2010 Aron Parsons <aparsons@redhat.com> - 0.4-1
- version bump
- added a man page

* Fri Jun 25 2010 Aron Parsons <aparsons@redhat.com> - 0.3-1
- version bump
- added bash-completion support

* Mon Jun 21 2010 Aron Parsons <aparsons@redhat.com> - 0.2-1
- version bump

* Mon Jun 21 2010 Aron Parsons <aparsons@redhat.com> - 0.1-4
- added distribution headings
- added a copy of the GPL

* Thu Apr 29 2010 Aron Parsons <aparsons@redhat.com> - 0.1-3
- just touch __init__.py, no reason to version control an empty file

* Wed Apr 28 2010 Aron Parsons <aparsons@redhat.com> - 0.1-2
- moved SpacewalkShell.py to /usr/share/rhn/spacecmd

* Tue Apr 27 2010 Paul Morgan <pmorgan@redhat.com> - 0.1-1
- initial packaging
