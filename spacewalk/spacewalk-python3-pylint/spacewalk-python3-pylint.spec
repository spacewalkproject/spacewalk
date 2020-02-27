Name:		spacewalk-python3-pylint
Version:	2.11.0
Release:	1%{?dist}
Summary:	Pylint configuration for python3 spacewalk python packages

License:	GPLv2
URL:		https://github.com/spacewalkproject/spacewalk
Source0:	https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch:	noarch

%if 0%{?suse_version} >= 1320
Requires:	python3-pylint > 1.1
%else
%if 0%{?fedora} || 0%{?rhel} >= 7
Requires:	python3-pylint > 1.5
%else
Requires:	python3-pylint < 1.0
%endif
%endif
BuildRequires:	asciidoc
%if 0%{?mageia}
%if %{_arch} == x86_64
BuildRequires: lib64xslt1
%else
BuildRequires: libxslt1
%endif
%else
BuildRequires: libxslt
%endif
%if 0%{?rhel} && 0%{?rhel} < 6
BuildRequires:	docbook-style-xsl
%endif


%description
Pylint configuration fine tuned to check coding style of spacewalk python
packages.

%prep
%setup -q

%build
a2x -d manpage -f manpage spacewalk-python3-pylint.8.asciidoc

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}/%{_bindir}
install -p -m 755 spacewalk-python3-pylint %{buildroot}/%{_bindir}/
install -d -m 755 %{buildroot}/%{_sysconfdir}
install -p -m 644 spacewalk-python3-pylint.rc %{buildroot}/%{_sysconfdir}/
%if 0%{?rhel} && 0%{?rhel} < 7
# new checks in pylint 1.1
sed -i '/disable=/ s/,bad-whitespace,unpacking-non-sequence,superfluous-parens,cyclic-import//g;' \
        %{buildroot}%{_sysconfdir}/spacewalk-python3-pylint.rc
# new checks in pylint 1.0
sed -i '/disable=/ s/,C1001,W0121,useless-else-on-loop//g;' \
        %{buildroot}%{_sysconfdir}/spacewalk-python3-pylint.rc
%endif
%if 0%{?suse_version}
# new checks in pylint 1.2
sed -i '/disable=/ s/,bad-continuation//g;' \
        %{buildroot}%{_sysconfdir}/spacewalk-python3-pylint.rc
%endif
mkdir -p %{buildroot}/%{_mandir}/man8
install -m 644 spacewalk-python3-pylint.8 %{buildroot}/%{_mandir}/man8


%clean
rm -rf %{buildroot}


%files
%{_bindir}/spacewalk-python3-pylint
%config(noreplace)  %{_sysconfdir}/spacewalk-python3-pylint.rc
%doc %{_mandir}/man8/spacewalk-python3-pylint.8*
%doc LICENSE

%changelog
* Fri Nov 16 2018 Michael Mraka <michael.mraka@redhat.com> 2.9.3-1
- fix build on mageia i586

* Wed Oct 03 2018 Michael Mraka <michael.mraka@redhat.com> 2.9.1-1
- fix build on mageia
- Bumping package versions for 2.9.

* Mon Feb 12 2018 Eric Herget <eherget@redhat.com> 2.8.5-1
- Split spacewalk-pylint into spacewalk-python2-pylint and spacewalk-python3-pylint.  Original changelog maintained in spacewalk-python2-pylint package.

