insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
values (lookup_server_arch('sparc-sun4v-solaris'), lookup_sg_type('enterprise_entitled'));

insert into rhnServerServerGroupArchCompat ( server_arch_id, server_group_type )
values (lookup_server_arch('sparc-sun4v-solaris'), lookup_sg_type('provisioning_entitled'));
