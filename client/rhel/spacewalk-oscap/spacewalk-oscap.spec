Name:		spacewalk-oscap
Version:	0.0.23
Release:	1%{?dist}
Summary:	OpenSCAP plug-in for rhn-check

Group:		Applications/System
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk
Source0:	https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:	noarch
BuildRequires:	python-devel
BuildRequires:	rhnlib
BuildRequires:  libxslt
%if 0%{?rhel} && 0%{?rhel} < 6
Requires:	openscap-utils >= 0.8.0
%else
Requires:	openscap-utils >= 0.9.2
%endif
Requires:	libxslt
Requires:       rhnlib
Requires:       rhn-check
%description
spacewalk-oscap is a plug-in for rhn-check. With this plugin, user is able
to run OpenSCAP scan from Spacewalk or Red Hat Satellite server.

%prep
%setup -q


%build
make -f Makefile.spacewalk-oscap


%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.spacewalk-oscap install PREFIX=$RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT


%files
%config  /etc/sysconfig/rhn/clientCaps.d/scap
%{_datadir}/rhn/actions/scap.*
%{_datadir}/openscap/xsl/xccdf-resume.xslt


%changelog
* Mon Jan 27 2014 Simon Lukasik <slukasik@redhat.com> 0.0.23-1
- 1057647: Add tailoring support to the Spacewalk (OpenSCAP enabled) client

* Tue Oct 15 2013 Simon Lukasik <slukasik@redhat.com> 0.0.22-1
- Improve logged error message.

* Fri Oct 11 2013 Simon Lukasik <slukasik@redhat.com> 0.0.21-1
- 1009512 - redirect stdout of xsltproc to /dev/null

* Tue Sep 10 2013 Simon Lukasik <slukasik@redhat.com> 0.0.20-1
- 1006383 - redirect stdout of oscap to /dev/null

* Thu Jul 25 2013 Simon Lukasik <slukasik@redhat.com> 0.0.19-1
- Do not try to parse xccdf-report.html with SAX parser

* Wed Jul 24 2013 Simon Lukasik <slukasik@redhat.com> 0.0.18-1
- Log exception in the file, when non XML encountered.

* Wed Jul 24 2013 Simon Lukasik <slukasik@redhat.com> 0.0.17-1
- Correct a typo in the error message.

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 0.0.16-1
- rebranding RHN Satellite to Red Hat Satellite in client stuff

* Tue May 28 2013 Simon Lukasik <slukasik@redhat.com> 0.0.15-1
- Precede internal error messages by xccdf_eval: prefix.
- Submit the OpenSCAP HTML report as well.
- Rewind, after using SAX to parse XML.
- Upload also full XCCDF results along the OVAL results.
- Refactor: Extract function _upload_file().
- Make sure to only upload XML files
- Use opened socket when to assessing file type.
- Client shall upload full results of the scap.xccdf_eval action
- Delete the temp file even when the content is useless

* Thu Apr 11 2013 Simon Lukasik <slukasik@redhat.com> 0.0.14-1
- Drop requires which cannot be fulfilled on rhel5

* Tue Dec 11 2012 Simon Lukasik <slukasik@redhat.com> 0.0.13-1
- Support for XCCDF 1.2.

* Tue Dec 11 2012 Simon Lukasik <slukasik@redhat.com> 0.0.12-1
- Allow --cpe command-line argument to oscap.

* Thu Nov 01 2012 Jan Pazdziora 0.0.11-1
- 872248: Enable new `oscap' features in spacewalk-openscap.

* Tue Jul 10 2012 Michael Mraka <michael.mraka@redhat.com> 0.0.10-1
- Fix spacewalk-oscap typos

* Thu May 31 2012 Simon Lukasik <slukasik@redhat.com> 0.0.9-1
- Forbid oscap args other than --profile and --skip-valid
- %%defattr is not needed since rpm 4.4

* Mon Apr 30 2012 Simon Lukasik <slukasik@redhat.com> 0.0.8-1
- Do not pass empty string as parameter to oscap tool. (slukasik@redhat.com)

* Fri Apr 27 2012 Jan Pazdziora 0.0.7-1
- Spacewalk-oscap requires oscap tool of particular version.
  (slukasik@redhat.com)

* Thu Mar 29 2012 Simon Lukasik <slukasik@redhat.com> 0.0.6-1
- When errors occur submit them back to the server. (slukasik@redhat.com)

* Thu Mar 29 2012 Simon Lukasik <slukasik@redhat.com> 0.0.5-1
- Store also @idref of xccdf:rule-result element (slukasik@redhat.com)
- We want to store all idents per rule-result (slukasik@redhat.com)
- Only one Profile element is useful (slukasik@redhat.com)
- Make sure only one TestResult element is used (slukasik@redhat.com)

* Wed Feb 29 2012 Simon Lukasik <slukasik@redhat.com> 0.0.4-1
- Send capabilities to server. (slukasik@redhat.com)

* Tue Feb 28 2012 Simon Lukasik <slukasik@redhat.com> 0.0.3-1
- Do not unlink file, tempfile will do that automatically.
  (slukasik@redhat.com)
- This module is not supposed to be used as a stand-alone script.
  (slukasik@redhat.com)
- Do submit empty dict, when something goes wrong (slukasik@redhat.com)
- Fix syntax for python 2.4 (slukasik@redhat.com)

* Mon Feb 27 2012 Simon Lukasik <slukasik@redhat.com> 0.0.2-1
- new package built with tito

