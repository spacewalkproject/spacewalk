insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference)
    select lookup_server_arch('sparc-sun4u-solaris'),
           lookup_package_arch('noarch-solaris'),
           410
    from dual
    where not exists (
        select 1
		from rhnServerPackageArchCompat
		where server_arch_id = lookup_server_arch('sparc-sun4u-solaris') and
		      package_arch_id = lookup_package_arch('noarch-solaris') and
		      preference = 410
        );

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference)
    select lookup_server_arch('sparc-sun4u-solaris'),
           lookup_package_arch('noarch-solaris-patch'),
           510
    from dual
    where not exists (
        select 1
		from rhnServerPackageArchCompat
		where server_arch_id = lookup_server_arch('sparc-sun4u-solaris') and
		      package_arch_id = lookup_package_arch('noarch-solaris-patch') and
		      preference = 510
        );

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference)
    select lookup_server_arch('sparc-sun4u-solaris'),
           lookup_package_arch('noarch-solaris-patch-cluster'),
           610
    from dual
    where not exists (
        select 1
        from rhnServerPackageArchCompat
        where server_arch_id = lookup_server_arch('sparc-sun4u-solaris') and
              package_arch_id = lookup_package_arch('noarch-solaris-patch-cluster') and
              preference = 610
    );
