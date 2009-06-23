insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) (
    select lookup_server_arch('sparc-sun4v-solaris'), lookup_sg_type('enterprise_entitled')
    from dual
    where not exists (
        select server_arch_id,
               server_group_type
        from rhnServerServerGroupArchCompat
        where server_arch_id = lookup_server_arch('sparc-sun4v-solaris') and
              server_group_type = lookup_sg_type('enterprise_entitled')
    )
);

insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) (
    select lookup_server_arch('sparc-sun4v-solaris'), lookup_sg_type('provisioning_entitled')
    from dual
    where not exists (
        select server_arch_id,
               server_group_type
        from rhnServerServerGroupArchCompat
        where server_arch_id = lookup_server_arch('sparc-sun4v-solaris') and
              server_group_type = lookup_sg_type('provisioning_entitled')
    )
);
