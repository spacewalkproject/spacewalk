%{?nodejs_find_provides_and_requires}

Name:           nodejs-less
Version:        1.4.1
Release:        1.4%{?dist}
Summary:        Less.js The dynamic stylesheet language
Group  :        Unspecified

# cssmin.js is licensed under BSD license
# everything else is ASL 2.0
License:        ASL 2.0 and BSD

URL:            http://lesscss.org
Source0: http://registry.npmjs.org/less/-/less-%{version}.tgz

# Since we're installing this in a global location, fix the require()
# calls to point there.
Patch0001: 0001-Require-include-files-from-the-default-location.patch

BuildArch:      noarch
BuildRequires:  nodejs-devel
BuildRequires:  python-simplejson
Requires:       nodejs
ExclusiveArch:  %{ix86} %{arm} x86_64 noarch

%global _rpmconfigdir /usr/lib/rpm

Provides:  lessjs = %{version}-%{release}
Obsoletes: lessjs < 1.3.3-2

%description
LESS extends CSS with dynamic behavior such as variables, mixins, operations
and functions. LESS runs on both the client-side (Chrome, Safari, Firefox)
and server-side, with Node.js and Rhino.

%prep
%setup -q -n package

%patch0001 -p1

# Remove pre-built files from the dist/ directory
rm -f dist/*.js

# enable compression using ycssmin
%nodejs_fixdep ycssmin '~1.0.1'

%build
# Nothing to be built, we're just carrying around flat files

%check
make %{?_smp_mflags} test


%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{nodejs_sitelib}/less
chmod a+x bin/lessc
cp -rp bin package.json lib/less/* %{buildroot}/%{nodejs_sitelib}/less

# Install /usr/bin/lessc
ln -s %{nodejs_sitelib}/less/bin/lessc \
      %{buildroot}%{_bindir}

%nodejs_symlink_deps

%files
%doc LICENSE README.md CHANGELOG.md CONTRIBUTING.md
%{_bindir}/lessc
%{nodejs_sitelib}/less


%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 1.4.1-1.4
- removed BuildRoot from specfiles
- fixed tito build warning

* Wed Nov 20 2013 Michael Mraka <michael.mraka@redhat.com> 1.4.1-1.3
- simplejson has to be available in build time

* Wed Nov 20 2013 Michael Mraka <michael.mraka@redhat.com> 1.4.1-1.2
- packaging changes for RHEL5

* Fri Nov 15 2013 Michael Mraka <michael.mraka@redhat.com> 1.4.1-1.1
- koji build needs Group specified

* Fri Nov 15 2013 Michael Mraka <michael.mraka@redhat.com> 1.4.1-1
- initial build

* Fri Jul 05 2013 Stephen Gallagher <sgallagh@redhat.com> - 1.4.1-1
- New upstream release 1.4.1
- https://github.com/less/less.js/blob/v1.4.1/CHANGELOG.md
- Fix syncImports and yui-compress option, as they were being ignored
- Fixed several global variable leaks
- Handle getting null or undefined passed as the options object

* Tue Jun 18 2013 Stephen Gallagher <sgallagh@redhat.com> - 1.4.0-1
- New upstream release 1.4.0
- https://github.com/cloudhead/less.js/blob/master/CHANGELOG.md
- support for :extend() in selectors (e.g. input:extend(.button) {}) and &
  :extend(); in ruleset (e.g. input { &:extend(.button all); })
- maths is now only done inside brackets. This means font: statements, media
  queries and the calc function can use a simpler format without being escaped.
  Disable this with --strict-maths-off in lessc and strictMaths:false in
  JavaScript.
- units are calculated, e.g. 200cm+1m = 3m, 3px/1px = 3. If you use units
  inconsistently you will get an error. Suppress this error with
  --strict-units-off in lessc or strictUnits:false in JavaScript
- (~"@var") selector interpolation is removed. Use @{var} in selectors to have
  variable selectors
- default behaviour of import is to import each file once. @import-once has
  been removed.
- You can specify options on imports to force it to behave as css or less
  @import (less) "file.css" will process the file as less
- variables in mixins no longer 'leak' into their calling scope
- added data-uri function which will inline an image into the output css. If
  ieCompat option is true and file is too large, it will fallback to a url()
- significant bug fixes to our debug options
- other parameters can be used as defaults in mixins e.g. .a(@a, @b:@a)
- an error is shown if properties are used outside of a ruleset
- added extract function which picks a value out of a list,
  e.g. extract(12 13 14, 3) => 3
- added luma, hsvhue, hsvsaturation, hsvvalue functions
- added pow, pi, mod, tan, sin, cos, atan, asin, acos and sqrt math functions
- added convert function, e.g. convert(1rad, deg) => value in degrees
- lessc makes output directories if they don't exist
- lessc @import supports https and 301's
- lessc "-depends" option for lessc writes out the list of import files used in
  makefile format
- lessc "-lint" option just reports errors
- support for namespaces in attributes and selector interpolation in attributes
- other bug fixes
- strictUnits now defaults to false and the true case now gives more useful but
  less correct results, e.g. 2px/1px = 2px
- Process ./ when having relative paths
- add isunit function for mixin guards and non basic units
- extends recognise attributes
- exception errors extend the JavaScript Error
- remove es-5-shim as standard from the browser
- Fix path issues with windows/linux local paths
- change strictMaths to strictMath. Enable this with --strict-math=on in lessc
  and strictMath:true in JavaScript.
- change lessc option for strict units to --strict-units=off
- fix passing of strict maths option

* Tue Jun 18 2013 Stephen Gallagher <sgallagh@redhat.com> - 1.3.3-5
- Use correct build architectures

* Mon May 06 2013 T.C. Hollingsworth <tchollingsworth@gmail.com> - 1.3.3-4
- enable compression using ycssmin

* Wed Apr 10 2013 Stephen Gallagher <sgallagh@redhat.com> - 1.3.3-3
- Fix BuildRequires to include nodejs-devel

* Tue Apr 09 2013 Stephen Gallagher <sgallagh@redhat.com> - 1.3.3-2
- Rename package to nodejs-less

* Tue Apr 09 2013 Stephen Gallagher <sgallagh@redhat.com> - 1.3.3-1
- Upgrade to new upstream release and switch to proper Node.js packaging
- New upstream release 1.3.3
    * Fix critical bug with mixin call if using multiple brackets
    * When using the filter contrast function, the function is passed through if
      the first argument is not a color
- New upstream release 1.3.2
    * browser and server url re-writing is now aligned to not re-write (previous
      lessc behaviour)
    * url-rewriting can be made to re-write to be relative to the entry file
      using the relative-urls option (less.relativeUrls option)
    * rootpath option can be used to add a base path to every url
    * Support mixin argument seperator of ';' so you can pass comma seperated
      values. e.g. .mixin(23px, 12px;);
    * Fix lots of problems with named arguments in corner cases, not behaving
      as expected
    * hsv, hsva, unit functions
    * fixed lots more bad error messages
    * fix @import-once to use the full path, not the relative one for
      determining if an import has been imported already
    * support :not(:nth-child(3))
    * mixin guards take units into account
    * support unicode descriptors (U+00A1-00A9)
    * support calling mixins with a stack when using & (broken in 1.3.1)
    * support @namespace and namespace combinators
    * when using %% with colour functions, take into account a colour is out of
      256
    * when doing maths with a %% do not divide by 100 and keep the unit
    * allow url to contain %% (e.g. %%20 for a space)
    * if a mixin guard stops execution a default mixin is not required
    * units are output in strings (use the unit function if you need to get the
      value without unit)
    * do not infinite recurse when mixins call mixins of the same name
    * fix issue on important on mixin calls
    * fix issue with multiple comments being confused
    * tolerate multiple semi-colons on rules
    * ignore subsequant @charset
    * syncImport option for node.js to read files syncronously
    * write the output directory if it is missing
    * change dependency on cssmin to ycssmin
    * lessc can load files over http
    * allow calling less.watch() in non dev mode
    * don't cache in dev mode
    * less files cope with query parameters better
    * sass debug statements are now chrome compatible
    * modifyVars function added to re-render with different root variables

* Thu Feb 14 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.3.1-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Wed Dec 19 2012 Stephen Gallagher <sgallagh@redhat.com> - 1.3.1-4
- Unbundle cssmin.js from the sources
- Throw an error when --yui-compress is passed at the lessc command line
- Convert assorted %%prep actions into patches

* Wed Dec 19 2012 Matthias Runge <mrunge@redhat.com> - 1.3.1-3
- include LICENSE and README.md

* Wed Dec 19 2012 Matthias Runge <mrunge@redhat.com> - 1.3.1-2
- minor spec cleanup
- clear dist-dir
- license clearification

* Thu Dec 13 2012 Stephen Gallagher <sgallagh@redhat.com> - 1.3.1-1
- Update to the 1.3.1 release
- Fix versioning bugs, get the tarball from a cleaner, tagged location

* Mon Sep 17 2012 Matthias Runge <mrunge@redhat.com> - 1.3.0-20120917git55d6e5a.1
- initial packaging
