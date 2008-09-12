
delete from rhnChannelFamilyPermissions
where channel_family_id in (
	select id from rhnchannelfamily where label = 'demo-private'
);

for rec in (
	select channel_id from rhnChannelFamilyMembers
	where channel_family_id in (
		select id from rhnchannelfamily where label = 'demo-private'
		)
	) loop
	delete from rhnChannel
	where id = rec.channel_id and label like 'private-demo-%';
end loop;

delete from rhnChannelFamilyMembers
where channel_family_id in (
	select id from rhnchannelfamily where label = 'demo-private'
);

delete from rhnChannelFamily
where label = 'demo-private';

