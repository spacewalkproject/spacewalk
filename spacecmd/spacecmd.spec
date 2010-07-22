%global rhnroot %{_datadir}/rhn

Name:        spacecmd
Version:     0.5.1
Release:     1%{?dist}
Summary:     Command-line interface to Spacewalk and Satellite servers

Group:       Applications/System
License:     GPLv3+
URL:         https://fedorahosted.org/spacewalk/wiki/spacecmd
Source:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:   %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:   noarch

Requires:    python

%description
spacecmd is a command-line interface to Spacewalk and Satellite servers

%prep
%setup -q

%build
# nothing to build

%install
%{__rm} -rf %{buildroot}

%{__mkdir_p} %{buildroot}/%{_bindir}
%{__install} -m0755 src/bin/spacecmd %{buildroot}/%{_bindir}/

%{__mkdir_p} %{buildroot}/%{_sysconfdir}/bash_completion.d
%{__install} -m0644 src/misc/spacecmd-bash-completion %{buildroot}/%{_sysconfdir}/bash_completion.d/spacecmd

%{__mkdir_p} %{buildroot}/%{rhnroot}/spacecmd
%{__install} -m0644 src/lib/*.py %{buildroot}/%{rhnroot}/spacecmd/

%{__mkdir_p} %{buildroot}/%{_mandir}/man1
%{__gzip} -c src/doc/spacecmd.1 > %{buildroot}/%{_mandir}/man1/spacecmd.1.gz

touch %{buildroot}/%{rhnroot}/spacecmd/__init__.py
%{__chmod} 0644 %{buildroot}/%{rhnroot}/spacecmd/__init__.py

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_bindir}/spacecmd
%dir %{rhnroot}
%{rhnroot}/spacecmd/
%dir %{_sysconfdir}/bash_completion.d
%{_sysconfdir}/bash_completion.d/spacecmd
%doc src/doc/README src/doc/COPYING
%doc %{_mandir}/man1/spacecmd.1.gz

%changelog
* Mon Jul 19 2010 Aron Parsons <aparsons@redhat.com> 0.5.1-1
- new package built with tito

* Mon Jul 19 2010 Aron Parsons <aparsons@redhat.com> 0.5.0-1
- new package built with tito
* Mon Jul 19 2010 Aron Parsons <aparsons@redhat.com> 0.5.0-1
- version bump
- update the URL to point at fedorahosted.org
- fixes from rpmlint

* Fri Jul 09 2010 Aron Parsons <aparsons@redhat.com> 0.4.2-1
- fixed an unhandled exception when doing a history lookup (aparsons@redhat.com)
- cleaned up system_upgradepackage and system_listupgrades (aparsons@redhat.com)
- added calls to generate_package_cache in get_package_name and get_package_id
  (aparsons@redhat.com)
- use macros for commands where possible (aparsons@redhat.com)
- use existing file details (owner, group, mode) when updating a config file
  (aparsons@redhat.com)
- cleanup the bash completion file (aparsons@redhat.com)
- Automatic commit of package [spacecmd] release [0.4.2-1]. (aparsons@redhat.com)
- system_applyerrata now just calls errata_apply() with the correct arguments
  (aparsons@redhat.com)
- reworked errata_apply() to schedule all errata for each system via one API
  call.  this also only schedules currently unscheduled errata, which
  eliminates error messages when an errata is already scheduled
  (aparsons@redhat.com)
- removed print_action_output() (aparsons@redhat.com)
- cleaned up schedule_getoutput (aparsons@redhat.com)
- removed an unnecessary sort (aparsons@redhat.com)
- changed the cancel prompt to be consistent with other prompts fixed the tab
  completion for schedule_cancel (aparsons@redhat.com)
- removed format_time() (aparsons@redhat.com)
- use the action name instead of type to be more verbose (aparsons@redhat.com)
- rewrote schedule_list* so be more concise and greppable (aparsons@redhat.com)
- added an explanation of valid date strings (aparsons@redhat.com)
- fix the handling of YYYYMMDD dates (aparsons@redhat.com)
- remove limit option from system_listevents (aparsons@redhat.com)
- minor tweaks to some output (aparsons@redhat.com)
- cleanup of system_installpackage (aparsons@redhat.com)
- added package_listerrata (aparsons@redhat.com)
- removed an unnecessary call to generate_package_cache (aparsons@redhat.com)
- fixed the exception handling in get_package_{name,id} (aparsons@redhat.com)
- changed the global separator to use # instead of - (aparsons@redhat.com)
- print the number of installed systems in package_details allow globbing in
  package_details (aparsons@redhat.com)
- added package_listinstalledsystems (aparsons@redhat.com)
- cache the reverse dictionary of (package_id, package_name) renamed the global
  variables that hold all package names (aparsons@redhat.com)
- allow timestamps of YYYYMMDDHHMM (aparsons@redhat.com)
- don't prompt the user in softwarechannel_removepackages if there are no
  packages to remove (aparsons@redhat.com)
- print a newline before the debug messages when generating the caches
  (aparsons@redhat.com)
- added toggle_confirmations (aparsons@redhat.com)
- reworked errata_apply to speed it up (some more stuff is coming)
  (aparsons@redhat.com)
- package_search wasn't returning an empty list if no results were found
  (aparsons@redhat.com)
- tweaked the format of the output (replaced trailing colons with underlines to
  separate sections) (aparsons@redhat.com)
- sort the package list in softwarechannel_adderrata and added some debug
  statements (aparsons@redhat.com)
- move the call to generate the errata cache up a little bit (aparsons@redhat.com)
- added softwarechannel_adderrata and changed softwarechannel_mergeerrata to
  softwarechannel_adderratabydate (aparsons@redhat.com)
- compile and re-use patterns in filter_results (aparsons@redhat.com)
- remove the seemingly unnecessary report_activesystems (aparsons@redhat.com)
- fix displaying file contents in configchannel_filedetails (aparsons@redhat.com)
- added functions to list only base and child channels (aparsons@redhat.com)
- fixed tab completion for system_addchildchannel and system_removechildchannel
  (aparsons@redhat.com)
- tweaked the shell intro (aparsons@redhat.com)
- added a confirmation and status to system_deployconfigfiles (aparsons@redhat.com)
- fixed exception handling regarding limits in schedule.py (aparsons@redhat.com)
- when merging errata, only add packages that exist in the source channel
  (aparsons@redhat.com)
- - add a message for user interrupts on single commands (aparsons@redhat.com)
- - show the number of affected systems in errata_details (aparsons@redhat.com)
- - handle user interrupts better in errata_apply - be more diligent about
  finding the errata ID in errata_apply (aparsons@redhat.com)

* Tue Jul 06 2010 Paul Morgan <pmorgan@redhat.com> - 0.4.1-1
- ADD: support for builds via tito
- CHANGE: x.y.z versioning (better for tito)
- tagged man page as doc 

* Thu Jul 01 2010 Aron Parsons <aparsons@redhat.com> - 0.4-1
- version bump
- added a man page

* Fri Jun 25 2010 Aron Parsons <aparsons@redhat.com> - 0.3-1
- version bump
- added bash-completion support

* Mon Jun 21 2010 Aron Parsons <aparsons@redhat.com> - 0.2-1
- version bump

* Mon Jun 21 2010 Aron Parsons <aparsons@redhat.com> - 0.1-4
- added distribution headings
- added a copy of the GPL

* Thu Apr 29 2010 Aron Parsons <aparsons@redhat.com> - 0.1-3
- just touch __init__.py, no reason to version control an empty file

* Wed Apr 28 2010 Aron Parsons <aparsons@redhat.com> - 0.1-2
- moved SpacewalkShell.py to /usr/share/rhn/spacecmd

* Tue Apr 27 2010 Paul Morgan <pmorgan@redhat.com> - 0.1-1
- initial packaging
