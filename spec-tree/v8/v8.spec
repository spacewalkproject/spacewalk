# Hi Googlers! If you're looking in here for patches, nifty.
# You (and everyone else) are welcome to use any of my Chromium spec files and
# patches under the terms of the GPLv2 or later.
# You (and everyone else) are welcome to use any of my V8-specific spec files
# and patches under the terms of the BSD license.
# You (and everyone else) may NOT use my spec files or patches under any other
# terms.
# I hate to be a party-pooper here, but I really don't want to help Google
# make a proprietary browser. There are enough of those already.
# All copyrightable work in these spec files and patches is Copyright 2011
# Tom Callaway <spot@fedoraproject.org>

# For the 1.2 branch, we use 0s here
# For 1.3+, we use the three digit versions
# Hey, now there are four digits. What do they mean? Popsicle.
%global somajor 3
%global sominor 14
%global sobuild 5
%global sotiny 10
%global sover %{somajor}.%{sominor}.%{sobuild}

# %%global svnver 20110721svn8716

%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}

Name:		v8
Version:	%{somajor}.%{sominor}.%{sobuild}.%{sotiny}
Release:	2.3%{?dist}
Epoch:		1
Summary:	JavaScript Engine
License:	BSD
URL:		http://code.google.com/p/v8
Source0:	http://commondatastorage.googleapis.com/chromium-browser-official/v8-%{version}.tar.bz2
ExclusiveArch:	%{ix86} x86_64 %{arm}
BuildRequires:	scons, readline-devel, libicu-devel

#backport fix for CVE-2013-2634 (RHBZ#924495)
Patch1:		v8-3.14.5.8-CVE-2013-2634.patch

#backport fix for CVE-2013-2882 (RHBZ#991116)
Patch2:     v8-3.14.5.10-CVE-2013-2882.patch

%description
V8 is Google's open source JavaScript engine. V8 is written in C++ and is used
in Google Chrome, the open source browser from Google. V8 implements ECMAScript
as specified in ECMA-262, 3rd edition.

%package devel
Summary:	Development headers and libraries for v8
Requires:	%{name} = %{epoch}:%{version}-%{release}

%description devel
Development headers and libraries for v8.

%prep
%setup -q -n %{name}-%{version}
%patch1 -p1
%patch2 -p1

# -fno-strict-aliasing is needed with gcc 4.4 to get past some ugly code
PARSED_OPT_FLAGS=`echo \'$RPM_OPT_FLAGS -fPIC -fno-strict-aliasing -Wno-unused-parameter\'| sed "s/ /',/g" | sed "s/',/', '/g"`
sed -i "s|'-O3',|$PARSED_OPT_FLAGS,|g" SConstruct

# clear spurious executable bits
find . \( -name \*.cc -o -name \*.h -o -name \*.py \) -a -executable \
  |while read FILE ; do
    echo $FILE
    chmod -x $FILE
  done

%build
mkdir -p obj/release/
export GCC_VERSION="44"

# SCons is going away, but for now build with
# I_know_I_should_build_with_GYP=yes
scons library=shared snapshots=on \
%ifarch x86_64
arch=x64 \
%endif
%ifarch armv7hl armv7hnl
armeabi=hard \
%endif
%ifarch armv5tel armv6l armv7l
armeabi=soft \
%endif
visibility=default \
env=CCFLAGS:"-fPIC" \
I_know_I_should_build_with_GYP=yes

%if 0%{?fedora}
export ICU_LINK_FLAGS=`pkg-config --libs-only-l icu-i18n`
%else
export ICU_LINK_FLAGS=`pkg-config --libs-only-l icu`
%endif

# When will people learn to create versioned shared libraries by default?
# first, lets get rid of the old .so file
rm -rf libv8.so libv8preparser.so
# Now, lets make it right.
g++ $RPM_OPT_FLAGS -fPIC -o libv8preparser.so.%{sover} -shared -Wl,-soname,libv8preparser.so.%{somajor} \
	obj/release/allocation.os \
	obj/release/bignum.os \
	obj/release/bignum-dtoa.os \
	obj/release/cached-powers.os \
	obj/release/diy-fp.os \
	obj/release/dtoa.os \
	obj/release/fast-dtoa.os \
	obj/release/fixed-dtoa.os \
	obj/release/preparse-data.os \
	obj/release/preparser-api.os \
	obj/release/preparser.os \
	obj/release/scanner.os \
	obj/release/strtod.os \
	obj/release/token.os \
	obj/release/unicode.os \
	obj/release/utils.os

