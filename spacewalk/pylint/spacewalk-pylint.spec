Name:		spacewalk-pylint
Version:	0.6
Release:	1%{?dist}
Summary:	Pylint configuration for spacewalk python packages

Group:		Development/Debuggers
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk
Source0:	https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:	noarch

Requires:	pylint
BuildRequires:	asciidoc
BuildRequires:	libxslt
%if 0%{?rhel} < 6
BuildRequires:	docbook-style-xsl
%endif


%description
Pylint configuration fine tuned to check coding style of spacewalk python
packages.

%prep
%setup -q

%build
a2x -d manpage -f manpage spacewalk-pylint.8.asciidoc

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}/%{_bindir}
install -p -m 755 spacewalk-pylint %{buildroot}/%{_bindir}/
install -d -m 755 %{buildroot}/%{_sysconfdir}
install -p -m 644 spacewalk-pylint.rc %{buildroot}/%{_sysconfdir}/
mkdir -p %{buildroot}/%{_mandir}/man8
install -m 644 spacewalk-pylint.8 %{buildroot}/%{_mandir}/man8


%clean
rm -rf %{buildroot}


%files
%{_bindir}/spacewalk-pylint
%config(noreplace)  %{_sysconfdir}/spacewalk-pylint.rc
%doc %{_mandir}/man8/spacewalk-pylint.8*
%doc LICENSE

%changelog
* Fri Aug 24 2012 Michael Mraka <michael.mraka@redhat.com> 0.6-1
- let's silence pylint on our large modules and objects

* Mon Jun 04 2012 Miroslav Suchý <msuchy@redhat.com> 0.5-1
- %%defattr is not needed since rpm 4.4 (msuchy@redhat.com)

* Wed May 16 2012 Miroslav Suchý <msuchy@redhat.com> 0.4-1
- 800899 - consistently use macros
- 800899 - include license file
- Spacewalk is released under GPLv2, lets stick to it

* Wed Mar 07 2012 Miroslav Suchý 0.3-1
- add man page
- Description lines must not exceed 80 characters
- Summary must begin with capital letter

* Wed Feb 15 2012 Michael Mraka <michael.mraka@redhat.com> 0.2-1
- made it noarch package

* Wed Feb 15 2012 Michael Mraka <michael.mraka@redhat.com> 0.1-1
- new package built with tito

