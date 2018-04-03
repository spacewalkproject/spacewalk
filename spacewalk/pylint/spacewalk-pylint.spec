Name:		spacewalk-pylint
Version:	2.9.0
Release:	1%{?dist}
Summary:	Pylint configuration for spacewalk python packages

License:	GPLv2
URL:		https://github.com/spacewalkproject/spacewalk
Source0:	https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch:	noarch

%if 0%{?suse_version} >= 1320
Requires:	pylint > 1.1
%else
%if 0%{?fedora} || 0%{?rhel} >= 7
%if 0%{?fedora} >= 26
Requires:	python2-pylint > 1.5
%else
Requires:	pylint > 1.5
%endif
%else
Requires:	pylint < 1.0
%endif
%endif
BuildRequires:	asciidoc
BuildRequires:	libxslt
%if 0%{?rhel} && 0%{?rhel} < 6
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
%if 0%{?rhel} && 0%{?rhel} < 7
# new checks in pylint 1.1
sed -i '/disable=/ s/,bad-whitespace,unpacking-non-sequence,superfluous-parens,cyclic-import//g;' \
        %{buildroot}%{_sysconfdir}/spacewalk-pylint.rc
# new checks in pylint 1.0
sed -i '/disable=/ s/,C1001,W0121,useless-else-on-loop//g;' \
        %{buildroot}%{_sysconfdir}/spacewalk-pylint.rc
%endif
%if 0%{?suse_version}
# new checks in pylint 1.2
sed -i '/disable=/ s/,bad-continuation//g;' \
        %{buildroot}%{_sysconfdir}/spacewalk-pylint.rc
%endif
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
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.4-1
- removed Group from specfile

* Mon Nov 13 2017 Jan Dobes 2.8.3-1
- disable no-else-return check

* Thu Sep 07 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- removed unnecessary BuildRoot tag

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Wed Jun 07 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.2-1
- use python2 pylint even on Fedora 26+

* Wed May 24 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.1-1
- Fedora and EPEL7 contain pylint 1.5+
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Tue Aug 16 2016 Jan Dobes 2.6.2-1
- redefined-variable-type check is broken in pylint-1.5.6-1.fc24.noarch

* Mon Jun 13 2016 Grant Gainey 2.6.1-1
- spacewalk-pylint: require pylint > 1.1 for openSUSE
- Bumping package versions for 2.6.
- Bumping package versions for 2.5.
- Bumping package versions for 2.4.

* Wed Jan 14 2015 Matej Kollar <mkollar@redhat.com> 2.3.2-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Fri Aug 01 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.1-1
- disable reporting cyclic imports

* Mon Jun 30 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.10-1
- disable useless-else-on-loop also in pylint 1.0

* Fri Jun 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.9-1
- fixed  Invalid class attribute name
- fixed Else clause on loop without a break statement

* Fri Jun 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.8-1
- silenced Abstract class is only referenced 1 times
- fixed Invalid name

* Thu Jun 26 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.7-1
- fix condition for Fedora

* Mon Jun 23 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.6-1
- fixed pylint version for RHEL7

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.5-1
- spec file polish

* Wed Apr 02 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.4-1
- pylint in Fedora 19 has been updated to 1.1

* Thu Mar 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.3-1
- don't report optional parens as error

* Mon Mar 24 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.2-1
- pylint 1.1 landed in Fedora 20 updates

* Wed Mar 05 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.1-1
- disable pylint 1.1 checks we don't enforce