# "obj/release/preparser-api.os" should not be included in the libv8.so file.
export RELEASE_BUILD_OBJS=`echo obj/release/*.os | sed 's|obj/release/preparser-api.os||g'`

%ifarch %{arm}
g++ $RPM_OPT_FLAGS -fPIC -o libv8.so.%{sover} -shared -Wl,-soname,libv8.so.%{somajor} $RELEASE_BUILD_OBJS obj/release/extensions/*.os obj/release/arm/*.os $ICU_LINK_FLAGS
%endif
%ifarch %{ix86}
g++ $RPM_OPT_FLAGS -fPIC -o libv8.so.%{sover} -shared -Wl,-soname,libv8.so.%{somajor} $RELEASE_BUILD_OBJS obj/release/extensions/*.os obj/release/ia32/*.os $ICU_LINK_FLAGS
%endif
%ifarch x86_64
g++ $RPM_OPT_FLAGS -fPIC -o libv8.so.%{sover} -shared -Wl,-soname,libv8.so.%{somajor} $RELEASE_BUILD_OBJS obj/release/extensions/*.os obj/release/x64/*.os $ICU_LINK_FLAGS
%endif

# We need to do this so d8 can link against it.
ln -sf libv8.so.%{sover} libv8.so
ln -sf libv8preparser.so.%{sover} libv8preparser.so

# This will fail to link d8 because it doesn't use the icu libs.
# Don't build d8 shared. Stupid Google. Hate.
# SCons is going away, but for now build with
# I_know_I_should_build_with_GYP=yes
scons d8 \
I_know_I_should_build_with_GYP=yes \
%ifarch x86_64
arch=x64 \
%endif
%ifarch armv7hl armv7hnl
armeabi=hard \
%endif
%ifarch armv5tel armv6l armv7l
armeabi=soft \
%endif
snapshots=on visibility=default || :
# library=shared snapshots=on console=readline visibility=default || :

# Sigh. I f*****g hate scons.
# But gyp is worse.
# rm -rf d8

# g++ $RPM_OPT_FLAGS -o d8 obj/release/d8.os -lreadline -lpthread -L. -lv8 $ICU_LINK_FLAGS

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_includedir}
mkdir -p %{buildroot}%{_libdir}
install -p include/*.h %{buildroot}%{_includedir}
install -p libv8.so.%{sover} %{buildroot}%{_libdir}
install -p libv8preparser.so.%{sover} %{buildroot}%{_libdir}
mkdir -p %{buildroot}%{_bindir}
install -p -m0755 d8 %{buildroot}%{_bindir}

pushd %{buildroot}%{_libdir}
ln -sf libv8.so.%{sover} libv8.so
ln -sf libv8.so.%{sover} libv8.so.%{somajor}
ln -sf libv8.so.%{sover} libv8.so.%{somajor}.%{sominor}
ln -sf libv8preparser.so.%{sover} libv8preparser.so
ln -sf libv8preparser.so.%{sover} libv8preparser.so.%{somajor}
ln -sf libv8preparser.so.%{sover} libv8preparser.so.%{somajor}.%{sominor}
popd

chmod -x %{buildroot}%{_includedir}/v8*.h

mkdir -p %{buildroot}%{_includedir}/v8/extensions/
install -p src/extensions/*.h %{buildroot}%{_includedir}/v8/extensions/

chmod -x %{buildroot}%{_includedir}/v8/extensions/*.h

# install Python JS minifier scripts for nodejs
install -d %{buildroot}%{python_sitelib}
sed -i 's|/usr/bin/python2.4|/usr/bin/python|g' tools/jsmin.py
sed -i 's|/usr/bin/python2.4|/usr/bin/python|g' tools/js2c.py
install -p -m0744 tools/jsmin.py %{buildroot}%{python_sitelib}/
install -p -m0744 tools/js2c.py %{buildroot}%{python_sitelib}/
chmod -R -x %{buildroot}%{python_sitelib}/*.py*

%clean
rm -rf %{buildroot}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%doc AUTHORS ChangeLog LICENSE
%{_bindir}/d8
%{_libdir}/*.so.*

%files devel
%{_includedir}/*.h
%dir %{_includedir}/v8/
%{_includedir}/v8/extensions/
%{_libdir}/*.so
%{python_sitelib}/j*.py*

%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 3.14.5.10-2.3
- removed %%%%defattr from specfile
- removed Group from specfile
- removed BuildRoot from specfiles

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 3.14.5.10-2.2
- spec file polish

* Fri Aug 02 2013 T.C. Hollingsworth <tchollingsworth@gmail.com> - 1:3.14.5.10-2
- backport fix for remote DoS or unspecified other impact via type confusion
  (RHBZ#991116; CVE-2013-2882)

* Wed May 29 2013 T.C. Hollingsworth <tchollingsworth@gmail.com> - 1:3.14.5.10-1
- new upstream release 3.14.5.10

* Mon May 06 2013 Stanislav Ochotnicky <sochotnicky@redhat.com> - 1:3.14.5.8-2
- Fix ownership of include directory (#958729)

* Fri Mar 22 2013 T.C. Hollingsworth <tchollingsworth@gmail.com> - 1:3.14.5.8-1
- new upstream release 3.14.5.8
- backport security fix for remote DoS via crafted javascript (RHBZ#924495; CVE-2013-2632)

* Mon Mar 11 2013 Stephen Gallagher <sgallagh@redhat.com> - 1:3.14.5.7-3
- Update to v8 3.14.5.7 for Node.js 0.10.0

* Sat Jan 26 2013 T.C. Hollingsworth <tchollingsworth@gmail.com> - 1:3.13.7.5-2
- rebuild for icu-50
- ignore new GCC 4.8 warning

* Tue Dec  4 2012 Tom Callaway <spot@fedoraproject.org> - 1:3.13.7.5-1
- update to 3.13.7.5 (needed for chromium 23)
- Resolves multiple security issues (CVE-2012-5120, CVE-2012-5128)
- d8 is now using a static libv8, resolves bz 881973)

* Sun Jul 22 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1:3.10.8-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Fri Jul  6 2012 Tom Callaway <spot@fedoraproject.org> 1:3.10.8-1
- update to 3.10.8 (chromium 20)

* Tue Jun 12 2012 Tom Callaway <spot@fedoraproject.org> 1:3.9.24-1
- update to 3.9.24 (chromium 19)

* Mon Apr 23 2012 Thomas Spura <tomspur@fedoraproject.org> 1:3.7.12.6
- rebuild for icu-49

* Fri Mar 30 2012 Dennis Gilmore <dennis@ausil.us> 1:3.7.12-5
- make sure the right arm abi is used in the second call of scons

* Thu Mar 29 2012 Dennis Gilmore <dennis@ausil.us> 1:3.7.12-4
- use correct arm macros
- use the correct abis for hard and soft float

* Tue Mar 20 2012 Tom Callaway <spot@fedoraproject.org> 3.7.12-3
- merge changes from Fedora spec file, sync, add epoch

* Fri Feb 17 2012 Tom Callaway <spot@fedoraproject.org> 3.7.12-2
- add -Wno-error=strict-overflow for gcc 4.7 (hack, hack, hack)

* Mon Feb 13 2012 Tom Callaway <spot@fedoraproject.org> 3.7.12-1
- update to 3.7.12

* Thu Nov  3 2011 Tom Callaway <spot@fedoraproject.org> 3.5.10-1
- update to 3.5.10

* Mon Sep 26 2011 Tom Callaway <spot@fedoraproject.org> 3.4.14-2
- final 3.4.14 tag
- include JavaScript minifier scripts in -devel

* Fri Jun 10 2011 Tom Callaway <spot@fedoraproject.org> 3.2.10-1
- tag 3.2.10

* Thu Apr 28 2011 Tom Callaway <spot@fedoraproject.org> 3.1.8-1
- "stable" v8 match for "stable" chromium (tag 3.1.8)

* Tue Feb 22 2011 Tom Callaway <spot@fedoraproject.org> 3.1.5-1.20110222svn6902
- update to 3.1.5
- enable experimental i18n icu stuff for chromium

* Tue Jan 11 2011 Tom Callaway <spot@fedoraproject.org> 3.0.7-1.20110111svn6276
- update to 3.0.7

* Tue Dec 14 2010 Tom "spot" Callaway <tcallawa@redhat.com> 3.0.0-2.20101209svn5957
- fix sloppy code where NULL is used

* Thu Dec  9 2010 Tom "spot" Callaway <tcallawa@redhat.com> 3.0.0-1.20101209svn5957
- update to 3.0.0

* Fri Oct 22 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.5.1-1.20101022svn5692
- update to 2.5.1
- fix another fwrite with no return checking case

* Thu Oct 14 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.5.0-1.20101014svn5625
- update to 2.5.0

* Mon Oct  4 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.4.8-1.20101004svn5585
- update to 2.4.8

* Tue Sep 14 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.4.3-1.20100914svn5450
- update to 2.4.3

* Tue Aug 31 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.3.11-1.20100831svn5385
- update to svn5385

* Fri Aug 27 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.3.11-1.20100827svn5365
- update to 2.3.11, svn5365

* Tue Aug 24 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.3.10-1.20100824svn5332
- update to 2.3.10, svn5332

* Thu Aug 18 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.3.9-1.20100819svn5308
- update to 2.3.9, svn5308

* Thu Aug 11 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.3.7-1.20100812svn5251
- update to svn5251

* Wed Aug 11 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.3.7-1.20100811svn5248
- update to 2.3.7, svn5248

* Mon Aug 10 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.3.6-1.20100809svn5217
- update to 2.3.6, svn5217

* Fri Aug  6 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.3.5-1.20100806svn5198
- update to 2.3.5, svn5198

* Mon Jul 26 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.3.3-1.20100726svn5134
- update to 2.3.3, svn5134

* Fri Jul 16 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.3.0-1.20100716svn5088
- update to 2.3.0, svn5088

* Tue Jul  6 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.22-1.20100706svn5023
- update to 2.2.22, svn5023

* Fri Jul  2 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.21-1.20100702svn5010
- update to svn5010

* Wed Jun 30 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.21-1.20100630svn4993
- update to 2.2.21, svn4993
- include checkout script

* Thu Jun  3 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.14-1.20100603svn4792
- update to 2.2.14, svn4792

* Tue Jun  1 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.13-1.20100601svn4772
- update to 2.2.13, svn4772

* Thu May 27 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.12-1.20100527svn4747
- update to 2.2.12, svn4747

* Tue May 25 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.11-1.20100525svn4718
- update to 2.2.11, svn4718

* Thu May 20 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.10-1.20100520svn4684
- update to svn4684

* Mon May 17 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.10-1.20100517svn4664
- update to 2.2.10, svn4664

* Thu May 13 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.9-1.20100513svn4653
- update to svn4653

* Mon May 10 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.9-1.20100510svn4636
- update to 2.2.9, svn4636

* Tue May  4 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.7-1.20100504svn4581
- update to 2.2.7, svn4581

* Mon Apr 19 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.3-1.20100419svn4440
- update to 2.2.3, svn4440

* Tue Apr 13 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.2-1.20100413svn4397
- update to 2.2.2, svn4397

* Thu Apr  8 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.1-1.20100408svn4359
- update to 2.2.1, svn4359

* Mon Mar 29 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.2.0-1.20100329svn4309
- update to 2.2.0, svn4309

* Thu Mar 25 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.1.8-1.20100325svn4273
- update to 2.1.8, svn4273

* Mon Mar 22 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.1.5-1.20100322svn4204
- update to 2.1.5, svn4204

* Mon Mar 15 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.1.4-1.20100315svn4129
- update to 2.1.4, svn4129

* Wed Mar 10 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.1.0-1.20100310svn4088
- update to 2.1.3, svn4088

* Thu Feb 18 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.1.0-1.20100218svn3902
- update to 2.1.0, svn3902

* Fri Jan 22 2010 Tom "spot" Callaway <tcallawa@redhat.com> 2.0.6-1.20100122svn3681
- update to 2.0.6, svn3681

* Tue Dec 29 2009 Tom "spot" Callaway <tcallawa@redhat.com> 2.0.5-1.20091229svn3528
- svn3528

* Mon Dec 21 2009 Tom "spot" Callaway <tcallawa@redhat.com> 2.0.5-1.20091221svn3511
- update to 2.0.5, svn3511

* Wed Dec  9 2009 Tom "spot" Callaway <tcallawa@redhat.com> 2.0.3-1.20091209svn3443
- update to 2.0.3, svn3443

* Tue Nov 24 2009 Tom "spot" Callaway <tcallawa@redhat.com> 2.0.2-1.20091124svn3353
- update to 2.0.2, svn3353

* Wed Nov 18 2009 Tom "spot" Callaway <tcallawa@redhat.com> 2.0.0-1.20091118svn3334
- update to 2.0.0, svn3334

* Tue Oct 27 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.16-1.20091027svn3152
- update to 1.3.16, svn3152

* Tue Oct 13 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.15-1.20091013svn3058
- update to svn3058

* Thu Oct  8 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.15-1.20091008svn3036
- update to 1.3.15, svn3036

* Tue Sep 29 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.13-1.20090929svn2985
- update to svn2985
- drop unused parameter patch, figured out how to work around it with optflag mangling
- have I mentioned lately that scons is garbage?

* Mon Sep 28 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.13-1.20090928svn2980
- update to 1.3.13, svn2980

* Wed Sep 16 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.11-1.20090916svn2903
- update to 1.3.11, svn2903

* Wed Sep  9 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.9-1.20090909svn2862
- update to 1.3.9, svn2862

* Thu Aug 27 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.8-1.20090827svn2777
- update to 1.3.8, svn2777

* Mon Aug 24 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.6-1.20090824svn2747
- update to 1.3.6, svn2747

* Tue Aug 18 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.4-1.20090818svn2708
- update to svn2708, build and package d8

* Fri Aug 14 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.4-1.20090814svn2692
- update to 1.3.4, svn2692

* Wed Aug 12 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.3-1.20090812svn2669
- update to 1.3.3, svn2669

* Mon Aug 10 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.2-1.20090810svn2658
- update to svn2658

* Fri Aug  7 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.2-1.20090807svn2653
- update to svn2653

* Wed Aug  5 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.2-1.20090805svn2628
- update to 1.3.2, svn2628

* Mon Aug  3 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.1-1.20090803svn2607
- update to svn2607

* Fri Jul 31 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.1-1.20090731svn2602
- update to svn2602

* Thu Jul 30 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.1-1.20090730svn2592
- update to 1.3.1, svn 2592

* Mon Jul 27 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.3.0-1.20090727svn2543
- update to 1.3.0, svn 2543

* Fri Jul 24 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.14-1.20090724svn2534
- update to svn2534

* Mon Jul 20 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.14-1.20090720svn2510
- update to svn2510

* Thu Jul 16 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.14-1.20090716svn2488
- update to svn2488

* Wed Jul 15 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.14-1.20090715svn2477
- update to 1.2.14, svn2477

* Mon Jul 13 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.13-1.20090713svn2434
- update to svn2434

* Sat Jul 11 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.13-1.20090711svn2430
- update to 1.2.13, svn2430

* Wed Jul  8 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.12-1.20090708svn2391
- update to 1.2.12, svn2391

* Sat Jul  4 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.11-1.20090704svn2356
- update to 1.2.11, svn2356

* Fri Jun 26 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.9-1.20090626svn2284
- update to svn2284

* Wed Jun 24 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.9-1.20090624svn2262
- update to 1.2.9, svn2262

* Thu Jun 18 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.7-2.20090618svn2219
- fix unused-parameter patch

* Thu Jun 18 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.7-1.20090618svn2219
- update to 1.2.8, svn2219

* Mon Jun 8 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.7-2.20090608svn2123
- fix gcc44 compile for Fedora 11

* Mon Jun  8 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.7-1.20090608svn2123
- update to 1.2.7, svn2123

* Thu May 28 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.2.5-1.20090528svn2072
- update to newer svn checkout

* Sun Feb 22 2009 Tom "spot" Callaway <tcallawa@redhat.com> 1.0.1-1.20090222svn1332
- update to newer svn checkout

* Sun Sep 14 2008 Tom "spot" Callaway <tcallawa@redhat.com> 0.2-2.20080914svn300
- make a versioned shared library properly

* Sun Sep 14 2008 Tom "spot" Callaway <tcallawa@redhat.com> 0.2-1.20080914svn300
- Initial package for Fedora
