%if ! (0%{?fedora} > 12 || 0%{?rhel} > 5)
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%{!?python_sitearch: %global python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(1))")}
%endif

Name:        spacewalk-remote-utils
Version:     1.0.0
Release:     1%{?dist}
Summary:     Command-line interface to Spacewalk and Satellite servers

Group:       Applications/System
License:     GPLv3+
URL:         https://fedorahosted.org/spacewalk/wiki/spacecmd
Source:      %{name}-%{version}.tar.gz
BuildRoot:   %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:   noarch

BuildRequires: python-devel

%description
spacecmd is a command-line interface to Spacewalk and Satellite servers

%prep
%setup -q

%build
docbook2man ./spacewalk-create-channel/doc/spacewalk-create-channel.sgml -o ./spacewalk-create-channel/doc/

%install
%{__rm} -rf %{buildroot}

%{__mkdir_p} %{buildroot}/%{_bindir}
%{__install} -p -m0755 spacewalk-create-channel/spacewalk-create-channel %{buildroot}/%{_bindir}/

%{__mkdir_p} %{buildroot}/%{_datadir}/channel-data
%{__install} -p -m0644 spacewalk-create-channel/data/* %{buildroot}/%{_datadir}/channel-data/

%{__mkdir_p} %{buildroot}/%{_mandir}/man1
%{__gzip} -c ./spacewalk-create-channel/doc/spacewalk-create-channel.1 > %{buildroot}/%{_mandir}/man1/spacecwalk-create-channel.1.gz

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_bindir}/spacewalk-create-channel
#%{python_sitelib}/spacecmd/
%{_datadir}/channel-data/

%doc spacewalk-create-channel/doc/README spacewalk-create-channel/doc/COPYING
%doc %{_mandir}/man1/spacecwalk-create-channel.1.gz

%changelog
* Fri Aug 20 2010 Justin Sherrill <jsherril@redhat.com> 1.0.0-0
- Initial build.  (jlsherrill@redhat.com)

