-- oracle equivalent source sha1 e823f54e201b9590cce5a14977ba2e91f8f148f3

alter table rhnChannelComps add column comps_type_id numeric not null default 1 constraint rhn_channelcomps_comps_type_fk references rhnCompsType(id);

update rhnChannelComps set comps_type_id = (select id from rhnCompsType where label = 'comps');

alter table rhnChannelComps alter comps_type_id drop default;

alter table rhnChannelComps drop constraint rhn_channelcomps_cid_uq;

create unique index rhn_channelcomps_cid_ctype_uq on rhnChannelComps (channel_id, comps_type_id);
