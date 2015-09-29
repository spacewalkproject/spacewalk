Name:		spacewalk-pylint
Version:	2.5.0
Release:	1%{?dist}
Summary:	Pylint configuration for spacewalk python packages

Group:		Development/Debuggers
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk
Source0:	https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:	noarch

%if 0%{?fedora}
Requires:	pylint > 1.1
%else
%if 0%{?rhel} > 6
Requires:	pylint > 1.0
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
%if 0%{?rhel}
# new checks in pylint 1.1
sed -i '/disable=/ s/,bad-whitespace,unpacking-non-sequence,superfluous-parens,cyclic-import//g;' \
        %{buildroot}%{_sysconfdir}/spacewalk-pylint.rc
%endif
%if 0%{?rhel} && 0%{?rhel} < 7
# new checks in pylint 1.0
sed -i '/disable=/ s/,C1001,W0121,useless-else-on-loop//g;' \
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

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 0.12-1
- ignore old-style-* pylint warnings for pylint-1.0

* Mon Jan 28 2013 Michael Mraka <michael.mraka@redhat.com> 0.11-1
- Revert "ignore Container implementation related warnings"

* Fri Jan 25 2013 Michael Mraka <michael.mraka@redhat.com> 0.10-1
- ignore Container implementation related warnings

* Sun Nov 11 2012 Michael Calmer <mc@suse.de> 0.9-1
- BuildRequire docbook-style-xsl only on redhat

* Wed Oct 24 2012 Michael Mraka <michael.mraka@redhat.com> 0.8-1
- Revert "put W1201 on list of ignored pylint warnings"

* Fri Aug 24 2012 Miroslav Suchý <msuchy@redhat.com> 0.7-1
- put W1201 on list of ignored pylint warnings

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

