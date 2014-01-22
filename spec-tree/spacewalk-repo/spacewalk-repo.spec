Summary: Spacewalk packages yum repository configuration
Name: spacewalk-repo
Version: 2.1.1
Release: 1%{?dist}
License: GPLv2
Group: System Environment/Base
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

%package -n spacewalk-client-repo
Summary: Spacewalk client packages yum repository configuration
Group: System Environment/Base

%description -n spacewalk-client-repo
This package contains the Spacewalk repository configuration for yum.

%prep
mkdir -p $RPM_BUILD_ROOT

%build

%install
rm -rf $RPM_BUILD_ROOT

# some sane default value
%define reposubdir      RHEL/%{rhel}
# redefine on fedora
%{?fedora: %define reposubdir      Fedora/\$releasever}

mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
cat >>$RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/spacewalk.repo <<REPO
[spacewalk]
name=Spacewalk
baseurl=http://yum.spacewalkproject.org/%{version}/%{reposubdir}/\$basearch/
gpgkey=http://yum.spacewalkproject.org/RPM-GPG-KEY-spacewalk-2012
enabled=1
gpgcheck=1
REPO

cat >>$RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/spacewalk-client.repo <<REPO
[spacewalk-client]
name=Spacewalk Client Tools
baseurl=http://yum.spacewalkproject.org/%{version}-client/%{reposubdir}/\$basearch/
gpgkey=http://yum.spacewalkproject.org/RPM-GPG-KEY-spacewalk-2012
enabled=1
gpgcheck=1
REPO

cat >>$RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/spacewalk-source.repo <<REPO
[spacewalk-source]
name=Spacewalk SRPMS
baseurl=http://yum.spacewalkproject.org/%{version}/%{reposubdir}/source/
gpgkey=http://yum.spacewalkproject.org/RPM-GPG-KEY-spacewalk-2012
enabled=0
gpgcheck=1
REPO

cat >>$RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/spacewalk-nightly.repo <<REPO
[spacewalk-nightly]
name=Spacewalk nightly
baseurl=http://yum.spacewalkproject.org/nightly/%{reposubdir}/\$basearch/
gpgkey=http://yum.spacewalkproject.org/RPM-GPG-KEY-spacewalk-2012
enabled=0
gpgcheck=0
REPO

cat >>$RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/spacewalk-client-nightly.repo <<REPO
[spacewalk-client-nightly]
name=Spacewalk Client Tools nightly
baseurl=http://yum.spacewalkproject.org/nightly-client/%{reposubdir}/\$basearch/
gpgkey=http://yum.spacewalkproject.org/RPM-GPG-KEY-spacewalk-2012
enabled=0
gpgcheck=0
REPO

%clean
rm -rf $RPM_BUILD_ROOT

%files
%config(noreplace) %{_sysconfdir}/yum.repos.d/spacewalk.repo
%config(noreplace) %{_sysconfdir}/yum.repos.d/spacewalk-source.repo
%config(noreplace) %{_sysconfdir}/yum.repos.d/spacewalk-nightly.repo
%config(noreplace) %{_sysconfdir}/yum.repos.d/spacewalk-source.repo

%files -n spacewalk-client-repo
%config(noreplace) %{_sysconfdir}/yum.repos.d/spacewalk-client.repo
%config(noreplace) %{_sysconfdir}/yum.repos.d/spacewalk-client-nightly.repo

%changelog
* Wed Jan 22 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.1-1
- reverted tagger to VersionTagger

* Wed Jan 22 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.0-2
- make spacewalk*.repo on Fedora more generic

* Thu Jul 18 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.0-1
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.0-2
- Bumping package versions for 2.0.
- replace legacy name of Tagger with new one

* Mon Mar 04 2013 Stephen Herr <sherr@redhat.com> 1.10-1
- 

* Wed Oct 31 2012 Jan Pazdziora 1.9-1
- Bumping up version.

* Wed Oct 31 2012 Jan Pazdziora 1.8-4
- We put the source directory under the respective version subdirectory.
- %%defattr is not needed since rpm 4.4

* Mon Apr 23 2012 Jan Pazdziora 1.8-3
- Use the yum.spacewalkproject.org address for yum repos.

* Mon Mar 12 2012 Jan Pazdziora 1.8-2
- Marking all .repo files as noreplace, so that they survive local
  modifications like enabling nightly repo.

* Fri Mar 02 2012 Jan Pazdziora 1.8-1
- Bumping package versions for 1.8.

* Fri Mar 02 2012 Jan Pazdziora 1.7-5
- Start signing with new gpg key.
- Add separate -nightly.repo definitions for nightly Spacewalk repos.

* Wed Feb 01 2012 Jan Pazdziora 1.7-4
- Revert "add Source0"

* Wed Feb 01 2012 Miroslav Suchý 1.7-3
- do not check gpg at nightly - it is not signed

* Wed Feb 01 2012 Miroslav Suchý 1.7-2
- add Source0
- point spacewalk-repo to nightly

* Thu Dec 22 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.7-1
- Spacewalk 1.7

* Wed Jul 20 2011 Jan Pazdziora 1.6-1
- Bumping package versions for 1.6 for spacewalk-repo.

* Mon Apr 11 2011 Miroslav Suchý 1.5-1
- bump up version for Spacewalk 1.5

* Wed Feb 02 2011 Tomas Lestach <tlestach@redhat.com> 1.4-1
- Bumping spacewalk-repo package version for 1.4

* Mon Jan 31 2011 Tomas Lestach <tlestach@redhat.com> 1.3-1
- enable rhel6 repo (tlestach@redhat.com)

* Mon Nov 15 2010 Jan Pazdziora 1.3-0
- Bumping up version for 1.3.

* Wed Aug 18 2010 Jan Pazdziora 1.2-0
- point the repos to new spacewalk gpg key

* Tue Aug 10 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1-2
- add spacewalk-source.repo to .spec

* Tue Aug 10 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1-1
- prepare for 1.1
- Define yum repo for source rpms

* Thu Feb 11 2010 Michael Mraka <michael.mraka@redhat.com> 0.9-1
- pointed to Spacewalk 0.9 repo

* Thu Feb 11 2010 Michael Mraka <michael.mraka@redhat.com> 0.8-1
- pointed to Spacewalk 0.8 repo

* Fri Nov 27 2009 Miroslav Suchý <msuchy@redhat.com> 0.7-4
- create subpackage spacewalk-client-repo

* Fri Oct 16 2009 Michael Mraka <michael.mraka@redhat.com> 0.7-3
- fixed version of spacewalk-repo

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
