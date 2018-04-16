# This is a dummy spec file used by tito
# only for tagging and building tarballs

Name: apt-spacewalk
Summary: Spacewalk plugin for Advanced Packaging tool.
Version: 1.0.13
Release: 1%{?dist}
License: GPLv2
Source0: https://example.com/%{name}-%{version}.tar.gz
URL: https://github.com/spacewalkproject/spacewalk
BuildArch: noarch
BuildRequires: python

%description
apt-spacewalk is plugin used on Debian clients
to acquire content from Spacewalk server

%files

%changelog
* Mon Apr 16 2018 Tomas Kasparek <tkasparek@redhat.com> 1.0.13-1
- apt-transport-spacewalk: missed part of patch within pre_invoke
- further modifications on apt-transport-spacewalk
- modify apt-transport-spacewalk to support signed repos

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 1.0.12-1
- removed BuildRoot from specfiles

* Mon Jul 17 2017 Jan Dobes 1.0.11-1
- Migrating Fedorahosted to GitHub

* Tue Feb 24 2015 Matej Kollar <mkollar@redhat.com> 1.0.10-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 1.0.9-1
- removed trailing whitespaces

* Thu Mar 21 2013 Jan Pazdziora 1.0.8-1
- forward port debian bugs #703207, 700821

* Wed Feb 06 2013 Jan Pazdziora 1.0.7-1
- update documentation on Debian packages

* Sun Jun 17 2012 Miroslav Suchý <msuchy@redhat.com> 1.0.6-1
- add copyright information to header of .py files
- ListRefresh is in APT:Update namespace

* Sun Jun 17 2012 Miroslav Suchý 1.0.5-1
- add LICENSE file for apt-spacewalk tar.gz
- %%defattr is not needed since rpm 4.4

* Thu Apr 28 2011 Simon Lukasik <slukasik@redhat.com> 1.0.4-1
- The method can be killed by the keyboard interrupt (slukasik@redhat.com)

* Sun Apr 17 2011 Simon Lukasik <slukasik@redhat.com> 1.0.3-1
- Introducing actions.packages dispatcher (slukasik@redhat.com)
- Do not use rpmUtils on Debian (slukasik@redhat.com)
- Skip the extra lines sent by Apt (slukasik@redhat.com)

* Wed Apr 13 2011 Jan Pazdziora 1.0.2-1
- utilize config.getServerlURL() (msuchy@redhat.com)

* Thu Mar 17 2011 Simon Lukasik <slukasik@redhat.com> 1.0.1-1
- new package

