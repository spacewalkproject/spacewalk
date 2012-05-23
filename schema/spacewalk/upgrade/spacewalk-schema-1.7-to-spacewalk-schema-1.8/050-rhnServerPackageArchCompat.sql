insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_PACKAGE_ARCH('armv7hnl'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_PACKAGE_ARCH('armv7hl'), 10);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_PACKAGE_ARCH('armv7l'), 20);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_PACKAGE_ARCH('armv6l'), 30);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_PACKAGE_ARCH('armv5tel'), 40);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('armv7l-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);


insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('armv5tejl-redhat-linux'), LOOKUP_PACKAGE_ARCH('armv5tel'), 0);

insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('armv5tejl-redhat-linux'), LOOKUP_PACKAGE_ARCH('noarch'), 1000);
