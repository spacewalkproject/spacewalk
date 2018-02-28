# we use the upstream version from http_parser.h as the SONAME
%global somajor 2
%global sominor 0

%global git_date 20121128
%global git_commit_hash cd01361
%global github_seq 7

Name:           http-parser
Version:        %{somajor}.%{sominor}
Release:        4.%{git_date}git%{git_commit_hash}.3%{?dist}
Summary:        HTTP request/response parser for C

License:        MIT
URL:            https://github.com/joyent/http-parser
# download from https://github.com/joyent/http-parser/tarball/%%{version}
Source0:        joyent-http-parser-v%{version}-%{github_seq}-g%{git_commit_hash}.tar.gz

# Build shared library with SONAME using gyp and remove -O flags so optflags take over
# TODO: do this nicely upstream
Patch1:		http-parser-gyp-sharedlib.patch

BuildRequires:	gyp

%description
This is a parser for HTTP messages written in C. It parses both requests and
responses. The parser is designed to be used in performance HTTP applications.
It does not make any syscalls nor allocations, it does not buffer data, it can
be interrupted at anytime. Depending on your architecture, it only requires
about 40 bytes of data per message stream (in a web server that is per
connection).


%package devel
Summary:        Development headers and libraries for http-parser
Requires:       %{name} = %{version}-%{release}

%description devel
Development headers and libraries for http-parser.


%prep
%setup -q -n joyent-http-parser-%{git_commit_hash}
%patch1


%build
# TODO: fix -fPIC upstream
export CFLAGS='%{optflags} -fPIC'
gyp -f make --depth=`pwd` http_parser.gyp
make %{?_smp_mflags} BUILDTYPE=Release 


%install
rm -rf %{buildroot}

install -d %{buildroot}%{_includedir}
install -d %{buildroot}%{_libdir}

install -pm644 http_parser.h %{buildroot}%{_includedir}

#install regular variant
install out/Release/lib.target/libhttp_parser.so.%{somajor} %{buildroot}%{_libdir}/libhttp_parser.so.%{somajor}.%{sominor}
ln -sf libhttp_parser.so.%{somajor}.%{sominor} %{buildroot}%{_libdir}/libhttp_parser.so.%{somajor}
ln -sf libhttp_parser.so.%{somajor}.%{sominor} %{buildroot}%{_libdir}/libhttp_parser.so

#install strict variant
install out/Release/lib.target/libhttp_parser_strict.so.%{somajor} %{buildroot}%{_libdir}/libhttp_parser_strict.so.%{somajor}.%{sominor}
ln -sf libhttp_parser_strict.so.%{somajor}.%{sominor} %{buildroot}%{_libdir}/libhttp_parser_strict.so.%{somajor}
ln -sf libhttp_parser_strict.so.%{somajor}.%{sominor} %{buildroot}%{_libdir}/libhttp_parser_strict.so


%check
export LD_LIBRARY_PATH='./out/Release/lib.target' 
./out/Release/test-nonstrict
./out/Release/test-strict


%clean
rm -rf %{buildroot}


%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig


%files
%{_libdir}/libhttp_parser.so.*
%{_libdir}/libhttp_parser_strict.so.*
%doc AUTHORS CONTRIBUTIONS LICENSE-MIT README.md


%files devel
%{_includedir}/*
%{_libdir}/libhttp_parser.so
%{_libdir}/libhttp_parser_strict.so


%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.0-4.20121128gitcd01361.3
- removed %%%%defattr from specfile
- removed Group from specfile
- removed BuildRoot from specfiles

* Mon Jul 17 2017 Jan Dobes 2.0-4.20121128gitcd01361.2
- Use HTTPS in all Github links
- fixed tito build warning

* Tue Apr 09 2013 Stephen Gallagher <sgallagh@redhat.com> - 2.0-4.20121128gitcd01361
- Bumping revision for rebuild

* Sun Dec 02 2012 T.C. Hollingsworth <tchollingsworth@gmail.com> - 2.0-3.20121128gitcd01361
- latest git snapshot
- fixes buffer overflow in tests

* Tue Nov 27 2012 T.C. Hollingsworth <tchollingsworth@gmail.com> - 2.0-2.20121110git245f6f0
- latest git snapshot
- fixes tests
- use SMP make flags
- build as Release instead of Debug
- ship new strict variant

* Sat Oct 13 2012 T.C. Hollingsworth <tchollingsworth@gmail.com> - 2.0-1
- new upstream release 2.0
- migrate to GYP buildsystem

* Thu Jul 19 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.0-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Fri Jan 13 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.0-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Mon Aug 22 2011 T.C. Hollingsworth <tchollingsworth@gmail.com> - 1.0-1
- New upstream release 1.0
- Remove patches, no longer needed for nodejs
- Fix typo in -devel description
- use github tarball instead of checkout

* Wed Feb 09 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.3-6.20100911git
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Tue Jan 11 2011 Lubomir Rintel <lkundrak@v3.sk> - 0.3-5.20100911git
- Add support for methods used by node.js

* Thu Nov  4 2010 Dan HorÃ¡k <dan[at]danny.cz> - 0.3-4.20100911git
- build with -fsigned-char

* Wed Sep 29 2010 jkeating - 0.3-3.20100911git
- Rebuilt for gcc bug 634757

* Mon Sep 20 2010 Lubomir Rintel <lkundrak@v3.sk> - 0.3-2.20100911git
- Call ldconfig (Peter Lemenkov)

* Fri Sep 17 2010 Lubomir Rintel <lkundrak@v3.sk> - 0.3-1.20100911git
- Initial packaging
