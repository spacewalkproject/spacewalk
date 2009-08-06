insert into rhnServerChannelArchCompat (server_arch_id, channel_arch_id) (
    select lookup_server_arch('sparc-sun4v-solaris'),
           lookup_channel_arch('channel-sparc-sun-solaris')
    from dual
    where not exists (
        select server_arch_id, channel_arch_id
        from rhnServerChannelArchCompat
        where server_arch_id = lookup_server_arch('sparc-sun4v-solaris') and
              channel_arch_id = lookup_channel_arch('channel-sparc-sun-solaris')
	)
);
