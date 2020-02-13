Summary: A library that performs asynchronous DNS operations
Name: c-ares19
Version: 1.9.1
Release: 4%{?dist}.3.2
License: MIT
URL: http://c-ares.haxx.se/
Source0: http://c-ares.haxx.se/download/c-ares-%{version}.tar.gz
# The license can be obtained at http://c-ares.haxx.se/license.html
Source1: LICENSE
Patch0001: 0001-Use-RPM-compiler-options.patch
Patch0002: c-ares-1.8.0-multilib.patch

BuildRequires: autoconf
BuildRequires: automake
BuildRequires: libtool

# EPEL-specific patches
Patch0003: 0001-Rename-output-to-libcares19.patch
Patch0004: 0002-Don-t-build-manpages-on-EPEL6.patch


%description
c-ares is a C library that performs DNS requests and name resolves 
asynchronously. c-ares is a fork of the library named 'ares', written 
by Greg Hudson at MIT.

%package devel
Summary: Development files for c-ares
Requires: %{name} = %{version}-%{release}
Requires: pkgconfig

%description devel
This package contains the header files and libraries needed to
compile applications or shared objects that use c-ares.

%prep
%setup -q -n c-ares-1.9.1
%patch0001 -p1
%patch0002 -p0 -b .multilib
%patch0003 -p1
%patch0004 -p1



cp %{SOURCE1} .
f=CHANGES ; iconv -f iso-8859-1 -t utf-8 $f -o $f.utf8 ; mv $f.utf8 $f

%build
autoreconf -if
%configure --enable-shared --disable-static \
           --disable-dependency-tracking

export echo=echo
%{__make} %{?_smp_mflags}

%install
export echo=echo
make DESTDIR=$RPM_BUILD_ROOT install
rm -f $RPM_BUILD_ROOT/%{_libdir}/libcares19.la

%clean

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%files
%doc README README.cares CHANGES NEWS LICENSE
%{_libdir}/*.so.*

%files devel
%{_includedir}/c-ares19/ares.h
%{_includedir}/c-ares19/ares_build.h
%{_includedir}/c-ares19/ares_dns.h
%{_includedir}/c-ares19/ares_rules.h
%{_includedir}/c-ares19/ares_version.h
%{_libdir}/*.so
%{_libdir}/pkgconfig/libcares19.pc

%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 1.9.1-4.3.2
- removed %%%%defattr from specfile
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles
- fixed tito build warning

* Thu Apr 11 2013 Stephen Gallagher <sgallagh@redhat.com> - 1.9.1-4.3
- Fix changelog dates

* Wed Apr 10 2013 Stephen Gallagher <sgallagh@redhat.com> - 1.9.1-4.2
- Replace optflag patch with one that modifies m4/cares-compilers.m4

* Tue Apr 09 2013 Stephen Gallagher <sgallagh@redhat.com> - 1.9.1-4.1
- Rename to c-ares19 for EPEL6

* Wed Feb 13 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.9.1-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Wed Aug 9 2012 Jakub Hrozek <jhrozek@redhat.com> - 1.9.1-3
- Include URL to the license text

* Wed Jul 18 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.9.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Mon Jun 25 2012 Tom Callaway <spot@fedoraproject.org> - 1.9.1-1
- update to 1.9.1

* Sat Apr 28 2012 Tom Callaway <spot@fedoraproject.org> - 1.8.0-1
- update to 1.8.0
- fix multilib patch (thanks to Paul Howarth)

* Thu Jan 12 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.7.5-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Wed Aug 17 2011 Jakub Hrozek <jhrozek@redhat.com> - 1.7.5-1
- New upstream release 1.7.5
- Obsoletes patch #2
- Rebase patch #1 (optflags) to match the 1.7.5 code
- Fixed Source0 URL to point at the upstream tarball

* Mon Apr 11 2011 Jakub Hrozek <jhrozek@redhat.com> - 1.7.4-3
- Apply upstream patch to fix rhbz#695424

* Tue Feb 08 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.7.4-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Fri Dec 10 2010 Tom "spot" Callaway <tcallawa@redhat.com> - 1.7.4-1
- update to 1.7.4

* Wed Aug 25 2010 Jakub Hrozek <jhrozek@redhat.com> - 1.7.3-3
- Actually apply the patches

* Wed Aug 25 2010 Jakub Hrozek <jhrozek@redhat.com> - 1.7.3-2
- apply couple of patches from upstream

* Tue Jun 15 2010 Jakub Hrozek <jhrozek@redhat.com> - 1.7.3-1
- Upgrade to new upstream release 1.7.3 (obsoletes search/domain patch)
- Fix conflict of -devel packages on multilib architectures (#602880)

* Thu Jun 3 2010 Jakub Hrozek <jhrozek@redhat.com> - 1.7.1-2
- Use last instance of search/domain, not the first one (#597286)

* Tue Mar 23 2010 Jakub Hrozek <jhrozek@redhat.com> - 1.7.1-1
- update to 1.7.1 which contains the IPv6 nameserver patch

* Sun Mar  7 2010 Jakub Hrozek <jhrozek@redhat.com> - 1.7.0-3
- Change IPv6 nameserver patch according to upstream changes
  (upstream revisions 1199,1201,1202)

* Wed Mar  3 2010 Jakub Hrozek <jhrozek@redhat.com> - 1.7.0-2
- Add a patch to allow usage of IPv6 nameservers

* Tue Dec  1 2009 Tom "spot" Callaway <tcallawa@redhat.com> - 1.7.0-1
- update to 1.7.0

* Sat Jul 25 2009 Ville Skyttä <ville.skytta at iki.fi> - 1.6.0-3
- Patch to make upstream build system honor our CFLAGS and friends.
- Don't bother building throwaway static libs.
- Disable autotools dependency tracking for cleaner build logs and possible
  slight build speedup.
- Convert docs to UTF-8.
- Update URLs.

* Fri Jul 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.6.0-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Wed Jul 22 2009 Tom "spot" Callaway <tcallawa@redhat.com> - 1.6.0-1
- update to 1.6.0

* Mon Feb 23 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.5.3-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Fri Sep 12 2008 Tom "spot" Callaway <tcallawa@redhat.com> - 1.5.3-1
- update to 1.5.3

* Tue Feb 19 2008 Fedora Release Engineering <rel-eng@fedoraproject.org> - 1.5.1-2
- Autorebuild for GCC 4.3

* Tue Feb 19 2008 Tom "spot" Callaway <tcallawa@redhat.com> 1.5.1-1
- update to 1.5.1

* Thu Aug 23 2007 Tom "spot" Callaway <tcallawa@redhat.com> 1.4.0-2
- rebuild for ppc32

* Wed Jun 27 2007 Tom "spot" Callaway <tcallawa@redhat.com> 1.4.0-1
- bump to 1.4.0 (resolves bugzilla 243591)
- get rid of static library (.a)

* Wed Jan 17 2007 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.2-1
- bump to 1.3.2

* Mon Sep 11 2006 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.1-2
- FC-6 bump

* Mon Jul 10 2006 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.1-1
- bump to 1.3.1

* Tue Feb 28 2006 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.0-2
- bump for FC-5 rebuild

* Sun Sep  4 2005 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.0-1
- include LICENSE text
- bump to 1.3.0

* Tue May 31 2005 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.1-4
- use dist tag to prevent EVR overlap

* Fri Apr 22 2005 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.1-2
- fix license (MIT, not LGPL)
- get rid of libcares.la

* Fri Apr 22 2005 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.1-1
- initial package creation

