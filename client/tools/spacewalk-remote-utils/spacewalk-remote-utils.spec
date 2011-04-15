%if ! (0%{?fedora} > 12 || 0%{?rhel} > 5)
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%{!?python_sitearch: %global python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(1))")}
%endif

Name:        spacewalk-remote-utils
Version:     1.5.0
Release:     1%{?dist}
Summary:     Utilities to interact with a RHN Satellite or Spacewalk server remotely.

Group:       Applications/System
License:     GPLv3+
URL:         http://fedorahosted.org/spacewalk
Source:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:   %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:   noarch

Requires:    rhnlib >= 2.5.38
BuildRequires: python-devel
BuildRequires: docbook-utils
%if 0%{?suse_version}
# provide directories for filelist check in OBS
BuildRequires: rhn-client-tools
%endif

%description
Utilities to interact with a RHN Satellite or Spacewalk server remotely over XMLRPC.

%prep
%setup -q

%build
docbook2man ./spacewalk-create-channel/doc/spacewalk-create-channel.sgml -o ./spacewalk-create-channel/doc/

%install
%{__rm} -rf %{buildroot}

%{__mkdir_p} %{buildroot}/%{_bindir}
%{__install} -p -m0755 spacewalk-create-channel/spacewalk-create-channel %{buildroot}/%{_bindir}/

%{__mkdir_p} %{buildroot}/%{_datadir}/rhn/channel-data
%{__install} -p -m0644 spacewalk-create-channel/data/* %{buildroot}/%{_datadir}/rhn/channel-data/

%{__mkdir_p} %{buildroot}/%{_mandir}/man1
%{__gzip} -c ./spacewalk-create-channel/doc/spacewalk-create-channel.1 > %{buildroot}/%{_mandir}/man1/spacewalk-create-channel.1.gz

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_bindir}/spacewalk-create-channel
#%{python_sitelib}/spacecmd/
%{_datadir}/rhn/channel-data/

%doc spacewalk-create-channel/doc/README spacewalk-create-channel/doc/COPYING
%doc %{_mandir}/man1/spacewalk-create-channel.1.gz

%changelog
* Fri Apr 08 2011 Miroslav Suchý 1.4.7-1
- Revert "idn_unicode_to_pune() have to return string" (msuchy@redhat.com)

* Tue Apr 05 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.6-1
- idn_unicode_to_pune() has to return string

* Wed Mar 30 2011 Miroslav Suchý 1.4.5-1
- 683200 - support IDN

* Wed Mar 16 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.4-1
- allowing input of 0 insteado f 'gold' in spacewalk-create-channel
  (jsherril@redhat.com)
- replace dead code with default from optparse

* Tue Mar 08 2011 Justin Sherrill <jsherril@redhat.com> 1.4.3-1
- adding new data files for spacewalk-create-channel (jsherril@redhat.com)
- updating spacewalk-create-channel to properly support RHEL 6 and added
  supplementary repos for it (jsherril@redhat.com)

* Mon Mar 07 2011 Jan Pazdziora 1.4.2-1
- Fixing description of the -u/--update option in spacewalk-create-channel man
  page. (luc@delouw.ch)

* Thu Feb 03 2011 Justin Sherrill <jsherril@redhat.com> 1.4.1-1
- Adding RHEL 5.6 data files for spacewalk-create-channel (jsherril@redhat.com)

* Tue Oct 12 2010 Jan Pazdziora 1.0.5-1
- correct Summary and Description (msuchy@redhat.com)
- correct URL and Source0 (msuchy@redhat.com)
- man page formatting fix (jsherril@redhat.com)
- man page formatting fix (jsherril@redhat.com)
- fixing man page name (jsherril@redhat.com)

* Tue Oct 05 2010 Justin Sherrill <jsherril@redhat.com> 1.0.4-1
- adding RHEL 6 data files for spacewalk-create-channel (jsherril@redhat.com)
- adding initial support for RHEL 6 to spacewalk-create-channel
  (jsherril@redhat.com)
- updating readme for spacewalk-create-channel (jsherril@redhat.com)

* Thu Sep 30 2010 Justin Sherrill <jsherril@redhat.com> 1.0.3-1
- updating spacewalk-remote-utils man page to remove left over bits from copied
  spec (jsherril@redhat.com)

* Mon Sep 20 2010 Shannon Hughes <shughes@redhat.com> 1.0.2-1
- adding docbook-utils build require (shughes@redhat.com)

* Mon Sep 20 2010 Shannon Hughes <shughes@redhat.com> 1.0.1-1
- new package built with tito

* Fri Aug 20 2010 Justin Sherrill <jsherril@redhat.com> 1.0.0-0
- Initial build.  (jlsherrill@redhat.com)

