--
-- Copyright (c) 2008--2016 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
-- tricky view.  it explodes to a full cartesian product when
-- not queried via org_id, so DO NOT DO THAT :)

drop view rhnOrgErrata;
drop view rhnAvailableChannels;
drop view rhnOrgChannelTreeView;
drop view rhnOrgChannelFamilyPermissions;

create or replace view rhnOrgChannelFamilyPermissions as
        select  pcf.channel_family_id,
                u.org_id as org_id,
                pcf.created,
                pcf.modified
        from    rhnPublicChannelFamily pcf,
                web_contact u
        union
        select  channel_family_id,
                org_id,
                created,
                modified
        from    rhnPrivateChannelFamily;

CREATE OR REPLACE VIEW rhnOrgChannelTreeView
(
	org_id,
        id,
        depth,
	name,
        padded_name,
	channel_arch_id,
        last_modified,
        label,
	parent_or_self_label,
	parent_or_self_id,
	end_of_life
)
AS
select * from (
	select	cfp.org_id		as org_id,
		c.id			as id,
		1			as depth,
		c.name			as name,
		'  ' || c.name		as padded_name,
		c.channel_arch_id	as channel_arch_id,
		c.last_modified		as last_modified,
		c.label			as label,
		c.label			as parent_or_self_label,
		c.id			as parent_or_self_id,
		c.end_of_life		as end_of_life
	from	rhnChannel		c,
		rhnChannelFamilyMembers cfm,
		rhnOrgChannelFamilyPermissions cfp
	where	cfp.channel_family_id = cfm.channel_family_id
		and cfm.channel_id = c.id
		and c.parent_channel is null
	union
	select	cfp.org_id		as org_id,
		c.id			as id,
		2			as depth,
		c.name			as name,
		'' || c.name		as padded_name,
		c.channel_arch_id 	as channel_arch_id,
		c.last_modified		as last_modified,
		c.label			as label,
		pc.label		as parent_or_self_label,
		pc.id			as parent_or_self_id,
		c.end_of_life		as end_of_life
	from	rhnChannel		pc,
		rhnChannel		c,
		rhnChannelFamilyMembers	cfm,
		rhnOrgChannelFamilyPermissions cfp
	where	cfp.channel_family_id = cfm.channel_family_id
		and cfm.channel_id = c.id
		and c.parent_channel = pc.id
) s order by parent_or_self_label, parent_or_self_id;

create or replace view
rhnAvailableChannels
(
    	org_id,
	channel_id,
	channel_depth,
	channel_name,
	channel_arch_id,
	padded_name,
        last_modified,
        channel_label,
	parent_or_self_label,
	parent_or_self_id 
)
as
select
     ct.org_id,
     ct.id,
     CT.depth,
     CT.name,
     CT.channel_arch_id,
     CT.padded_name,
     CT.last_modified,
     CT.label,
     CT.parent_or_self_label,
     CT.parent_or_self_id
from
     rhnOrgChannelTreeView CT
UNION ALL
select
     ct.org_id,
     ct.id,
     CT.depth,
     CT.name,
     CT.channel_arch_id,
     CT.padded_name,
     CT.last_modified,
     CT.label,
     CT.parent_or_self_label,
     CT.parent_or_self_id
from
     rhnSharedChannelTreeView CT
;

create or replace view
rhnOrgErrata
(
        org_id,
        errata_id,
        channel_id
)
as
select
    ac.org_id,
    ce.errata_id,
    ac.channel_id
from
    rhnChannelErrata ce,
    rhnAvailableChannels ac
where
    ce.channel_id = ac.channel_id
;
