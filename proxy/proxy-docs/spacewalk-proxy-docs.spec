Name: spacewalk-proxy-docs
Summary: Spacewalk Proxy Server Documentation
Group: Applications/Internet
License: Open Publication
URL:     https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 2.5.0
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
Obsoletes: rhns-proxy-docs < 5.3.0
Provides: rhns-proxy-docs = 5.3.0

%description
This package includes the installation/configuration guide,
and whitepaper in support of an Spacewalk Proxy Server. Also included
are the Client Configuration, Channel Management,
and Enterprise User Reference guides.

%prep
%setup -q

%build
#nothing to do here

%install
rm -rf $RPM_BUILD_ROOT
install -m 755 -d $RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files
%doc *.pdf
%doc LICENSE
%doc squid.conf.sample

%changelog
* Wed Jan 14 2015 Matej Kollar <mkollar@redhat.com> 2.3.1-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files
- Bumping package versions for 2.3.
- Bumping package versions for 2.2.
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.2-1
- removed old CVS/SVN version ids

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.1-1
- rebranding RHN Proxy to Red Hat Proxy
- Bumping package versions for 1.9
- Bumping package versions for 1.9.
- %%defattr is not needed since rpm 4.4
- Bumping package versions for 1.8.
- Bumping package versions for 1.7.
- Bumping package versions for 1.6.
- Bumping package versions for 1.5
- Bumping package versions for 1.4
- Bumping package versions for 1.3.

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- rebuild for spacewalk 0.8

* Wed May 20 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.2-1
- clarify the license. It is Open Publication instead of GPLv2

* Thu May 14 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.1-1
- 497892 - create access.log on rhel5
- point source0 to fedorahosted.org
- provide versioned Provides: to Obsolete:
- make rpmlint happy
- change buildroot to recommended value
- marking documentation files as %%doc

* Tue Dec  9 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.1-1
- fixed Obsoletes: rhns-* < 5.3.0

* Thu Aug  7 2008 Miroslav Suchy <msuchy@redhat.com> 0.1-2
- Rename to spacewalk-proxy-docs
- clean up spec

* Thu Apr 10 2008 Miroslav Suchy <msuchy@redhat.com>
- Isolate from rhns-proxy

