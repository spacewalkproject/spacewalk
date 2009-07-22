%define release_name Alpha
Name:           spacewalk
Version:        0.6.3
Release:        1%{?dist}
Summary:        Spacewalk Systems Management Application
URL:            https://fedorahosted.org/spacewalk
Group:          Applications/Internet
License:        GPLv2
BuildRoot:      %{_tmppath}/%{name}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  python
Requires:       python >= 2.3
Requires:       spacewalk-setup

# Java
Requires:       spacewalk-java
Requires:       spacewalk-taskomatic
Requires:       spacewalk-search

# Perl
Requires:       spacewalk-html
Requires:       spacewalk-base
Requires:       spacewalk-cypress
Requires:       spacewalk-grail
Requires:       spacewalk-pxt
Requires:       spacewalk-sniglets
Requires:       spacewalk-moon

# Python
Requires:       spacewalk-certs-tools
Requires:       spacewalk-backend
Requires:       spacewalk-backend-app
Requires:       spacewalk-backend-applet
Requires:       spacewalk-backend-config-files
Requires:       spacewalk-backend-config-files-common
Requires:       spacewalk-backend-config-files-tool
Requires:       spacewalk-backend-iss
Requires:       spacewalk-backend-iss-export
Requires:       spacewalk-backend-package-push-server
Requires:       spacewalk-backend-tools
Requires:       spacewalk-backend-server
Requires:       spacewalk-backend-sql
Requires:       spacewalk-backend-xml-export-libs
Requires:       spacewalk-backend-xmlrpc
Requires:       spacewalk-backend-xp
Requires:       rhnpush


# Misc
Requires:       spacewalk-schema
Requires:       spacewalk-config
Requires:       yum-utils

# Requires:       osa-dispatcher
# Requires:       jabberpy

# Monitoring packages
Requires:       spacewalk-monitoring

# Solaris
# Requires:       rhn-solaris-bootstrap
# Requires:       rhn_solaris_bootstrap_5_1_0_3

# SELinux
%if 0%{?fedora} == 11
%else
Requires:       spacewalk-selinux
Requires:       jabberd-selinux
Requires:       osa-dispatcher-selinux
Requires:       spacewalk-monitoring-selinux
%endif


%description
Spacewalk is a systems management application that will 
inventory, provision, update and control your Linux and 
Solaris machines.

%prep
#nothing to do here

%build
#nothing to do here

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{_sysconfdir}
echo "Spacewalk release %{version} (%{release_name})" > $RPM_BUILD_ROOT/%{_sysconfdir}/spacewalk-release

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
/%{_sysconfdir}/spacewalk-release

%changelog
* Wed Jul 22 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.3-1
- Re-enable selinux for everything but Fedora 11. (dgoodwin@redhat.com)

* Mon Jul 20 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.2-1
- Disabling spacewalk selinux support temporarily. (dgoodwin@redhat.com)

* Fri Apr 17 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.1-1
- bump Versions to 0.6.0 (jesusr@redhat.com)

* Fri Feb 27 2009 Miroslav Suchy <msuchy@redhat.com> 0.5.4-1
- require ISS packages

* Tue Feb 10 2009 Jan Pazdziora 0.5.3-2
- Require jabberd-selinux, osa-dispatcher-selinux, and
  spacewalk-monitoring-selinux

* Wed Jan 21 2009 Devan Goodwin <dgoodwin@redhat.com> 0.5.3-1
- Restore dependency on taskomatic and search.

* Mon Jan 19 2009 Jan Pazdziora 0.5.1-1
- rebuilt for 0.5, after repository reorg

* Thu Jan  8 2009 Jan Pazdziora 0.4.2-3
- Require spacewalk-selinux, making it a mandatory rpm

* Mon Dec 22 2008 Mike McCune <mmccune@gmail.com> 0.4.2-2
- Removing cobbler requirement down to RPMs that actually need it 

* Tue Nov 18 2008 Miroslav Suchý <msuchy@redhat.com> 0.4.2-1
- require spacewalk-monitoring instead each individual monitoring package

* Fri Oct 24 2008 Jesus Rodriguez <jesusr@redhat.com> 0.3.2-1
- respin for 0.3

* Wed Oct 22 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.4-1
- Remove spacewalk-dobby dependency, only needed for Satellite embedded Oracle installs.

* Mon Sep 29 2008 Miroslav Suchý <msuchy@redhat.com> 0.2.3-1
- rename oracle_config to nocpulse-db-perl
- merge NPusers and NPconfig to nocpulse-common
- remove nslogs
- enable monitoring again
- fix rpmlint errors

* Tue Sep  2 2008 Jesus Rodriguez <jesusr@redhat.com> 0.2.2-1
- add spacewalk-search as a new Requires
- change version to work with the new make srpm rules

* Mon Sep  1 2008 Milan Zazrivec <mzazrivec@redhat.com> 0.2-4
- bumped minor release for new package build

* Wed Aug 13 2008 Mike 0.2-3
- Fixing requires for new package names

* Mon Aug 11 2008 Mike 0.2-2
- tag to rebuild

* Wed Aug  6 2008 Jan Pazdziora 0.1-7
- tag to rebuild

* Mon Aug  4 2008 Miroslav Suchy <msuchy@redhat.com>
- Migrate name of packages to spacewalk namespace.

* Tue Jun 3 2008 Jesus Rodriguez <mmccune at redhat dot com> 0.1
- initial rpm release
