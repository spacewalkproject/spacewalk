%global rhnroot %{_datadir}/rhn
%global rhnconf %{_sysconfdir}/sysconfig/rhn
%global client_caps_dir %{rhnconf}/clientCaps.d

%if 0%{?fedora} || 0%{?suse_version} > 1320 || 0%{?rhel} >= 8
%global build_py3   1
%global default_py3 1
%endif

%if ( 0%{?fedora} && 0%{?fedora} < 28 ) || ( 0%{?rhel} && 0%{?rhel} < 8 )
%global build_py2   1
%endif

%define pythonX %{?default_py3: python3}%{!?default_py3: python2}

Name: rhncfg
Version: 5.10.124
Release: 1%{?dist}
Summary: Spacewalk Configuration Client Libraries
License: GPLv2
URL:     https://github.com/spacewalkproject/spacewalk
Source0: https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch: noarch
BuildRequires: docbook-utils
Requires: %{pythonX}-%{name} = %{version}-%{release}

%if 0%{?suse_version}
# provide rhn directories and no selinux on suse
BuildRequires: rhn-client-tools
%else
%if 0%{?build_py2}
Requires: libselinux-python
%else
Requires: python3-libselinux
%endif
%endif

%description
The base libraries and functions needed by all rhncfg-* packages.

%if 0%{?build_py2}
%package -n python2-%{name}
Summary: Spacewalk Configuration Client Libraries
%{?python_provide:%python_provide python2-%{name}}
Requires: %{name} = %{version}-%{release}
Requires: python
Requires: rhnlib >= 2.8.3
Requires: spacewalk-usix
Requires: python2-rhn-client-tools >= 2.8.4
%if 0%{?rhel} <= 5
Requires: python-hashlib
%endif
BuildRequires: python
%description -n python2-%{name}
Python 2 specific files for %{name}.
%endif

%if 0%{?build_py3}
%package -n python3-%{name}
Summary: Spacewalk Configuration Client Libraries
%{?python_provide:%python_provide python3-%{name}}
Requires: %{name} = %{version}-%{release}
Requires: python3
Requires: python3-rhnlib >= 2.8.3
Requires: python3-spacewalk-usix
Requires: python3-rhn-client-tools >= 2.8.4
BuildRequires: python3
BuildRequires: python3-rpm-macros
%description -n python3-%{name}
Python 3 specific files for %{name}.
%endif


%package client
Summary: Spacewalk Configuration Client
Requires: %{name} = %{version}-%{release}
Requires: %{pythonX}-%{name}-client = %{version}-%{release}

%description client
A command line interface to the client features of the RHN Configuration
Management system.

%if 0%{?build_py2}
%package -n python2-%{name}-client
Summary: Spacewalk Configuration Client
%{?python_provide:%python_provide python2-%{name}-client}
Requires: %{name}-client = %{version}-%{release}
%description -n python2-%{name}-client
Python 2 specific files for %{name}-client.
%endif

%if 0%{?build_py3}
%package -n python3-%{name}-client
Summary: Spacewalk Configuration Client
%{?python_provide:%python_provide python3-%{name}-client}
Requires: %{name}-client = %{version}-%{release}
%description -n python3-%{name}-client
Python 3 specific files for %{name}-client.
%endif


%package management
Summary: Spacewalk Configuration Management Client
Requires: %{name} = %{version}-%{release}
Requires: %{pythonX}-%{name}-management = %{version}-%{release}

%description management
A command line interface used to manage Spacewalk configuration.

%if 0%{?build_py2}
%package -n python2-%{name}-management
Summary: Spacewalk Configuration Management Client
%{?python_provide:%python_provide python2-%{name}-management}
Requires: %{name}-management = %{version}-%{release}
%description -n python2-%{name}-management
Python 2 specific files for python2-%{name}-management.
%endif

%if 0%{?build_py3}
%package -n python3-%{name}-management
Summary: Spacewalk Configuration Management Client
%{?python_provide:%python_provide python3-%{name}-management}
Requires: %{name}-management = %{version}-%{release}
%description -n python3-%{name}-management
Python 2 specific files for python3-%{name}-management.
%endif


