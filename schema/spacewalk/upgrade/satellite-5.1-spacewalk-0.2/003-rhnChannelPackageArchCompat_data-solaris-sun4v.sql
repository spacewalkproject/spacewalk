insert into rhnChannelPackageArchCompat (channel_arch_id, package_arch_id) (
    select lookup_channel_arch('channel-sparc-sun-solaris'),
           lookup_package_arch('sparc.sun4v-solaris')
    from dual
    where not exists (
        select channel_arch_id, package_arch_id
        from rhnChannelPackageArchCompat
        where channel_arch_id = lookup_channel_arch('channel-sparc-sun-solaris') and
              package_arch_id = lookup_package_arch('sparc.sun4v-solaris')
	)
);
