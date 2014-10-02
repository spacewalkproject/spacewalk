insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('aarch64-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);

