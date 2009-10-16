Summary: Spacewalk packages yum repository configuration.
Name: spacewalk-repo
Version: 0.7
Release: 2%{?dist}
License: GPL
Group: Development
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd spec-tree/spacewalk-repo
# make test-srpm
URL:          https://fedorahosted.org/spacewalk
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch: noarch

%description
This package contains the Spacewalk repository configuration for yum.

%prep
mkdir -p $RPM_BUILD_ROOT

%build

%install
rm -rf $RPM_BUILD_ROOT

# some sane default value
%define reposubdir      RHEL/5
# redefine on fedora
%{?fedora: %define reposubdir      Fedora/%{fedora}}

mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
cat >>$RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/spacewalk.repo <<REPO
[spacewalk]
name=Spacewalk
baseurl=http://spacewalk.redhat.com/yum/%{version}/%{reposubdir}/\$basearch/
gpgkey=http://spacewalk.redhat.com/yum/RPM-GPG-KEY-spacewalk
enabled=1
gpgcheck=1
REPO

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%config %{_sysconfdir}/yum.repos.d/spacewalk.repo

%changelog
* Mon Aug 10 2009 jesus m. rodriguez 0.7.0-2
- rename rhel to RHEL
- rename fedora to Fedora
- remove Server from 5Server

* Thu Apr 30 2009 Jan Pazdziora 0.6-1
- bump version to 0.6

* Tue Mar 31 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.2-1
- rebuilding for 0.5

* Thu Jan 15 2009 Jan Pazdziora 0.4-1
- building new version to point to 0.4 repo

* Fri Oct 24 2008 Michael Mraka <michael.mraka@redhat.com> 0.3-1
- Initial release
