insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
LOOKUP_SERVER_ARCH('aarch64-redhat-linux'), LOOKUP_SG_TYPE('virtualization_host_platform') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('aarch64-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('virtualization_host_platform'));

insert into rhnServerServerGroupArchCompat (server_arch_id, server_group_type) select
LOOKUP_SERVER_ARCH('ppc64le-redhat-linux'), LOOKUP_SG_TYPE('virtualization_host_platform') from dual
where not exists (select 1 from rhnServerServerGroupArchCompat where server_arch_id = LOOKUP_SERVER_ARCH('ppc64le-redhat-linux') and server_group_type = LOOKUP_SG_TYPE('virtualization_host_platform'));

