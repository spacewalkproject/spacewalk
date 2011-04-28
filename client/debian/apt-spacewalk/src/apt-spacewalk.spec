# This is a dummy spec file used by tito
# only for tagging and building tarballs

Name: apt-spacewalk
Summary: Spacewalk plugin for Advanced Packaging tool.
Version: 1.0.4
Release: 1%{?dist}
License: GPLv2
Source0: https://example.com/%{name}-%{version}.tar.gz
URL: https://fedorahosted.org/spacewalk
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
BuildRequires: python

%description
apt-spacewalk is plugin used on Debian clients
to acquire content from Spacewalk server

%files
%defattr(-,root,root,-)

%changelog
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

