update rhnServerPackageArchCompat
set preference = 710
where server_arch_id = LOOKUP_SERVER_ARCH('sparc-sun4m-solaris')
	and package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch-cluster');

update rhnServerPackageArchCompat
set preference = 610
where server_arch_id = LOOKUP_SERVER_ARCH('sparc-sun4m-solaris')
	and package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris-patch');

update rhnServerPackageArchCompat
set preference = 510
where server_arch_id = LOOKUP_SERVER_ARCH('sparc-sun4m-solaris')
	and package_arch_id = LOOKUP_PACKAGE_ARCH('noarch-solaris');

update rhnServerPackageArchCompat
set preference = 410
where server_arch_id = LOOKUP_SERVER_ARCH('sparc-sun4m-solaris')
	and package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch-cluster');

update rhnServerPackageArchCompat
set preference = 310
where server_arch_id = LOOKUP_SERVER_ARCH('sparc-sun4m-solaris')
	and package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris-patch');

update rhnServerPackageArchCompat
set preference = 210
where server_arch_id = LOOKUP_SERVER_ARCH('sparc-sun4m-solaris')
	and package_arch_id = LOOKUP_PACKAGE_ARCH('sparc-solaris');

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference)
    select lookup_server_arch('sparc-sun4m-solaris'),
           lookup_package_arch('sparc.sun4v-solaris'),
           100
    from dual
    where not exists (
        select 1
        from rhnServerPackageArchCompat
        where server_arch_id = lookup_server_arch('sparc-sun4m-solaris') and
              package_arch_id = lookup_package_arch('sparc.sun4v-solaris') and
              preference = 100
);