%package actions
Summary: Spacewalk Configuration Client Actions
Requires: %{name} = %{version}-%{release}
Requires: %{pythonX}-%{name}-actions = %{version}-%{release}

%description actions
The code required to run configuration actions scheduled via the RHN Classic website or Red Hat Satellite or Spacewalk.

%if 0%{?build_py2}
%package -n python2-%{name}-actions
Summary: Spacewalk Configuration Client Actions
%{?python_provide:%python_provide python2-%{name}-actions}
Requires: %{name}-actions = %{version}-%{release}
Requires: python2-%{name}-client
%description -n python2-%{name}-actions
Python 2 specific files for python2-%{name}-actions.
%endif

%if 0%{?build_py3}
%package -n python3-%{name}-actions
Summary: Spacewalk Configuration Client Actions
%{?python_provide:%python_provide python3-%{name}-actions}
Requires: %{name}-actions = %{version}-%{release}
Requires: python3-%{name}-client
%description -n python3-%{name}-actions
Python 3 specific files for python2-%{name}-actions.
%endif

%prep
%setup -q

%build
make -f Makefile.rhncfg all

%install
install -d $RPM_BUILD_ROOT/%{python_sitelib}
%if 0%{?build_py2}
make -f Makefile.rhncfg install PREFIX=$RPM_BUILD_ROOT ROOT=%{python_sitelib} \
    MANDIR=%{_mandir} PYTHONVERSION=%{python_version}
