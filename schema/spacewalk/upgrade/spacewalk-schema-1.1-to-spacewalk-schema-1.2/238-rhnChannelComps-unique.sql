
delete from rhnChannelComps
where id not in (
	select max(id)
	from rhnChannelComps
	group by channel_id
);

alter table rhnChannelComps
	add constraint rhn_channelcomps_cid_uq unique(channel_id)
	using index tablespace [[2m_tbs]];

