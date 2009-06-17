insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) (
    select lookup_server_arch('sparc-sun4v-solaris'), lookup_package_arch('sparc.sun4v-solaris'), 10
    from dual
    where not exists (
        select server_arch_id, package_arch_id, preference
        from rhnServerPackageArchCompat
        where server_arch_id = lookup_server_arch('sparc-sun4v-solaris') and
              package_arch_id = lookup_package_arch('sparc.sun4v-solaris') and
              preference = 10)
);

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) (
    select lookup_server_arch('sparc-sun4v-solaris'),
           lookup_package_arch('sparc-solaris'),
           100
    from dual
    where not exists (
        select server_arch_id, package_arch_id, preference
        from rhnServerPackageArchCompat
        where server_arch_id = lookup_server_arch('sparc-sun4v-solaris') and
              package_arch_id = lookup_package_arch('sparc-solaris') and
              preference = 100
	)
);

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) (
    select lookup_server_arch('sparc-sun4v-solaris'),
           lookup_package_arch('sparc-solaris-patch'),
           210
    from dual
    where not exists (
        select server_arch_id, package_arch_id, preference
        from rhnServerPackageArchCompat
        where server_arch_id = lookup_server_arch('sparc-sun4v-solaris') and
              package_arch_id = lookup_package_arch('sparc-solaris-patch') and
              preference = 210
    )
);

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) (
    select lookup_server_arch('sparc-sun4v-solaris'),
           lookup_package_arch('sparc-solaris-patch-cluster'),
           310
    from dual
    where not exists (
        select server_arch_id, package_arch_id, preference
        from rhnServerPackageArchCompat
        where server_arch_id = lookup_server_arch('sparc-sun4v-solaris') and
              package_arch_id = lookup_package_arch('sparc-solaris-patch-cluster') and
              preference = 310
    )
);

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) (
    select lookup_server_arch('sparc-sun4v-solaris'),
           lookup_package_arch('noarch-solaris'),
           410
    from dual
    where not exists (
        select server_arch_id, package_arch_id, preference
        from rhnServerPackageArchCompat
        where server_arch_id = lookup_server_arch('sparc-sun4v-solaris') and
              package_arch_id = lookup_package_arch('noarch-solaris') and
              preference = 410
    )
);

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) (
    select lookup_server_arch('sparc-sun4v-solaris'),
           lookup_package_arch('noarch-solaris-patch'),
           510
    from dual
    where not exists (
        select server_arch_id, package_arch_id, preference
        from rhnServerPackageArchCompat
        where server_arch_id = lookup_server_arch('sparc-sun4v-solaris') and
              package_arch_id = lookup_package_arch('noarch-solaris-patch') and
              preference = 510
    )
);

insert into rhnServerPackageArchCompat (server_arch_id, package_arch_id, preference) (
    select lookup_server_arch('sparc-sun4v-solaris'),
           lookup_package_arch('noarch-solaris-patch-cluster'),
           610
    from dual
    where not exists (
        select server_arch_id, package_arch_id, preference
        from rhnServerPackageArchCompat
        where server_arch_id = lookup_server_arch('sparc-sun4v-solaris') and
              package_arch_id = lookup_package_arch('noarch-solaris-patch-cluster') and
              preference = 610
    )
);
