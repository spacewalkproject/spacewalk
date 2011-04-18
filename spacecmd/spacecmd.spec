%if ! (0%{?fedora} > 12 || 0%{?rhel} > 5)
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%{!?python_sitearch: %global python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(1))")}
%endif

Name:        spacecmd
Version:     1.5.1
Release:     1%{?dist}
Summary:     Command-line interface to Spacewalk and Satellite servers

Group:       Applications/System
License:     GPLv3+
URL:         https://fedorahosted.org/spacewalk/wiki/spacecmd
Source:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:   %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:   noarch

BuildRequires: python-devel

%description
spacecmd is a command-line interface to Spacewalk and Satellite servers

%prep
%setup -q

%build
# nothing to build

%install
%{__rm} -rf %{buildroot}

%{__mkdir_p} %{buildroot}/%{_bindir}
%{__install} -p -m0755 src/bin/spacecmd %{buildroot}/%{_bindir}/

%{__mkdir_p} %{buildroot}/%{_sysconfdir}
touch %{buildroot}/%{_sysconfdir}/spacecmd.conf

%{__mkdir_p} %{buildroot}/%{_sysconfdir}/bash_completion.d
%{__install} -p -m0644 src/misc/spacecmd-bash-completion %{buildroot}/%{_sysconfdir}/bash_completion.d/spacecmd

