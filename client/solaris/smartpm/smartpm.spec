# Smartpm rpm spec file for Solaris

%define python_sitearch %(%{__python} -c 'from distutils import sysconfig; print sysconfig.get_python_lib(1)')
%define python_version %(%{__python} -c 'import sys; print sys.version.split(" ")[0]')

%define _prefix /opt/redhat/rhn/solaris/usr
%define _localstatedir /opt/redhat/rhn/solaris/var

Summary: Next generation package handling tool
Name: smartpm
Source0: smartpm-%{version}.tar.gz
Epoch:   1 
Version: 5.5.0
Release: 3
License: GPLv2
Group: Applications/System
URL: http://www.smartpm.org/

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

Requires: python = %{python_version}

%description
Smart Package Manager is a next generation package handling tool.

%prep
%setup

%build
env %{__python} setup.py build

%install
%{__rm} -rf %{buildroot}

%{__python} setup.py install --root="%{buildroot}" --install-scripts="%{_bindir}"

%{__install} -d -m 0755 %{buildroot}%{_localstatedir}/lib/smart/
%{__cp} -p contrib/solaris/distro-solaris.py %{buildroot}%{_localstatedir}/lib/smart/distro.py
%{__cp} -p contrib/solaris/adminfile %{buildroot}%{_localstatedir}/lib/smart/adminfile
%{__install} -d -m 0755 %{buildroot}%{python_sitearch}/rhn/actions/
%{__mv} %{buildroot}%{python_sitearch}/smart/interfaces/up2date/solarispkgs.py* %{buildroot}%{python_sitearch}/rhn/actions/

# For now, remove unused language files
%{__rm} -r %{buildroot}/opt/redhat/rhn/solaris/share/locale

%clean
%{__rm} -rf %{buildroot}

%files
%doc HACKING IDEAS LICENSE README TODO doc/*
%{_bindir}/smart
%{_bindir}/up2date
%{python_sitearch}/smart/
%exclude %{python_sitearch}/smart/interfaces/gtk/
%{_localstatedir}/lib/smart/
%{python_sitearch}/rhn/actions/solarispkgs.py*

%changelog
* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 5.5.0-3
- removed old CVS/SVN version ids

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 5.5.0-2
- branding clean-up of solaris client stuff
- replace legacy name of Tagger with new one

* Mon Nov 26 2012 Michael Mraka <michael.mraka@redhat.com> 5.5.0-1
- let's reset version above satellite version
- 838033 - Remove use of ZipFile object to avoid ZipFile 64 extension missing
  in python 2.4
- %%defattr is not needed since rpm 4.4

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 0.2-5
- update copyright info

* Fri Jul 15 2011 Michael Mraka <michael.mraka@redhat.com> 0.2-4
- 559092 - fixed patchset installation on x86
- 559092 - made patch cluster dir readable for nobody
- 559092 - new solaris patches contain installcluster

* Mon May 24 2010 Miroslav Suchý <msuchy@redhat.com> 0.2-3
- return smartpm back to 0.2 version and bump up epoch
- 555659 - do not freak out when SUNW_PATCHID do not have SUN format

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 0.5-1
- updated copyrights

* Fri Jan 29 2010 Miroslav Suchý <msuchy@redhat.com> 0.4-1
- replaced popen2 with subprocess in client (michael.mraka@redhat.com)

* Thu Jun 25 2009 John Matthews <jmatthew@redhat.com> 0.3-1
- 498079 - the -u option has to be specified before the file name, in call to
  unzip. (jpazdziora@redhat.com)
- 498079 - when unzip fails, show the actual error message and the target
  directory. (jpazdziora@redhat.com)

* Mon Mar 23 2009 Devan Goodwin <dgoodwin@redhat.com> 0.2-1
- Rebuild from Spacewalk git.

* Mon Jun 23 2005 Joel Martin <jmartin@redhat.com> - 4.0.0-6
- Fix Solaris patch db bug

* Mon Jun 15 2005 Joel Martin <jmartin@redhat.com> - 4.0.0-5
- Change to use version file, change spec and package name to smartpm

* Mon May 31 2005 Joel Martin <jmartin@redhat.com> - 4.0.0-2
- Make solarispkgs.py byte compiled 

* Mon May 24 2005 Joel Martin <jmartin@redhat.com> - 4.0.0-1
- Initial package creation for RHN 400 release
