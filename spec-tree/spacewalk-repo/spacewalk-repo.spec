Summary: Spacewalk packages yum repository configuration
Name: spacewalk-repo
Version: 2.9
Release: 1%{?dist}
License: GPLv2
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone https://github.com/spacewalkproject/spacewalk.git
# cd spec-tree/spacewalk-repo
# make test-srpm
Source0:   %{name}-%{version}.tar.gz
URL:          https://github.com/spacewalkproject/spacewalk
BuildArch: noarch
%description
This package contains the Spacewalk repository configuration for yum.

%package -n spacewalk-client-repo
Summary: Spacewalk client packages yum repository configuration

%description -n spacewalk-client-repo
This package contains the Spacewalk repository configuration for yum.

%prep
%setup -q

%build

%install

# some sane default value
%define reposubdir      epel-%{rhel}
# redefine on fedora
%{?fedora: %define reposubdir      fedora-\\\$releasever}

mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
cat >>$RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/spacewalk.repo <<REPO
[spacewalk]
name=Spacewalk
baseurl=https://copr-be.cloud.fedoraproject.org/results/@spacewalkproject/spacewalk-%{version}/%{reposubdir}-\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-spacewalk-%{version}
enabled=1
gpgcheck=1
REPO

cat >>$RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/spacewalk-client.repo <<REPO
[spacewalk-client]
name=Spacewalk Client Tools
baseurl=https://copr-be.cloud.fedoraproject.org/results/@spacewalkproject/spacewalk-%{version}-client/%{reposubdir}-\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-spacewalk-%{version}-client
enabled=1
gpgcheck=1
REPO

cat >>$RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/spacewalk-nightly.repo <<REPO
[spacewalk-nightly]
name=Spacewalk nightly
baseurl=https://copr-be.cloud.fedoraproject.org/results/@spacewalkproject/nightly/%{reposubdir}-\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-spacewalk-nightly
enabled=0
gpgcheck=1
REPO

cat >>$RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/spacewalk-client-nightly.repo <<REPO
[spacewalk-client-nightly]
name=Spacewalk Client Tools nightly
baseurl=https://copr-be.cloud.fedoraproject.org/results/@spacewalkproject/nightly-client/%{reposubdir}-\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-spacewalk-nightly-client
enabled=0
gpgcheck=1
REPO

%if 0%{?rhel}

        cat >$RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/spacewalk-java.repo <<REPO

[group_spacewalkproject-java-packages]
name=Copr repo for java-packages owned by @spacewalkproject
baseurl=https://copr-be.cloud.fedoraproject.org/results/@spacewalkproject/java-packages/epel-7-x86_64/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-spacewalk-java-packages
gpgcheck=1
repo_gpgcheck=0
enabled=1
enabled_metadata=1
REPO

%if 0%{?rhel} == 6
        cat >>$RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/spacewalk-java.repo <<REPO

[group_spacewalkproject-epel6-addons]
name=Copr repo for epel6-addons owned by @spacewalkproject
baseurl=https://copr-be.cloud.fedoraproject.org/results/@spacewalkproject/epel6-addons/epel-6-x86_64/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-spacewalk-epel6-addons
gpgcheck=1
repo_gpgcheck=0
enabled=1
enabled_metadata=1
REPO
%endif

%endif

# install gpg keys
install -d 755 $RPM_BUILD_ROOT%{_sysconfdir}/pki/rpm-gpg
grep -h ^gpgkey= $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/*.repo \
    | while read i ; do 
        install -m 755 $(basename "$i") $RPM_BUILD_ROOT%{_sysconfdir}/pki/rpm-gpg/
    done

%clean

%files
%config(noreplace) %{_sysconfdir}/yum.repos.d/spacewalk.repo
%config(noreplace) %{_sysconfdir}/yum.repos.d/spacewalk-nightly.repo
%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-spacewalk-%{version}
%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-spacewalk-nightly
%if 0%{?rhel}
%config(noreplace) %{_sysconfdir}/yum.repos.d/spacewalk-java.repo
%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-spacewalk-java-packages
%if 0%{?rhel} == 6
%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-spacewalk-epel6-addons
%endif
%endif

%files -n spacewalk-client-repo
%config(noreplace) %{_sysconfdir}/yum.repos.d/spacewalk-client.repo
%config(noreplace) %{_sysconfdir}/yum.repos.d/spacewalk-client-nightly.repo
%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-spacewalk-%{version}-client
%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-spacewalk-nightly-client

%changelog
* Tue Apr 03 2018 Jiri Dostal <jdostal@redhat.com> 2.9-1
- Bumping package versions for repo

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8-10
- remove install/clean section initial cleanup
- removed Group from specfile

* Fri Oct 20 2017 Michael Mraka <michael.mraka@redhat.com> 2.8-9
- epel6-addons key is only on RHEL6

* Thu Oct 19 2017 Michael Mraka <michael.mraka@redhat.com> 2.8-8
- added gpg keys
- distribute gpg keys with repo definitions

* Mon Sep 25 2017 Michael Mraka <michael.mraka@redhat.com> 2.8-7
- epel-addons should be added to spacewalk-java.repo

* Thu Sep 07 2017 Michael Mraka <michael.mraka@redhat.com> 2.8-6
- java repositories should be defined just once

* Thu Sep 07 2017 Michael Mraka <michael.mraka@redhat.com> 2.8-5
- don't fail if macro is undefined

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8-4
- removed unnecessary BuildRoot tag

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8-3
- java repos for RHEL added directly to spacewalk.repo

* Tue Sep 05 2017 Michael Mraka <michael.mraka@redhat.com> 2.8-2
- 1488441 - spacewalk repo is now in COPR

* Thu Aug 17 2017 Eric Herget <eherget@redhat.com> 2.8-1
- Bumping spacewalk-repo version for 2.8.

* Fri Jul 21 2017 Tomas Lestach <tlestach@redhat.com> 2.7-1
- bumping spacewalk-repo to 2.7

* Mon Jul 17 2017 Jan Dobes 2.6-1
- Remove more fedorahosted links
- removed outdated Makefile
- Migrating Fedorahosted to GitHub

* Mon Nov 14 2016 Gennadii Altukhov <galt@redhat.com> 2.6-0
- Bumping package versions for 2.6.

* Tue Sep 29 2015 Jan Dobes 2.5-3
- Bumping spacewalk-repo version to 2.5.

* Wed May 06 2015 Tomas Lestach <tlestach@redhat.com> 2.4-3
- Update spacewalk-repo to use 2015 RPM-GPG-KEY

* Fri Mar 27 2015 Grant Gainey 2.4-2
- Update for Spacewalk 2.4

* Thu Jul 31 2014 Michael Mraka <michael.mraka@redhat.com> 2.3-2
- New signing key for 2014-2016

* Mon Jul 14 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.3-1
- update for Spacewalk 2.3

* Mon Feb 24 2014 Matej Kollar <mkollar@redhat.com> 2.2-1
- Bumping package versions for 2.2.

* Tue Jan 28 2014 Michael Mraka <michael.mraka@redhat.com> 2.1-2
- reverted versioning of package

* Tue Jan 28 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.2-1
- fixed variable quoting

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