%{__mkdir_p} %{buildroot}/%{python_sitelib}/spacecmd
%{__install} -p -m0644 src/lib/*.py %{buildroot}/%{python_sitelib}/spacecmd/

%{__mkdir_p} %{buildroot}/%{_mandir}/man1
%{__gzip} -c src/doc/spacecmd.1 > %{buildroot}/%{_mandir}/man1/spacecmd.1.gz

touch %{buildroot}/%{python_sitelib}/spacecmd/__init__.py
%{__chmod} 0644 %{buildroot}/%{python_sitelib}/spacecmd/__init__.py

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_bindir}/spacecmd
%{python_sitelib}/spacecmd/
%ghost %config %{_sysconfdir}/spacecmd.conf
%dir %{_sysconfdir}/bash_completion.d
%{_sysconfdir}/bash_completion.d/spacecmd
%doc src/doc/README src/doc/COPYING
%doc %{_mandir}/man1/spacecmd.1.gz

%changelog
* Mon Apr 18 2011 Aron Parsons <aparsons@redhat.com> 1.5.1-1
- 696681 - fix spaces in system names in system_updatecustomvalue and
  system_addcustomvalue (aparsons@redhat.com)
- 696681 - allow special characters in server names
- whitespace cleanup (aparsons@redhat.com)
- fix handling of group names with spaces when expanding with
  'group:' (aparsons@redhat.com)
- added kickstart_clone (aparsons@redhat.com)
- Bumping package versions for 1.5 (msuchy@redhat.com)

* Mon Mar 28 2011 Aron Parsons <aparsons@redhat.com> 1.4.5-1
- added 'repo' module into shell (aparsons@redhat.com)
- added repo_list and repo_details (tljohnsn@oreillyschool.com)

* Fri Mar 11 2011 Aron Parsons <aparsons@redhat.com> 1.4.4-1
- added configchannel_verifyfile (aparsons@redhat.com)

* Fri Mar 11 2011 Aron Parsons <aparsons@redhat.com> 1.4.3-1
- fix invalid key name in errata_search (aparsons@redhat.com)

* Tue Mar 08 2011 Aron Parsons <aparsons@redhat.com> 1.4.2-1
- added group_backup and group_restore functions (john@vanzantvoort.org)
- don't get the UUID on older API versions (aparsons@redhat.com)

* Thu Mar 03 2011 Aron Parsons <aparsons@redhat.com> 1.4.1-1
- spacecmd: log channel access issues in debug mode only (aparsons@redhat.com)
- spacecmd: ignore channel failures introduced by organizations when caching
  packages (aparsons@redhat.com)
- spacecmd: print a summary list of all errata (name, synopsis, date)
  (aparsons@redhat.com)
- spacecmd: ignore channel failures introduced by organizations when caching
  errata (aparsons@redhat.com)
- spacecmd: delete child channels first in softwarechannel_delete
  (aparsons@redhat.com)
- Bumping package versions for 1.4 (tlestach@redhat.com)

* Thu Jan 27 2011 Aron Parsons <aparsons@redhat.com> 1.3.8-1
- added configchannel_backup function (john@vanzantvoort.org)

* Thu Dec 23 2010 Aron Parsons <aparsons@redhat.com> 1.3.7-1
- added system_syncpackages function

* Wed Dec 22 2010 Aron Parsons <aparsons@redhat.com> 1.3.6-1
- added organization functions

* Tue Dec 21 2010 Aron Parsons <aparsons@redhat.com> 1.3.5-1
- discard the password variable once we use it
- attempt to re-login as the same user if the cached credentials are invalid
- fix logic regarding which configuration files to load
- don't try to load non-existent config sections

* Tue Dec 21 2010 Aron Parsons <aparsons@redhat.com> 1.3.4-1
- support server-specific configuration sections in the configuration file
- added support for a system-wide configuration file
- added support for server-specific sections in the configuration file

* Fri Dec 10 2010 Aron Parsons <aparsons@redhat.com> 1.3.3-1
- add support for server UUIDs

* Tue Nov 30 2010 Aron Parsons <aparsons@redhat.com> 1.3.2-1
- don't use a cached session if username and password are passed as arguments
- added get_session function

* Mon Nov 22 2010 Aron Parsons <aparsons@redhat.com> 1.3.1-1
- fix uninitialized variable in snippet_create
- 655055 - honor the quiet flag when generating caches in spacecmd
* Fri Nov 05 2010 Aron Parsons <aparsons@redhat.com> 1.2.2-1
- spacecmd: fixed exception in kickstart_create due to typo
  (aparsons@redhat.com)

* Fri Oct 29 2010 Aron Parsons <aparsons@redhat.com> 1.2.1-1
- renamed system_addchildchannel to system_addchildchannels and
  system_removechildchannel to system_removechildchannels for consistency
- added help topics for time and system options
- print the system ID and last checkin in report_duplicates
- print help messages for functions if the user passes --help
- exit the shell if the initial login attempt fails
- version bump to 1.2 to stay in sync with other Spacewalk packages
* Thu Oct 07 2010 Aron Parsons <aparsons@redhat.com> 0.7.5-1
- fix unhandled exception in activationkey_create
  (aparsons@redhat.com)

* Wed Oct 06 2010 Aron Parsons <aparsons@redhat.com> 0.7.4-1
- fix compatability with Satellite 5.3 in configchannel_addfile
  (aparsons@redhat.com)
- fix man page formatting (aparsons@redhat.com)

* Tue Sep 28 2010 Aron Parsons <aparsons@redhat.com> 0.7.3-1
- forgot to add the actual option for revision in
  configchannel_addfile (aparsons@redhat.com)
* Tue Sep 28 2010 Aron Parsons <aparsons@redhat.com> 0.7.2-1
- allow the user to provide a revision number in
  configchannel_addfile (aparsons@redhat.com)
- force the user to enter a valid channel name in
  configchannel_addfile (aparsons@redhat.com)
- allow configchannel_addfile to be run non-interactively
  (aparsons@redhat.com)
- don't use mergeErrataWithPackages API (aparsons@redhat.com)

* Thu Sep 23 2010 Aron Parsons <aparsons@redhat.com> 0.7.1-1
- allow configchannel_create to be called non-interactively
  (aparsons@redhat.com)
- updated man page to explain how to run non-interactive commands
  (aparsons@redhat.com)
- allow softwarechannel_* functions to be called non-interactively
  (aparsons@redhat.com)
- allow system_* functions to be called non-interactively
  (aparsons@redhat.com)
- more fixes for ignorning the '-y' command-line option when it's not
  applicable (aparsons@redhat.com)
- allow user_* functions to be called non-interactively
  (aparsons@redhat.com)
- don't honor the '-y' command-line option when user_confirm isn't
  used as a confirmation (aparsons@redhat.com)
- allow snippet_* functions to be called non-interactively
  (aparsons@redhat.com)
- remove a comment about a fix that was committed ages ago
  (aparsons@redhat.com)
- allow kickstart_* functions to be called non-interactively
  (aparsons@redhat.com)
- allow distribution_* functions to be called non-interactively
  (aparsons@redhat.com)
- allow cryptokey_* functions to be called non-interactively
  (aparsons@redhat.com)
- added a function to read files (aparsons@redhat.com)
- allow activationkey_* functions to be called non-interactively
  (aparsons@redhat.com)
- added function to test if the called function is interactive
  (aparsons@redhat.com)
- support for named arguments in utils.parse_arguments()
  (aparsons@redhat.com)

* Tue Sep 21 2010 Aron Parsons <aparsons@redhat.com> 0.6.2-1
- added new function softwarechannel_removeerrata
  (aparsons@redhat.com)
- update softwarechannel_adderrata to use the new
  mergeErratawithPackages API call (aparsons@redhat.com)
* Mon Sep 20 2010 Aron Parsons <aparsons@redhat.com> 0.6.1-1
- support symlinks, selinux contexts and revisions in configchannel_*
  (aparsons@redhat.com)
- added new function softwarechannel_listallpackages
  (aparsons@redhat.com)
- avoid proxy timeouts when cloning errata by doing them individually
  (aparsons@redhat.com)
- allow --debug to be passed multiple times (aparsons@redhat.com)
- revert to the old-style of errata merging due to bugzilla 591291
  (aparsons@redhat.com)
- cleanup column headers in report_outofdatesystems
  (aparsons@redhat.com)
- show the last checkin time in report_inactivesystems
  (aparsons@redhat.com)
- clarify what 'Original State' means when cloning a software channel
  (aparsons@redhat.com)
- remove prompts for summary/description when creating software
  channels and just use the name (aparsons@redhat.com)

* Fri Aug 20 2010 Aron Parsons <aparsons@redhat.com> 0.5.7-1
- simplify checks for debug mode (aparsons@redhat.com)
- enable verbose mode for xmlrpclib when debugging is enabled
  (aparsons@redhat.com)

* Thu Aug 19 2010 Aron Parsons <aparsons@redhat.com> 0.5.6-1
- updated documentation to point bug reports at Bugzilla
  (aparsons@redhat.com)
- added new function user_create (aparsons@redhat.com)
- added a parameter to return integers from user_confirm()
  (aparsons@redhat.com)
- add parameter to not print a blank line on user confirmations
  (aparsons@redhat.com)

* Thu Aug 05 2010 Milan Zazrivec <mzazrivec@redhat.com> 0.5.5-1
- added a missing hyphen in the spacecmd man page

* Wed Jul 28 2010 Aron Parsons <aparsons@redhat.com> 0.5.4-1
- simplified softwarechannel_adderrata (aparsons@redhat.com)
- added new function errata_publish (aparsons@redhat.com)
- support quoting of package profile names in tab completion
  (aparsons@redhat.com)
- remove old instance of system_createpackageprofile (aparsons@redhat.com)
- only call the system.listDuplicates* functions if the API supports it
  (aparsons@redhat.com)
- support quoting of group names (aparsons@redhat.com)
- support quoting of arguments (aparsons@redhat.com)
- change the log level for warning that cached credentials are invalid
  (aparsons@redhat.com)
- added new functions system_deletepackageprofile and
  system_listpackageprofiles (aparsons@redhat.com)
- added new functions to create and compare package profiles
  (aparsons@redhat.com)
- added new function system_listduplicates (aparsons@redhat.com)
- regenerate the errata cache after cloning errata (aparsons@redhat.com)
- added new function errata_delete (aparsons@redhat.com)
- list CVEs in errata_details (aparsons@redhat.com)
- added new function errata_listcves (aparsons@redhat.com)
- make system_installpackage use the new API system.listLatestAvailablePackage
  (aparsons@redhat.com)
- don't include archived actions in the default call of schedule_list
  (aparsons@redhat.com)
- significant improvement to the performance of schedule_list* functions
  (aparsons@redhat.com)
- changed where an empty list is checked for in schedule_reschedule
  (aparsons@redhat.com)
- fixed tab completion in schedule_cancel (aparsons@redhat.com)
- added function schedule_reschedule (aparsons@redhat.com)
- allow filtering in report_errata (aparsons@redhat.com)

* Mon Jul 26 2010 Miroslav Suchý <msuchy@redhat.com> 0.5.3-1
- 616120 - remove python requires (msuchy@redhat.com)
- 616120 - add -p to install, to preserve timestamps (msuchy@redhat.com)

* Thu Jul 22 2010 Aron Parsons <aparsons@redhat.com> 0.5.2-1
- move python files in site-packages (aparsons@redhat.com)
- fixes to spacecmd.spec per Fedora package review (aparsons@redhat.com)
- fixed report_kernels not grabbing the correct value for each system (thanks
  to James Tanner) (aparsons@redhat.com)
- don't print an empty line if there are no results from package_search
  (aparsons@redhat.com)
- temporarily update the command prompt to tell the user when caches are being
  generated (aparsons@redhat.com)
- rename kickstart_getfile to kickstart_getcontents (aron@redhat.com)
- remove a false statement (aron@redhat.com)
- remove references to closed Bugzillas (aron@redhat.com)
- remove unused binary file support from configchannel_addfile
  (aron@redhat.com)
- update kickstart_getfile to use the new
  kickstart.profile.downloadRenderedKickstart method (aron@redhat.com)
- remove reference to 584860 since it has been fixed in spacewalk
  (aron@redhat.com)
- implemented configchannel_listsystems (aron@redhat.com)
- moved global variables out of shell.py and into more appropriate locations
  (aron@redhat.com)
- session_file didn't need to be global (aron@redhat.com)
- make sure ~/.spacecmd/<server> exists before writing the session cache
  (aron@redhat.com)
- only store one session in the cache (aron@redhat.com)

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