%endif
%if 0%{?build_py3}
    install -d $RPM_BUILD_ROOT/%{python3_sitelib}
    sed -i 's|#!/usr/bin/python|#!/usr/bin/python3|' config_*/*.py actions/*.py
    make -f Makefile.rhncfg install PREFIX=$RPM_BUILD_ROOT ROOT=%{python3_sitelib} \
        MANDIR=%{_mandir} PYTHONVERSION=%{python3_version}
%endif
mkdir -p $RPM_BUILD_ROOT/%{_sharedstatedir}/rhncfg/backups
mkdir -p $RPM_BUILD_ROOT/%{_localstatedir}/spool/rhn
mkdir -p $RPM_BUILD_ROOT/%{_localstatedir}/log
touch $RPM_BUILD_ROOT/%{_localstatedir}/log/rhncfg-actions

# create links to default script version
%define default_suffix %{?default_py3:-%{python3_version}}%{!?default_py3:-%{python_version}}
for i in \
    /usr/bin/rhncfg-client \
    /usr/bin/rhncfg-manager \
    /usr/bin/rhn-actions-control \
; do
    ln -s $(basename "$i")%{default_suffix} "$RPM_BUILD_ROOT$i"
done

%if 0%{?suse_version}
%py_compile -O %{buildroot}/%{python_sitelib}
%if 0%{?build_py3}
%py3_compile -O %{buildroot}/%{python3_sitelib}
%endif
%endif

%clean

%post
if [ -f %{_localstatedir}/log/rhncfg-actions ]
then 
chown root %{_localstatedir}/log/rhncfg-actions
chmod 600 %{_localstatedir}/log/rhncfg-actions
fi

%files
%if 0%{?suse_version}
%dir %{_sharedstatedir}
%endif
%dir %{_sharedstatedir}/rhncfg
%dir %{_localstatedir}/spool/rhn
%{_sharedstatedir}/rhncfg/backups
%doc LICENSE

%if 0%{?build_py2}
%files -n python2-%{name}
%{python_sitelib}/config_common
%endif

%if 0%{?build_py3}
%files -n python3-%{name}
%{python3_sitelib}/config_common
%endif

%files client
%{_bindir}/rhncfg-client
%attr(644,root,root) %config(noreplace) %{rhnconf}/rhncfg-client.conf
%{_mandir}/man8/rhncfg-client.8*

%if 0%{?build_py2}
%files -n python2-%{name}-client
%{python_sitelib}/config_client
%{_bindir}/rhncfg-client-%{python_version}
%endif

%if 0%{?build_py3}
%files -n python3-%{name}-client
%{python3_sitelib}/config_client
%{_bindir}/rhncfg-client-%{python3_version}
%endif

%files management
%{_bindir}/rhncfg-manager
%attr(644,root,root) %config(noreplace) %{rhnconf}/rhncfg-manager.conf
%{_mandir}/man8/rhncfg-manager.8*

%if 0%{?build_py2}
%files -n python2-%{name}-management
%{python_sitelib}/config_management
%{_bindir}/rhncfg-manager-%{python_version}
%endif

%if 0%{?build_py3}
%files -n python3-%{name}-management
%{python3_sitelib}/config_management
%{_bindir}/rhncfg-manager-%{python3_version}
%endif

%files actions
%{_bindir}/rhn-actions-control
%config(noreplace) %{client_caps_dir}/*
%{_mandir}/man8/rhn-actions-control.8*
%ghost %attr(600,root,root) %{_localstatedir}/log/rhncfg-actions

%if 0%{?build_py2}
%files -n python2-%{name}-actions
%{python_sitelib}/rhn/actions
%{_bindir}/rhn-actions-control-%{python_version}
%if 0%{?suse_version}
%dir %{python_sitelib}/rhn
%endif
%endif

%if 0%{?build_py3}
%files -n python3-%{name}-actions
%{python3_sitelib}/rhn/actions
%{_bindir}/rhn-actions-control-%{python3_version}
%if 0%{?suse_version}
%dir %{python3_sitelib}/rhn
%endif
%endif

%changelog
* Mon May 14 2018 Tomas Kasparek <tkasparek@redhat.com> 5.10.124-1
- 1577138 - when loading a file take into account if it's binary or not
- 1572652 - do not report that files differ due to python3 octal number
  represenatation

* Mon May 14 2018 Tomas Kasparek <tkasparek@redhat.com> 5.10.123-1
- require python3-libselinux on python3 only OS

* Mon Mar 19 2018 Tomas Kasparek <tkasparek@redhat.com> 5.10.122-1
- don't build python2 subpackages on systems with default python3

* Tue Feb 20 2018 Tomas Kasparek <tkasparek@redhat.com> 5.10.121-1
- use python3 on rhel8 in rhncfg

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 5.10.120-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Tue Jan 02 2018 Jiri Dostal <jdostal@redhat.com> 5.10.119-1
- 1528252 - Add --config option to rhncfg-manager and rhncfg-client.

* Tue Dec 12 2017 Tomas Kasparek <tkasparek@redhat.com> 5.10.118-1
- 1498813 - add better handling of interrupted system calls

* Mon Oct 23 2017 Michael Mraka <michael.mraka@redhat.com> 5.10.117-1
- rhncfg: add missing dirs to filelist for SUSE and enable py3 build on
  Tumbleweed

* Wed Oct 18 2017 Jan Dobes 5.10.116-1
- rhncfg - unused string import

* Thu Oct 12 2017 Eric Herget <eherget@redhat.com> 5.10.115-1
- 1474872 - rhncfg-manager download-channel failed during download utf8

* Fri Oct 06 2017 Michael Mraka <michael.mraka@redhat.com> 5.10.114-1
- write in binary mode
- import method from standard path

* Thu Oct 05 2017 Tomas Kasparek <tkasparek@redhat.com> 5.10.113-1
- 1498813 - store output in the action file so partial output can arrive to
  server
- 1494389 - Revert "[1260527] RHEL7 reboot loop"
- 1494389 - Revert "1260527 - fix Python 2.4 syntax (RHEL5)"

* Thu Oct 05 2017 Michael Mraka <michael.mraka@redhat.com> 5.10.112-1
- install files into python_sitelib/python3_sitelib
- move rhncfg-actions files into proper python2/python3 subpackages
- move rhncfg-management files into proper python2/python3 subpackages
- move rhncfg-client files into proper python2/python3 subpackages
- move rhncfg files into proper python2/python3 subpackages
- split rhncfg-actions into python2/python3 specific packages
- split rhncfg-management into python2/python3 specific packages
- split rhncfg-client into python2/python3 specific packages
- split rhncfg into python2/python3 specific packages

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 5.10.111-1
- purged changelog entries for Spacewalk 2.0 and older

* Wed Aug 09 2017 Michael Mraka <michael.mraka@redhat.com> 5.10.110-1
- precompile py3 bytecode on Fedora 23+
- use standard brp-python-bytecompile

* Mon Aug 07 2017 Eric Herget <eherget@redhat.com> 5.10.109-1
- another pass to update copyright year

* Wed Aug 02 2017 Tomas Kasparek <tkasparek@redhat.com> 5.10.108-1
- 1455513 - print different message if file does not exist
- 1455513 - print a name of file which does not exist during diff
- 1455513 - tell user which file differs

* Tue Aug 01 2017 Michael Mraka <michael.mraka@redhat.com> 5.10.107-1
- move version and release before sources

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 5.10.106-1
- update copyright year

* Tue May 16 2017 Laurence Rochfort <laurence.rochfort@oracle.com>
- PR 543 - Add password config option to rhncfg-manager.

* Tue Apr 25 2017 Michael Mraka <michael.mraka@redhat.com> 5.10.104-1
- 1105723 - execute remote commands in clean environment

* Fri Apr 07 2017 Michael Mraka <michael.mraka@redhat.com> 5.10.103-1
- fix missing import in rhncfg
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Wed Feb 22 2017 Eric Herget <eherget@redhat.com> 5.10.102-1
- 1361269 - Symlink target overwritten when the symlink is replaced by a file
  managed by rhncfg-client

* Wed Feb 15 2017 Tomas Kasparek <tkasparek@redhat.com> 5.10.101-1
- require spacewalk-usix indead of spacewalk-backend-usix

* Thu Nov 24 2016 Jiri Dostal <jdostal@redhat.com> 5.10.100-1
- 1260527 - fix Python 2.4 syntax (RHEL5)

* Fri Nov 11 2016 Jiri Dostal <jdostal@redhat.com> 5.10.99-1
- [1260527] RHEL7 reboot loop

* Thu Oct 20 2016 Gennadii Altukhov <galt@redhat.com> 5.10.98-1
- 1381343 - make rhncfg action configfile compatible with Python 2/3

* Thu Sep 22 2016 Jan Dobes 5.10.97-1
- python 3.5 dropped MAXFD from subprocess, workaround by getting this value
  directly

* Tue Jul 26 2016 Eric Herget <eherget@redhat.com> 5.10.96-1
- 1345843 - sane output when diff of binary config files
- 1358484 - dest file in diff output prefixed with '+++'

* Mon Jun 13 2016 Tomas Kasparek <tkasparek@redhat.com> 5.10.95-1
- Show info message as string - not array
- headers.get_all exists only in python 3
- verify doesn't work with binary files

* Thu Jun 09 2016 Gennadii Altukhov <galt@redhat.com> 5.10.94-1
- 1343653 - Uploading binary file by rhncfg-manager doesn't work in Fedora 23

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 5.10.93-1
- updating copyright years

* Wed May 18 2016 Tomas Kasparek <tkasparek@redhat.com> 5.10.92-1
- convert string to work in python 3
- method os.path.walk doesn't exist in Python 3

* Tue May 17 2016 Tomas Kasparek <tkasparek@redhat.com> 5.10.91-1
- fix 'ValueError: invalid literal for int() with base 10' in python 3

* Tue May 03 2016 Gennadii Altukhov <galt@redhat.com> 5.10.90-1
- fix remote command doesn't work in Python 3
- Fix typo

* Fri Apr 29 2016 Gennadii Altukhov <galt@redhat.com> 5.10.89-1
- used defined values from rpclib
- Fix: 'generator' object has no attribute 'next' in Python 3
- sys.exc_type and sys.exc_value is deprecated since version 1.5
- open /dev/tty to work in python 3
- basestring contains type str and bytes in python3
- urllib compatibility in python 2/3
- function raw_input doesn't exist in python 3
- fixed TypeError: expected bytes-like object, not str
- modified raise to work in python 2/3
- rewrite function map and filter to clause 'for'
- method iteritems was renamed to items
- fix module ConfigParser was moved in python3
- fix library xmlrpc was moved in python3
- compatibility for octal format of number
- replaced method has_key to work with python 2/3
- replaced call apply to work in python 3
- modified exception and raise to work in python 2/3
- build package for fedora 23+ with default python 3
- replaced string module calls to work in python 2/3
- modified imports to compatibility with python 2/3
- function print compatibility for python 2 and 3

* Mon Feb 29 2016 Gennadii Altukhov <galt@redhat.com> 5.10.88-1
- 1309003 fixing removing of temporary files during transaction rollback for
  rhncfg-manager.
- 1309006 fixing removing directories which rhncfg-manager didn't create.

* Thu Oct 29 2015 Jan Dobes 5.10.87-1
- 518128 - python 2.4 compatibility

* Thu Oct 29 2015 Jan Dobes 5.10.86-1
- 518128 - remove temporary files when exception occurs

* Tue Aug 25 2015 Tomas Kasparek <tkasparek@redhat.com> 5.10.85-1
- specify that md5 is not used for security purposes

* Fri Jul 10 2015 Matej Kollar <mkollar@redhat.com> 5.10.84-1
- Unused code removal

* Thu Mar 19 2015 Grant Gainey 5.10.83-1
- Updating copyright info for 2015

* Thu Mar 05 2015 Matej Kollar <mkollar@redhat.com> 5.10.82-1
- 1199197 - Avoid addition of None and str

* Mon Jan 19 2015 Matej Kollar <mkollar@redhat.com> 5.10.81-1
- 1177656 - Normalize path sooner

* Tue Jan 13 2015 Matej Kollar <mkollar@redhat.com> 5.10.80-1
- 1177656 - Fix directory creation
- Getting rid of Tabs and trailing spaces in Python
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Fri Oct 03 2014 Stephen Herr <sherr@redhat.com> 5.10.79-1
- 1148250 - errror in rhncfg if selinux off, rhel 5, and new libselinux-python

* Tue Sep 16 2014 Stephen Herr <sherr@redhat.com> 5.10.78-1
- 1142337 - rhncfg throws exception when verifying config files with macros

* Thu Sep 11 2014 Stephen Herr <sherr@redhat.com> 5.10.77-1
- 1133652 - make rhncfg support sha256 and use it by default

* Mon Aug 25 2014 Stephen Herr <sherr@redhat.com> 5.10.76-1
- 1133652 - validate the content of config files before deploying

* Thu Jul 31 2014 Stephen Herr <sherr@redhat.com> 5.10.75-1
- Avoid traceback with a configfiles upload action with no selinux context

* Tue Jul 22 2014 Stephen Herr <sherr@redhat.com> 5.10.74-1
- 1120802 - make webui config dir diff work
- bumping rhncfg version to avoid tag collision with 2.2

* Thu Jul 17 2014 Stephen Herr <sherr@redhat.com> 5.10.72-1
- 1120802 - remove debuging output and fix perm comparison from previous patch
- 1120802 - ensure webui config file diff looks at owner and permissions

* Wed Jul 16 2014 Stephen Herr <sherr@redhat.com> 5.10.71-1
- 1113848 - make sure webui doesn't say there are diffs if there aren't
- bz1113848 - Reverting changes of 1003459 and making GUI results compatible to
  rhncfg-client

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.10.70-1
- fix copyright years

* Thu May 29 2014 Michael Mraka <michael.mraka@redhat.com> 5.10.69-1
- list / elist: allow to specify list of files

* Thu Apr 24 2014 Stephen Herr <sherr@redhat.com> 5.10.68-1
- 1089729 - fix for assigning all groups user belongs to running process

* Mon Apr 14 2014 Michael Mraka <michael.mraka@redhat.com> 5.10.67-1
- fixes bnc871549 uncaught exception config deploy

* Fri Mar 14 2014 Michael Mraka <michael.mraka@redhat.com> 5.10.66-1
- show server modified time with rhncfg-client diff

* Thu Oct 10 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.65-1
- cleaning up old svn Ids

* Fri Oct 04 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.64-1
- Adding fallback support for numeric UID/GID

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.63-1
- removed trailing whitespaces

* Mon Sep 23 2013 Grant Gainey <ggainey@redhat.com> 5.10.62-1
- 1006480 - Another problem was hidden by the previous one   - Have to lay down
  directories to where the rhncfg-actions logfile is set   - Make it clearer
  that the scripts-output should go to a different place     than where the
  rhncfg code logs itself to

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.61-1
- Grammar error occurred

* Wed Sep 11 2013 Grant Gainey <ggainey@redhat.com> 5.10.60-1
- 1006480 - os.write() is for file-descriptors, not *files*

* Mon Sep 09 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.59-1
- 918036 - update man page for rhncfg-manager

* Thu Sep 05 2013 Milan Zazrivec <mzazrivec@redhat.com> 5.10.58-1
- 1002880 - Selinux status check for diff function from cli

* Wed Sep 04 2013 Stephen Herr <sherr@redhat.com> 5.10.57-1
- 908011 - require correct rhn-client-tools for RHEL 5

* Wed Aug 28 2013 Stephen Herr <sherr@redhat.com> 5.10.56-1
- 1002193 - remove spacewalk-backend-libs dependency from rhncfg

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 5.10.55-1
- updating copyright years

* Wed Jun 26 2013 Dimitar Yordanov <dyordano@redhat.com> 5.10.54-1
- 918034 - rhncfg-* --server-name now overwrites rhncfg-*.conf

* Thu Jun 20 2013 Matej Kollar <mkollar@redhat.com> 5.10.53-1
- Fix and simplyfy deci_to_octal conversion

* Wed Jun 19 2013 Jan Dobes 5.10.52-1
- 957506 - unicode support for Remote Command scripts

* Tue Jun 18 2013 Dimitar Yordanov <dyordano@redhat.com> 5.10.51-1
- 918036 - RFE - rhncfg-manager supports --username and --password from CLI

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.50-1
- branding fixes in man pages
- more branding cleanup

* Mon Jun 17 2013 Tomas Kasparek <tkasparek@redhat.com> 5.10.49-1
- rebranding few more strings in client stuff

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 5.10.48-1
- rebranding RHN Satellite to Red Hat Satellite in client stuff

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 5.10.47-1
- branding clean-up of client tools

* Fri Apr 12 2013 Grant Gainey 5.10.46-1
- 951243 - Let remote-cmds log to the local machine in addition to sending
  results back to SW

* Tue Apr 09 2013 Stephen Herr <sherr@redhat.com> 5.10.45-1
- 947639 - make rhncfg less stupid

* Thu Apr 04 2013 Stephen Herr <sherr@redhat.com> 5.10.44-1
- 948605 - make diffs initiated from Satellite obey display_diff config option
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Tue Feb 12 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.43-1
- cleanup old accidentaly commited eclipse project files

* Wed Feb 06 2013 Stephen Herr <sherr@redhat.com> 5.10.42-1
- 908011 - make rhncfg depend on correct version of rhn-client-tools for RHEL
- 908011 - make rhncfg depend on newer rhn-client-tools

* Mon Feb 04 2013 Jan Pazdziora 5.10.41-1
- 856608 - moved rhncfg dependency on spacewalk-backend-libs to base package
  All sub-packages now require it

* Mon Jan 28 2013 Stephen Herr <sherr@redhat.com> 5.10.40-1
- 903534 - Web UI config diff always shows 'binary files differ'

