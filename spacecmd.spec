%define rhnroot %{_datadir}/rhn

Name:        spacecmd
Version:     0.4.2
Release:     1%{?dist}
Summary:     Command-line interface to Spacewalk and Satellite servers

Group:       Applications/System
License:     GPL
URL:         http://github.com/aparsons/spacecmd
Source:      %{name}-%{version}.tar.gz
BuildRoot:   %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:   noarch

Requires:    python >= 2.4

%description
spacecmd is a command-line interface to Spacewalk and Satellite servers

%prep
%setup -q

%build
# nothing to build

%install
rm -rf %{buildroot}

mkdir -p %{buildroot}/%{_bindir}
install -m0755 src/bin/spacecmd %{buildroot}/%{_bindir}/

mkdir -p %{buildroot}/%{_sysconfdir}/bash_completion.d
install -m0644 src/misc/spacecmd-bash-completion %{buildroot}/%{_sysconfdir}/bash_completion.d/spacecmd

mkdir -p %{buildroot}/%{rhnroot}/spacecmd
install -m0644 src/lib/*.py %{buildroot}/%{rhnroot}/spacecmd/

mkdir -p %{buildroot}/%{_mandir}/man1
gzip -c src/doc/spacecmd.1 > %{buildroot}/%{_mandir}/man1/spacecmd.1.gz

touch %{buildroot}/%{rhnroot}/spacecmd/__init__.py
chmod 0644 %{buildroot}/%{rhnroot}/spacecmd/__init__.py

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_bindir}/spacecmd
%dir %{rhnroot}/spacecmd
%{rhnroot}/spacecmd/*
%{_sysconfdir}/bash_completion.d/spacecmd
%doc src/doc/README src/doc/COPYING
%doc %{_mandir}/man1/spacecmd.1.gz

%changelog
* Fri Jul 09 2010 aparsons <aron@redhat.com> 0.4.2-1
- system_applyerrata now just calls errata_apply() with the correct arguments
  (aron@redhat.com)
- reworked errata_apply() to schedule all errata for each system via one API
  call.  this also only schedules currently unscheduled errata, which
  eliminates error messages when an errata is already scheduled
  (aron@redhat.com)
- removed print_action_output() (aron@redhat.com)
- cleaned up schedule_getoutput (aron@redhat.com)
- removed an unnecessary sort (aron@redhat.com)
- changed the cancel prompt to be consistent with other prompts fixed the tab
  completion for schedule_cancel (aron@redhat.com)
- removed format_time() (aron@redhat.com)
- use the action name instead of type to be more verbose (aron@redhat.com)
- rewrote schedule_list* so be more concise and greppable (aron@redhat.com)
- added an explanation of valid date strings (aron@redhat.com)
- fix the handling of YYYYMMDD dates (aron@redhat.com)
- remove limit option from system_listevents (aron@redhat.com)
- minor tweaks to some output (aron@redhat.com)
- cleanup of system_installpackage (aron@redhat.com)
- added package_listerrata (aron@redhat.com)
- removed an unnecessary call to generate_package_cache (aron@redhat.com)
- fixed the exception handling in get_package_{name,id} (aron@redhat.com)
- changed the global separator to use # instead of - (aron@redhat.com)
- print the number of installed systems in package_details allow globbing in
  package_details (aron@redhat.com)
- added package_listinstalledsystems (aron@redhat.com)
- cache the reverse dictionary of (package_id, package_name) renamed the global
  variables that hold all package names (aron@redhat.com)
- allow timestamps of YYYYMMDDHHMM (aron@redhat.com)
- don't prompt the user in softwarechannel_removepackages if there are no
  packages to remove (aron@redhat.com)
- print a newline before the debug messages when generating the caches
  (aron@redhat.com)
- added toggle_confirmations (aron@redhat.com)
- reworked errata_apply to speed it up (some more stuff is coming)
  (aron@redhat.com)
- package_search wasn't returning an empty list if no results were found
  (aron@redhat.com)
- tweaked the format of the output (replaced trailing colons with underlines to
  separate sections) (aron@redhat.com)
- sort the package list in softwarechannel_adderrata and added some debug
  statements (aron@redhat.com)
- move the call to generate the errata cache up a little bit (aron@redhat.com)
- added softwarechannel_adderrata and changed softwarechannel_mergeerrata to
  softwarechannel_adderratabydate (aron@redhat.com)
- compile and re-use patterns in filter_results (aron@redhat.com)
- remove the seemingly unnecessary report_activesystems (aron@redhat.com)
- fix displaying file contents in configchannel_filedetails (aron@redhat.com)
- added functions to list only base and child channels (aron@redhat.com)
- fixed tab completion for system_addchildchannel and system_removechildchannel
  (aron@redhat.com)
- tweaked the shell intro (aron@redhat.com)
- added a confirmation and status to system_deployconfigfiles (aron@redhat.com)
- fixed exception handling regarding limits in schedule.py (aron@redhat.com)
- when merging errata, only add packages that exist in the source channel
  (aron@redhat.com)
- add a message for user interrupts on single commands (aron@redhat.com)
- show the number of affected systems in errata_details (aron@redhat.com)
- handle user interrupts better in errata_apply - be more diligent about
  finding the errata ID in errata_apply (aron@redhat.com)

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
