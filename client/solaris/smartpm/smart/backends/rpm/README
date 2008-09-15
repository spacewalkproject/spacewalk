If you want to implement a new loader for RPM packages,
take care about the following issues:

- Package versions must have the architecture appended as
  @arch. We can't use '.' as the separator because this is
  a character present in many package releases, thus we
  wouldn't be able to tell if we're looking at an
  archiutecture or a part of a release, when dealing with
  provides.

- There's a special RPMNameProvides class that must be used
  to provide the package name itself together with the package
  version and the architecture appended. We must use a special
  class here to be able to match RPMObsoletes against
  package names only, since that's the way RPM expects it to
  happen. Appending the architecture is necessary for
  multilib handling of upgrades. Notice that RPM packages
  already provide the name/version explicitly, so instead
  of just adding a new provides, it's usually necessary
  to catch the existent provides and change the class/append
  the arch when matching the package name/version.

- The equivalent of RPM Obsoletes relation is Upgrades+Conflicts
  in Smart, so do not just use upgrades instead of obsoletes.

- There's a special RPMPreRequires class to handle pre-requires.
  If the channel provides this information, you should use
  RPMRequires and RPMPreRequires instances as necessary.

- The way Smart handles upgrades is by introducing Upgrades
  relations. Smart will NOT check package names when upgrading.
  This way, for RPM it's necessary to introduce explicit
  upgrade relations like RPMObsoletes(name, "<", versionarch).
  This will match against RPMNameProvides of packages with a
  lower version

- Strip out epochs == 0 everywhere (package version, provide
  version, require version, etc). There are some sources of
  information which do not differentiate an absent epoch from
  a 0 epoch, so the only way to handle that is using epoch 0
  everywhere.

- When handling dependencies (provides, requires, etc) without
  versions, use None as the version/relation, not the empty
  string ("").

