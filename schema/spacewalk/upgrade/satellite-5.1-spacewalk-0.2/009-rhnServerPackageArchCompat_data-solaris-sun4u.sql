insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4u-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris'), 410);
  
insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4u-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch'), 510);
  
insert into rhnServerPackageArchCompat
(server_arch_id, package_arch_id, preference) values
(LOOKUP_SERVER_ARCH('sparc-sun4u-solaris'), LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster'), 610); 
